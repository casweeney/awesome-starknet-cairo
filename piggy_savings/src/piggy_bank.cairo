#[starknet::contract]
mod PiggyBank {
    use piggy_savings::interfaces::piggy_bank_interface::IPiggyBank;
    use core::starknet::{ContractAddress, get_caller_address};
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess, Map};


    #[storage]
    struct Storage {
        saving_purpose: ByteArray,
        balance: Map<ContractAddress, u256>,
        supported_tokens: Map<ContractAddress, bool>,
        dev_address: ContractAddress,
        time_lock: u256,
        owner: ContractAddress,
    }

    #[abi(embed_v0)]
    impl PiggyBankImpl of IPiggyBank<ContractState> {
        fn deposit_token(ref self: ContractState, token_address: ContractAddress, amount: u256) {

        }

        fn safe_withdraw(ref self: ContractState) {

        }

        fn emergency_withdrawal(ref self: ContractState) {

        }

        fn add_supported_token(ref self: ContractState, token_address: ContractAddress) {

        }

        fn total_amount_saved(ref self: ContractState) -> u256 {
            1
        }

        fn get_contract_balance(ref self: ContractState) -> u256 {
            2
        }
    }

    #[generate_trait]
    pub impl InternalImpl of InternalTrait {
        fn calculate_penal_fee() -> u256 {

            80
        }

        fn saving_commission() -> u256 {
            10
        }
    }
}
