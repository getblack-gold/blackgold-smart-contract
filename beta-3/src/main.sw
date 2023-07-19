contract;
use std::auth::{ AuthError, msg_sender };
use std::hash::{keccak256, sha256}; 
use std::logging::log;


enum SellerType {
    Store: (),
    Organisation: (),
}

abi BlackGold {

    //functions for organisations
    #[storage(read, write)]
    fn new_organisation(creator_id: str[1], owner: str[1], stores: (str[1], str[1], str[1], str[1], str[1]));

    #[storage(read)]
    fn get_org(org_id: u64) -> Organisation;
    //functions from user to org
    #[storage(read, write)]
    fn user_org_update_points(id: u64, points_spent: u64, seller_type: SellerType) -> u64;

    #[storage(read,write)]
    fn user_spend_points(id: u64, points_spent: u64, seller_type: SellerType) -> u64;

    #[storage(read, write)]
    fn update_org(org_id: u64, owner: str[1] , stores: (str[1], str[1], str[1], str[1], str[1]), exists: bool);
}



pub struct Organisation {
    id: u64,
    owner: str[1],
    stores: (str[1], str[1], str[1], str[1], str[1]),
    exists: bool,
}

storage {
    organisation_counter: u64 = 0,
    id_to_organisation: StorageMap<u64, Organisation> = StorageMap {},
    user_seller_to_points: StorageMap<(Identity,SellerType,u64), u64> = StorageMap {},
}

impl BlackGold for Contract {
    #[storage(read, write)]
    fn new_organisation(creator_id: str[1], owner: str[1] , stores: (str[1], str[1], str[1], str[1], str[1])) {
        storage.organisation_counter += 1;
        let new_org: Organisation = Organisation {
            id: storage.organisation_counter,
            owner: owner,
            stores: stores,
            exists: true,
        };
        storage.id_to_organisation.insert(storage.organisation_counter, new_org);

    }
    #[storage(read)]
    fn get_org(org_id: u64) -> Organisation {
        return storage.id_to_organisation.get(org_id).unwrap();
    }

    #[storage(read, write)]
    fn user_org_update_points(id: u64, points_added: u64, seller_type: SellerType) -> u64 {
        let points = storage.user_seller_to_points.get((msg_sender().unwrap(), seller_type, id)).unwrap_or(0);
        let user_points_updated = points + points_added;
        storage.user_seller_to_points.insert((msg_sender().unwrap(), seller_type, id), user_points_updated);
        return user_points_updated;
    }

   #[storage(read,write)]
   fn user_spend_points(id: u64, points_spent: u64, seller_type: SellerType) -> u64 {
        let points = storage.user_seller_to_points.get((msg_sender().unwrap(), seller_type, id)).unwrap_or(0);
        let user_points_spent = points - points_spent; 
        storage.user_seller_to_points.insert((msg_sender().unwrap(), seller_type, id ), user_points_spent);
        return user_points_spent;
   }

   #[storage(read, write)]
   fn update_org(org_id: u64, owner: str[1] , stores: (str[1], str[1], str[1], str[1], str[1]), exists: bool) {
        let updated_org: Organisation = Organisation {
            id: org_id,
            owner: owner,
            stores: stores,
            exists: true,
        };
        storage.id_to_organisation.insert(org_id, updated_org);
   }




}
