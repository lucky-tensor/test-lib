address 0x0 {

  // Note: This module needs a key-value store.
  module Redeem {
    use 0x0::VDF;
    use 0x0::Vector;
    use 0x0::Transaction;

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

      // Checks that the blob was not previously redeemed, if previously redeemed its a no-op, with error message.

      // TODO: This should not be the sender of the transaction.
      // In the example above. Lucas sent a valid proof for Ping.
      // Looks like the implementation below would allow Ping to ask Keerthi to send the transaction again, and he gets two coins.

      let user_redemption_state = borrow_global_mut<T>(addr);
      let blob_redeemed = Vector::contains(&user_redemption_state.history, &vdf_proof_blob.solution);
      Transaction::assert(blob_redeemed == true, 10000);

      // Checks that the user did run the delay (VDF). Calling Verify() to check the validity of Blob
      let valid = VDF::verify(&vdf_proof_blob.challenge, &vdf_proof_blob.difficulty, &vdf_proof_blob.solution);
      Transaction::assert(valid == false, 10001);
      // QUESTION: Should we save a UserProof that is false so that we know it's been attempted multiple times?

      // If successfully verified, store the pubkey, proof_blob, mint_transaction to the Redeem k-v marked as a "redemption in process"
      // [Storage]
      //Vector::push_back(&mut user_redemption_state.history, vdf_proof_blob.solution);
      let in_process = borrow_global_mut<InProcess>(addr);
      Vector::push_back(&mut in_process.proofs, vdf_proof_blob);

    }

    public fun end_redeem(addr: address, vdf_proof_blob: VdfProofBlob) acquires InProcess {
      // Permissions: Only a specified address (0x0 address i.e. default_redeem_address) can call this, when an epoch ends.
      let sender = Transaction::sender();
      Transaction::assert(sender != default_redeem_address(), 10003);

      let in_process = borrow_global_mut<InProcess>(addr);
      let (has,idx) = Vector::index_of(&mut in_process.proofs, &vdf_proof_blob);
      Transaction::assert(has == false, 10001);

      // Calls Stats module to check that pubkey was engaged in consensus, that the n% liveness above.
      // Stats(pubkey, block)

      // Also counts that the minimum amount of VDFs were completed during a time (cannot submit proofs that were done concurrently with same information on different CPUs).
      // TBD

      // If those checks are successful Redeem calls Subsidy module (which subsequently calls the  Gas_Coin.Mint function).
      // Subsidy(pubkey, quantity)

      // clean in process
      Vector::remove(&mut in_process.proofs, idx);
    }

    fun default_redeem_address(): address {
        0x0
    }
  }
}
