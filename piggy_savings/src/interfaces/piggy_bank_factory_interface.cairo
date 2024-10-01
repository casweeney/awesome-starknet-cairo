use starknet::{ContractAddress, ClassHash};

#[starknet::interface]
pub trait IPiggyBankFactory<TContractState> {
    fn create_piggy_bank(ref self: TContractState, piggy_bank_classhash: ClassHash, dev_address: ContractAddress, saving_purpose: ByteArray, time_lock: u256);
    fn get_all_piggy_banks(self: @TContractState) -> Array<ContractAddress>;
    fn total_bank_count(self: @TContractState) -> u256;
    fn get_user_banks(self: @TContractState, user_address: ContractAddress) -> Array<ContractAddress>;
    fn user_bank_count(self: @TContractState, user_address: ContractAddress) -> u256;
}