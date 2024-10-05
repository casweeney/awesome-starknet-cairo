use starknet::{ContractAddress};

use snforge_std::{declare, ContractClassTrait, start_cheat_caller_address, stop_cheat_caller_address};

use piggy_savings::interfaces::piggy_bank_factory_interface::IPiggyBankFactoryDispatcher;
use piggy_savings::interfaces::piggy_bank_factory_interface::IPiggyBankFactoryDispatcherTrait;
use piggy_savings::interfaces::piggy_bank_interface::IPiggyBankDispatcher;
use piggy_savings::interfaces::piggy_bank_interface::IPiggyBankDispatcherTrait;
use piggy_savings::interfaces::erc20_interface::IERC20Dispatcher;
use piggy_savings::interfaces::erc20_interface::IERC20DispatcherTrait;
use core::byte_array::ByteArray;

fn deploy_contract(name: ByteArray) -> (ContractAddress, ContractAddress) {
    let owner: ContractAddress = starknet::contract_address_const::<0x123456789>();

    let mut constructor_calldata = ArrayTrait::new();
    constructor_calldata.append(owner.into());

    let contract = declare(name).unwrap();
    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();

    (contract_address, owner)
}

fn deploy_erc20_contract(name: ByteArray) -> ContractAddress {

    let mut constructor_calldata = ArrayTrait::new();

    let contract = declare(name).unwrap();
    let (erc20_contract_address, _) = contract.deploy(@constructor_calldata).unwrap();

    erc20_contract_address
}

#[test]
fn test_piggy_factory_constructor() {

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

#[test]
fn test_dev_address_is_properly_initiated() {
    let (contract_address, owner) = deploy_contract("PiggyBankFactory");

    let piggy_factory = IPiggyBankFactoryDispatcher { contract_address };

    start_cheat_caller_address(contract_address, owner);

    let dev_address: ContractAddress =  0x03af13f04C618e7824b80b61e141F5b7aeDB07F5CCe3aD16Dbd8A4BE333A3Ffa.try_into().unwrap();
    piggy_factory.init_dev_address(dev_address);

    stop_cheat_caller_address(contract_address);

    let contract_dev_address = piggy_factory.show_dev_address();

    assert(contract_dev_address == dev_address, 'wrong dev address');
}

#[test]
fn test_piggy_bank_constructor() {
    let piggy_bank_class = declare("PiggyBank").unwrap();

    let saving_purpose = "Buy a House";
    let time_lock: u256 = 36800_u256;

    let (contract_address, owner) = deploy_contract("PiggyBankFactory");

    let piggy_factory = IPiggyBankFactoryDispatcher { contract_address };

    start_cheat_caller_address(contract_address, owner);
    let dev_address: ContractAddress =  0x03af13f04C618e7824b80b61e141F5b7aeDB07F5CCe3aD16Dbd8A4BE333A3Ffa.try_into().unwrap();
    piggy_factory.init_dev_address(dev_address);
    stop_cheat_caller_address(contract_address);


    let caller: ContractAddress = starknet::contract_address_const::<0x123456711>();
    start_cheat_caller_address(contract_address, caller);

    piggy_factory.create_piggy_bank(piggy_bank_class.class_hash, saving_purpose.clone(), time_lock);

    let total_bank_count = piggy_factory.total_bank_count();

    assert(total_bank_count == 1, 'Failed to create bank');

    // testing the piggy bank contract

    let bank_contract = *piggy_factory.get_all_piggy_banks()[0];

    let piggy_bank = IPiggyBankDispatcher {contract_address: bank_contract};
    let (piggy_saving_purpose, piggy_time_lock) = piggy_bank.get_contract_details();

    assert(piggy_bank.owner() == caller, 'wrong caller set');
    assert(piggy_saving_purpose == saving_purpose.clone(), 'wrong saving purpose');
    assert(piggy_time_lock == time_lock, 'wrong time lock');
}

#[test]
fn test_piggy_bank_deposit() {
    let piggy_bank_class = declare("PiggyBank").unwrap();

    let saving_purpose = "Buy a House";
    let time_lock: u256 = 36800_u256;

    let (contract_address, owner) = deploy_contract("PiggyBankFactory");

    let piggy_factory = IPiggyBankFactoryDispatcher { contract_address };

    // cheat caller to make the owner caller
    start_cheat_caller_address(contract_address, owner);

    let dev_address: ContractAddress =  0x03af13f04C618e7824b80b61e141F5b7aeDB07F5CCe3aD16Dbd8A4BE333A3Ffa.try_into().unwrap();
    piggy_factory.init_dev_address(dev_address);
    
    stop_cheat_caller_address(contract_address);


    let caller: ContractAddress = starknet::contract_address_const::<0x123456711>();
    start_cheat_caller_address(contract_address, caller);

    piggy_factory.create_piggy_bank(piggy_bank_class.class_hash, saving_purpose.clone(), time_lock);

    let total_bank_count = piggy_factory.total_bank_count();

    assert(total_bank_count == 1, 'Failed to create bank');

    // testing the piggy bank contract

    let bank_contract = *piggy_factory.get_all_piggy_banks()[0];
    let piggy_bank = IPiggyBankDispatcher {contract_address: bank_contract};

    // deploy, mint and approve ERC20
    let erc20_contract_address = deploy_erc20_contract("ERC20");
    let token = IERC20Dispatcher {contract_address: erc20_contract_address};
    let token_decimal = token.decimals();

    start_cheat_caller_address(erc20_contract_address, caller);

    let mint_amount: u256 = 1000 * token_decimal.into();
    token.mint(caller, mint_amount);

    assert(token.balance_of(caller) == mint_amount, 'mint failed');

    let approve_amount = 100 * token_decimal.into();
    token.approve(bank_contract, approve_amount);

    start_cheat_caller_address(bank_contract, caller);
    // add token as supported token
    piggy_bank.add_supported_token(erc20_contract_address);

    // deposit into piggy bank contract
    let deposit_amount = 10 * token_decimal.into();
    piggy_bank.deposit_token(erc20_contract_address, deposit_amount);

    let amount_saved = piggy_bank.total_amount_saved(erc20_contract_address);

    assert(amount_saved == deposit_amount, 'deposit faild');
}