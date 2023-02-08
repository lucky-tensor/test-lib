//! genesis-wrapper

use std::fs::File;
use std::io::Write;
use std::path::PathBuf;

use crate::process_snapshot::{db_backup_into_recovery_struct, merge_writeset};
use crate::recover::{
    recover_validator_configs, AccountRole, LegacyRecovery, RecoverConsensusAccounts,
};
use anyhow::{bail, Error};
use diem_types::access_path::AccessPath;
use diem_types::account_address::AccountAddress;
use diem_types::account_config::{BalanceResource, CurrencyInfoResource};
use diem_types::ol_miner_state::TowerStateResource;
use diem_types::transaction::{ChangeSet, Transaction, WriteSetPayload};
use diem_types::write_set::{WriteOp, WriteSetMut};
use move_core_types::identifier::Identifier;
use move_core_types::move_resource::MoveResource;
use ol_types::autopay::AutoPayResource;
use ol_types::fullnode_counter::FullnodeCounterResource;
use ol_types::wallet::{CommunityWalletsResource, SlowWalletResource};
use vm_genesis::encode_recovery_genesis_changeset;

/// Make a recovery genesis blob from archive
pub async fn make_recovery_genesis_from_db_backup(
    genesis_blob_path: PathBuf,
    archive_path: PathBuf,
    append: bool,
    is_legacy: bool,
    genesis_vals: Vec<AccountAddress>,
) -> Result<(), Error> {
    // get the legacy data from archive
    let recovery = db_backup_into_recovery_struct(&archive_path, is_legacy).await?;

    make_recovery_genesis_from_vec_legacy_recovery(
      recovery, 
      genesis_vals,
      genesis_blob_path, 
      append
    )
}

/// Make a recovery genesis blob
pub fn make_recovery_genesis_from_vec_legacy_recovery(
    recovery: Vec<LegacyRecovery>,
    genesis_vals: Vec<AccountAddress>,
    genesis_blob_path: PathBuf,
    append_user_accounts: bool,
) -> Result<(), Error> {
    // get consensus accounts
    let all_validator_configs = recover_validator_configs(&recovery)?;

    // we use the vm-genesis to properly migrate EVERY validator account.
    // then we select a subset which will be the validators of the first epoch.
    let genesis_changeset_with_validators = get_baseline_genesis_change_set(all_validator_configs, &genesis_vals)?;

    // For a real upgrade or fork, we want to include all user accounts.
    // this is the default.
    // Otherwise, we might need to just collect the validator accounts
    // for debugging or other test purposes.
    let expected_len_all_users = recovery.len() as u64;

    let gen_tx = if append_user_accounts {
        // append further writeset to genesis
        append_genesis(
          genesis_changeset_with_validators,
          recovery,
          expected_len_all_users
        )?
    } else {
        Transaction::GenesisTransaction(WriteSetPayload::Direct(genesis_changeset_with_validators))
    };
    // save genesis
    save_genesis(gen_tx, genesis_blob_path)
}

/// Get the minimal viable genesis from consensus accounts.
pub fn get_baseline_genesis_change_set(
    genesis_accounts: RecoverConsensusAccounts,
    validator_set: &[AccountAddress],
) -> Result<ChangeSet, Error> {
    encode_recovery_genesis_changeset(
        &genesis_accounts.vals,
        &genesis_accounts.opers,
        &validator_set,
        1, // mainnet
    )
}

/// make the recovery genesis transaction, and file
pub fn append_genesis(
    gen_cs: ChangeSet,
    legacy_vec: Vec<LegacyRecovery>,
    expected_len_all_users: u64,
) -> Result<Transaction, Error> {
    // merge writesets
    let mut all_writesets = gen_cs.write_set().to_owned().into_mut();
    let mut total_coin_value = 0u64;
    let mut len = 0u64;
    // iterate through all the accounts
    // this includes the Validator accounts.
    // at a minimum balances will need to be recovered
    // and the total tokens calculated, and checked for matching sums.
    // there may also be migrations on other account state that may need to be done.
    for l in &legacy_vec {
        assert!(l.account.is_some());

        diem_logger::debug!("migrating: {} - {}", &l.account.unwrap(), &len);

        // get balance
        if let Some(b) = &l.balance {
            total_coin_value = total_coin_value + b.coin();
        }
        let ws = migrate_account(l)?;
        all_writesets = merge_writeset(all_writesets, ws)?;
        len = len + 1;
    }

    assert!(
        len == expected_len_all_users,
        "mismatched number of users in attempted recovery"
    );

    // after counting balance, reset total coin value.
    let coin_ws = total_coin_value_restore(legacy_vec, total_coin_value as u128)?;
    all_writesets = merge_writeset(all_writesets, coin_ws)?;

    let all_changes = ChangeSet::new(all_writesets.freeze().unwrap(), gen_cs.events().to_owned());
    Ok(Transaction::GenesisTransaction(WriteSetPayload::Direct(
        all_changes,
    )))
}
/// make the recovery genesis transaction, and file
pub fn migrate_account(legacy: &LegacyRecovery) -> Result<WriteSetMut, Error> {
    let mut write_set_mut = WriteSetMut::new(vec![]);
    let account = legacy.account.unwrap();
    // add writesets, for recovering e.g. user accounts, balance, miner state, or application state

    // TODO: Restore Balance and Total Supply
    // legacy.balance
    // TODO: Change legacy names
    // NOTE: this is only needed from Libra -> Diem renames
    if let Some(bal) = &legacy.balance {
        let new = BalanceResource::new(bal.coin());
        write_set_mut.push((
            AccessPath::new(account, BalanceResource::resource_path()),
            WriteOp::Value(bcs::to_bytes(&new).unwrap()),
        ));
    }

    // Restore Miner State

    if let Some(m) = &legacy.miner_state {
        write_set_mut.push((
            AccessPath::new(account, TowerStateResource::resource_path()),
            WriteOp::Value(bcs::to_bytes(&m).unwrap()),
        ));
    }

    // Set all wallet types to slow
    if legacy.role != AccountRole::System {
        let new = SlowWalletResource { is_slow: true };
        write_set_mut.push((
            AccessPath::new(account, SlowWalletResource::resource_path()),
            WriteOp::Value(bcs::to_bytes(&new).unwrap()),
        ));
    }

    // Autopay
    if let Some(a) = &legacy.autopay {
        // TODO: confirm no transformation is needed since the serialization remains the same.
        // let new = AutoPayResource::new(bal.coin());
        write_set_mut.push((
            AccessPath::new(account, AutoPayResource::resource_path()),
            WriteOp::Value(bcs::to_bytes(&a).unwrap()),
        ));
    }

    // System state to recover.
    // Community Wallets
    if let Some(w) = &legacy.comm_wallet {
        let new = CommunityWalletsResource {
            list: w.list.clone(),
        };
        write_set_mut.push((
            AccessPath::new(account, CommunityWalletsResource::resource_path()),
            WriteOp::Value(bcs::to_bytes(&new).unwrap()),
        ));
    }
    // fullnode counter
    if let Some(f) = &legacy.fullnode_counter {
        //   let new = FullnodeCounterResource {
        //     proofs_submitted_in_epoch: f.proofs_submitted_in_epoch,
        //     proofs_paid_in_epoch: f.proofs_paid_in_epoch,
        //     subsidy_in_epoch: f.subsidy_in_epoch,
        //     cumulative_proofs_submitted: f.cumulative_proofs_submitted,
        //     cumulative_proofs_paid: f.cumulative_proofs_paid,
        //     cumulative_subsidy: f.cumulative_subsidy,
        // };

        // TODO: confirm no transformation is needed since the serialization remains the same.
        write_set_mut.push((
            AccessPath::new(account, FullnodeCounterResource::resource_path()),
            WriteOp::Value(bcs::to_bytes(&f).unwrap()),
        ));
    }

    // make the genesis transaction
    Ok(write_set_mut)
}

/// get writeset for the total coin value
pub fn total_coin_value_restore(
    legacy_vec: Vec<LegacyRecovery>,
    total_value: u128,
) -> Result<WriteSetMut, Error> {
    let mut write_set_mut = WriteSetMut::new(vec![]);
    let sys_legacy = legacy_vec
        .iter()
        .find(|&a| a.account == Some(AccountAddress::ZERO));

    match sys_legacy {
        Some(legacy) => {
            if let Some(c) = &legacy.currency_info {
                let new = CurrencyInfoResource::new(
                    // replace total value
                    total_value,
                    c.preburn_value(),
                    c.to_xdx_exchange_rate(),
                    c.is_synthetic(),
                    c.scaling_factor(),
                    c.fractional_part(),
                    c.currency_code().to_owned(),
                    c.can_mint(),
                    c.mint_events().to_owned(),
                    c.burn_events().to_owned(),
                    c.preburn_events().to_owned(),
                    c.cancel_burn_events().to_owned(),
                    c.exchange_rate_update_events().to_owned(),
                );

                let access_path = CurrencyInfoResource::resource_path_for(
                    Identifier::new("GAS".to_owned()).unwrap(),
                );
                write_set_mut.push((access_path, WriteOp::Value(bcs::to_bytes(&new).unwrap())));

                return Ok(write_set_mut);
            }
            bail!("no currency info struct found!")
        }
        None => bail!("no system address legacy state found!"),
    }
    // TODO: Name change from libra -> diem needs to be mapped
}

/// save the genesis blob
pub fn save_genesis(gen_tx: Transaction, output_path: PathBuf) -> Result<(), Error> {
    let mut file = File::create(output_path)?;
    let bytes = bcs::to_bytes(&gen_tx)?;
    file.write_all(&bytes)?;
    Ok(())
}
