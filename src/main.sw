contract;

use std::auth::{ AuthError, msg_sender , };


storage {
    user_to_tokens: StorageMap<Identity, u64> = StorageMap {},
}


abi BlackGold {
    #[storage(read, write)]
    fn update_user_tokens(token_amount: u64);
    #[storage(read)]
    fn read_user_tokens() -> (u64);
    #[storage(read, write)]
    fn points_spent(points: u64) -> (u64);

}


impl BlackGold for Contract {
    //Will create a function that checks if the message sender is ok


    #[storage(read, write)]
    fn update_user_tokens(token_amount: u64) {
        std::logging::log("Hello there");

        let mut amount: Option<u64>  = storage.user_to_tokens.get(msg_sender().unwrap());
        
        if amount.unwrap_or(0) == 0 {
            storage.user_to_tokens.insert(msg_sender().unwrap() , token_amount)
        }
        else {
            let updated_amount = amount.unwrap() + token_amount;
            storage.user_to_tokens.insert(msg_sender().unwrap(), updated_amount);
        }
    }
    #[storage(read)]
    fn read_user_tokens() -> (u64) {
        let user_token = storage.user_to_tokens.get(msg_sender().unwrap());
        return user_token.unwrap();
    }

    #[storage(read, write)]
    fn points_spent(points: u64) -> (u64) {
        let amount: Option<u64>  = storage.user_to_tokens.get(msg_sender().unwrap());
        if amount.unwrap_or(0) >= points {
            let new_amount = amount.unwrap() - points;
            storage.user_to_tokens.insert(msg_sender().unwrap(), new_amount);
            return new_amount;
        }
        return amount.unwrap();
    }
    
}