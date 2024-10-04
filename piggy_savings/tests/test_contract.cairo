use starknet::{ContractAddress};

use snforge_std::{declare, ContractClassTrait, start_cheat_caller_address, stop_cheat_caller_address};

use piggy_savings::interfaces::piggy_bank_factory_interface::IPiggyBankFactoryDispatcher;
use piggy_savings::interfaces::piggy_bank_factory_interface::IPiggyBankFactoryDispatcherTrait;
use core::byte_array::ByteArray;

fn deploy_contract(name: ByteArray) -> (ContractAddress, ContractAddress) {
    let owner: ContractAddress = starknet::contract_address_const::<0x123456789>();

    let mut constructor_calldata = ArrayTrait::new();
    constructor_calldata.append(owner.into());

    let contract = declare(name).unwrap();
    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();

    (contract_address, owner)
}

#[test]
fn test_constructor() {

    let (contract_address, owner) = deploy_contract("PiggyBankFactory");

    let piggy_factory = IPiggyBankFactoryDispatcher { contract_address };

    let contract_owner = piggy_factory.owner();

    assert(contract_owner == owner, 'Owner failed to set');
}

#[test]
#[should_panic(expected: ("dev address not initialized",))]
fn test_create_piggy_bank_should_panic_when_not_init_dev_address() {
    let piggy_bank_class = declare("PiggyBank").unwrap();

    let saving_purpose = "Buy a House";
    let time_lock = 36800;

    let (contract_address, _) = deploy_contract("PiggyBankFactory");

    let piggy_factory = IPiggyBankFactoryDispatcher { contract_address };

    piggy_factory.create_piggy_bank(piggy_bank_class.class_hash, saving_purpose, time_lock);
}

#[test]
fn test_create_piggy_bank() {
    let piggy_bank_class = declare("PiggyBank").unwrap();

    let saving_purpose = "Buy a House";
    let time_lock: u256 = 36800_u256;

    let (contract_address, owner) = deploy_contract("PiggyBankFactory");

    let piggy_factory = IPiggyBankFactoryDispatcher { contract_address };

    start_cheat_caller_address(contract_address, owner);

    let dev_address: ContractAddress =  0x03af13f04C618e7824b80b61e141F5b7aeDB07F5CCe3aD16Dbd8A4BE333A3Ffa.try_into().unwrap();
    piggy_factory.init_dev_address(dev_address);

    stop_cheat_caller_address(contract_address);

    piggy_factory.create_piggy_bank(piggy_bank_class.class_hash, saving_purpose, time_lock);

    let total_bank_count = piggy_factory.total_bank_count();

    assert(total_bank_count == 1, 'Failed to create bank');
}
