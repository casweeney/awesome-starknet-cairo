use starknet::{ContractAddress, ClassHash};

#[starknet::interface]
pub trait IPiggyBankFactory<TContractState> {
    fn create_piggy_bank(ref self: TContractState, piggy_bank_classhash: ClassHash, saving_purpose: ByteArray, time_lock: u256);
    fn get_all_piggy_banks(self: @TContractState) -> Array<ContractAddress>;
    fn total_bank_count(self: @TContractState) -> u256;
    fn get_user_banks(self: @TContractState, user_address: ContractAddress) -> Array<ContractAddress>;
    fn user_bank_count(self: @TContractState, user_address: ContractAddress) -> u256;
    fn init_dev_address(ref self: TContractState, dev_address: ContractAddress);
    fn show_dev_address(self: @TContractState) -> ContractAddress;
    fn owner(self: @TContractState) -> ContractAddress;
}