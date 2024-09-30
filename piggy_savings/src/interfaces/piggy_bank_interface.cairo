use starknet::ContractAddress;

#[starknet::interface]
pub trait IPiggyBank<TContractState> {
    fn deposit_token(ref self: TContractState, token_address: ContractAddress, amount: u256);
    fn safe_withdraw(ref self: TContractState);
    fn emergency_withdrawal(ref self: TContractState);
    fn add_supported_token(ref self: TContractState, token_address: ContractAddress);
    fn total_amount_saved(ref self: TContractState) -> u256;
    fn get_contract_balance(ref self: TContractState) -> u256;
}