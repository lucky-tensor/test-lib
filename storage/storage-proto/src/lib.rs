// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

#![forbid(unsafe_code)]

//! This crate provides Protocol Buffers definitions for the services provided by the
//! [`storage_service`](../storage_service/index.html) crate.
//!
//! The protocol is documented in Protocol Buffers sources files in the `.proto` extension and the
//! documentation is not viewable via rustdoc. Refer to the source code to see it.
//!
//! The content provided in this documentation falls to two categories:
//!
//!   1. Those automatically generated by [`grpc-rs`](https://github.com/pingcap/grpc-rs):
//!       * In [`proto::storage`] are structs corresponding to our Protocol Buffers messages.
//!       * In [`proto::storage_grpc`] live the [GRPC](grpc.io) client struct and the service trait
//! which correspond to our Protocol Buffers services.
//!   2. Structs we wrote manually as helpers to ease the manipulation of the above category of
//! structs. By implementing the [`TryFrom`](std::convert::TryFrom) and
//! [`From`](std::convert::From) traits, these structs convert from/to the above category of
//! structs in a single method call and in that process data integrity check can be done. These live
//! right in the root module of this crate (this page).
//!
//! This is provided as a separate crate so that crates that use the storage service via
//! [`storage-client`](../storage-client/index.html) don't need to depending on the entire
//! [`storage-service`](../storage-service/index.html).

pub mod proto;

use anyhow::{ensure, format_err, Error, Result};
use libra_crypto::HashValue;
use libra_types::{
    account_address::AccountAddress,
    account_state_blob::AccountStateBlob,
    crypto_proxies::{LedgerInfoWithSignatures, ValidatorSet},
    proof::SparseMerkleProof,
    transaction::{TransactionListWithProof, TransactionToCommit, Version},
};
#[cfg(any(test, feature = "fuzzing"))]
use proptest::prelude::*;
#[cfg(any(test, feature = "fuzzing"))]
use proptest_derive::Arbitrary;
use std::convert::{TryFrom, TryInto};

#[derive(Debug, PartialEq, Eq, Clone)]
#[cfg_attr(any(test, feature = "fuzzing"), derive(Arbitrary))]
pub struct GetLatestStateRootResponse {
    pub version: Version,
    pub state_root_hash: HashValue,
}

impl GetLatestStateRootResponse {
    pub fn new(version: Version, state_root_hash: HashValue) -> Self {
        Self {
            version,
            state_root_hash,
        }
    }
}

impl TryFrom<crate::proto::storage::GetLatestStateRootResponse> for GetLatestStateRootResponse {
    type Error = Error;

    fn try_from(proto: crate::proto::storage::GetLatestStateRootResponse) -> Result<Self> {
        let version = proto.version;
        let state_root_hash = HashValue::from_slice(&proto.state_root_hash)?;

        Ok(Self::new(version, state_root_hash))
    }
}

impl From<GetLatestStateRootResponse> for crate::proto::storage::GetLatestStateRootResponse {
    fn from(response: GetLatestStateRootResponse) -> Self {
        Self {
            version: response.version,
            state_root_hash: response.state_root_hash.to_vec(),
        }
    }
}

impl Into<(Version, HashValue)> for GetLatestStateRootResponse {
    fn into(self) -> (Version, HashValue) {
        (self.version, self.state_root_hash)
    }
}

#[derive(Debug, PartialEq, Eq, Clone)]
#[cfg_attr(any(test, feature = "fuzzing"), derive(Arbitrary))]
pub struct GetLatestAccountStateRequest {
    pub address: AccountAddress,
}

impl GetLatestAccountStateRequest {
    pub fn new(address: AccountAddress) -> Self {
        Self { address }
    }
}

impl TryFrom<crate::proto::storage::GetLatestAccountStateRequest> for GetLatestAccountStateRequest {
    type Error = Error;

    fn try_from(proto: crate::proto::storage::GetLatestAccountStateRequest) -> Result<Self> {
        let address = AccountAddress::try_from(&proto.address[..])?;
        Ok(Self::new(address))
    }
}

impl From<GetLatestAccountStateRequest> for crate::proto::storage::GetLatestAccountStateRequest {
    fn from(request: GetLatestAccountStateRequest) -> Self {
        Self {
            address: request.address.into(),
        }
    }
}

#[derive(Debug, PartialEq, Eq, Clone)]
#[cfg_attr(any(test, feature = "fuzzing"), derive(Arbitrary))]
pub struct GetLatestAccountStateResponse {
    pub account_state_blob: Option<AccountStateBlob>,
}

impl GetLatestAccountStateResponse {
    pub fn new(account_state_blob: Option<AccountStateBlob>) -> Self {
        Self { account_state_blob }
    }
}

impl TryFrom<crate::proto::storage::GetLatestAccountStateResponse>
    for GetLatestAccountStateResponse
{
    type Error = Error;

    fn try_from(proto: crate::proto::storage::GetLatestAccountStateResponse) -> Result<Self> {
        let account_state_blob = proto
            .account_state_blob
            .map(TryFrom::try_from)
            .transpose()?;
        Ok(Self::new(account_state_blob))
    }
}

impl From<GetLatestAccountStateResponse> for crate::proto::storage::GetLatestAccountStateResponse {
    fn from(response: GetLatestAccountStateResponse) -> Self {
        Self {
            account_state_blob: response.account_state_blob.map(Into::into),
        }
    }
}

/// Helper to construct and parse [`proto::storage::GetAccountStateWithProofByVersionRequest`]
#[derive(PartialEq, Eq, Clone)]
pub struct GetAccountStateWithProofByVersionRequest {
    /// The access path to query with.
    pub address: AccountAddress,

    /// The version the query is based on.
    pub version: Version,
}

impl GetAccountStateWithProofByVersionRequest {
    /// Constructor.
    pub fn new(address: AccountAddress, version: Version) -> Self {
        Self { address, version }
    }
}

impl TryFrom<crate::proto::storage::GetAccountStateWithProofByVersionRequest>
    for GetAccountStateWithProofByVersionRequest
{
    type Error = Error;

    fn try_from(
        proto: crate::proto::storage::GetAccountStateWithProofByVersionRequest,
    ) -> Result<Self> {
        let address = AccountAddress::try_from(&proto.address[..])?;
        let version = proto.version;

        Ok(Self { address, version })
    }
}

impl From<GetAccountStateWithProofByVersionRequest>
    for crate::proto::storage::GetAccountStateWithProofByVersionRequest
{
    fn from(request: GetAccountStateWithProofByVersionRequest) -> Self {
        Self {
            address: request.address.into(),
            version: request.version,
        }
    }
}

/// Helper to construct and parse [`proto::storage::GetAccountStateWithProofByVersionResponse`]
#[derive(PartialEq, Eq, Clone)]
pub struct GetAccountStateWithProofByVersionResponse {
    /// The account state blob requested.
    pub account_state_blob: Option<AccountStateBlob>,

    /// The state root hash the query is based on.
    pub sparse_merkle_proof: SparseMerkleProof,
}

impl GetAccountStateWithProofByVersionResponse {
    /// Constructor.
    pub fn new(
        account_state_blob: Option<AccountStateBlob>,
        sparse_merkle_proof: SparseMerkleProof,
    ) -> Self {
        Self {
            account_state_blob,
            sparse_merkle_proof,
        }
    }
}

impl TryFrom<crate::proto::storage::GetAccountStateWithProofByVersionResponse>
    for GetAccountStateWithProofByVersionResponse
{
    type Error = Error;

    fn try_from(
        proto: crate::proto::storage::GetAccountStateWithProofByVersionResponse,
    ) -> Result<Self> {
        let account_state_blob = proto
            .account_state_blob
            .map(AccountStateBlob::try_from)
            .transpose()?;
        Ok(Self {
            account_state_blob,
            sparse_merkle_proof: SparseMerkleProof::try_from(
                proto.sparse_merkle_proof.unwrap_or_else(Default::default),
            )?,
        })
    }
}

impl From<GetAccountStateWithProofByVersionResponse>
    for crate::proto::storage::GetAccountStateWithProofByVersionResponse
{
    fn from(response: GetAccountStateWithProofByVersionResponse) -> Self {
        Self {
            account_state_blob: response.account_state_blob.map(Into::into),
            sparse_merkle_proof: Some(response.sparse_merkle_proof.into()),
        }
    }
}

impl Into<(Option<AccountStateBlob>, SparseMerkleProof)>
    for GetAccountStateWithProofByVersionResponse
{
    fn into(self) -> (Option<AccountStateBlob>, SparseMerkleProof) {
        (self.account_state_blob, self.sparse_merkle_proof)
    }
}

/// Helper to construct and parse [`proto::storage::SaveTransactionsRequest`]
#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(any(test, feature = "fuzzing"), derive(Arbitrary))]
pub struct SaveTransactionsRequest {
    pub txns_to_commit: Vec<TransactionToCommit>,
    pub first_version: Version,
    pub ledger_info_with_signatures: Option<LedgerInfoWithSignatures>,
}

impl SaveTransactionsRequest {
    /// Constructor.
    pub fn new(
        txns_to_commit: Vec<TransactionToCommit>,
        first_version: Version,
        ledger_info_with_signatures: Option<LedgerInfoWithSignatures>,
    ) -> Self {
        SaveTransactionsRequest {
            txns_to_commit,
            first_version,
            ledger_info_with_signatures,
        }
    }
}

impl TryFrom<crate::proto::storage::SaveTransactionsRequest> for SaveTransactionsRequest {
    type Error = Error;

    fn try_from(proto: crate::proto::storage::SaveTransactionsRequest) -> Result<Self> {
        let txns_to_commit = proto
            .txns_to_commit
            .into_iter()
            .map(TransactionToCommit::try_from)
            .collect::<Result<Vec<_>>>()?;
        let first_version = proto.first_version;
        let ledger_info_with_signatures = proto
            .ledger_info_with_signatures
            .map(LedgerInfoWithSignatures::try_from)
            .transpose()?;

        Ok(Self {
            txns_to_commit,
            first_version,
            ledger_info_with_signatures,
        })
    }
}

impl From<SaveTransactionsRequest> for crate::proto::storage::SaveTransactionsRequest {
    fn from(request: SaveTransactionsRequest) -> Self {
        let txns_to_commit = request.txns_to_commit.into_iter().map(Into::into).collect();
        let first_version = request.first_version;
        let ledger_info_with_signatures = request.ledger_info_with_signatures.map(Into::into);

        Self {
            txns_to_commit,
            first_version,
            ledger_info_with_signatures,
        }
    }
}

/// Helper to construct and parse [`proto::storage::GetTransactionsRequest`]
#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(any(test, feature = "fuzzing"), derive(Arbitrary))]
pub struct GetTransactionsRequest {
    pub start_version: Version,
    pub batch_size: u64,
    pub ledger_version: Version,
    pub fetch_events: bool,
}

impl GetTransactionsRequest {
    /// Constructor.
    pub fn new(
        start_version: Version,
        batch_size: u64,
        ledger_version: Version,
        fetch_events: bool,
    ) -> Self {
        GetTransactionsRequest {
            start_version,
            batch_size,
            ledger_version,
            fetch_events,
        }
    }
}

impl TryFrom<crate::proto::storage::GetTransactionsRequest> for GetTransactionsRequest {
    type Error = Error;

    fn try_from(proto: crate::proto::storage::GetTransactionsRequest) -> Result<Self> {
        Ok(GetTransactionsRequest {
            start_version: proto.start_version,
            batch_size: proto.batch_size,
            ledger_version: proto.ledger_version,
            fetch_events: proto.fetch_events,
        })
    }
}

impl From<GetTransactionsRequest> for crate::proto::storage::GetTransactionsRequest {
    fn from(request: GetTransactionsRequest) -> Self {
        Self {
            start_version: request.start_version,
            batch_size: request.batch_size,
            ledger_version: request.ledger_version,
            fetch_events: request.fetch_events,
        }
    }
}

/// Helper to construct and parse [`proto::storage::GetTransactionsResponse`]
#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(any(test, feature = "fuzzing"), derive(Arbitrary))]
pub struct GetTransactionsResponse {
    pub txn_list_with_proof: TransactionListWithProof,
}

impl GetTransactionsResponse {
    /// Constructor.
    pub fn new(txn_list_with_proof: TransactionListWithProof) -> Self {
        GetTransactionsResponse {
            txn_list_with_proof,
        }
    }
}

impl TryFrom<crate::proto::storage::GetTransactionsResponse> for GetTransactionsResponse {
    type Error = Error;

    fn try_from(proto: crate::proto::storage::GetTransactionsResponse) -> Result<Self> {
        Ok(GetTransactionsResponse {
            txn_list_with_proof: proto
                .txn_list_with_proof
                .unwrap_or_else(Default::default)
                .try_into()?,
        })
    }
}

impl From<GetTransactionsResponse> for crate::proto::storage::GetTransactionsResponse {
    fn from(response: GetTransactionsResponse) -> Self {
        Self {
            txn_list_with_proof: Some(response.txn_list_with_proof.into()),
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(any(test, feature = "fuzzing"), derive(Arbitrary))]
pub struct TreeState {
    pub version: Version,
    pub ledger_frozen_subtree_hashes: Vec<HashValue>,
    pub account_state_root_hash: HashValue,
}

impl TreeState {
    pub fn new(
        version: Version,
        ledger_frozen_subtree_hashes: Vec<HashValue>,
        account_state_root_hash: HashValue,
    ) -> Self {
        Self {
            version,
            ledger_frozen_subtree_hashes,
            account_state_root_hash,
        }
    }
}

impl TryFrom<crate::proto::storage::TreeState> for TreeState {
    type Error = Error;

    fn try_from(proto: crate::proto::storage::TreeState) -> Result<Self> {
        let account_state_root_hash = HashValue::from_slice(&proto.account_state_root_hash[..])?;
        let ledger_frozen_subtree_hashes = proto
            .ledger_frozen_subtree_hashes
            .iter()
            .map(|x| &x[..])
            .map(HashValue::from_slice)
            .collect::<Result<Vec<_>>>()?;
        let version = proto.version;

        Ok(Self::new(
            version,
            ledger_frozen_subtree_hashes,
            account_state_root_hash,
        ))
    }
}

impl From<TreeState> for crate::proto::storage::TreeState {
    fn from(info: TreeState) -> Self {
        let account_state_root_hash = info.account_state_root_hash.to_vec();
        let ledger_frozen_subtree_hashes = info
            .ledger_frozen_subtree_hashes
            .into_iter()
            .map(|x| x.to_vec())
            .collect();
        let version = info.version;

        Self {
            version,
            ledger_frozen_subtree_hashes,
            account_state_root_hash,
        }
    }
}

/// Helper to construct and parse [`proto::storage::StartupInfo`]
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct StartupInfo {
    /// The latest ledger info.
    pub latest_ledger_info: LedgerInfoWithSignatures,
    /// If the above ledger info doesn't carry a validator set, the latest validator set. Otherwise
    /// `None`.
    pub latest_validator_set: Option<ValidatorSet>,
    pub committed_tree_state: TreeState,
    pub synced_tree_state: Option<TreeState>,
}

impl StartupInfo {
    pub fn new(
        latest_ledger_info: LedgerInfoWithSignatures,
        latest_validator_set: Option<ValidatorSet>,
        committed_tree_state: TreeState,
        synced_tree_state: Option<TreeState>,
    ) -> Self {
        Self {
            latest_ledger_info,
            latest_validator_set,
            committed_tree_state,
            synced_tree_state,
        }
    }

    pub fn get_validator_set(&self) -> &ValidatorSet {
        match self.latest_ledger_info.ledger_info().next_validator_set() {
            Some(x) => x,
            None => self
                .latest_validator_set
                .as_ref()
                .expect("Validator set must exist."),
        }
    }
}

#[cfg(any(test, feature = "fuzzing"))]
fn arb_startup_info() -> impl Strategy<Value = StartupInfo> {
    any::<LedgerInfoWithSignatures>()
        .prop_flat_map(|latest_ledger_info| {
            let latest_validator_set_strategy = if latest_ledger_info
                .ledger_info()
                .next_validator_set()
                .is_some()
            {
                Just(None).boxed()
            } else {
                any::<ValidatorSet>().prop_map(Some).boxed()
            };

            (
                Just(latest_ledger_info),
                latest_validator_set_strategy,
                any::<TreeState>(),
                any::<Option<TreeState>>(),
            )
        })
        .prop_map(
            |(
                latest_ledger_info,
                latest_validator_set,
                committed_tree_state,
                synced_tree_state,
            )| {
                StartupInfo::new(
                    latest_ledger_info,
                    latest_validator_set,
                    committed_tree_state,
                    synced_tree_state,
                )
            },
        )
}

#[cfg(any(test, feature = "fuzzing"))]
impl Arbitrary for StartupInfo {
    type Parameters = ();
    type Strategy = BoxedStrategy<Self>;

    fn arbitrary_with(_args: Self::Parameters) -> Self::Strategy {
        arb_startup_info().boxed()
    }
}

impl TryFrom<crate::proto::storage::StartupInfo> for StartupInfo {
    type Error = Error;

    fn try_from(proto: crate::proto::storage::StartupInfo) -> Result<Self> {
        let latest_ledger_info: LedgerInfoWithSignatures = proto
            .latest_ledger_info
            .ok_or_else(|| format_err!("Missing latest_ledger_info"))?
            .try_into()?;
        let latest_validator_set = proto
            .latest_validator_set
            .map(TryInto::try_into)
            .transpose()?;
        let committed_tree_state = proto
            .committed_tree_state
            .ok_or_else(|| format_err!("Missing committed_tree_state"))?
            .try_into()?;
        let synced_tree_state = proto.synced_tree_state.map(TryInto::try_into).transpose()?;

        ensure!(
            latest_ledger_info
                .ledger_info()
                .next_validator_set()
                .is_some()
                != latest_validator_set.is_some(),
            "Only one validator set should exist.",
        );

        Ok(Self {
            latest_ledger_info,
            latest_validator_set,
            committed_tree_state,
            synced_tree_state,
        })
    }
}

impl From<StartupInfo> for crate::proto::storage::StartupInfo {
    fn from(info: StartupInfo) -> Self {
        let latest_ledger_info = Some(info.latest_ledger_info.into());
        let latest_validator_set = info.latest_validator_set.map(Into::into);
        let committed_tree_state = Some(info.committed_tree_state.into());
        let synced_tree_state = info.synced_tree_state.map(Into::into);

        Self {
            latest_ledger_info,
            latest_validator_set,
            committed_tree_state,
            synced_tree_state,
        }
    }
}

/// Helper to construct and parse [`proto::storage::GetStartupInfoResponse`]
#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(any(test, feature = "fuzzing"), derive(Arbitrary))]
pub struct GetStartupInfoResponse {
    pub info: Option<StartupInfo>,
}

impl TryFrom<crate::proto::storage::GetStartupInfoResponse> for GetStartupInfoResponse {
    type Error = Error;

    fn try_from(proto: crate::proto::storage::GetStartupInfoResponse) -> Result<Self> {
        let info = proto.info.map(StartupInfo::try_from).transpose()?;

        Ok(Self { info })
    }
}

impl From<GetStartupInfoResponse> for crate::proto::storage::GetStartupInfoResponse {
    fn from(response: GetStartupInfoResponse) -> Self {
        Self {
            info: response.info.map(Into::into),
        }
    }
}

/// Helper to construct and parse [`proto::storage::GetEpochChangeLedgerInfosRequest`]
#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(any(test, feature = "fuzzing"), derive(Arbitrary))]
pub struct GetEpochChangeLedgerInfosRequest {
    pub start_epoch: u64,
    pub end_epoch: u64,
}

impl GetEpochChangeLedgerInfosRequest {
    /// Constructor.
    pub fn new(start_epoch: u64, end_epoch: u64) -> Self {
        Self {
            start_epoch,
            end_epoch,
        }
    }
}

impl TryFrom<crate::proto::storage::GetEpochChangeLedgerInfosRequest>
    for GetEpochChangeLedgerInfosRequest
{
    type Error = Error;

    fn try_from(proto: crate::proto::storage::GetEpochChangeLedgerInfosRequest) -> Result<Self> {
        Ok(Self {
            start_epoch: proto.start_epoch,
            end_epoch: proto.end_epoch,
        })
    }
}

impl From<GetEpochChangeLedgerInfosRequest>
    for crate::proto::storage::GetEpochChangeLedgerInfosRequest
{
    fn from(request: GetEpochChangeLedgerInfosRequest) -> Self {
        Self {
            start_epoch: request.start_epoch,
            end_epoch: request.end_epoch,
        }
    }
}

/// Helper to construct and parse [`proto::storage::GetEpochChangeLedgerInfosResponse`]
#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(any(test, feature = "fuzzing"), derive(Arbitrary))]
pub struct GetEpochChangeLedgerInfosResponse {
    pub ledger_infos_with_sigs: Vec<LedgerInfoWithSignatures>,
    pub more: bool,
}

impl GetEpochChangeLedgerInfosResponse {
    /// Constructor.
    pub fn new(ledger_infos_with_sigs: Vec<LedgerInfoWithSignatures>, more: bool) -> Self {
        Self {
            ledger_infos_with_sigs,
            more,
        }
    }
}

impl TryFrom<crate::proto::storage::GetEpochChangeLedgerInfosResponse>
    for GetEpochChangeLedgerInfosResponse
{
    type Error = Error;

    fn try_from(proto: crate::proto::storage::GetEpochChangeLedgerInfosResponse) -> Result<Self> {
        Ok(Self {
            ledger_infos_with_sigs: proto
                .latest_ledger_infos
                .into_iter()
                .map(TryFrom::try_from)
                .collect::<Result<Vec<_>>>()?,
            more: proto.more,
        })
    }
}

impl From<GetEpochChangeLedgerInfosResponse>
    for crate::proto::storage::GetEpochChangeLedgerInfosResponse
{
    fn from(response: GetEpochChangeLedgerInfosResponse) -> Self {
        Self {
            latest_ledger_infos: response
                .ledger_infos_with_sigs
                .into_iter()
                .map(Into::into)
                .collect(),
            more: response.more,
        }
    }
}

impl Into<(Vec<LedgerInfoWithSignatures>, bool)> for GetEpochChangeLedgerInfosResponse {
    fn into(self) -> (Vec<LedgerInfoWithSignatures>, bool) {
        (self.ledger_infos_with_sigs, self.more)
    }
}

/// Helper to construct and parse [`proto::storage::BackupAccountStateRequest`]
#[derive(PartialEq, Eq, Clone)]
pub struct BackupAccountStateRequest {
    /// The version of state to backup.
    pub version: Version,
}

impl BackupAccountStateRequest {
    /// Constructor.
    pub fn new(version: Version) -> Self {
        Self { version }
    }
}

impl TryFrom<crate::proto::storage::BackupAccountStateRequest> for BackupAccountStateRequest {
    type Error = Error;

    fn try_from(proto: crate::proto::storage::BackupAccountStateRequest) -> Result<Self> {
        Ok(Self {
            version: proto.version,
        })
    }
}

impl From<BackupAccountStateRequest> for crate::proto::storage::BackupAccountStateRequest {
    fn from(request: BackupAccountStateRequest) -> Self {
        Self {
            version: request.version,
        }
    }
}

/// Helper to construct and parse [`proto::storage::BackupAccountStateResponse`]
#[derive(PartialEq, Eq, Clone)]
pub struct BackupAccountStateResponse {
    /// The hashed account address
    pub account_key: HashValue,

    /// The accompanying account state blob
    pub account_state_blob: AccountStateBlob,
}

impl BackupAccountStateResponse {
    /// Constructor.
    pub fn new(account_key: HashValue, account_state_blob: AccountStateBlob) -> Self {
        Self {
            account_key,
            account_state_blob,
        }
    }
}

impl TryFrom<crate::proto::storage::BackupAccountStateResponse> for BackupAccountStateResponse {
    type Error = Error;

    fn try_from(proto: crate::proto::storage::BackupAccountStateResponse) -> Result<Self> {
        let account_key = HashValue::from_slice(&proto.account_key[..])?;
        let account_state_blob = proto
            .account_state_blob
            .ok_or_else(|| format_err!("Missing account state blob"))?
            .try_into()?;
        Ok(Self {
            account_key,
            account_state_blob,
        })
    }
}

impl From<BackupAccountStateResponse> for crate::proto::storage::BackupAccountStateResponse {
    fn from(response: BackupAccountStateResponse) -> Self {
        Self {
            account_key: response.account_key.to_vec(),
            account_state_blob: Some(response.account_state_blob.into()),
        }
    }
}

impl Into<(HashValue, AccountStateBlob)> for BackupAccountStateResponse {
    fn into(self) -> (HashValue, AccountStateBlob) {
        (self.account_key, self.account_state_blob)
    }
}

pub mod prelude {
    pub use super::*;
}

#[cfg(test)]
mod tests;
