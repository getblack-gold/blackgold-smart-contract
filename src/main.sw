contract;
use std::collections::HashMap;

storage {
    user_to_tokens: StorageMap<Address, u64> = StorageMap {},
}


abi BlackGold {
    fn update_user_tokens(user: Address);
}


impl BlackGold for Contract {
    #[storage(read, write)]
    fn update_user_tokens(user: Address) -> bool {

        if storage.user_to_tokens.get(user).try_read().unwrap_or(0);
    }
}