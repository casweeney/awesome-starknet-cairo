use starknet::ContractAddress;

#[starknet::interface]
pub trait IUniswapV2Pair<TContractState> {
    fn get_reserves(self: @TContractState) -> (u256, u256, u32);
    fn initialize(ref self: TContractState, token0: ContractAddress, token1: ContractAddress);
    fn mint(ref self: TContractState, to: ContractAddress) -> u256;
    fn burn(ref self: TContractState, to: ContractAddress) -> (u256, u256);
    fn swap(ref self: TContractState, amount0_out: u256, amount1_out: u256, to: ContractAddress);
    fn skim(ref self: TContractState, to: ContractAddress);
    fn sync(ref self: TContractState);
}