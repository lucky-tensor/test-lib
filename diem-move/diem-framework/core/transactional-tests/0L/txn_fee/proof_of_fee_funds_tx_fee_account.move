//# init --validators Alice Bob Carol Dave Eve

// Happy case: All validators from genesis are compliant
// and place sucessful bids for the next set.
// we get to a new epoch.
// Note: we are also testing the test runner syntax for advancing to new epoch.

// Here EPOCH-LENGTH = 15 Blocks.
// NOTE: This test will fail with Staging and Production Constants, only for Debug - due to epoch length.

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::Mock;
    use DiemFramework::EpochBoundary;
    use DiemFramework::TransactionFee;
    use DiemFramework::Debug::print;
    use Std::Vector;



    fun main(vm: signer, _: signer) {
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 5, 7357008012001);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357008012002);
        assert!(DiemSystem::is_validator(@Bob) == true, 7357008012003);

        // all validators compliant
        // Mock::all_good_validators(&vm);
        Mock::mock_case_1(&vm, @Alice, 0, 10);
        Mock::mock_case_1(&vm, @Bob, 0, 10);

        let vals = Vector::singleton(@Alice);
        Vector::push_back(&mut vals, @Bob);
        Mock::mock_bids(&vm, &vals);

        let fees = TransactionFee::get_fees_collected();
        print(&fees);

        EpochBoundary::reconfigure(&vm, 10);

        let fees = TransactionFee::get_fees_collected();
        print(&fees);

    }
}
// check: EXECUTED