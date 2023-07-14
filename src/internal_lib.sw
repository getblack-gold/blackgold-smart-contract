library;

use std::storage::storage_vec::*;

pub struct Organisation {
    id: u64,
    owner: str[40],
    member_limit: u64,
    exists: bool,
}
