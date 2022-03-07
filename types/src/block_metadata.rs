// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{
    account_address::AccountAddress,
    account_config::diem_root_address,
    event::{EventHandle, EventKey},
};
use diem_crypto::HashValue;
use move_core_types::{
    ident_str,
    identifier::IdentStr,
    move_resource::{MoveResource, MoveStructType},
};
use once_cell::sync::Lazy;
use serde::{Deserialize, Serialize};

/// Struct that will be persisted on chain to store the information of the current block.
///
/// The flow will look like following:
/// 1. The executor will pass this struct to VM at the end of a block proposal.
/// 2. The VM will use this struct to create a special system transaction that will emit an event
///    represents the information of the current block. This transaction can't
///    be emitted by regular users and is generated by each of the validators on the fly. Such
///    transaction will be executed before all of the user-submitted transactions in the blocks.
/// 3. Once that special resource is modified, the other user transactions can read the consensus
///    info by calling into the read method of that resource, which would thus give users the
///    information such as the current leader.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct BlockMetadata {
    id: HashValue,
    round: u64,
    timestamp_usecs: u64,
    // The vector has to be sorted to ensure consistent result among all nodes
    previous_block_votes: Vec<AccountAddress>,
    proposer: AccountAddress,
}

impl BlockMetadata {
    pub fn new(
        id: HashValue,
        round: u64,
        timestamp_usecs: u64,
        previous_block_votes: Vec<AccountAddress>,
        proposer: AccountAddress,
    ) -> Self {
        Self {
            id,
            round,
            timestamp_usecs,
            previous_block_votes,
            proposer,
        }
    }

    pub fn id(&self) -> HashValue {
        self.id
    }

    pub fn into_inner(self) -> (u64, u64, Vec<AccountAddress>, AccountAddress) {
        (
            self.round,
            self.timestamp_usecs,
            self.previous_block_votes.clone(),
            self.proposer,
        )
    }

    pub fn timestamp_usec(&self) -> u64 {
        self.timestamp_usecs
    }

    pub fn proposer(&self) -> AccountAddress {
        self.proposer
    }

    pub fn previous_block_votes(&self) -> &Vec<AccountAddress> {
        &self.previous_block_votes
    }

    pub fn round(&self) -> u64 {
        self.round
    }
}

pub fn new_block_event_key() -> EventKey {
    EventKey::new_from_address(&diem_root_address(), 12) /////// 0L /////////
}

/// The path to the new block event handle under a DiemBlock::BlockMetadata resource.
pub static NEW_BLOCK_EVENT_PATH: Lazy<Vec<u8>> = Lazy::new(|| {
    let mut path = DiemBlockResource::resource_path();
    // it can be anything as long as it's referenced in AccountState::get_event_handle_by_query_path
    path.extend_from_slice(b"/new_block_event/");
    path
});

#[derive(Deserialize, Serialize)]
pub struct DiemBlockResource {
    height: u64,
    new_block_events: EventHandle,
}

impl DiemBlockResource {
    pub fn new_block_events(&self) -> &EventHandle {
        &self.new_block_events
    }

    pub fn height(&self) -> u64 {
        self.height
    }
}

impl MoveStructType for DiemBlockResource {
    const MODULE_NAME: &'static IdentStr = ident_str!("DiemBlock");
    const STRUCT_NAME: &'static IdentStr = ident_str!("BlockMetadata");
}

impl MoveResource for DiemBlockResource {}

#[derive(Clone, Deserialize, Serialize)]
pub struct NewBlockEvent {
    round: u64,
    proposer: AccountAddress,
    votes: Vec<AccountAddress>,
    timestamp: u64,
}

impl NewBlockEvent {
    pub fn new(
        round: u64,
        proposer: AccountAddress,
        votes: Vec<AccountAddress>,
        timestamp: u64,
    ) -> Self {
        Self {
            round,
            proposer,
            votes,
            timestamp,
        }
    }
    pub fn round(&self) -> u64 {
        self.round
    }

    pub fn proposer(&self) -> AccountAddress {
        self.proposer
    }

    pub fn votes(&self) -> Vec<AccountAddress> {
        self.votes.clone()
    }
}
