// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{
    CryptoStorage, Error, GetResponse, GitHubStorage, InMemoryStorage, KVStorage,
    NamespacedStorage, OnDiskStorage, PublicKeyResponse, Value, VaultStorage,
};
use enum_dispatch::enum_dispatch;
use libra_crypto::{
    ed25519::{Ed25519PrivateKey, Ed25519PublicKey, Ed25519Signature},
    HashValue,
};

/// This is the Libra interface into secure storage. Any storage engine implementing this trait
/// should support both key/value operations (e.g., get, set and create) and cryptographic key
/// operations (e.g., generate_key, sign_message and rotate_key).

/// This is a hack that allows us to convert from SecureBackend into a useable
/// T: Storage. This boilerplate can be 100% generated by a proc macro.
#[enum_dispatch(KVStorage, CryptoStorage)]
pub enum BoxedStorage {
    GitHubStorage(GitHubStorage),
    VaultStorage(VaultStorage),
    InMemoryStorage(InMemoryStorage),
    NamespacedStorage(NamespacedStorage),
    OnDiskStorage(OnDiskStorage),
}
