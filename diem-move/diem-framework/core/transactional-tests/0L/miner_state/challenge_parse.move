
//! account: dummy-prevents-genesis-reload, 100000 ,0, validator
//! account: bob, 10000000GAS
//! new-transaction
//! sender: bob
script {
    use 0x1::TowerState;
    fun main() {
        // First 32 bytes (64 hex characters) make up the auth_key. Of this,
        // the first 16 bytes (32 hex characters) make up the auth_key pefix
        // the last 16 bytes of the auth_key make up the account address
        // The native function implemented in Rust parses this and gives out the
        // address. This is then confirmed in the the TowerState module (move-space)
        // to be the same address as the one passed in

        let challenge = x"232fb6ae7221c853232fb6ae7221c853000000000000000000000000deadbeef";
        let new_account_address = @0x000000000000000000000000deadbeef;

        // Parse key and check
        TowerState::first_challenge_includes_address(new_account_address, &challenge);
        // Note: There is a assert statement in this function already
        // which checks to confim that the parsed address and new_account_address
        // the same. Execution of this guarantees that the test of the native
        // function passed.

        challenge = x"232fb6ae7221c853232fb6ae7221c853000000000000000000000000deadbeef00000000000000000000000000000000000000000000000000000000000000000000000000004f6c20746573746e6574640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070726f74657374732072616765206163726f737320416d6572696361";

        let new_account_address = @0x000000000000000000000000deadbeef;
        TowerState::first_challenge_includes_address(new_account_address, &challenge);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: bob
script {
    use 0x1::TowerState;

    fun main() {
        // Another key whose parsing will fail because it's too short.
        let challenge = x"7005110127";
        let new_account_address = @0x000000000000000000000000deadbeef;

        // Parse key and check
        TowerState::first_challenge_includes_address(new_account_address, &challenge);
    }
}
// check: ABORTED