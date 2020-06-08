// This module is used to select the validators who would participate in LibraBFT protocol. Due to the restrictions on throughput with increasing validators above a threshold, 
// we rank nodes based on node weight (i.e., stake they own, previous participation trends) to select the validators for an epoch. 
address 0x0 {
  module NodeWeight {

    use 0x0::Vector;
    use 0x0::LibraAccount;
    use 0x0::LBR;

    // Input: a vector of account addresses
    //Output: Top n according to weight (Just account balance for now) 
    public fun top_n_accounts(accounts: vector<address>, n: u64): vector<address> {
      
      let length = Vector::length<address>(&accounts);
      
      //BASE CASE
      // If n is greater than or equal to accounts vector length - return the vector.
      if(length<=n)
        return accounts;
      
      // Now we rank to find out top n accounts based on weights.
      //Weight - currently only considers the account balance.
      // TODO: Stats module results.  

      // Vector to store node_weights
      let weights = Vector::empty<u64>();     
      let k = 0;
      while (k < length) {
          let cur_address = Vector::borrow<address>(&accounts, k);
          // Retrieve balance for the current account
          let balance = LibraAccount::balance<LBR::T>({{*cur_address}});
          // Weight is just account balance for now. 
          Vector::push_back<u64>(&mut weights, balance);
          k = k + 1;
      };


      // Sorting the accounts vector based on value (weights). 
      // Bubble sort algorithm
      let i = 0;
      while (i < length){
        let j = 0;
        while(j < length-i-1){
          let value_j = *(Vector::borrow<u64>(&weights, j));
          let value_jp1 = *(Vector::borrow<u64>(&weights, j+1));
          if(value_j > value_jp1){
            Vector::swap<u64>(&mut weights, j, j+1);
            Vector::swap<address>(&mut accounts, j, j+1);
          };
          j = j + 1;
        };
        i = i + 1;
      };

      // Reverse to have sorted order - high to low. 
      Vector::reverse<address>(&mut accounts);
      let index = n;
      while(index < length){
        Vector::pop_back<address>(&mut accounts);
        index = index + 1;
      };
      return accounts
    } 
  }
}