use diem_crypto::HashValue;
use move_binary_format::errors::PartialVMResult;
use move_vm_types::{
    gas_schedule::NativeCostIndex,
    loaded_data::runtime_types::Type,
    natives::function::{native_gas, NativeContext, NativeResult},
    values::Value,
};
use sha2::{Digest, Sha256};
use smallvec::smallvec;
use std::collections::VecDeque;


pub fn verify_merkle_sha3(
    context: &impl NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    debug_assert!(_ty_args.is_empty());
    debug_assert!(arguments.len() == 1);

    let hash_arg = pop_arg!(arguments, Vec<u8>);

    let cost = native_gas(
        context.cost_table(),
        NativeCostIndex::MERKLE,
        hash_arg.len(),
    );

    let hash_vec = HashValue::sha3_256_of(hash_arg.as_slice()).to_vec();
    Ok(NativeResult::ok(
        cost,
        smallvec![Value::vector_u8(hash_vec)],
    ))
}
