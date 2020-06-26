// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

//
// Noise Fuzzing
// =============
//
// This fuzzes the wrappers we have around our Noise library.
//

use crate::{
    noise::{AntiReplayTimestamps, HandshakeAuthMode, NoiseUpgrader},
    testutils::fake_socket::{ReadOnlyTestSocket, ReadWriteTestSocket},
};
use futures::{executor::block_on, future::join};
use libra_crypto::{test_utils::TEST_SEED, x25519, Uniform as _};
use libra_types::PeerId;
use once_cell::sync::Lazy;
use rand_core::SeedableRng;

//
// Corpus generation
// =================
//
// - KEYPAIR: a unique keypair for fuzzing
// - generate_first_two_messages: it will generate the first or second message in the handshake.
// - generate_corpus: the function called by our fuzzer to retrieve the corpus.
//

// let's cache the deterministic keypairs
pub static KEYPAIRS: Lazy<(
    (x25519::PrivateKey, x25519::PublicKey, PeerId),
    (x25519::PrivateKey, x25519::PublicKey, PeerId),
)> = Lazy::new(|| {
    let mut rng = ::rand::rngs::StdRng::from_seed(TEST_SEED);

    let initiator_private_key = x25519::PrivateKey::generate(&mut rng);
    let initiator_public_key = initiator_private_key.public_key();
    let initiator_peer_id = PeerId::from_identity_public_key(initiator_public_key);

    let responder_private_key = x25519::PrivateKey::generate(&mut rng);
    let responder_public_key = responder_private_key.public_key();
    let responder_peer_id = PeerId::from_identity_public_key(responder_public_key);

    (
        (
            initiator_private_key,
            initiator_public_key,
            initiator_peer_id,
        ),
        (
            responder_private_key,
            responder_public_key,
            responder_peer_id,
        ),
    )
});

fn generate_first_two_messages() -> (Vec<u8>, Vec<u8>) {
    // build
    let (
        (initiator_private_key, initiator_public_key, initiator_peer_id),
        (responder_private_key, responder_public_key, responder_peer_id),
    ) = KEYPAIRS.clone();

    let initiator = NoiseUpgrader::new(
        initiator_peer_id,
        initiator_private_key,
        HandshakeAuthMode::ServerOnly,
    );
    let responder = NoiseUpgrader::new(
        responder_peer_id,
        responder_private_key,
        HandshakeAuthMode::ServerOnly,
    );

    // create exposing socket
    let (mut initiator_socket, mut responder_socket) = ReadWriteTestSocket::new_pair();
    let mut init_msg = Vec::new();
    let mut resp_msg = Vec::new();
    initiator_socket.save_writing(&mut init_msg);
    responder_socket.save_writing(&mut resp_msg);

    // perform the handshake
    let (initiator_session, responder_session) = block_on(join(
        initiator.upgrade_outbound(initiator_socket, responder_public_key, fake_timestamp),
        responder.upgrade_inbound(responder_socket),
    ));

    // take result
    let initiator_session = initiator_session.unwrap();
    let (responder_session, peer_id) = responder_session.unwrap();

    // some sanity checks
    assert_eq!(initiator_session.get_remote_static(), responder_public_key);
    assert_eq!(responder_session.get_remote_static(), initiator_public_key);
    assert_eq!(initiator_peer_id, peer_id);

    (init_msg, resp_msg)
}

pub fn generate_corpus(gen: &mut libra_proptest_helpers::ValueGenerator) -> Vec<u8> {
    let (init_msg, resp_msg) = generate_first_two_messages();
    // choose a random one
    let strategy = proptest::arbitrary::any::<bool>();
    if gen.generate(strategy) {
        init_msg
    } else {
        resp_msg
    }
}

//
// Fuzzing
// =======
//
// - fuzz_initiator: fuzzes the second message of the handshake, received by the initiator.
// - fuzz_responder: fuzzes the first message of the handshake, received by the responder.
//

/// let's provide the same timestamp everytime, faster
fn fake_timestamp() -> [u8; AntiReplayTimestamps::TIMESTAMP_SIZE] {
    [0u8; AntiReplayTimestamps::TIMESTAMP_SIZE]
}

pub fn fuzz_initiator(data: &[u8]) {
    // setup initiator
    let ((initiator_private_key, _, initiator_peer_id), (_, responder_public_key, _)) =
        KEYPAIRS.clone();
    let initiator = NoiseUpgrader::new(
        initiator_peer_id,
        initiator_private_key,
        HandshakeAuthMode::ServerOnly,
    );

    // setup NoiseStream
    let mut fake_socket = ReadOnlyTestSocket::new(data);
    fake_socket.set_trailing();

    // send a message, then read fuzz data
    let _ = block_on(initiator.upgrade_outbound(fake_socket, responder_public_key, fake_timestamp));
}

pub fn fuzz_responder(data: &[u8]) {
    // setup responder
    let (_, (responder_private_key, _, responder_peer_id)) = KEYPAIRS.clone();
    let responder = NoiseUpgrader::new(
        responder_peer_id,
        responder_private_key,
        HandshakeAuthMode::ServerOnly,
    );

    // setup NoiseStream
    let mut fake_socket = ReadOnlyTestSocket::new(data);
    fake_socket.set_trailing();

    // read fuzz data
    let _ = block_on(responder.upgrade_inbound(fake_socket));
}

//
// Tests
// =====
//
// To ensure fuzzers will not break, this test the fuzzers.
//

#[test]
fn test_noise_fuzzer() {
    let (init_msg, resp_msg) = generate_first_two_messages();
    fuzz_responder(&init_msg);
    fuzz_initiator(&resp_msg);
}
