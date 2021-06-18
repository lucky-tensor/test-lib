// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{errors::*, parser::syntax::make_loc};
use move_ir_types::location::*;

pub fn decode(loc: Loc, s: &str) -> Result<Vec<u8>, Errors> {
    match hex::decode(s) {
        Ok(vec) => Ok(vec),
        Err(hex::FromHexError::InvalidHexCharacter { c, index }) => {
            let filename = loc.file();
            let start_offset = loc.span().start().0 as usize;
            let offset = start_offset + 2 + index;
            let loc = make_loc(filename, offset, offset);
            Err(Errors::from(vec![vec![(
                loc,
                format!("Invalid hexadecimal character: '{}'", c),
            )]]))
        }
        Err(hex::FromHexError::OddLength) => Err(Errors::from(vec![vec![(
            loc,
            "Odd number of characters in hex string. Expected 2 hexadecimal digits for each byte"
                .to_string(),
        )]])),
        Err(_) => unreachable!("unexpected error parsing hex byte string value"),
    }
}
