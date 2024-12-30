#[starknet::interface]
pub trait IMockERC20<TContractState> {
    fn increase_balance(ref self: TContractState, amount: felt252);
    fn get_balance(self: @TContractState) -> felt252;
}

#[starknet::contract]
mod MockERC20 {
    #[storage]
    struct Storage {
        balance: felt252, 
    }

    #[abi(embed_v0)]
    impl MockERC20Impl of super::IMockERC20<ContractState> {
        fn increase_balance(ref self: ContractState, amount: felt252) {
            assert(amount != 0, 'Amount cannot be 0');
            self.balance.write(self.balance.read() + amount);
        }

        fn get_balance(self: @ContractState) -> felt252 {
            self.balance.read()
        }
    }
}
