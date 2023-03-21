address DiemFramework {

/// Donor directed wallets is a service of the chain.
/// Any address can voluntarily turn their account into a donor directed account.

/// By creating a DonorDirected wallet you are providing certain restrictions and guarantees to the users that interact with this wallet.

/// 1. The wallet's contents is propoperty of the owner. The owner is free to issue transactions which change the state of the wallet, including transferring funds. There are however time, and veto policies.
/// 2. All transfers out of the account are timed. Meaning, they will execute automatically after a set period of time passes. The VM address triggers these events at each epoch boundary. The purpose of the delayed transfers is that the transaction can be paused for analysis, and eventually rejected by the donors of the wallet.
/// 3. Every pending transaction can be "vetoed". This adds one day/epoch to the transaction, extending the delay. If a sufficient number of Donors vote on the Veto, then the transaction will be rejected.

/// 4. After three consecutive transaction rejections, the account will become frozen. The funds remain in the account but no operations are available until the Donors, un-freeze the account.

/// 5. Voting for all purposes are done on a pro-rata basis according to the amounts donated. Voting using ParticipationVote method, which in short, biases the threshold based on the turnout of the vote. TL;DR a low turnout of 12.5% would require 100% of the voters to veto, and lower thresholds for higher turnouts until 51%.

/// 6. The donors can vote to liquidate a frozen DonorDirected account. The result will depend on the configuration of the DonorDirected account from when it was initialized: the funds by default return to the end user who was the donor. 

/// 7. Third party contracts can wrap the Donor Directed wallet. The outcomes of the votes can be returned to a handler in a third party contract For example, liquidiation of a frozen account is programmable: a handler can be coded to determine the outcome of the donor directed wallet. See in CommunityWallets the funds return to the InfrastructureEscrow side-account of the user.





module DonorDirected {
    use DiemFramework::CoreAddresses;
    use Std::Vector;
    use Std::Signer;
    use Std::Errors;
    use DiemFramework::DiemConfig;
    use Std::Option::{Self,Option};
    use DiemFramework::DiemSystem;
    use DiemFramework::NodeWeight;
    use DiemFramework::MultiSig;
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Debug::print;

    const ERR_PREFIX: u64 = 023;

    const PROPOSED: u8 = 0;
    const APPROVED: u8 = 1;
    const REJECTED: u8 = 2;

    const EIS_NOT_SLOW_WALLET: u64 = 0231010;

    //////// DONOR DIRECTED WALLETS ////////

    struct Registry has key {
      list: vector<address>
    }

    // Timed transfer submission
    struct DonorDirected has key {
      proposed: vector<TimedTransfer>,
      approved: vector<TimedTransfer>,
      rejected: vector<TimedTransfer>,
      max_uid: u64,
    }

    struct TimedTransfer has copy, drop, key, store {
      uid: u64,
      expire_epoch: u64,
      payer: address,
      payee: address,
      value: u64,
      description: vector<u8>,
      veto: Veto,
    }

    struct Veto has copy, drop, store {
      list: vector<address>,
      count: u64,
      threshold: u64,
    }

    struct Freeze has key {
      is_frozen: bool,
      consecutive_rejections: u64,
      unfreeze_votes: vector<address>,
    }

    // Utility used at genesis (and on upgrade) to initialize the system state.
    public fun init(vm: &signer) {
      CoreAddresses::assert_diem_root(vm);
      
      // TODO: this struct goes to the individual accounts.
      if (!exists<DonorDirected>(@0x0)) {
        move_to<DonorDirected>(
          vm,
          DonorDirected {
            proposed: Vector::empty<TimedTransfer>(),
            approved: Vector::empty<TimedTransfer>(),
            rejected: Vector::empty<TimedTransfer>(),
            max_uid: 0,
          }
        )
      }; 

      if (!exists<Registry>(@0x0)) {
        move_to<Registry>(vm, Registry {
          list: Vector::empty<address>()
        });
      };
    }

    public fun make_multisig(sponsor: &signer, cfg_default_n_sigs: u64, new_authorities: vector<address>) {
      MultiSig::init_gov(sponsor, cfg_default_n_sigs, &new_authorities);
      MultiSig::init_type<TimedTransfer>(sponsor, false); // cannot withdraw through multisig process
      MultiSig::finalize_and_brick(sponsor);
    }

    public fun is_init():bool {
      exists<DonorDirected>(@0x0)
    }

    public fun is_donor_directed(addr: address):bool {
      exists<DonorDirected>(addr)
    }

    public fun set_comm(sig: &signer) acquires Registry {
      if (!exists<Registry>(@0x0)) return;

      let addr = Signer::address_of(sig);
      let list = get_comm_list();
      if (!Vector::contains<address>(&list, &addr)) {
        let s = borrow_global_mut<Registry>(@0x0);
        Vector::push_back(&mut s.list, addr);
      };

      move_to<Freeze>(
        sig, 
        Freeze {
          is_frozen: false,
          consecutive_rejections: 0,
          unfreeze_votes: Vector::empty<address>()
        }
      )
    }


    // Getter for retrieving the list of DonorDirected wallets.
    public fun get_comm_list(): vector<address> acquires Registry{
      if (exists<Registry>(@0x0)) {
        let s = borrow_global<Registry>(@0x0);
        return *&s.list
      } else {
        return Vector::empty<address>()
      }
    }

    // // Utility for vm to remove the CommunityWallet tag from an address
    // public fun vm_remove_comm(vm: &signer, addr: address) acquires Registry {
    //   CoreAddresses::assert_diem_root(vm);
    //   if (!exists<Registry>(@0x0)) return;
     
    //   let list = get_comm_list();
    //   let (yes, i) = Vector::index_of<address>(&list, &addr);
    //   if (yes) {
    //     let s = borrow_global_mut<Registry>(@0x0);
    //     Vector::remove(&mut s.list, i);
    //   }
    // }

    // Todo: Can be private, used only in tests
    // The DonorDirected wallet Signer can propose a timed transaction.
    // the timed transaction defaults to occurring in the 3rd following epoch.
    // TODO: Increase this time?
    // the transaction will automatically occur at the epoch boundary, 
    // unless a veto vote by the validator set is successful.
    // at that point the transaction leves the proposed queue, and is added 
    // the rejected list.
    public fun new_timed_transfer(
      sender: &signer, payee: address, value: u64, description: vector<u8>
    ): u64 acquires DonorDirected {
      // firstly check if payee is a slow wallet
      // TODO: This function should check if the account is a slow wallet before sending
      // but there's a circular dependency with DiemAccount which has the slow wallet struct.
      // curretly we move that check to the transaction script to initialize the payment.
      // assert!(DiemAccount::is_slow(payee), EIS_NOT_SLOW_WALLET);

      let sender_addr = Signer::address_of(sender);
      // let list = get_comm_list();
      // assert!(
      //   Vector::contains<address>(&list, &sender_addr),
      //   Errors::requires_role(ERR_PREFIX + 001)
      // );

      let transfers = borrow_global_mut<DonorDirected>(@0x0);
      transfers.max_uid = transfers.max_uid + 1;
      
      // add current epoch + 1
      let current_epoch = DiemConfig::get_current_epoch();

      let t = TimedTransfer {
        uid: transfers.max_uid,
        expire_epoch: current_epoch + 2, // pays at the end of second (start of third epoch),
        payer: sender_addr,
        payee: payee,
        value: value,
        description: description,
        veto: Veto {
          list: Vector::empty<address>(),
          count: 0,
          threshold: 0,
        }
      };

      Vector::push_back<TimedTransfer>(&mut transfers.proposed, t);
      return transfers.max_uid
    }
  
  // A validator casts a vote to veto a proposed/pending transaction 
  // by a DonorDirected wallet.
  // The validator identifies the transaction by a unique id.
  // Tallies are computed on the fly, such that if a veto happens, 
  // the community which is faster than waiting for epoch boundaries.
  public fun veto(
    sender: &signer,
    uid: u64
  ) acquires DonorDirected, Freeze {
    let addr = Signer::address_of(sender);
    assert!(
      DiemSystem::is_validator(addr),
      Errors::requires_role(ERR_PREFIX + 001)
    );
    let (opt, i) = find(uid, PROPOSED);
    if (Option::is_some<TimedTransfer>(&opt)) {
      let c = borrow_global_mut<DonorDirected>(@0x0);
      let t = Vector::borrow_mut<TimedTransfer>(&mut c.proposed, i);
      // add voters address to the veto list
      Vector::push_back<address>(&mut t.veto.list, addr);
      // if not at rejection threshold
      // add latency to the payment, to get further reviews
      t.expire_epoch = t.expire_epoch + 1;

      if (tally_veto(i)) {
        reject(uid)
      }
    };
  }

  // private function. Once vetoed, the CommunityWallet transaction is 
  // removed from proposed list.
  fun reject(uid: u64) acquires DonorDirected, Freeze {
    let c = borrow_global_mut<DonorDirected>(@0x0);
    let list = *&c.proposed;
    let len = Vector::length(&list);
    let i = 0;
    while (i < len) {
      let t = *Vector::borrow<TimedTransfer>(&list, i);
      if (t.uid == uid) {
        Vector::remove<TimedTransfer>(&mut c.proposed, i);
        let f = borrow_global_mut<Freeze>(*&t.payer);
        f.consecutive_rejections = f.consecutive_rejections + 1;
        Vector::push_back(&mut c.rejected, t);
      };

      i = i + 1;
    };
    
  }

    // private function. Once vetoed, the CommunityWallet transaction is 
  // removed from proposed list.
  public fun mark_processed(vm: &signer, t: TimedTransfer) acquires DonorDirected {
    CoreAddresses::assert_vm(vm);

    let c = borrow_global_mut<DonorDirected>(@0x0);
    let list = *&c.proposed;
    let len = Vector::length(&list);
    let i = 0;
    while (i < len) {
      let search = *Vector::borrow<TimedTransfer>(&list, i);
      if (search.uid == t.uid) {
        Vector::remove<TimedTransfer>(&mut c.proposed, i);
        Vector::push_back(&mut c.approved, search);
      };

      i = i + 1;
    };
    
  }

  public fun reset_rejection_counter(vm: &signer, wallet: address) acquires Freeze {
    CoreAddresses::assert_diem_root(vm);
    borrow_global_mut<Freeze>(wallet).consecutive_rejections = 0;
  }

  // private function to tally vetos.
  // checks if a voter is in the validator set.
  // tallies everytime called. Only counts votes in the validator set.
  // does not remove an address if not in the validator set, in case 
  // the validator returns to the set on the next tally.
  fun tally_veto(index: u64): bool acquires DonorDirected {
    let c = borrow_global_mut<DonorDirected>(@0x0);
    let t = Vector::borrow_mut<TimedTransfer>(&mut c.proposed, index);

    let votes = 0;
    let threshold = calculate_proportional_voting_threshold();
    
    let k = 0;
    let len = Vector::length<address>(&t.veto.list);

    while (k < len) {
      let addr = *Vector::borrow<address>(&t.veto.list, k);
      // ignore votes that are no longer in the validator set,
      // BUT DON'T REMOVE, since they may rejoin the validator set,
      // and shouldn't need to vote again.

      if (DiemSystem::is_validator(addr)) {
        votes = votes + NodeWeight::proof_of_weight(addr)
      };
      k = k + 1;
    };

    t.veto.count = votes;
    t.veto.threshold = threshold;

    return votes > threshold
  }

  // private function to get the total voting power of the validator set,
  // and find the 2/3rds threshold
  fun calculate_proportional_voting_threshold(): u64 {
      let val_set_size = DiemSystem::validator_set_size();
      let i = 0;
      let voting_power = 0;
      while (i < val_set_size) {
        let addr = DiemSystem::get_ith_validator_address(i);        
        voting_power = voting_power + NodeWeight::proof_of_weight(addr);
        i = i + 1;
      };
      let threshold = voting_power * 2 / 3;
      threshold
  }

  // Utility to list CommunityWallet transfers due, by epoch. Anyone can call this.
  // This is used by VM in DiemAccount at epoch boundaries to process the wallet transfers.
  public fun list_tx_by_epoch(epoch: u64): vector<TimedTransfer> acquires DonorDirected {
      let c = borrow_global<DonorDirected>(@0x0);

      // loop proposed list
      let pending = Vector::empty<TimedTransfer>();
      let len = Vector::length(&c.proposed);
      let i = 0;
      while (i < len) {
        let t = Vector::borrow(&c.proposed, i);
        if (t.expire_epoch == epoch) {
          
          Vector::push_back<TimedTransfer>(&mut pending, *t);
        };
        i = i + 1;
      };
      return pending
    }


    public fun list_transfers(type_of: u8): vector<TimedTransfer> acquires DonorDirected {
      let c = borrow_global<DonorDirected>(@0x0);
      if (type_of == 0) {
        *&c.proposed
      } else if (type_of == 1) {
        *&c.approved
      } else {
        *&c.rejected
      }
    }

        // Todo: Can be private, used only in tests
    // Utlity to query a CommunityWallet transfer wallet.
    // Note: does not need to be a public function, except for use in tests.
    public fun find(
      uid: u64,
      type_of: u8
    ): (Option<TimedTransfer>, u64) acquires DonorDirected {
      let list = &list_transfers(type_of);

      let len = Vector::length(list);
      let i = 0;
      while (i < len) {
        let t = *Vector::borrow<TimedTransfer>(list, i);
        if (t.uid == uid) {
          return (Option::some<TimedTransfer>(t), i)
        };
        i = i + 1;
      };
      (Option::none<TimedTransfer>(), 0)
    }


    // Private function to freeze a DonorDirected wallet
    // DonorDirected wallets get frozen if 3 consecutive attempts to transfer are rejected.
    fun maybe_freeze(wallet: address) acquires Freeze {
      if (borrow_global<Freeze>(wallet).consecutive_rejections > 2) {
        let f = borrow_global_mut<Freeze>(wallet);
        f.is_frozen = true;
      }
    }

    //////// GETTERS ////////
    public fun get_tx_args(t: TimedTransfer): (address, address, u64, vector<u8>) {
      (t.payer, t.payee, t.value, *&t.description)
    }

    public fun get_tx_epoch(uid: u64): u64 acquires DonorDirected {
      let (opt, _) = find(uid, PROPOSED);
      if (Option::is_some<TimedTransfer>(&opt)) {
        let t = Option::borrow<TimedTransfer>(&opt);
        return *&t.expire_epoch
      };
      0
    }
    
    public fun transfer_is_proposed(uid: u64): bool acquires  DonorDirected {
      let (opt, _) = find(uid, PROPOSED);
      Option::is_some<TimedTransfer>(&opt)
    }

    public fun transfer_is_rejected(uid: u64): bool acquires  DonorDirected {
      let (opt, _) = find(uid, REJECTED);
      Option::is_some<TimedTransfer>(&opt)
    }



    // getter to check if wallet is frozen
    // used in DiemAccount before attempting a transfer.
    public fun is_frozen(addr: address): bool acquires Freeze{
      let f = borrow_global<Freeze>(addr);
      f.is_frozen
    }


    //////// 0L ////////
    public fun process_community_wallets(
        vm: &signer, epoch: u64
    ) acquires DonorDirected, Freeze  { //////// 0L ////////
        if (Signer::address_of(vm) != @DiemRoot) return;
        
        print(&990100);
        // Migrate on the fly if state doesn't exist on upgrade.
        if (!is_init()) {
            init(vm);
            return
        };
        print(&990200);
        let all = list_transfers(0);
        print(&all);

        let v = list_tx_by_epoch(epoch);
        let len = Vector::length<TimedTransfer>(&v);
        print(&len);
        let i = 0;
        while (i < len) {
            print(&990201);
            let t: TimedTransfer = *Vector::borrow(&v, i);
            // TODO: Is this the best way to access a struct property from 
            // outside a module?
            let (payer, payee, value, description) = get_tx_args(*&t);
            if (is_frozen(payer)) {
              i = i + 1;
              continue
            };
            print(&990202);
            DiemAccount::vm_make_payment_no_limit<GAS>(payer, payee, value, description, b"", vm);
            print(&990203);
            mark_processed(vm, t);
            reset_rejection_counter(vm, payer);
            print(&990204);
            i = i + 1;
        };
    }
}
}