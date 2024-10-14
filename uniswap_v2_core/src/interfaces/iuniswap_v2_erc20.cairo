use starknet::ContractAddress;

#[starknet::interface]
pub trait IUniswapV2ERC20<TContractState> {
    fn name(self: @TContractState) -> ByteArray;
    fn symbol(self: @TContractState) -> ByteArray;
    fn decimals(self: @TContractState) -> u8;
    fn total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, owner: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;

    fn approve(ref self: TContractState, spender: ContractAddress, value: u256) -> bool;
    fn transfer(ref self: TContractState, to: ContractAddress, value: u256) -> bool;
    fn transfer_from(ref self: TContractState, from: ContractAddress, to: ContractAddress, value: u256) -> bool;

    fn mint(ref self: TContractState, to: ContractAddress, value: u256) -> bool;
}