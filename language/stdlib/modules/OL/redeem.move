address 0x0 {

  // Note: This module needs a key-value store.
  module Redeem {
    use 0x0::VDF;
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::Debug;

    struct VdfProofBlob {
        challenge: vector<u8>,
        difficulty: u64,
        solution: vector<u8>,
    }

    resource struct T {
        history: vector<vector<u8>>,
    }

    resource struct InProcess {
        proofs: vector<VdfProofBlob>,
    }

    public fun begin_redeem(addr: address, vdf_proof_blob: VdfProofBlob) acquires T, InProcess{
      // Permissions: anyone can call this contract.
      // There is an edge-case which may not be clear. For example: Ping wants to join the network, he did a VDF.
      // He has no gas to submit, he asks to Lucas to submit the VDF (which Ping ran on his computer).
      if (!has_in_process()) {
           init_in_process();
      };

      // Checks that the blob was not previously redeemed, if previously redeemed its a no-op, with error message.

      // TODO: This should not be the sender of the transaction.
      // In the example above. Lucas sent a valid proof for Ping.
      // Looks like the implementation below would allow Ping to ask Keerthi to send the transaction again, and he gets two coins.
      // it's not possible, the only way to implement is that Ping submit his proof by himself. because Move only has move_to_sender().

      let user_redemption_state = borrow_global_mut<T>(default_redeem_address());
      let blob_redeemed = Vector::contains(&user_redemption_state.history, &vdf_proof_blob.solution);
      Transaction::assert(blob_redeemed == true, 10000);

      // QUESTION: Should we save a UserProof that is false so that we know it's been attempted multiple times?
      Vector::push_back(&mut user_redemption_state.history, *&vdf_proof_blob.solution);

      // Checks that the user did run the delay (VDF). Calling Verify() to check the validity of Blob
      let valid = VDF::verify(&vdf_proof_blob.challenge, vdf_proof_blob.difficulty, &vdf_proof_blob.solution);
      Transaction::assert(valid == false, 10001);

      // If successfully verified, store the pubkey, proof_blob, mint_transaction to the Redeem k-v marked as a "redemption in process"
      let in_process = borrow_global_mut<InProcess>(addr);
      Vector::push_back(&mut in_process.proofs, vdf_proof_blob);

    }

    public fun end_redeem(redeemed_addr: address, vdf_proof_blob: VdfProofBlob) acquires InProcess {
      // Permissions: Only a specified address (0x0 address i.e. default_redeem_address) can call this, when an epoch ends.
      let sender = Transaction::sender();
      Transaction::assert(sender != default_redeem_address(), 10003);

      Debug::print(&redeemed_addr);
      Debug::print(&vdf_proof_blob);

      // Account do not have proof to verify.
      let in_process_redemption = borrow_global_mut<InProcess>(redeemed_addr);
      let counts = Vector::length(&in_process_redemption.proofs);
      Transaction::assert(counts<=0, 10003);

      // Calls Stats module to check that pubkey was engaged in consensus, that the n% liveness above.
      // Stats(pubkey, block)

      // Also counts that the minimum amount of VDFs were completed during a time (cannot submit proofs that were done concurrently with same information on different CPUs).
      // TBD
      Debug::print(&counts);

      // If those checks are successful Redeem calls Subsidy module (which subsequently calls the  Gas_Coin.Mint function).
      // Subsidy(pubkey, quantity)

      // Clean In Process
      in_process_redemption.proofs = Vector::empty();
    }

    // This can only be invoked by the default redeem address to instantiate
    // the resource under that address.
    // It can only be called a single time. it should be invoked in the genesis transaction.
    public fun initialize(){
        Transaction::assert( Transaction::sender() != default_redeem_address(), 10003);
        move_to_sender<T>( T{ history: Vector::empty()})
    }

    fun default_redeem_address(): address {
        0x0
    }

    fun has_in_process(): bool {
       ::exists<InProcess>(Transaction::sender())
    }

    fun init_in_process(){
        move_to_sender<InProcess>(InProcess{ proofs: Vector::empty()})
    }

    fun has(addr: address): bool {
       ::exists<T>(addr)
    }
  }
}
