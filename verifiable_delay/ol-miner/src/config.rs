//! OlMiner Config
//!
//! See instructions in `commands.rs` to specify the path to your
//! application's configuration file and/or command-line options
//! for specifying it.

use serde::{Deserialize, Serialize};
use std::assert;
use byteorder::{LittleEndian, WriteBytesExt};


/// OlMiner Configuration
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct OlMinerConfig {
    /// An example configuration section
    pub profile: Profile,
    pub chain_info: ChainInfo,

}

impl OlMinerConfig {
    ///Format the config file data into a fixed byte structure for easy parsing in Move/other languages
    pub fn gen_preimage(&self) -> Vec<u8> {
    let mut preimage:Vec<u8> = vec![]; 

     let mut padded_key_bytes = match hex::decode(self.profile.public_key.clone()){
         Err(x)=> panic!("Invalid Public key {}",x),
         Ok( key_bytes)=>{
             if key_bytes.len() != 64{
                 panic!("Expected a 64 byte public_key. Got{}", key_bytes.len());
             }
             key_bytes
         }
     };

     preimage.append(&mut padded_key_bytes);
     

     let mut padded_chain_id_bytes = {
        let mut chain_id_bytes = self.chain_info.chain_id.clone().into_bytes(); 



        match chain_id_bytes.len(){
            d if d > 64 => panic!("Chain Id is longer than 64 bytes. Got {} bytes", chain_id_bytes.len()),
            d if d < 64 =>{
                let padding_length = 64 - chain_id_bytes.len() as usize;
            let mut padding_bytes:Vec<u8> = vec!(0;padding_length);
            padding_bytes.append(&mut chain_id_bytes);
            padding_bytes            
            },
            d if d == 64 =>chain_id_bytes,
            _=> unreachable!(),
        }
    };

    preimage.append(&mut padded_chain_id_bytes);

    preimage.write_u64::<LittleEndian>(self.chain_info.block_size).unwrap();


     let mut padded_statements_bytes = {
        let mut statement_bytes = self.profile.statement.clone().into_bytes(); 

        match statement_bytes.len(){
            d if d > 1024 => panic!("Chain Id is longer than 1024 bytes. Got {} bytes", statement_bytes.len()),
            d if d < 1024 =>{
                let padding_length = 1024 - statement_bytes.len() as usize;
            let mut padding_bytes:Vec<u8> = vec!(0;padding_length);
            padding_bytes.append(&mut statement_bytes);
            padding_bytes            
            },
            d if d == 1024 =>statement_bytes,
            _=> unreachable!(),
        }
    };

    preimage.append(&mut padded_statements_bytes);

    
    

     assert!(preimage.len() == (64 //Public Key
        +64 //chain_id
        +8 // iterations
        +1024 //statement
    ), "preimage is the incorrect size");
     return preimage;
     }
}

/// Default configuration settings.
///
/// Note: if your needs are as simple as below, you can
/// use `#[derive(Default)]` on OlMinerConfig instead.
impl Default for OlMinerConfig {
    fn default() -> Self {
        Self {
            profile: Profile::default(),
            chain_info: ChainInfo::default(),
        }
    }
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct ChainInfo {
    pub chain_id: String,
    pub block_size: u64,
    pub block_dir: String,
}

impl Default for ChainInfo {
    fn default() -> Self {
        Self{
            chain_id: "Ol testnet".to_owned(),
            block_size: 100,
            block_dir: "blocks".to_owned(),
        }
    }
}


#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Profile {
    pub public_key: String,
    pub statement: String,

}

impl Default for Profile {
    fn default() -> Self {
        Self {
            public_key: "ed25519_key".to_owned(),
             statement: "protests rage across America".to_owned(),

        }
    }
}
