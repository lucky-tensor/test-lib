//! Genesis storage context. 

// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

// NOTE: This is duplicated from vm-genesis/src/genesis_context.rs
// it's private over there.
#![forbid(unsafe_code)]

use anyhow::Result;
use diem_state_view::StateView;
use diem_types::access_path::AccessPath;
use move_core_types::language_storage::ModuleId;
use std::collections::HashMap;

// `StateView` has no data given we are creating the genesis
/// Genesis state view.
pub struct GenesisStateView {
    data: HashMap<AccessPath, Vec<u8>>,
}
///
impl GenesisStateView {
    ///
    pub fn new() -> Self {
        Self {
            data: HashMap::new(),
        }
    }
    ///
    pub fn add_module(&mut self, module_id: &ModuleId, blob: &[u8]) {
        let access_path = AccessPath::from(module_id);
        self.data.insert(access_path, blob.to_vec());
    }
}

impl StateView for GenesisStateView {
    fn get(&self, access_path: &AccessPath) -> Result<Option<Vec<u8>>> {
        Ok(self.data.get(access_path).cloned())
    }

    fn is_genesis(&self) -> bool {
        true
    }
}