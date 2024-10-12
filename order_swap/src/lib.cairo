use starknet::ContractAddress;
pub mod ierc20;

#[starknet::interface]
pub trait IOrderSwap<TContractState> {
    fn create_order(ref self: TContractState, from_token: ContractAddress, to_token: ContractAddress, amount_in: u256, amount_out: u256);
    fn execute_order(ref self: TContractState, order_id: u256);
}

#[starknet::contract]
mod OrderSwap {
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use core::starknet::storage::{Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess};
    use order_swap::ierc20::{IERC20Dispatcher, IERC20DispatcherTrait};

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
            let caller = get_caller_address();
            let this_contract = get_contract_address();
            let token_from = IERC20Dispatcher { contract_address: from_token };
            let order_id = self.last_order_id.read();

            assert(token_from.balance_of(caller) >= amount_in, 'insufficient funds');
            let transfer_in = token_from.transfer_from(caller, this_contract, amount_in);
            assert(transfer_in, 'transfer failed');

            let order = Order {
                order_owner: caller,
                token_from: from_token,
                token_to: to_token,
                amount_in,
                amount_out,
                is_order_opened: true
            };

            self.orders.entry(order_id).write(order);

            // self.orders.entry(order_id).order_owner.write(caller);
            // self.orders.entry(order_id).token_from.write(from_token);
            // self.orders.entry(order_id).token_to.write(to_token);
            // self.orders.entry(order_id).amount_in.write(amount_in);
            // self.orders.entry(order_id).amount_out.write(amount_out);
            // self.orders.entry(order_id).is_order_opened.write(true);

            self.last_order_id.write(order_id);
        }

        fn execute_order(ref self: ContractState, order_id: u256) {
            let order = self.orders.entry(order_id).read();

            assert(order.is_order_opened, 'order is closed');

            let caller = get_caller_address();
            let this_contract = get_contract_address();

            let token_to = IERC20Dispatcher{ contract_address: order.token_to };
            let token_from = IERC20Dispatcher{ contract_address: order.token_from };

            assert(token_to.balance_of(caller) >= order.amount_out, 'insufficient funds');
            let transfer_in = token_to.transfer_from(caller, this_contract, order.amount_out);
            assert(transfer_in, 'tranfer in failed');

            self.orders.entry(order_id).is_order_opened.write(false);

            token_to.transfer(order.order_owner, order.amount_out);
            token_from.transfer(caller, order.amount_in);
        }
    }
}
