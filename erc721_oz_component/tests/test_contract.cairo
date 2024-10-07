use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait};

use erc721_oz_component::erc721_interface::IERC721Dispatcher;
use erc721_oz_component::erc721_interface::IERC721DispatcherTrait;

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let token_uri: ByteArray = "https://dummy_uri.com/your_id";

    let mut constructor_calldata = ArrayTrait::new();
    constructor_calldata.append(token_uri);

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
