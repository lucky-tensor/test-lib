// Copyright 2018 Chia Network Inc and POA Networks, Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// and limitations under the License.

//! Creation of discriminants.
//!
//! The `pot` tool does not accept a discriminant as a command-line argument.
//! Instead, it generates the discriminant from a (much smaller) seed.  This file
//! implements this process.  The table of precomputed constants used is generated by
//! `build.rs`.

#![forbid(warnings)]

include!(concat!(env!("OUT_DIR"), "/constants.rs"));

use super::gmp_classgroup::ffi::{mpz_add_ui_self, mpz_rem_u16};
use gmp::mpz::Mpz;
use sha2::{digest::FixedOutput, Digest, Sha256};
use std::mem;
use std::u16;

fn entropy_from_seed(seed: &[u8], byte_count: usize) -> Vec<u8> {
    let mut blob = Vec::with_capacity(byte_count);
    let mut extra: u16 = 0;
    while blob.len() < byte_count {
        let mut hasher = Sha256::new();
        hasher.input(seed);
        let extra_bits: [u8; 2] = unsafe { mem::transmute(extra.to_be()) };
        hasher.input(&extra_bits);
        blob.extend_from_slice(&hasher.fixed_result()[..]);
        assert!(byte_count >= blob.len() || extra < u16::MAX);
        extra += 1;
    }
    blob.resize(byte_count, 0);
    blob
}

pub fn create_discriminant(seed: &[u8], length: u16) -> Mpz {
    let extra: u8 = (length as u8) & 7;
    let entropy_bytes = ((length >> 3) + if extra == 0 { 2 } else { 3 }) as usize;
    let mut entropy = entropy_from_seed(seed, entropy_bytes);
    assert_eq!(entropy.len(), entropy_bytes);
    let residue = {
        let last_2 = &mut entropy[entropy_bytes - 2..];
        let numerator = (usize::from(last_2[0]) << 8) + usize::from(last_2[1]);
        RESIDUES[numerator % RESIDUES.len()]
    };
    let orig_n = Mpz::from(&entropy[..entropy_bytes as usize - 2usize]);
    drop(entropy);
    let mut n: Mpz = &orig_n >> ((8 - extra) & 7).into();
    n.setbit((length - 1) as _);
    {
        let q: Mpz = M.into();
        let r: Mpz = &n % q;
        n -= r;
    }
    {
        mpz_add_ui_self(&mut n, residue);
    }
    loop {
        let mut sieve = Vec::with_capacity(1 << 16);
        sieve.resize(1 << 16, false);
        for &(p, q) in SIEVE_INFO.iter() {
            let mut i: usize = (mpz_rem_u16(&n, p) as usize * q as usize) % p as usize;
            while i < sieve.len() {
                sieve[i] = true;
                i += p as usize;
            }
        }
        for (i, &x) in sieve.iter().enumerate() {
            let i = i as u32;
            if !x {
                let mut res: Mpz = (u64::from(M) * u64::from(i)).into();
                res += &n;
                if res.probab_prime(50) != gmp::mpz::ProbabPrimeResult::NotPrime {
                    return -res;
                }
            }
        }
        n += (u64::from(M) * (1 << 16)) as u64
    }
}

#[cfg(test)]
mod test {
    use super::*;
    #[test]
    fn check_discriminant() {
        use std::str::FromStr;

        assert_eq!(
            create_discriminant(b"\xaa", 40),
            (-685_537_176_559i64).into()
        );
        assert_eq!(create_discriminant(b"\xaa", 2048), -Mpz::from_str("20149392707186525162590355071292053575364559848351567085354700987844093330948936280039379742871107183330808146182415920691586415080574829617024503722195777232804427670557174581127121229242207584973924825787037130000131358603651587961876409377224876056238680407347843315752681629521613772380379341182886747008940959623895895000737071932595957989286658892888724991242968836440986789551081768017186919005412288127429935094766982059615711599441803409172888758437372755538407566562462485676644100997464269306675140005421720998149066720895066941777378563169387978299301916769407006303085854796535778826115224633447713584423").unwrap());
    }
    #[test]
    fn check_entropy() {
        assert_eq!(&entropy_from_seed(b"\xaa", 7), b"\x9f\x9d*\xe5\xe7<\xcb");
        assert_eq!(&entropy_from_seed(b"\xaa", 258)[..], &b"\x9f\x9d*\xe5\xe7<\xcbq\xa4q\x8e\xbc\xf0\xe3:\xa2\x98\xf8\xbd\xdc\xaa\xcbi\xcb\x10\xff\x0e\xafv\xdb\xec!\xc4K\xc6Jf\xf3\xa5\xda.7\xb7\xef\x87I\x85\xb8YX\xfc\xf2\x03\xa1\x8f4\xaf`\xab\xae]n\xcc,g1\x12EI\xc7\xd5\xe2\xfc\x8b\x9a\xde\xd5\xf3\x8f'\xcd\x08\x0fU\xc7\xee\xa85[>\x87]\x07\x82\x00\x13\xce\xf7\xc3/@\xef\x08v\x8f\x85\x87dm(1\x8b\xd9w\xffA]xzY\xa0,\xebz\xff\x03$`\x91\xb66\x88-_\xa9\xf1\xc5\x8e,\x15\xae\x8f\x04\rvhnU3f\x84[{$\xa6l\x95w\xa9\x1f\xba\xa8)\x05\xe6\x8f\x167o\x11/X\x9cl\xab\x9c\xcb}\xec\x88\xf8\xa5\xabXpY\xb0\x88\xed@r\x05\xba\\\x03\xf6\x91\xf8\x03\xca\x18\x1c\xcdH\x1c\x91\xe1V\xed;\x94oJ\xa8 \xa4\x97\xb7K\xce\xc4e\xea\xa2\xbf\x8b\x1f\x90\x87\xc8\x15\xee\x0e\x0fPC:\xb5\xe1g\x97\xea/_\x86c\xaf\x12Wp\xfd\x11\xdb\x17\xe6\x9f\xa5\x8a"[..]);
    }
}
