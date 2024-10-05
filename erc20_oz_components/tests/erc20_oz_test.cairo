use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, start_cheat_caller_address, stop_cheat_caller_address};

use erc20_oz_components::{IERC20CombinedDispatcher, IERC20CombinedDispatcherTrait};


fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}

#[test]
fn test_token_constructor() {
    let contract_address = deploy_contract("ERC20");

    let erc20_token = IERC20CombinedDispatcher { contract_address };

    let token_name = erc20_token.name();
    let token_symbol = erc20_token.symbol();
    let token_decimal = erc20_token.decimals();
    

    assert(token_name == "CodingCas", 'wrong token name');
    assert(token_symbol == "CDC", 'wrong token symbol');
    assert(token_decimal == 18, 'wrong token decimal');
}

#[test]
fn test_total_supply() {
    let contract_address = deploy_contract("ERC20");
    
    let erc20_token = IERC20CombinedDispatcher { contract_address };

    let token_decimal = erc20_token.decimals();
    let token_recipient: ContractAddress = starknet::contract_address_const::<0x123456711>();

    let mint_amount = 1000 * token_decimal.into();
    erc20_token.mint(token_recipient, mint_amount);

    let supply = erc20_token.total_supply();

    assert(supply == mint_amount, 'Incorrect Supply');
}

#[test]
fn test_mint() {
    let contract_address = deploy_contract("ERC20");
    
    let erc20_token = IERC20CombinedDispatcher { contract_address };

    let token_decimal = erc20_token.decimals();
    let token_recipient: ContractAddress = starknet::contract_address_const::<0x123456711>();
    let mint_amount = 1000 * token_decimal.into();

    erc20_token.mint(token_recipient, mint_amount);

    assert(erc20_token.balance_of(token_recipient) > 0, 'mint worked');
    assert(erc20_token.balance_of(token_recipient) == mint_amount, 'mint failed');
    assert(erc20_token.total_supply() == mint_amount, 'Incorrect Supply');
}

#[test]
fn test_approve() {
    let contract_address = deploy_contract("ERC20");
    let erc20_token = IERC20CombinedDispatcher { contract_address };

    let owner: ContractAddress = 0x07ab19dfcc6981ad7beba769a71a2d1cdd52b3d8a1484637bbb79f18a170cd51.try_into().unwrap();

    let amount: u256 = 10000;

    let recipient: ContractAddress = 0x03af13f04C618e7824b80b61e141F5b7aeDB07F5CCe3aD16Dbd8A4BE333A3Ffa.try_into().unwrap();

    start_cheat_caller_address(contract_address, owner);
    erc20_token.approve(recipient, amount);
    stop_cheat_caller_address(contract_address);

    assert(erc20_token.allowance(owner, recipient) > 0, 'incorrect allowance');
    assert(erc20_token.allowance(owner, recipient) == amount, 'wrong allowance amount');
}

#[test]
fn test_transfer() {
    let contract_address = deploy_contract("ERC20");
    let erc20_token = IERC20CombinedDispatcher { contract_address };

    let owner: ContractAddress = 0x07ab19dfcc6981ad7beba769a71a2d1cdd52b3d8a1484637bbb79f18a170cd51.try_into().unwrap();
    let recipient: ContractAddress = 0x03af13f04C618e7824b80b61e141F5b7aeDB07F5CCe3aD16Dbd8A4BE333A3Ffa.try_into().unwrap();

    let amount: u256 = 10000;
    let amount2: u256 = 5000;

    start_cheat_caller_address(contract_address, owner);

    erc20_token.mint(owner, amount);

    assert(erc20_token.balance_of(owner) > 0, 'mint failed');
    assert(erc20_token.balance_of(owner) == amount, 'wrong mint amount');

    let receiver_previous_balance = erc20_token.balance_of(recipient);

    erc20_token.transfer(recipient, amount2);

    stop_cheat_caller_address(contract_address);

    assert(erc20_token.balance_of(owner) < amount, 'amount failed to deduct');
    assert(erc20_token.balance_of(owner) == amount - amount2, 'amount deduction failed');

    assert(erc20_token.balance_of(recipient) > receiver_previous_balance, 'wrong recipient balance');
    assert(erc20_token.balance_of(recipient) == amount2, 'balance increment failed');
    
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
