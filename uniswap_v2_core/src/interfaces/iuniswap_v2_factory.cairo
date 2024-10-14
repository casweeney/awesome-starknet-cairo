use starknet::ContractAddress;

#[starknet::interface]
pub trait IUniswapV2Factory<TContractState> {
    fn fee_to(self: @TContractState) -> ContractAddress;
    fn fee_to_setter(self: @TContractState) -> ContractAddress;
    fn get_pair(self: @TContractState, token_A: ContractAddress, token_B: ContractAddress) -> ContractAddress;
    fn all_pairs(self: @TContractState) -> ContractAddress;
    fn all_pairs_length(self: @TContractState) -> u256;
    fn create_pair(ref self: TContractState, token_A: ContractAddress, token_B: ContractAddress) -> ContractAddress;
    fn set_fee_to(ref self: TContractState, fee_to_address: ContractAddress);
    fn set_fee_to_setter(ref self: TContractState, fee_to_setter_address: ContractAddress);
}