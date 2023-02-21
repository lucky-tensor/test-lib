//# init --validators Alice --parent-vasps Bob Carol

// Scenario: Alice is a validators. There are two community wallets, Bob and Carol. The excess network fees from the auction, will be burnt according to Alice's preferences.


//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::Wallet;
    use Std::Vector;
    use DiemFramework::GAS::GAS;
    use Std::Signer;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, sender: signer) {
      Wallet::set_comm(&sender);
      let bal = DiemAccount::balance<GAS>(Signer::address_of(&sender));
      DiemAccount::init_cumulative_deposits(&sender, bal);
      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 1, 7357001);
    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::Wallet;
    use Std::Vector;
    use DiemFramework::GAS::GAS;
    use Std::Signer;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, sender: signer) {
      Wallet::set_comm(&sender);
      let bal = DiemAccount::balance<GAS>(Signer::address_of(&sender));
      DiemAccount::init_cumulative_deposits(&sender, bal);
      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 2, 7357002);
    }
}
// check: EXECUTED


//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Burn;
    use DiemFramework::Mock;
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;

    fun main(vm: signer, sender: signer) {
      // alice burns to community
      Burn::set_send_community(&sender, true);

      Mock::mock_network_fees(&vm, 10000000);

      // send to community wallet Bob
      DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, @Bob, 10000, x"", x"", &vm);
      // send to community wallet Carol
      DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, @Carol, 60000, x"", x"", &vm);

      // end of epoch, recalculate the index
      Burn::reset_ratios(&vm);
    }
}
// check: EXECUTED


// //# run --admin-script --signers DiemRoot Carol
// script {
//     use DiemFramework::Burn;

//     fun main(dr: signer, _sender: signer) {
//       Burn::burn_network_fees(&dr, 33333);
//     }
// }
// // check: EXECUTED

// //# run --admin-script --signers DiemRoot DiemRoot
// script {
//   use DiemFramework::DiemAccount;
//   use DiemFramework::GAS::GAS;
//   use DiemFramework::Burn;
//   use Std::Vector;
//   use Std::FixedPoint32;
//   use DiemFramework::Debug::print;

//   fun main(vm: signer, _:signer) {
//     let bal_alice_old = DiemAccount::balance<GAS>(@Alice);
//     print(&bal_alice_old);
//     // send to community wallet Bob
//     DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, @Bob, 100000, x"", x"", &vm);
//     // send to community wallet Carol
//     DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, @Carol, 600000, x"", x"", &vm);

//     let bal_alice_old = DiemAccount::balance<GAS>(@Alice);
//     print(&bal_alice_old);

//     let bal_bob_old = DiemAccount::balance<GAS>(@Bob);

//     assert!(bal_bob_old == 10100000, 7357003);
//     let bal_carol_old = DiemAccount::balance<GAS>(@Carol);

//     assert!(bal_carol_old == 10600000, 7357004);

//     Burn::reset_ratios(&vm);
//     let (addr, _ , ratios) = Burn::get_ratios();
//     assert!(Vector::length(&addr) == 2, 7357005);

//     let carol_mult = *Vector::borrow<FixedPoint32::FixedPoint32>(&ratios, 1);
//     let pct_carol = FixedPoint32::multiply_u64(100, carol_mult);
//     // print(&pct_carol);
//     // ratio for carol's community wallet.
//     assert!(pct_carol == 51, 7357006); // todo

//     // up to here Alice has 9_300_000 
//     Burn::burn_network_fees(&vm, 100000);
//     // alice burns 100_000, and now has 9_200_000

//     let bal_alice = DiemAccount::balance<GAS>(@Alice);
//     print(&bal_alice);
//     assert!(
//       (bal_alice >= 9100000 && bal_alice <= 9200001), 7357007
//     ); // rounding issues
    
//     // unchanged balance
//     let bal_bob = DiemAccount::balance<GAS>(@Bob);
//     // print(&bal_bob);
//     assert!(bal_bob == bal_bob_old, 7357008);

//     // unchanged balance
//     let bal_carol = DiemAccount::balance<GAS>(@Carol);
//     assert!(bal_carol == bal_carol_old, 7357009);
//   }
// }
// // check: EXECUTED


// //# run --admin-script --signers DiemRoot Alice
// script {
//   use DiemFramework::Burn;

//     fun main(_dr: signer, sender: signer) {
//     Burn::set_send_community(&sender, true);
//   }
// }
// //////// SETS community send

// //# run --admin-script --signers DiemRoot DiemRoot
// script {
//   use DiemFramework::DiemAccount;
//   use DiemFramework::GAS::GAS;
//   use DiemFramework::Burn;
//   use DiemFramework::Debug::print;

//   fun main(vm: signer, _:signer) {
//     let bal_alice = DiemAccount::balance<GAS>(@Alice);
//     print(&bal_alice);

//     let bal_bob_old = DiemAccount::balance<GAS>(@Bob);
//     print(&bal_bob_old);
//     let bal_carol_old = DiemAccount::balance<GAS>(@Carol);

//     // this time alice changed burn settings, and is resending to community.
//     Burn::burn_network_fees(&vm, 100000);
    

//     let bal_alice = DiemAccount::balance<GAS>(@Alice);
//     print(&bal_alice);
//     assert!(bal_alice == 9100000, 7357010); // rounding issues

//     // balances are greater than before.
//     let bal_bob = DiemAccount::balance<GAS>(@Bob);
//     assert!(bal_bob > bal_bob_old, 7357011);

//     // balances are greater than before.
//     let bal_carol = DiemAccount::balance<GAS>(@Carol);
//     assert!(bal_carol > bal_carol_old, 7357012);
//   }
// }
// // check: EXECUTED