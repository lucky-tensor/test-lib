//! functions for comparing LegacyRecovery data to a genesis blob
//! every day is like sunday
//! -- morrissey via github copilot

use crate::db_utils;
use crate::recover;
use crate::recover::LegacyRecovery;
use anyhow;
use diem_types::account_address::AccountAddress;
use diem_types::account_state::AccountState;
use std::convert::TryFrom;
use std::path::PathBuf;

#[derive(Debug)]
/// struct for holding the results of a comparison
pub struct CompareError {
    /// index of LegacyRecover
    pub index: u64,
    /// user account
    pub account: Option<AccountAddress>,
    /// balance difference [LegacyRecover]- [genesis blob]
    pub bal_diff: i64,
    /// error message
    pub message: String,
}
/// Compare the balances in a recovery file to the balances in a genesis blob.
pub fn compare_recovery_vec_to_genesis_blob(
    recovery: Vec<LegacyRecovery>,
    genesis_path: PathBuf,
) -> Result<Vec<CompareError>, anyhow::Error> {
    // start an empty btree map
    let mut err_list: Vec<CompareError> = vec![];

    // iterate over the recovery file and compare balances
    let (db_rw, _) = db_utils::read_db_and_compute_genesis(genesis_path)?;

    recovery.into_iter().enumerate().for_each(|(i, v)| {
        if v.account.is_none() {
            err_list.push(CompareError {
                index: i as u64,
                account: None,
                bal_diff: 0,
                message: "account is None".to_string(),
            }); // instead of balance, if there is an account that is None, we insert the index of the recovery file
            return;
        };

        if v.account.unwrap() == AccountAddress::ZERO {
            return;
        };
        if v.balance.is_none() {
            err_list.push(CompareError {
                index: i as u64,
                account: v.account,
                bal_diff: 0,
                message: "recovery file balance is None".to_string(),
            });
            return;
        }

        let val_state = match db_rw
            .reader
            .get_latest_account_state(v.account.expect("need an address"))
        {
            Ok(Some(val_state)) => val_state,
            _ => {
                err_list.push(CompareError {
                    index: i as u64,
                    account: v.account,
                    bal_diff: 0,
                    message: "find account blob".to_string(),
                });
                return;
            }
        };

        let account_state = match AccountState::try_from(&val_state) {
            Ok(account_state) => account_state,
            _ => {
                err_list.push(CompareError {
                    index: i as u64,
                    account: v.account,
                    bal_diff: 0,
                    message: "parse account state".to_string(),
                });
                return;
            }
        };

        let bal = match account_state.get_balance_resources() {
            Ok(bal) => bal,
            _ => {
                err_list.push(CompareError {
                    index: i as u64,
                    account: v.account,
                    bal_diff: 0,
                    message: "get balance resource".to_string(),
                });
                return;
            }
        };

        let genesis_bal = match bal.iter().next() {
            Some((_, b)) => b.coin(),
            _ => {
                err_list.push(CompareError {
                    index: i as u64,
                    account: v.account,
                    bal_diff: 0,
                    message: "genesis resource is None".to_string(),
                });
                return;
            }
        };

        let recovery_bal = v.balance.unwrap().coin();
        if recovery_bal != genesis_bal {
            err_list.push(CompareError {
                index: i as u64,
                account: v.account,
                bal_diff: recovery_bal as i64 - genesis_bal as i64,
                message: "balance mismatch".to_string(),
            });
        }
    });

    Ok(err_list)
}

/// Compare the balances in a recovery file to the balances in a genesis blob.
pub fn compare_json_to_genesis_blob(
    json_path: PathBuf,
    genesis_path: PathBuf,
) -> Result<Vec<CompareError>, anyhow::Error> {
    let recovery = recover::read_from_recovery_file(&json_path);
    compare_recovery_vec_to_genesis_blob(recovery, genesis_path)
}
