use anyhow::Result;
use diem_secure_storage::{GitHubStorage, Storage};
use vm_genesis::{TestValidator, Validator};
use std::{path::PathBuf, process::exit, time::Duration, thread};
use ol_types::{legacy_recovery::{save_recovery_file, read_from_recovery_file}, OLProgress};
use gumdrop::Options;
use diem_genesis_tool::genesis::Genesis;
use crate::{
    compare,
    // swarm_genesis::make_swarm_genesis
    fork_genesis::{
        make_recovery_genesis_from_db_backup, make_recovery_genesis_from_vec_legacy_recovery,
    },
    process_snapshot::db_backup_into_recovery_struct,
};
use indicatif::ProgressIterator;


pub fn default_run(
  output_path: PathBuf,
  snapshot_path: PathBuf,
  genesis_repo_owner: String,
  genesis_repo_name: String,
  genesis_gh_token: String,
  test: bool,
) -> Result<()>{
          // create a genesis.blob
        // there are two paths here
        // 1) do a new genesis straight from a db backup. Useful
        // for testing, debugging, and ci.
        // 2) use a JSON file with specific schma, which contains structured data for accounts.
        // let output_path = opts
        //     .output_path
        //     .expect("ERROR: must provide output-path for genesis.blob, exiting.");


              
            let genesis_vals = if !test {
              let gh_config = GitHubStorage::new(
                genesis_repo_owner,
                genesis_repo_name,
                "master".to_string(),
                genesis_gh_token,
              );
              // NOTE: this is a real PITA.
              // There are two structs called SecureBackend, and we need to do some gymnastics. Plus they wrote their own parser for the cli args. Sigh.
              // let b =  diem_management::secure_backend::storage(&s).unwrap();

              let b = Storage::GitHubStorage(gh_config);

              Genesis::just_the_vals(b).expect("could not get the validator set")
            } 
            else {
              // TODO: this is duplicated in tests
              TestValidator::new_test_set(Some(4)).into_iter()
              .map(|v| {v.data}).collect()
              // create testnet genesis

            };

            let rt = tokio::runtime::Runtime::new().unwrap();
            rt.block_on({
              make_recovery_genesis_from_db_backup(
                output_path.clone(),
                snapshot_path,
                !test,
                &genesis_vals
                // genesis_vals
            )
          })?;
          carpe_diem();
          Ok(())
}

fn carpe_diem() {
    // be happy
    (0..20).progress_with_style(OLProgress::fun())
    .for_each(|_|{
      thread::sleep(Duration::from_millis(300));
    });
}
