//! get home path or set it
use anyhow::{bail, Error};
use dialoguer::{Confirm, Input};
use diem_crypto::HashValue;
use diem_global_constants::NODE_HOME;
use glob::glob;
use hex::encode;
use std::{fs, net::Ipv4Addr, path::PathBuf};

use crate::{block::VDFProof, config::{AppCfg, IS_TEST}};

/// interact with user to get the home path for files
pub fn what_home(swarm_path: Option<PathBuf>, swarm_persona: Option<String>) -> PathBuf {
    // For dev and CI setup
    if let Some(path) = swarm_path {
        return swarm_home(path, swarm_persona);
    } else {
        if *IS_TEST {
            return dirs::home_dir().unwrap().join(NODE_HOME);
        }
    }

    let mut default_home_dir = dirs::home_dir().unwrap();
    default_home_dir.push(NODE_HOME);

    let txt = &format!(
        "Will you use the default directory for node data and configs: {:?}?",
        default_home_dir
    );
    let dir = match Confirm::new().with_prompt(txt).interact().unwrap() {
        true => default_home_dir,
        false => {
            let input: String = Input::new()
                .with_prompt("Enter the full path to use (e.g. /home/name)")
                .interact_text()
                .unwrap();
            PathBuf::from(input)
        }
    };
    dir
}

/// interact with user to get the source path
pub fn what_source() -> Option<PathBuf> {
    let mut default_source_path = dirs::home_dir().unwrap();
    default_source_path.push("libra");

    let txt = &format!(
        "Is this the path to the source code? {:?}?",
        default_source_path
    );
    let dir = match Confirm::new().with_prompt(txt).interact().unwrap() {
        true => default_source_path,
        false => {
            let input: String = Input::new()
                .with_prompt("Enter the full path to use (e.g. /home/name)")
                .interact_text()
                .unwrap();
            PathBuf::from(input)
        }
    };
    Some(dir)
}

/// interact with user to get ip address
pub fn what_ip() -> Result<Ipv4Addr, Error> {
    let system_ip = match machine_ip::get() {
        Some(ip) => ip.to_string(),
        None => "127.0.0.1".to_string(),
    };
    let ip = system_ip
        .parse::<Ipv4Addr>()
        .expect("Could not parse IP address: {:?}");

    if *IS_TEST {
        return Ok(ip);
    }

    let txt = &format!(
        "Will you use this host, and this IP address {:?}, for your node?",
        system_ip
    );
    let ip = match Confirm::new().with_prompt(txt).interact().unwrap() {
        true => ip,
        false => {
            let input: String = Input::new()
                .with_prompt("Enter the IP address of the node")
                .interact_text()
                .unwrap();
            input
                .parse::<Ipv4Addr>()
                .expect("Could not parse IP address")
        }
    };

    Ok(ip)
}

/// interact with user to get a statement
pub fn what_statement() -> String {
    if *IS_TEST {
        return "test".to_owned();
    }
    Input::new()
        .with_prompt("Enter a (fun) statement to go into your first transaction")
        .interact_text()
        .expect(
            "We need some text unique to you which will go into your the first proof of your tower",
        )
}

/// interact with user to get a statement
pub fn add_tower(config: &AppCfg) -> Option<String> {
    let block = find_last_legacy_block(&config.workspace.node_home.join("blocks")).unwrap();
    let hash = hash_last_proof(&block.proof);
    let txt = "(optional) want to add a hash to previous tower?";
    match Confirm::new().with_prompt(txt).interact().unwrap() {
        false => None,
        true => {
          let hash_string = encode(hash);
          let txt = format!("Use this as your tower link? {} ", &hash_string);
          match Confirm::new().with_prompt(txt).interact().unwrap() {
            true => Some(hash_string),
            false => { 
              Input::new()
                .with_prompt("Enter hash of last proof")
                .interact_text()
                .ok()
            },
        }
    }
  }
}
/// returns node_home
/// usually something like "/root/.0L"
/// in case of swarm like "....../swarm_temp/0" for alice
/// in case of swarm like "....../swarm_temp/1" for bob
fn swarm_home(mut swarm_path: PathBuf, swarm_persona: Option<String>) -> PathBuf {
    if let Some(persona) = swarm_persona {
        let all_personas = vec!["alice", "bob", "carol", "dave", "eve"];
        let index = all_personas.iter().position(|&r| r == persona).unwrap();
        swarm_path.push(index.to_string());
    } else {
        swarm_path.push("0"); // default
    }
    swarm_path
}

// helper to parse the existing blocks in the miner's path. This function receives any path. Note: the path is configured in miner.toml which abscissa Configurable parses, see commands.rs.
fn find_last_legacy_block(blocks_dir: &PathBuf) -> Result<VDFProof, Error> {
    let mut max_block: Option<u64> = None;
    let mut max_block_path = None;
    // iterate through all json files in the directory.
    for entry in glob(&format!("{}/block_*.json", blocks_dir.display()))
        .expect("Failed to read glob pattern")
    {
        if let Ok(entry) = entry {
            let block_file =
                fs::read_to_string(&entry).expect("Could not read latest block file in path");

            let block: VDFProof = serde_json::from_str(&block_file)?;
            let blocknumber = block.height;
            if max_block.is_none() {
                max_block = Some(blocknumber);
                max_block_path = Some(entry);
            } else {
                if blocknumber > max_block.unwrap() {
                    max_block = Some(blocknumber);
                    max_block_path = Some(entry);
                }
            }
        }
    }
    
    if let Some(p) = max_block_path {
        let b = fs::read_to_string(p).expect("Could not read latest block file in path");
        match serde_json::from_str(&b) {
            Ok(v) => Ok(v),
            Err(e) => bail!(e),
        }
    } else {
        bail!("cannot find a legacy block in: {:?}", blocks_dir)
    }
}
fn hash_last_proof(proof: &Vec<u8>) -> Vec<u8>{
  HashValue::sha3_256_of(proof).to_vec()
}