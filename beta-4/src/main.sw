contract;

mod internal_lib;

use ::internal_lib::Organisation;

use std::auth::{ AuthError, msg_sender };
use std::hash::{keccak256, sha256}; 
use std::logging::log;


storage {
    shop_id_to_organisation_struct: StorageMap<u64, Organisation> = StorageMap {},
    organisation_id_to_sellers: StorageMap<u64, StorageVec<str[1]>> = StorageMap {},
    organisation_counter: u64 = 0,
    user_org_to_points: StorageMap<(Identity, u64), u64> = StorageMap {},
    organisation_id_to_tier_points: StorageMap<u64, StorageVec<(str[1], (u64, u64))>> = StorageMap {},
}





abi BlackGold {
    #[storage(read, write)]
    fn retrieve_all_sellers_from_org(id: u64) -> Vec<str[1]>;


    #[storage(read, write)]
    fn new_organisation(creator_id: str[40]);

    #[storage(read)]
    fn get_organisation(org_id: u64) -> Organisation;

   /* #[storage(read)]
    fn get_organisation_seller(index: u64, org: str[40]) -> bool;*/


    #[storage(read, write)]
    fn push_new_seller_to_org(id: u64, seller: str[1]);

    #[storage(read, write)]
    fn update_user_to_org(id: u64, new_value: u64) -> u64;

    #[storage(read,write)]
    fn user_use_points(id: u64, points_spent: u64) -> u64;

    #[storage(read, write)]
    fn remove_seller_from_org(org_id: u64, user_index: u64);

}


impl BlackGold for Contract {
    //Retrieves all sellers currently in the organisation
    #[storage(read, write)]
    fn retrieve_all_sellers_from_org(id: u64) -> Vec<str[1]> {
        let mut vector_sellers: Vec<str[1]> = Vec::new();
        let mut sellers = storage.organisation_id_to_sellers.get(id);
        let mut i = 0;
        while i < sellers.len() {
            vector_sellers.push(sellers.get(i).unwrap().read());
            i += 1;
        }
        return vector_sellers;
    }



    #[storage(read, write)]
    fn user_use_points(id: u64, points_spent: u64) -> u64 {
        let user_points = storage.user_org_to_points.get((msg_sender().unwrap() ,id)).try_read().unwrap_or(0);
        let user_points_updated = user_points - points_spent; 
        storage.user_org_to_points.insert((msg_sender().unwrap(), id), user_points_updated);
        return user_points_updated;
    }

    #[storage(read, write)]
    fn update_user_to_org(id: u64, new_value: u64) -> u64 {
        let user_point = storage.user_org_to_points.get((msg_sender().unwrap() ,id)).try_read().unwrap_or(0);
        let user_points_updated = user_point + new_value; 
        storage.user_org_to_points.insert((msg_sender().unwrap(), id), user_points_updated);
        return user_points_updated;
    }

    #[storage(read, write)]
    fn push_new_seller_to_org(id: u64, seller: str[1]) {
        storage.organisation_id_to_sellers.get(id).push(seller); 
    }

    //Creates a new org and adds to (user can have multiple of them)
    #[storage(read, write)]
    fn new_organisation(creator_id: str[40]) {
        storage.organisation_counter.write(storage.organisation_counter.read() + 1);
        let mut org = Organisation {
            id: storage.organisation_counter.read(),
            owner: creator_id,
            member_limit: 10,
            exists: true,
        };
        let sellers: StorageVec<str[1]> =  StorageVec {};
        
        storage.organisation_id_to_sellers.insert(storage.organisation_counter.read(), sellers);
        storage.shop_id_to_organisation_struct.insert(storage.organisation_counter.read(), org);

    }



    #[storage(read)]
    fn get_organisation(org_id: u64) -> Organisation {
        return storage.shop_id_to_organisation_struct.get(org_id).read();
    }

    //function that is going to be used both for kicking the seller and him leaving the group
    #[storage(read, write)]
    fn remove_seller_from_org(org_id: u64, user_index: u64) {
        
/*      let org_vec = storage.organisation_id_to_sellers.get(org_id);
        let mut i = 0;
        while i < org_vec.len() {
            let seller = org_vec.get(i).unwrap().read();
            if seller == user_id {
                */
                storage.organisation_id_to_sellers.get(org_id).remove(user_index);
          //  }

       // } 
    }

   /* #[storage(read, write)]
    add_tier_points(org_id: u64, new_tier: Vec<(str[1], (u64, u64))>){
        let mut i = 0;
        while i < storage.organisation_id_to_tier_points.len() {
            storage.organisation_id_to_tier_points.insert(new_tier.get(i));
        }
    }*/

}

#[test]
fn test_success_add_org() {
    let caller = abi(BlackGold, CONTRACT_ID);
    let result = caller.new_organisation {}("This is adasdfg string of 40 characters.");
    let org = caller.get_organisation(1);
    assert(org.exists == true);
}

#[test]
fn test_update_struct_values() {
    let caller = abi(BlackGold, CONTRACT_ID);
    let result = caller.new_organisation {}("This is adasdfg string of 40 characters.");
    let org = caller.get_organisation(1);
}


#[test]
fn test_push_func() { 
    let caller = abi(BlackGold, CONTRACT_ID);
    let result = caller.new_organisation {}("This is adasdfg string of 40 characters.");
    caller.push_new_seller_to_org(1, "a");
}