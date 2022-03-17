///////////////////////////////////////////////////////////////////////////
// Upgrade payload
// File Prefix for errors: 2100
///////////////////////////////////////////////////////////////////////////
address DiemFramework {
module Upgrade {
    use DiemFramework::CoreAddresses;
    use Std::Errors;
    use Std::Signer;
    use Std::Vector;

    /// Structs for UpgradePayload resource
    struct UpgradePayload has key {
        payload: vector<u8>, 
    }

    /// Structs for UpgradeHistory resource
    struct UpgradeBlobs has store {
        upgraded_version: u64,
        upgraded_payload: vector<u8>,
        validators_signed: vector<address>,
        consensus_height: u64,
    }

    struct UpgradeHistory has key {
        records: vector<UpgradeBlobs>, 
    }

    // Function code: 01
    public fun initialize(account: &signer) {
        assert!(Signer::address_of(account) == @DiemRoot, Errors::requires_role(210001)); 
        move_to(account, UpgradePayload{payload: x""});
        move_to(account, UpgradeHistory{
            records: Vector::empty<UpgradeBlobs>()},
        );
    }

    // Function code: 02
    public fun set_update(account: &signer, payload: vector<u8>) acquires UpgradePayload {
        assert!(Signer::address_of(account) == @DiemRoot, Errors::requires_role(210002)); 
        assert!(exists<UpgradePayload>(@DiemRoot), Errors::not_published(210002)); 
        let temp = borrow_global_mut<UpgradePayload>(@DiemRoot);
        temp.payload = payload;
    }

    use DiemFramework::Epoch;
    use DiemFramework::DiemConfig;

    // private. Can only be called by the VM
    fun upgrade_reconfig(vm: &signer) acquires UpgradePayload {
        CoreAddresses::assert_vm(vm);
        reset_payload(vm);
        let new_epoch_height = Epoch::get_timer_height_start(vm) + 2; // This is janky, but there's no other way to get the current block height, unless the prologue gives it to us. The upgrade reconfigure happens on round 2, so we'll increment the new start by 2 from previous.
        Epoch::reset_timer(vm, new_epoch_height);
        DiemConfig::upgrade_reconfig(vm);

    }

        // Function code: 03
    fun reset_payload(vm: &signer) acquires UpgradePayload {
        CoreAddresses::assert_vm(vm);
        assert!(exists<UpgradePayload>(@DiemRoot), Errors::not_published(210003)); 
        let temp = borrow_global_mut<UpgradePayload>(@DiemRoot);
        temp.payload = Vector::empty<u8>();
    }

        // Function code: 04
    public fun record_history(
        account: &signer, 
        upgraded_version: u64, 
        upgraded_payload: vector<u8>, 
        validators_signed: vector<address>,
        consensus_height: u64,
    ) acquires UpgradeHistory {
        assert!(Signer::address_of(account) == @DiemRoot, Errors::requires_role(210004)); 
        let new_record = UpgradeBlobs {
            upgraded_version: upgraded_version,
            upgraded_payload: upgraded_payload,
            validators_signed: validators_signed,
            consensus_height: consensus_height,
        };
        let history = borrow_global_mut<UpgradeHistory>(@DiemRoot);
        Vector::push_back(&mut history.records, new_record);
    }

        // Function code: 05
    public fun retrieve_latest_history(): (u64, vector<u8>, vector<address>, u64) acquires UpgradeHistory {
        let history = borrow_global<UpgradeHistory>(@DiemRoot);
        let len = Vector::length<UpgradeBlobs>(&history.records);
        if (len == 0) {
            return (0, Vector::empty<u8>(), Vector::empty<address>(), 0)
        };
        let entry = Vector::borrow<UpgradeBlobs>(&history.records, len-1);
        (entry.upgraded_version, *&entry.upgraded_payload, *&entry.validators_signed, entry.consensus_height)
    }

        // Function code: 06
    public fun has_upgrade(): bool acquires UpgradePayload {
        assert!(exists<UpgradePayload>(@DiemRoot), Errors::requires_role(210005)); 
        !Vector::is_empty(&borrow_global<UpgradePayload>(@DiemRoot).payload)
    }

        // Function code: 07
    public fun get_payload(): vector<u8> acquires UpgradePayload {
        assert!(exists<UpgradePayload>(@DiemRoot), Errors::requires_role(210006));
        *&borrow_global<UpgradePayload>(@DiemRoot).payload
    }

    //////// FOR E2E Testing ////////
    // NOTE: See file Upgrade.move.e2e
    // Do not delete these lines. Uncomment when needed to generate e2e test fixtures. 
    // use DiemFramework::Debug::print;
    // public fun foo() {
    //     print(&0x050D1AC);
    // }

    //////// FOR E2E Testing ////////
}
}
    