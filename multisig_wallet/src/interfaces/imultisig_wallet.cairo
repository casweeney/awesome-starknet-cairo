use starknet::ContractAddress;

#[starknet::interface]
pub trait IMultisigWallet<TContractState> {
    fn init_transfer(ref self: TContractState, token_address: ContractAddress, recipient: ContractAddress, amount: u256);
    fn approve_transaction(ref self: TContractState, tx_id: u256);
    fn quorum(self: @TContractState) -> u256;
    fn no_of_valid_signers(self: @TContractState) -> u256;
    fn tx_count(self: @TContractState) -> u256;
}