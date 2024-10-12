use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, start_cheat_caller_address, stop_cheat_caller_address};

use order_swap::{IOrderSwapDispatcher, IOrderSwapDispatcherTrait};
use order_swap::ierc20::{IERC20Dispatcher, IERC20DispatcherTrait};

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap();

    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    
    contract_address
}

#[test]
fn test_create_order() {
    let swap_contract_address = deploy_contract("OrderSwap");
    let from_token_contract_address = deploy_contract("FromToken");
    let to_token_contract_address = deploy_contract("ToToken");

    let swap_contract = IOrderSwapDispatcher { contract_address: swap_contract_address };
    let from_token = IERC20Dispatcher { contract_address: from_token_contract_address };


    let caller: ContractAddress = starknet::contract_address_const::<0x123456789>();
    let mint_amount: u256 = 10000_u256;
    from_token.mint(caller, mint_amount);
    assert(from_token.balance_of(caller) == mint_amount, 'Invalid balance');

    start_cheat_caller_address(from_token_contract_address, caller);
    from_token.approve(swap_contract_address, mint_amount);
    stop_cheat_caller_address(from_token_contract_address);

    start_cheat_caller_address(swap_contract_address, caller);
    let amount_in: u256 = 100_u256;
    let amount_out: u256 = 200_u256;
    swap_contract.create_order(from_token_contract_address, to_token_contract_address, amount_in, amount_out);
    stop_cheat_caller_address(swap_contract_address);

    assert(swap_contract.get_orders_count() == 1, 'order creation failed');
}


#[test]
fn test_execute_order() {
    let swap_contract_address = deploy_contract("OrderSwap");
    let from_token_contract_address = deploy_contract("FromToken");
    let to_token_contract_address = deploy_contract("ToToken");

    let swap_contract = IOrderSwapDispatcher { contract_address: swap_contract_address };
    let from_token = IERC20Dispatcher { contract_address: from_token_contract_address };
    let to_token = IERC20Dispatcher { contract_address: to_token_contract_address };


    let seller: ContractAddress = starknet::contract_address_const::<0x123456789>();
    let buyer: ContractAddress = starknet::contract_address_const::<0x129900789>();

    let mint_amount: u256 = 10000_u256;
    from_token.mint(seller, mint_amount);
    to_token.mint(buyer, mint_amount);

    assert(from_token.balance_of(seller) == mint_amount, 'Invalid from balance');
    assert(to_token.balance_of(buyer) == mint_amount, 'Invalid to balance');

    assert(from_token.balance_of(buyer) == 0, 'from unexpected increase');
    assert(to_token.balance_of(seller) == 0, 'to unexpected increase');

    start_cheat_caller_address(from_token_contract_address, seller);
    from_token.approve(swap_contract_address, mint_amount);
    stop_cheat_caller_address(from_token_contract_address);

    let amount_in: u256 = 100_u256;
    let amount_out: u256 = 200_u256;

    start_cheat_caller_address(swap_contract_address, seller);
    swap_contract.create_order(from_token_contract_address, to_token_contract_address, amount_in, amount_out);
    stop_cheat_caller_address(swap_contract_address);
    assert(swap_contract.get_orders_count() == 1, 'order creation failed');

    start_cheat_caller_address(to_token_contract_address, buyer);
    to_token.approve(swap_contract_address, mint_amount);
    stop_cheat_caller_address(to_token_contract_address);

    start_cheat_caller_address(swap_contract_address, buyer);
    swap_contract.execute_order(1);
    stop_cheat_caller_address(swap_contract_address);

    assert(from_token.balance_of(buyer) == amount_in, 'buyer amount failed');
    assert(to_token.balance_of(seller) == amount_out, ' seller amount failed');
}
