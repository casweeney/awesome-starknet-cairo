use starknet::ContractAddress;

#[starknet::interface]
trait IPiggyBankFactory<TContractState> {
    fn create_piggy_bank(ref self: TContractState, owner: ContractAddress, dev_address: ContractAddress, saving_purpose: ByteArray);
    fn get_all_piggy_banks(self: @TContractState) -> Array<ContractAddress>;
    fn total_bank_count(self: @TContractState) -> u256;
    fn get_user_banks(self: @TContractState) -> Array<ContractAddress>;
    fn total_user_bank_count(self: @TContractState) -> u256;
}