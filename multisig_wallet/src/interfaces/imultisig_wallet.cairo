use starknet::ContractAddress;

#[starknet::interface]
pub trait IMultisigWallet<TContractState> {
    fn init_transfer(ref self: TContractState, token_address: ContractAddress, recipient: ContractAddress, amount: u256);
    fn approve_transaction(ref self: TContractState, tx_id: u256);
}