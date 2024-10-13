use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, start_cheat_caller_address, stop_cheat_caller_address};

use escrow::ierc20::{IERC20Dispatcher, IERC20DispatcherTrait};
use escrow::{IEscrowDispatcher, IEscrowDispatcherTrait};

fn deploy_contract(name: ByteArray) -> (ContractAddress, ContractAddress) {
    let admin: ContractAddress = starknet::contract_address_const::<0x123456789>();
    let treasury: ContractAddress =  0x03af13f04C618e7824b80b61e141F5b7aeDB07F5CCe3aD16Dbd8A4BE333A3Ffa.try_into().unwrap();
    let fee_treasury: ContractAddress = starknet::contract_address_const::<0x123626789>();

    let mut constructor_calldata = ArrayTrait::new();
    constructor_calldata.append(admin.into());
    constructor_calldata.append(treasury.into());
    constructor_calldata.append(fee_treasury.into());

    let contract = declare(name).unwrap();
    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();

    (contract_address, admin)
}

fn deploy_token(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap();

    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    
    contract_address
}

#[test]
fn test_transact() {
    let (contract_address, _) = deploy_contract("Escrow");
    let token_address = deploy_token("ERC20");

    let escrow_contract = IEscrowDispatcher { contract_address };
    let erc20_token = IERC20Dispatcher { contract_address: token_address };

    let caller: ContractAddress = starknet::contract_address_const::<0x123116669>();
    let mint_amount: u256 = 1000;
    erc20_token.mint(caller, mint_amount);
    assert!(erc20_token.balance_of(caller) > 0, "mint failed");
    assert!(erc20_token.balance_of(caller) == mint_amount, "wrong mint amount");

    let transact_amount: u256 = 100;
    let transact_fee: u256 = 50;

    start_cheat_caller_address(token_address, caller);
    erc20_token.approve(contract_address, transact_amount + transact_fee);
    stop_cheat_caller_address(token_address);

    start_cheat_caller_address(contract_address, caller);
    escrow_contract.transact(token_address, transact_amount, transact_fee);
    stop_cheat_caller_address(contract_address);

    assert(erc20_token.balance_of(caller) == mint_amount - (transact_amount + transact_fee), 'failed to transact');
    assert(erc20_token.balance_of(contract_address) == (transact_amount + transact_fee), 'wrong contract balance');
    assert(escrow_contract.get_all_transaction().len() == 1, 'transact faild');
}