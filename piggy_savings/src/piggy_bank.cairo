#[starknet::contract]
mod PiggyBank {
    use piggy_savings::interfaces::piggy_bank_interface::IPiggyBank;
    use core::starknet::{ContractAddress, get_caller_address, get_contract_address};
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess, Map, StoragePathEntry};
    use piggy_savings::interfaces::ierc20::{IERC20, IERC20Dispatcher, IERC20DispatcherTrait};


    #[storage]
    struct Storage {
        owner: ContractAddress,
        dev_address: ContractAddress,
        saving_purpose: ByteArray,
        time_lock: u256,
        balance: Map<ContractAddress, u256>,
        supported_tokens: Map<ContractAddress, bool>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, dev_address: ContractAddress, saving_purpose: ByteArray, time_lock: u256,) {
        self.owner.write(owner);
        self.dev_address.write(dev_address);
        self.saving_purpose.write(saving_purpose);
        self.time_lock.write(10);
    }



    #[abi(embed_v0)]
    impl PiggyBankImpl of IPiggyBank<ContractState> {
        fn deposit_token(ref self: ContractState, token_address: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            let this_contract = get_contract_address();

            let is_token_supported = self.supported_tokens.entry(token_address).read();
            assert(is_token_supported, 'unsupported token');

            let token = IERC20Dispatcher{ contract_address: token_address };
            assert(token.balance_of(caller) >= amount, 'insufficient funds');

            token.transfer_from(caller, this_contract, amount);
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
