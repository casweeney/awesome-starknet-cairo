use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, start_cheat_caller_address, stop_cheat_caller_address};

use erc721_oz_component::erc721_interface::IERC721Dispatcher;
use erc721_oz_component::erc721_interface::IERC721DispatcherTrait;

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let token_uri: ByteArray = "https://dummy_uri.com/your_id";
    let mut constructor_calldata: Array<felt252> = ArrayTrait::new();
    token_uri.serialize(ref constructor_calldata);

    let contract = declare(name).unwrap();
    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();
    
    contract_address
}

#[test]
fn test_constructor() {
    let contract_address = deploy_contract("CasOnStark");

    let erc721_token = IERC721Dispatcher { contract_address };

    let token_name = erc721_token.name();
    let token_symbol = erc721_token.symbol();

    assert(token_name == "Cas on Starknet", 'wrong token name');
    assert(token_symbol == "COS", 'wrong token symbol');
}

#[test]
fn test_mint() {
    let contract_address = deploy_contract("CasOnStark");

    let erc721_token = IERC721Dispatcher { contract_address };

    let token_recipient: ContractAddress = starknet::contract_address_const::<0x123456711>();

    erc721_token.mint(token_recipient, 1);

    assert(erc721_token.owner_of(1) == token_recipient, 'wrong token id');
    assert(erc721_token.balance_of(token_recipient) > 0, 'mint failed');
}

#[test]
fn test_approve() {
    let contract_address = deploy_contract("CasOnStark");
    let erc721_token = IERC721Dispatcher { contract_address };

    let owner: ContractAddress = 0x07ab19dfcc6981ad7beba769a71a2d1cdd52b3d8a1484637bbb79f18a170cd51.try_into().unwrap();

    erc721_token.mint(owner, 1);


    let recipient: ContractAddress = 0x03af13f04C618e7824b80b61e141F5b7aeDB07F5CCe3aD16Dbd8A4BE333A3Ffa.try_into().unwrap();

    start_cheat_caller_address(contract_address, owner);
    erc721_token.approve(recipient, 1);
    stop_cheat_caller_address(contract_address);

    assert(erc721_token.get_approved(1) == recipient, 'incorrect approval');
}

#[test]
fn test_transfer() {
    let contract_address = deploy_contract("CasOnStark");
    let erc721_token = IERC721Dispatcher { contract_address };

    let owner: ContractAddress = 0x07ab19dfcc6981ad7beba769a71a2d1cdd52b3d8a1484637bbb79f18a170cd51.try_into().unwrap();
    let recipient: ContractAddress = 0x03af13f04C618e7824b80b61e141F5b7aeDB07F5CCe3aD16Dbd8A4BE333A3Ffa.try_into().unwrap();

    start_cheat_caller_address(contract_address, owner);

    erc721_token.mint(owner, 1);

    assert(erc721_token.balance_of(owner) > 0, 'mint failed');
    assert(erc721_token.balance_of(owner) == 1, 'wrong mint count');

    erc721_token.transfer_from(owner, recipient, 1);

    stop_cheat_caller_address(contract_address);

    assert(erc721_token.balance_of(owner) == 0, 'transfer failed');
    assert(erc721_token.balance_of(recipient) == 1, 'token transfer failed');

    assert(erc721_token.owner_of(1) == recipient, 'failed to transfer');
}

// #[test]
// #[feature("safe_dispatcher")]
// fn test_cannot_increase_balance_with_zero_value() {
//     let contract_address = deploy_contract("HelloStarknet");

//     let safe_dispatcher = IHelloStarknetSafeDispatcher { contract_address };

//     let balance_before = safe_dispatcher.get_balance().unwrap();
//     assert(balance_before == 0, 'Invalid balance');

//     match safe_dispatcher.increase_balance(0) {
//         Result::Ok(_) => core::panic_with_felt252('Should have panicked'),
//         Result::Err(panic_data) => {
//             assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
//         }
//     };
// }
