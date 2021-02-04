/////////////////////////////////////////////////////////////////////////
// 0L Module
// TestFixtures
// Collection of vdf proofs for testing.
/////////////////////////////////////////////////////////////////////////

address 0x1 {
module TestFixtures{
  use 0x1::Testnet;

    // Here, I experiment with persistence for now
    // Committing some code that worked successfully
    // struct ProofFixture {
    //   challenge: vector<u8>,
    //   solution: vector<u8>
    // }

    // public fun alice(){
    //   // In the actual module, must assert that this is the sender is the association
    //   move_to_sender<State>(State{ hist: Vector::empty() });
    // }

    public fun easy_chal(): vector<u8> {
      assert(Testnet::is_testnet(), 130102014010);
      x"aa"
    }

    public fun easy_sol(): vector<u8>  {
      assert(Testnet::is_testnet(), 130102014010);
      x"001eef1120c0b13b46adae770d866308a5db6fdc1f408c6b8b6a7376e9146dc94586bdf1f84d276d5f65d1b1a7cec888706b680b5e19b248871915bb4319bbe13e7a2e222d28ef9e5e95d3709b46d88424c52140e1d48c1f123f2a1341448b9239e40509a604b1c54cc6c2750ae1255287308d7b2dd5353bae649d4b1bcb65154cffe2e189ec6960d5fa88eef4aa4f1c1939ce8b4808c379562a45ffcda8c502b9558c0999a595dddc02601e837634081977be9195345fae0e858b2cf402e03844ccda24977966ca41706e84c3bf4a841c3845c7bb519547b735cb5644fb0f8a78384827a098b3c80432a4db1135e3df70ade040444d67936b949bd17b68f64fde81000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
    }

    public fun hard_chal(): vector<u8> {
      assert(Testnet::is_testnet(), 130102014010);
      x"a3a2855bbea4756f6f1926c0b06edbbb252f0b551c80cd9e951d82c6f70792ae000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006578706572696d656e74616c404b4c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004245545745454e20535542544c452053484144494e4720414e442054484520414253454e4345204f46204c49474854204c49455320544845204e55414e4345204f462049514c5553494f4e"
    }

    public fun hard_sol(): vector<u8>  {
      assert(Testnet::is_testnet(), 130102014010);
      x"0045273a066edaf0e875652bfb2987f3a4a97950143a217d6431877815445149d5dfb758fecc400cb0e8a2602efa30e25aa9d23183abb05a4b923a348d8b616fa2943dad900feaa25e6a0a2d37e9844e1e6a2df6d67e98774a8a4f2195d9a02f6cf45ae179ab7d6f82c16d6be3a26840768c4b27042439108fd3819f4d114a0676ffc6043ee5fbfee86590d01ccca3b56490eb936ade9fa0041176b0192e21c90b9d0b84c0dac37b2752388f99036325570ab2e81be07ef87d3859f1706245de5841f13296d5d30e101eff55cf44514e0b96ea39cef6c7c35cd5b2eb9f2f4127d3298b8182f3248a7292e5b418135c585636816553a7824bd2ac42e448324fb9fd2f0057f8c33512d731fd12280a92a673e6174092cebc036ea06bbcf6b112f91f53aad2941fe4ca5635a5c0cb40a3b7894b79eb81b4f12490fc6f39317cb9e57fab28726b7dcb90268de2bbab762df2d549137d59742f8eab879d5cc2a90dd90b36d03d7841204425e53e2c398e5ca834f182d2db1fd73af48d2f05d1e231a9d951daffd75d121dd32d4989ad90366ca4c02bee7ec4a6a06813fd1e9c6b0249769d2c80f1cdc7025c76dd06c95c7065d481fbd1f4941511a408a0dcedd398adfa374d83cd9fab785ab39128552c7551365dae6dee2686b5d993df405e155ff85b743e40ce093ef631720299ae500132b72e87109619ccac7db5b54c0ac90c063581909b"
    }

    //FROM: libra/fixtures/block_0.json.stage.alice
    public fun alice_0_easy_chal(): vector<u8> {
      assert(Testnet::is_testnet(), 130102014010);
      x"87515d94a244235a1433d7117bc0cb154c613c2f4b1e67ca8d98a542ee3f59f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304c20746573746e65746400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050726f74657374732072616765206163726f737320746865206e6174696f6e"
    }

    public fun alice_0_easy_sol(): vector<u8>  {
      assert(Testnet::is_testnet(), 130102014010);
      x"002c4dc1276a8a58ea88fc9974c847f14866420cbc62e5712baf1ae26b6c38a393c4acba3f72d8653e4b2566c84369601bdd1de5249233f60391913b59f0b7f797f66897de17fb44a6024570d2f60e6c5c08e3156d559fbd901fad0f1343e0109a9083e661e5d7f8c1cc62e815afeee31d04af8b8f31c39a5f4636af2b468bf59a0010f48d79e7475be62e7007d71b7355944f8164e761cd9aca671a4066114e1382fbe98834fe32cf494d01f31d1b98e3ef6bffa543928810535a063c7bbf491c472263a44d9269b1cbcb0aa351f8bd894e278b5d5667cc3f26a35b9f8fd985e4424bedbb3b77bdcc678ccbb9ed92c1730dcdd3a89c1a8766cbefa75d6eeb7e5921000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
    }

        //FROM: libra/fixtures/block_1.json.stage.alice

    public fun alice_1_easy_chal(): vector<u8> {
      assert(Testnet::is_testnet(), 130102014010);
      x"3190cef88aa2fb86fbfa062f62be33d08d1493e982597d7be286ab5b6d01e4b0"
    }

    public fun alice_1_easy_sol(): vector<u8>  {
      assert(Testnet::is_testnet(), 130102014010);
      x"006e33a9542693512b59aa04081bb2a87f0bf07328c62cfc5dafdebf57c35ddd6a75664ddfa7ebfe0b9cbc6c5d19f03f77841cef9923d32bea8a4a642adfd94a31d2b523cb32e8adc27ee63ec2d793f3c224c0be2c4258dcb7ba5b74ee78d21f1d045165c9bd7e41a42085ea4cdb95fb8ffd437448ad93610d4d445f339807fffbffb3a77ab38d67e301889a7d83a789895fa5a12113213b4674ec4dbd6037bcd7c9e8c5edb6f7bf738e19845aa25c0cd3cf258f978c406195c2a8d7edf8785d1697653d213add8cb632680f167dbb1a6a4716a2b174a91c5319c9b5224504975e94e7b751b55bad30b27678fa9c46d94d02f5bf757d27305b1283c542ca02927427000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
    }

  // // TODO: Replace with fixtures in libra/fixtures.
    public fun alice_0_hard_chal(): vector<u8> {
      assert(Testnet::is_testnet(), 130102014010);
      x"87515d94a244235a1433d7117bc0cb154c613c2f4b1e67ca8d98a542ee3f59f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304c20746573746e6574404b4c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050726f74657374732072616765206163726f737320746865206e6174696f6e"
    }

    public fun alice_0_hard_sol(): vector<u8>  {
      assert(Testnet::is_testnet(), 130102014010);
      x"001725678f78425dac39e394fc07698dd8fc891dfba0822cecc5d21434dacde903f508c1e12844eb4b97a598653cc6d03524335edf51b43f090199288488b537fd977cc5f53069f609a2f758f121e887f28f0fc1150aa5649255f8b7caea9edf6228640358d1a4fe43ddb6ad6ce1c3a6a28166e2f0b7e7310e80bfbb1db85e096000065a89b7f44ebc495d70db6034fd529a80e0b5bb74ace62cffb89f4e16e54f93e4a0063ca3651dd8486b466607973a51aacb0c66213e64e0b7bf291c64d81ed4a517a0abe58da4ae46f6191c808d9ba7c636cee404ed02248794db3fab6e5e4ab517f6f3fa12f39fb88fb5a143b5d9c16a31e3c3e173deb11494f792b52a67a70034a065c665b1ef05921a6a8ac4946365d61b2b4d5b86a607ba73659863d774c3fc7c2372f5b6c8b5ae068d4e20aac5e42b501bf441569d377f70e8f87db8a6f9b1eadb813880dbeb89872121849df312383f4d8007747ae76e66e5a13d9457af173ebb0c5eb9c39ee1ac5cef94aa75e1d5286349c88051c36507960de1f37377ffddc80a66578b437ac2a6d04fc7a595075b978bd844919d03ffe9db5b6440b753273c498aa2a139de42188d278d1ce1e3ddfdd99a97a64907e1cdf30d1c55dfc7262cd3175eb1f268ee2a91576fcd6bd644031413f55e42c510d08a81e747de36c0a6c9019d219571ea6851f43a551d6012a5317cc52992a72c270c1570419665"
    }
    public fun alice_1_hard_chal(): vector<u8> {
      assert(Testnet::is_testnet(), 130102014010);
      x"df6046be26c9a64ececa098a5ecbf724d91619ce64a4899087ac2098d394df59"
    }

    public fun alice_1_hard_sol(): vector<u8>  {
      assert(Testnet::is_testnet(), 130102014010);
      x"0061aec41fb46a2db9fd56d0112e432a55a5857df2626a80188b11228aab9a5e8ef2ee2c0838b1d623100fbf2e9516528733e8b376ec54c82a6f784ba146ea0fa004ef2d03d755ad5e41b5d09c0d073a1a507d4569505b4ad1d0ceb2bc1132e2f8a94f4ae5faa9e38f29703baf74d597e9e9f6a200a24add3d9109fe9b2aee72b6000b762eea2ec3fb9551366a0bd93bb2194f0b94c3020ed1172a7a99c3a3f7fa74f403ce9262e6bf5a6c128b52f577c2d99b38271cd23f26332be0819cad4ac5676074e203f448a1c94e443e3c83cb636c760a94a1b8cd0f4253970f9a571e62670a28b0adba42e1edfb9490ee5a5a83bcd6af50c6e35743d3b0c8bcacaf4282370014d13eb080ce34a49b2d49d4477672db2cd527e04cd0c8a6d9094f0d5e4cfe8edc21228ca12da68bbd53fca5b23fc275c82ba90197dc53f3eaf34393905ebf25a5f7e429d3c9dcdfa22c3098f2761c161d65c0eec4f57dd1b1354ccc9ae0b54f2741ac4a93dc1e80afa940dc515f25e66fc93614f51ac3bbfc64c2701161ce86fff832feb81d2e177b24315381a45c18d16ccac6d554a8871bcf859139d2ba6985ca57703b301ecce28d7922df352bdd5103295472d38840c3cf5e30d760083b39ae8cee53dfc9c5034443849f10db6425332603966fecfef38382ad7fb5d4618eb96a826fd2deeec0977c5bdeb270b09fd84eb974f87e14df1e7654217d69737f"
    }

    public fun eve_0_easy_chal(): vector<u8> {
      assert(Testnet::is_testnet(), 130102014010);
      x"2bffcbd0e9016013cb8ca78459f69d2b3dc18d1cf61faac6ac70e3a63f062e4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304c20746573746e65746400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050726f74657374732072616765206163726f737320746865206e6174696f6e"
    }

    public fun eve_0_easy_sol(): vector<u8>  {
      assert(Testnet::is_testnet(), 130102014010);
      x"00168e77068c3e4ebf4908cdad141265a65f390f0e82ac2510f9f92116d32a60f049f0d6e098fc3bf3cd363c34cbed43cf1ea9927db2f02934be9a1a7aba3a2c83f13e19336264b4688b7c329edc45ef510ec8b2c99a1ba2949a0577fbb8815da2e5c0ecc6852a9c42a10e001324547fda3858fae568b6405ee59bd2da7443295c0006c8d4ca51804171d1809f3c04546053b33e1f3b08624f33a68f76711bc27db33d1619f05308de1ac4cb349b8156fc073e6ce4730841363a350c5f2e4ac7a4a931916d5c508bcac40e2bfcc7b0ce475b0a5c492b2e752ecf2284b8bacff76b4ad2004ac8b8423bd11a016faa90ef1817c215a3426c9f80100f511177d4f4e2bd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
    }

    public fun valid_proof_hex(): vector<u8> {
      assert(Testnet::is_testnet(), 130102014010);
      x"e2cfd89ec881119a638cb117abe6b81f3aca4ce6cbdd99c36158cd61d64fd0b61d4fdfb0a57cbe671fd550e6e4723f2309cc8f334572938500a392d50402c24f17d2b3fc4f22fcbe07b7779ba21cf68f0811806362713bdd0221dbdbbd69b3b70eb34ec858a1da7217019a2a1e634a2f070076910ea75d131e6aba18fab422ff173a07b0412eafb619019597e5a701010d2d9635170f0ca309e3f8d72e43d24700a96aef8188ccee183f158f2c9f5bd311a4624ece900a80157afed198fa27e50ba207f7608ea34907be15196e0ee7450d49b553ede17f780ed68085f7e990dc1712bff08577ef82147bceec8c8343751221b666e3f8959915d10df4eb6e526d158c6700d04bce8509c1e05c8402babf1ae25db7bb18809609182ac6af4fbb2c07b2ca03ec61436a0d7b49772407eef8095bba5206ee910805187aebe9e5a1c60e7ac1f8ac77f87c10706827d67ef26111baadcde824a7dd0cce94b2798a77e8133fa8dc52b1f5b106409529db8ad73002161be2d7e4a7e5173e3d403373d27402192710b012f6081f8e2de1c0c424d20c59c3c325f69d7d14f47942d849e8dc16be7f7e52ff1de20b028f27edc54fb80c16c64282f0f3220b9803e5f73902fb1f747be4c73cc0c410dd9f2875f360d615ae33b25d7c63770658eee3ab41db131762662455cfc2634ebf40a6a6d9168fdc97d3ced212a6bd13f07d32c8c01a263a59d8cf654c9ebba227d7df5de7bfaa0fee5875e4f3bd29169e57629a06f48600000000000255c2131159b15b6f9b6310a855c365e9231e1340dad42f5665c009e0badacc164b3c0f48b260d996e3eb18b7771b65a2a44915e0c222f05f0b1600ad08ccd13dfbc81cfa27803a5e480013a464f090725fa31bd5cbad97cc10d90fb1ed4d0def233e1b9b971b333d9d4714c8a7d69eded48f17c9d9aaa4fce8b81623398677205bc91978bd82f39345351b8647d98306f34507cfe8f3ee6997aa1ac1e0a8c468517c1ad09473d7df76440443f5f8b7077b52054909fdf3a2d49c04f3992e16085fd213b47d4d08ea753c17c918a0603104ef113b61c1a4e6dc3c0f2f8cd00f8efe8e18b6a6520a0097ba07ebe12e7f62161a15c2b9f7889335fc0700ad0965a5eb5c18b61cd20b4e6d0613a0fa8b10ad799d1b6b45171bbd0b0409bf58d0082f4a5000b8558b2465052b0d59488b0993ec700dc9fb85ac05c4520b81c3b27075d1b214786574fd29d0321880aec0f74d96491bac02e41640ed590258bd6d4e4d773b1378a8742900ef771866ef4447b447df15bd4d4c4cc19a920df0dd45716f008e0a532614574810690b41970559768e941de9cf28669ab1311f2cdce937c36aa90a0ddc109e5c78cb0a02129c9868d6080fabb254872642c1134b1dd9f5dd3401014fe1f564a840f810bf86110125c85e048d68c8d80e786d191bc683a553a4da1334e321f80d78f60938a5b13e29c22f119e5ef3908488b708f06de2cc92b19d08b1c54a7f17a7ac09602bee751af8d51e9287bf2587c7ba1400866f98acfa42157e609cbaadb13218cd2a72f27f98531937952cb5ffb4361b5b38e49afe249c1d3a9d2c929898fe0ec216f2f8a39d620a14b07fc7652e6702449999c0100284160628e6691197eb03281230a139a63514f72ecf8ae2be8615cef2e6ead844e21baa41fde6e14516034020dfb16174a60df3fb68f79ab4791066de4f182bd8571ac47d8c276690071dc98c064f3ddeea0576e168d0cb1acb05bc97409e60afd40f999ff586063f4f0d4cad01a00ecfe20b38c897642da1e6041a7501b9650c051459c150e8da9d2d009040121b7872c60d18fe6e0f1c227c1e6b1be3d988e9e71b8539f5627405ab0200c8e0e3f6641402fe7c43c534774f15fbdee3ebb9a2110a512f6090ba55270a86b6604bfbd962020c19d014affb5c10ebd0f6796da0571df148a56a1a15ad10a87b371b9f9be3089c9913177dbab20c6ba8c196728774173937163e52a85711cfcc2a469e63c713165bda3fdf984100a9a72778b6d73001046291b204e992181e9b7c70cd963d1cf6f254fb159e0b1c2bf569b3c313740c7485eb7f563b4e11a7b18da550ea210b34c54c44ca550e090da670711586951831c211cbff615717207a5036d6d0a01ef9ba2b870326760b1ced71a23bde571ecaeeca00e4b29e1ec4b3527a04c0ec153390868180904b0f43892cbc2b92c5178262363c585aca0372874a815a60ac080ef95dee5f7c9004b17c098b42a9d01302c284d8e67d52008a6f0ea8705b5c013baadcfb03bea70dc984f47984a0db0935cab55cfe8efe08fcd3f047036d421564f6f1f5a6971f13bb0a2ad03f27e1070b6905714e4a760ac4eaa26291beb91622826ad969f8ca19e8d595ae40a25f1859c41b637b6b350923aa0a2c773bf701f639b716c7fc8e01a90d78362b7fe50559d612266c52e91e881c11a00888390a003f7fb5bfae3601d7ae0f98477c831d6fc22a8fedf9a119a055dd152433c41aff0224c28483780dbe6ab6dc1981d1162f6100d98fbde20ead23039f7d45900e2b7d3e00dbf7361e50ab3cce8f1fab1886fcc27ab5b9db1143d3e52d269b0e1cab3bcd6fb9485d0fd8830bb31cefd00771982dad6859c0095fcce03b0a79a114de8011388d3122179cc07ec2cd0008083e009b441280f1078bebed8fcd62c513d81b39e2766a2a17d9458dda848e2f0d78cd40d0200fe60f0db3456f77a5fc0f239f7ccb0b76a80f6b36def8aeb79711b2b5ae90bd8e211f452341f33ed51809f9f04b1decc65b0a8932fd7b5b268100c94aace011ee67175a2a7b3472ea621f2f635f4b088f8701828dda0006ac0a17b0fd72ee2728b60c1591338e93270d113b03858535868f1d18e8db3221b17907e7657fd141950b1dff130e52417588143ac1aaac06a0dc0f606fd83d0c17e51e235942ba87826e1075b96d06567a65046550381d0ea6411714dd71989275fa1c0dcad2308414d01d964dcbb9a1eba61f69d2a57f4208f2101cc3f50876d1e9094a5198e4e10f211f7fa8c8b9063df41e739352723c6c9911f82c49e1af79520346700b6057cfe311d5a155aecc70fe131f6560e1de651a1bb43f38769e6a79133e8c1ace94c1e80dc56c790af1f75e0a9bc7e6ed0e49cd1c9c4fb9dd344ea600cb0cadc1e974261dc5451c2d52cf4b031bfcff7b1e69f614132a32f7b6115516e0ea802598baae1ee918bf6875b98001fcf6605cde286402752e1a480f5f251cd8ce46e31cbf4b1341811e4c6d564e175460d15fcfa2ce1d83c006e3e4169607bca888e204dbd31cbbe4f0da28999a0856bb9088a6ba4419651c79b2bab2531efc1abad2c9587614c45165955c9f6c1e68ce110bec14421adfacfef263fdb61a4c3ab90b63fe9317290dc2aa17ba090244cf49b1df41280b2dc437266efdcc194df5c9003283c019cad4ff4976358e0dfb6fa44a8942900141c765ef212dfc0602ab6cf27c78630e3f914d9256ee6b037ef65a8e81f5b218a49fd7496e6dd51d496a896825eb381d3a68196f6c01bb01bb6684f12a357c08c078ff6e3507ef171b4c28a9e0a0650163be339b6a1ca8056f29c0bd905eb0031a36a0d3c26fb00429f980c1f28ae203fcd856f6e3d1d3017f1880b08020c40280ff8dc6d388cb02142b0565e439180cf4850d229721b3110b0c333070f45108098ca5c23c3792190407970f4a84e906ff713514f0a9f00f4bd0b26f62da581b8be47c7d218cd918873be4fa79ea8804796d8e09e6bc9014b53fb75082f25f00ff471d7170310c09d407a29e0df73f0e0ae2c58d4ddd611fb6884e2dd846b81d2886d9a25e09810a6c9013dd76a4b31a914a1635acc9440455796f974fd8b1120b5c399dbdfb6d0839ffa8bfff199710f1a882d3dc915d16efa1db211c27f2105ed19e0e1d495e18c570daff6f371b0de5fe8bd73f12831a8d9fb0495ecbd01193dc8f7236392d1aa2d6b426e61da516e12598023a8c3a1f540167f70158d01bfc8674f243bf51067ce987b5c89a60014a7b80fefc57ad048ca29a1f67a48e07468e49b9eccc790e62363162aa57b80593d18ebb48e177075d5d052e40b75e1c51e4d7494ef6a7075a9eaf54d8050b18c75e79b8f63625191077b0ee3d531a0178f795862c75f60d687d912d658b4b06d9074a001d74c204420002831785711a88a4a65b0e14381edff84ddf78354210c6db52ea108f05175c97cdfac37b24177416af258b3a9714ab78e684c85a0309fed7a739b86cc01cce990a84dd54ef05ae547b322f118d1f7ba42d5370989e07db5525e221144a0985dd3e36cb58c51092e942ab7cc624145852e7612563ca066382ca0d3de23001ac2e5e5d5b389b09d4b781d120b74b098283ebe8312343137c1b8c858902d00099023b1d14083b015060120795cc230d7c28fb624110b9194b57ee6268912d05cbf18cfec7941e0d50afe49ec155dc1d6376a09d510a7706a3965df04cc26c18ce55d1a95fd3eb01ba90ad7f8ae0f312756646c7d008ec0a5ef66d60ceee25033141683000c1ac0d607f1e1c5dde2e055d735260350fb11898e223b18afb41090bedb73d8c902a026182daf2c96bfb12a2dbbc095fd8fd1422aafabd08584c02996dce2710956519b01a84acd7193810a02376f62238120e1c68609562c14d02d8156dffd39f9707be5c833c1745f30c9b2c48e697acc81f67e773fcbbcb9417933c8bae0f2e750482a6148539002c0470d411591a2c191df4fa21ea09cd16009ce01b5694a9580fe0f8912bb5b45b075dab9f2bbb5a4305d22e9154b8120d0a332d27f0f36f0c1ab15a8d69e08e921aaba0d45651058613f990f8bede9a1e11094f1a57f35a6c09260db7719bd035105a21b2bf0b016c006b8b312876dc3a19e355c1e1da3a4b0f75984bb2327d9f1b5c8c0a50eed16c1276ad970d9248c00450a861cf5ee410072027fd5b2887b40ab336a342c114fa142e4b35b35c8b791bf15418f05e296816cff0d0d39cf5de14d9f30d95c7ad111732b44b2bf2403d05cda888556073e303657f64508201851a78f06f61de84e01950fa2e80de3b440d66aafca0badddc060b99c6a520f8b215a795b4fc4076cd15d477af04dcfebc1a8c930ab1df7538128efcde47306f831fc36139988b9a620730c2a6acc4854f11a007fd842a9e93082bdce541f4900a0314429507963693175012a45fe21d6209f7fead66f69bc715701189c4eb977c11a9f005426c3aa71d4f9b656ad69d0f0276de27f3242a150b394aeaa4c6b17601fb5ab14a70635c1ead72f06e87f6ae0c12a5f14626b049118eaa5fad2b93880082e684e9c4a96f022db1b752ae9cc21dbb6c9ef1aa3d30156b61ae0fada7050b9e1cc761f8916b05cf81b82786c2bc022496217dc9b46d12755758cc09888c09ed1f91fc93bf0d10b4fce180fd668f1b980b5474af8520197314c479fd58b60a52101718c2a66d097b0090ac264c2a098b894b36f4480806524ccebae065c11c8fc489f7b6a62613f42e18705ad23b1ac757e3d58866e81121e5266a832ba10931e9bf066e2b8c1b309592296e06810dfcef8bffea34bb14a7258d185f05970bc6d1df238f0432022408b473f733c904df2adf2438a6b5089583d538e0ffb30d4fc168fc1dc4830d8d511471f7ac37174c15e95b739f0e0a0a3480a80aeaf31ba4968ecc0e938100d8b62967539d2305bcf6c4c8ff1efc1e2983568234b90e1d44eb031c5d70f9053082308c69fb6307423061ac7a1e421b4b9b7e44e332c00dcf73778e181bab1271153c159eabf21c70da63ffb2b90b0bb4e15d2623d79c1806582f87df52a60d9926c796982f701a584803b118120b054a2a1523ad7ba11eb11b328f3eafb81640975bf36522b60586eb88be71fa6019263396ac44ac980e89575ca55862970c7fba145c2145d30c48af955ddb3c880372c5f9df70a8ca03cb7863e8d6edbc11fc067cda1e279f1268df789e8a4d680eaed5df2c48cf9c0272d9be9eff9eb704aa3c63cb2653160cb11a26df3d806f0fb0ade635e6847205c80cb18d9ee9df007fded7c432cade1b7a92f87e2d2ab11e03e2ce14f8f190042b3c3fa45655a114d066b875168c89054900f176f74c2e09bb626fec6320e90cdd8c804dad74d1140d202b9e30ac01094b15533d38f4c3133cd66eb5aacb2b1027658d32154fac1c259f68006c8bd11eab3ca6f961c3fc036bcd00266b97ce02d7c43f2402ce5b0f7cd183af6c1f2e0a75080b6c9e2d5d05c692de81e6264805fd9aaf5824873002f41ebf93ba214103c70d7b543a192515db2a551ebe4b48073ea07a97b1c93a0866c865d19515d91a57e3ac28fd76190a176f152ed16c76000f8cf467d577761545809307deeb0b0f9e9a8e8eb36d6415fb10b1e6ad013704a5edfb4a5a36191ea12e0811f8f3420d318b43ff02dc731efca53b59e50a5c09eda92f0028f54a168c5b7385ed4c1001150f60dbd00b220d591621aa9eeb7710a66bc8e56f26270d39838b3568a4e8193141a0dbb1f96c0425fb82c2e1716c08a2a8c2ab65fe2e185edb34e1b241c90a7c66c834d402ec02d5826204c4ee030c39405eec6fdd21112d6e9ad7f0a03905b45a33e212887909ac77a2688422bc0e1759921bf1f8491ed8520beb3083441780829b5084669314d57487486a34ad17cc9f85c8e30bf51727715293227deb1a9d6235c276fc5a177b0a66a94fa4beb34f528d252b178fab5d7acdfd2db153c5922a7293866232b56e340e7ba4e62c6d21d1e397d8de9075d4d9fb53e414420b9c690ba76ccfb9b4f2de9c68578f519a5657c95f8f602e04db4be8afb24d00e326167977b1ef1f5db10f73169c6f212403f45d4de76a432263cace71646c4acd43eef5a9c305d18d287a9785d951e1a503c6f19cd6ab7ddc023b25d2c4a60dfe07f999334375c895fa65fb1e4c96d6a28b6ee6cf632c51182b3d9f306cf83a25a4af3ca5c120b7d13c909eb72f3d1cd995c736eda89d5737e4f63153752637300277fcb66de74ff50e52fa0031d98a8f0b6416a4c7b44c98865e57baf431e44cafad0621de30d6280e8da916eb39add4f1aa81bce621b113df1a299ce7e3586537c108993c11ae555c120671a56163259b79949f127f3627ceeece4b6b6cb29401a21af66113363929b515660d42f3f536a54f77f1d29c20da686d22ee9538d4262b085fe0e71604071335f33ffee7f8a34972022edab712792e02fad6f05cbad9501a283256397e951a2c03fdfba5645cb935d5af236752332cc66f427f7b3171a8223fe9e802118d4cd60d3633fa5619336df7b42544be1854ece654fc23d04cc8a184d4e66675439ae3339b51e0e5f8478c76788fb9490effd27297659eaaebfbd2618a11d4e5b06d2353e4eadd0d2ea686d31823841d56b5115390d744091094bff02df4061cb0e4dbd0b421db19544cfda63feea4067f3f45bc03426a11b4d73a5a676c4a00cc80d4e29ed411074fdfde52893a6310af3251e2810afb012689a09336c93103eb3984491abe7c094bf76c57f935a30c0463f4586e7b1d066d1c6be4049c6f010146d871a3357311a3066ab55db40d1672efa497b4239a1eca6b7153aebd36036018e1cae6a27e175a79c394eacb2a01b21b6341916e9e0ee9c054bc75d22704893d661480e3410670aed5bc2db40606be73b417924fa91822da8902781ff20a06540e292b951911c0377eca0f4d8d1926da63482a25780fdd573068255d0215e518dccd87c7590abafebc361044fe11b7db29b9660d8800b48ea2e156b3d81ebd01ea56c5232e08da0bd16c7106640913abca43e49973023311271d493e0008af455db7a556ff1ea6f06941fd374f1718bf6ce9ab6dbf08e0de8c2466783705d6a84d7fb6a39e1c1dd9f13939ce9b1d120db5811f670b1539f5db0a6c40b9036a24518dd1a0e609093db7e4be6efa1854f66219b9efe807ce220d141a2422173f3cab0ba4f17a1c4dc96c38fdf16012aa8b1b77d3b99813ae238274edc2420ef62b9d0a2fc993132399f4594d342c1461ff5fa6c66ae80d6ef0c2f06d2c9a04bb9c62fd7186ef1566f8c65f06c0a1199f48ae06bcd03a0ac9adcb7c6dd3cd0ef4ce747676cc8b1cfff7e6210b4d9c13d389f546a3d814158a248698d5a9650f81414978d12650126e0baeba9952520a4dc92ab9131e7f0d14a853037899a5086a12babf253493007c0a0d8f4a71241f91f4b96b5ddf9919cdfedff3c7f5921df3adc017c964c303419401e9e80f0404608876fe7b78581f9add5b01a3ef37061d41e9a5c30d9b02feebf5964be16a0d5169b68281f98b07edf00525177ef60253ecd687a05aee1cb612bf00efaafc07259e62ddccaf2e1b1fd4b76b93da7d0448dc58e4e1eb6e17c1c64f1da5512007c55157a278f5ac0968809d9fde253f154411b4d83f55fb1d0179d20fbdfaaa0b6b14523f8480d21c2a8fa38d78297b0f0800330c6ebccb03991406347089860175340b0a9f220f04ddc4099374fd0918add948d37b6a72199949f0147fe02010491c10e1f2f3d409b512dd253216f11446e036d01d12070cc2f1bdfc143bb40638c75298428b8a09d9a9e5ff932eb30cb365f877f2d2e309d4087fbf60a38b1c03a192c1471f01124e6e4432644a361e692ff79e9a7f7e0d9a00f4235e8731146d69a37b2b002313334fd37537f6e717d9405adf0d8eab11c0b2f7c4f51dca1bcb573c564e200312a464c2aad26a031c4fa5d872b108bc1df18dfbea2767c60f2e45f057af1ab61cca4beb92415ac9142fe7ec6edcd59d18105f14721c167c17e058b28e840c19050b0817189ed7961197117f3a3449c101833550941a4e701fd20933fe33bcd4007ab9bcc461017d156806604ebc24011a32d1397e0243a81fb5b14cce0d1e7f0a8ce603677693f80f54d1a859e466ac11f9c1bf1815400f15918cd87939722c088755a39f245884025ee1f2677bdf1a032bf1ad13027e6316e223c1188e08d20805a4c1783a894d1582674ab26f4b360de6181779fadf2a142c8ba02bcf06e614df79078e1adc541e7659c6a9eef4c219821e25817ab0100ee4f61b46834b1518676a86ee2c0e2f0de4dc74b41086d70c32b9f28d431cd80aaafe84af53fc13151609a6e01d440a0551ea8a620f99030b0dbc557af1a278104f736678decd081f52d091a02a2af51ff778059cc179b311995217bf00f89c1c62c3bec9d438e90ce32269518bfb131979a9da3c8f6e6f15a2a63eb08d99bc116989609af045511c52a85da70a8af004f16cda6b74d4e802a9e5e51edca1e01cd9d10322db6dcf175f6b5ced2b537e133472ee2bfcd1620b33c107f2916aae02547e578dc4dfe21aafe12c8edfaf5d12e67f6c7ebf79651a3532264610134318d2edb93c00536910c3356b4411956d07b0a052cf2d6d4713ae37c9db354eab10cfd27db006af39151af83051567e7e1fe1cc382cc5c33d17ca37ad2c6824bd0c7e0e8514895af211f4627cd8e6b2d512c215f1fde0b87b1530cbea8b076b620723bbb24ea517f814529fd112b115661bd234ca632433770ec7f0e684f5a9511d950933dcf5d3f711349a56a09629691b2dc2bf62b37dac03e73814810a155c09977b0e43eb59280d51ddfe1acd40f209df49a00bd55faf1734a50042dfe37a07e4706d10aaa95f0efcc628eab8214b0a381e21b45a4a9a18beee4c478dd5ee1256e6d670185149193de089bb1a976f02e1f2944c70a3fe12e41c402afe729e0b3af503d68f9fb91144b3550973e99908c3c787995091d502515ffd3756a5f81cd7528c546dff9302b2f5a1bbf425f203d08fc7c25d971d08bd423accce00ee0b7ca951429ba43d1986972145d7984c158da292b69be2571dfc28471becdc820ffe50b454e2d47e1179a171407e10c0067c402f40dd1f0a01443ab33a80d8f91d4d2a94682e2c821fc71eaa3ead9348193327b7fc7399ed09b06e44aa82bda615abbfdba1f7a1751b130b427c17f4700577c725b24a729002e3cf8e8f4f6a0e0b1669b128c1aabf080d640dc257c4cd052e9e3f9d366a100f8c37ef6d740b880d1b86981fb5cf891b96f52b10fc687a06ed98babc7142a511b1ed47e37a107e088bf62baa78d2a51ee144bbe7e2847c0a539a262beb5aa11854ef6053d24dbe16f0c5a69c57e97013906ebe6762156a05bf8401083319d312744ac8b3fdfa690f3bef1731f8092a0d06f6bdb13199241543f6e51d6544471f83de8e0a78440513f9b2655e8318340c3e3f674f87194204beead6183ebb3d0d76192cfbff1c321ce4f9e5f1810ed61c54062b4bd3e9f2102d78ab63d9891d011b72f08ea683ac1e23fcf5f9a13e37110e4dc6f2ca67610e821f06b70ce1300b03726e4f30f11f16abded9ecb2c34f09c1067d88e06d521826c0510dec1e1e15daa22501e217a11a659e05415b50f719106b1ee578c3060af7a98ea1e65c091c79f0b50161e0611510194e466583f116cfbc332024161e0791be7bd04d52c612bbf233724448c00edf10d70018f329079da8394e0d35151fca22aad25af573019cd7457a0d35ee0d338574f68b698708779fd30fd113b616333a67ae976f12163bf138a4760a10087e5a1653d45f2a1d672fcd5dd5bfda01137a1d2515c88d07bd8b3a99d5650c1b6311f14d2ad3c100f651ed125b09d7074dd99a2ffdf41400a145a81ea8008b06323792cde8380d0a76e631a34afc5409d526a65a65536407c0dc66510384af1eeb734fd6abc3a914c3cd06827793fa1cc46d75a7a5d8ae131774f9547988c81b98e0ce8d771f8018e0f00f2bc3ec2c137231910c26bd47016cdf34d53c231713e548fcde3f4ac509321bcba92624a00703de044570826f1362135337c1cbf31a1aaab9e91fa9400c9e9e5fb22308300f7260a4e5d34fbe19972bcc0bf451b1193b6631060aadfb1b6e2409a6f5c07901b2acab5940baf91db25bf2f6d9399818d5ed5e25c50bf700166be6279618be1fe0d6fc66929e6607a12abfbc8acaf90f467efb19948b5c097e460b6878c4151ac54b0d7dca1aae09c1544c1a55029c0c7e1152b1536b381a4aa7435aa686260e7bc313a97986e5171654772dca141c1cc3e61341cf7de00cd5487854f7a5b80a97b08dd677658c063e4e1f1d1adf61095add314601246c117a951540205ad40644342ca5d0e7b70818cf87092c53fa177e63df70eb2b2f181b12d6d4bcae8b0c7f7992e8d9fb911efd37951c398d77035071f0076657b91b47688bfbc758330d61792e5d6c7b4005598f691c22c478047b9781af1404591d6128163d41b9031850c8e1c15d2d760d2b9437c73138651b67c70c62ae4a910793cf1ce9e494931d5402d8189df624afd6c5ac28902b59f17bf2234cc8e6d94191724725368f263c8ddeee118c3bcd618eb4d2b06ca90319a4354049e6c6d0550b5c6bb9ef638a74843e4c570e0fa5766bf4fb403f2ee0ccc6321fa7a66858b5ef82f824ea767cee9268f0526d19f65333670ecc0f605311a3d627e4a33ba22c8829095cd234f4c33485824114a375aa2570e1b26789c4d8dd803a78876b67f78d29c2ae66eeecb83f594595f97dc8d128251d41ef42c14f9437272a10bf328ae0d00f5d210ba397b4384c2fb227b37e0a0be212b0dcf9fb08360530c1f7b87f8460b51d673e3d887b66c7634fbfbe172eae7ce2fb32ebca28f8f0634f453ef50d89a1a7ba9da60d18a6a3b0f85805032b91845acf0fe09d6fb4a34aaae2d640f4eb1d71ea8b449be1f749155894974f560b58dd77bc94e185b53c912aabada0a33db4d98b896dc05c5cfee1ad3dcca99db0da3b2e56359849e8c3b2d5eb62414f69cf2d6ee0ed6c891694c0c687d58c36492e9d2a6f1010adc3779fcdaf3e59b555c3b9031a271095d752efc7e4ed43c6bfc4ebd6a12a3e3d3ba5fc8eca900c93e43898271f9cc45d92464d498c23c870e4034ebf09066183015b5409842a1f5e17018a2c0bd394322e8a99f7fd13db12ac0cf9cfd100ab5e1c436ddc049f0a4cd3b9e28cf9327c77d92ab5af03c614cdac2baaaadcf2105783cf8a8277101247ae6da4cd42c50af0e675392636e71ec87bb03b77ecb91891b399a37e73911caf4f2679ce03ab076afeddbb003f141582dcd3a6538aa20af1e74cba529fc41af73b7fc05a5dfb05deb99a285aeeb0076ab33a458a11f319dea72824d8bbd21dcadabe9cd34b761cb982d29e7da5ea12679edda5929cb31ae42019e2435cbd08f928687953106f1ce4b269d388b35507b3c229dd0764e509e27cacdbce279309e1df7fe90a944403c7dccec6aeae8c06a298575e9edf3b05dca06c8b667cd11695dc892a94021319ef75b848baa74f0444faff7c6fab8b12e7891f80c8a9df1ba6cbd1a6329f6d0bca21b19220555f1da2a1d91caeaf4f0163a25bc50ed20a1e9bb7cd9401721807a0e40d42ba0e4814dcac42c60a301213cce46ab6724e7805a906912f1075bc16ac49aff8622e010998832dfe324a0b027d5870729b13ed08bb9ee7ba5de7341967372027125f7f1df45d20eedf64c20f9413104df161901dc4ca9f0fd605161a9efb329f2670e10c7035428bf93bca1914bf8c853e0553163740ccdb60b43d0a0da03c463af13b0df84d6732991c1715b6d43b0a5217720cfab1dea4e2777800f0c575a73978180ae7cd7db9bae2f3042cf763775b98b210fefe7087ca7f561a2b3e5b7c9fa2db824214a42302d0495a1827b2c000e523f8ebbcca65fc03b866a49f59ed40b008ef7450f8338ff4d256a21f77172ab45d80147f77d67331f04cac6f8813e78c9cab32ab561011240801113b2f1e896ac2d16ff73a06a1b8c9f0afe74e0f107814d6112eab09682b0b14caf154"     
    }

    public fun invalid_proof_hex(): vector<u8> {
      assert(Testnet::is_testnet(), 130102014010);
      x"ab"
    }
    
    public fun valid_public_input_json(): vector<u8> {
      assert(Testnet::is_testnet(), 130102014010);
      // {"chain_length":3,"output":["0xdb0a16d9f9cedae","0x244b64cb5a39a2b","0x1f6c22cd3cfdde49","0x4bf27b6fae084cb"]}
      x"207b22636861696e5f6c656e677468223a332c226f7574707574223a5b223078646230613136643966396365646165222c223078323434623634636235613339613262222c22307831663663323263643363666464653439222c223078346266323762366661653038346362225d7d20"
    }

    public fun invalid_public_input_json(): vector<u8> {
      assert(Testnet::is_testnet(), 130102014010);
      // {"chain_length":3,"output":["0xab0a16d9f9cedae","0x244b64cb5a39a2b","0x1f6c22cd3cfdde49","0x4bf27b6fae084cb"]}
      x"207b22636861696e5f6c656e677468223a332c226f7574707574223a5b223078610230613136643966396365646165222c223078323434623634636235613339613262222c22307831663663323263643363666464653439222c223078346266323762366661653038346362225d7d20"
    }

    public fun parameters_json(): vector<u8> {
      assert(Testnet::is_testnet(), 130102014010);
      // {"stark":{"fri":{"fri_step_list":[1,2,2],"last_layer_degree_bound":1,"n_queries":30,"proof_of_work_bits":20},"log_n_cosets":2}}
      x"207b22737461726b223a7b22667269223a7b226672695f737465705f6c697374223a5b312c322c325d2c226c6173745f6c617965725f6465677265655f626f756e64223a312c226e5f71756572696573223a33302c2270726f6f665f6f665f776f726b5f62697473223a32307d2c226c6f675f6e5f636f73657473223a327d7d20"
    }

    public fun annotation_file_name(): vector<u8> {
      assert(Testnet::is_testnet(), 130102014010);
      // "annotation_file.txt"
      x"616e6e6f746174696f6e5f66696c652e747874"
    }
  }
}
