// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

//! This file defines system store APIs that operates data not part of the Diem core data
//! structures but information with regard to system running status, statistics, etc.

use crate::{
    ledger_counters::{LedgerCounterBumps, LedgerCounters},
    schema::ledger_counters::LedgerCountersSchema,
};
use anyhow::Result;
use diem_logger::prelude::*;
use diem_types::transaction::Version;
use schemadb::{SchemaBatch, DB};
use std::sync::Arc;

#[derive(Debug)]
pub(crate) struct SystemStore {
    db: Arc<DB>,
}

impl SystemStore {
    pub fn new(db: Arc<DB>) -> Self {
        Self { db }
    }

    /// Increase ledger counters.
    ///
    /// The base values are read out of db, to which the `diff` is combined to, and the result is
    /// stored to the db, keyed by `last_version`.
    pub fn bump_ledger_counters(
        &self,
        first_version: Version,
        last_version: Version,
        bumps: LedgerCounterBumps,
        batch: &mut SchemaBatch,
    ) -> Result<LedgerCounters> {
        assert!(first_version <= last_version);

        let mut counters = if first_version > 0 {
            let base_version = first_version - 1;
            if let Some(counters) = self.db.get::<LedgerCountersSchema>(&base_version)? {
                counters
            } else {
                warn!(
                    base_version = base_version,
                    "Base version ledger counters not found. Assuming zeros.",
                );
                LedgerCounters::new()
            }
        } else {
            LedgerCounters::new()
        };

        counters.bump(bumps);
        batch.put::<LedgerCountersSchema>(&last_version, &counters)?;

        Ok(counters)
    }
}

#[cfg(test)]
mod test;
