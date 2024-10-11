use starknet::ContractAddress;

#[starknet::interface]
pub trait IOrderSwap<TContractState> {
    fn create_order(ref self: TContractState, from_token: ContractAddress, to_token: ContractAddress, amount_in: u256, amount_out: u256);
    fn execute_order(ref self: TContractState, order_id: u256);
}

#[starknet::contract]
mod OrderSwap {
    use starknet::ContractAddress;
    use core::starknet::storage::{Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        last_order_id: u256,
        orders: Map<u256, Order>,
    }

    #[derive(Drop, Serde, starknet::Store)]
    struct Order {
        order_owner: ContractAddress,
        token_from: ContractAddress,
        token_to: ContractAddress,
        amount_in: u256,
        amount_out: u256,
        is_order_opened: bool
    }

    #[abi(embed_v0)]
    impl OrderSwapImpl of super::IOrderSwap<ContractState> {
        fn create_order(ref self: ContractState, from_token: ContractAddress, to_token: ContractAddress, amount_in: u256, amount_out: u256) {
            
        }

        fn execute_order(ref self: ContractState, order_id: u256) {

        }
    }
}
