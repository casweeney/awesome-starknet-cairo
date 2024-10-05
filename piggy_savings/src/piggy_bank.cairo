#[starknet::contract]
mod PiggyBank {
    use piggy_savings::interfaces::piggy_bank_interface::IPiggyBank;
    use core::starknet::{ContractAddress, get_caller_address, get_contract_address};
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess, Map, StoragePathEntry};
    use piggy_savings::interfaces::erc20_interface::{IERC20Dispatcher, IERC20DispatcherTrait};


    #[storage]
    struct Storage {
        owner: ContractAddress,
        dev_address: ContractAddress,
        saving_purpose: ByteArray,
        time_lock: u256,
        supported_tokens: Map<ContractAddress, bool>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Deposited: Deposited,
        TokenAdded: TokenAdded,
        Withdrawn: Withdrawn,
        EmergencyWithdrawal: EmergencyWithdrawal,
    }

    #[derive(Drop, starknet::Event)]
    struct Deposited {
        user: ContractAddress,
        amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct TokenAdded {
        token: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct Withdrawn {
        user: ContractAddress,
        token: ContractAddress,
        amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct EmergencyWithdrawal {
        user: ContractAddress,
        token: ContractAddress,
        amount: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, dev_address: ContractAddress, saving_purpose: ByteArray, time_lock: u256) {
        self.owner.write(owner);
        self.dev_address.write(dev_address);
        self.saving_purpose.write(saving_purpose);
        self.time_lock.write(time_lock);
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

            self.emit(Deposited { user: caller, amount });
        }

        fn safe_withdraw(ref self: ContractState, token_address: ContractAddress) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(),'unauthorized user');

            let token = IERC20Dispatcher { contract_address: token_address };

            let contract_token_balance = token.balance_of(get_contract_address());

            let saving_commission = self.saving_commission(token_address);
            let actual_withdraw_amount = contract_token_balance - saving_commission;

            token.transfer(caller, actual_withdraw_amount);
            token.transfer(self.dev_address.read(), saving_commission);

            self.emit(Withdrawn {
                user: caller,
                token: token_address,
                amount: contract_token_balance
            });
        }

        fn emergency_withdrawal(ref self: ContractState, token_address: ContractAddress) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(),'unauthorized user');

            let token = IERC20Dispatcher { contract_address: token_address };

            let contract_token_balance = token.balance_of(get_contract_address());

            let penal_fee = self.calculate_penal_fee(token_address);
            let actual_withdraw_amount = contract_token_balance - penal_fee;

            token.transfer(caller, actual_withdraw_amount);
            token.transfer(self.dev_address.read(), penal_fee);

            self.emit(EmergencyWithdrawal {
                user: caller,
                token: token_address,
                amount: contract_token_balance
            });
        }

        fn add_supported_token(ref self: ContractState, token_address: ContractAddress) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'invalid owner');

            let is_token_supported = self.supported_tokens.entry(token_address).read();
            assert(!is_token_supported, 'token is already supported');

            self.supported_tokens.entry(token_address).write(true);

            self.emit(TokenAdded {token: token_address});
        }

        fn total_amount_saved(self: @ContractState, token_address: ContractAddress) -> u256 {
            IERC20Dispatcher {contract_address: token_address}.balance_of(get_contract_address())
        }

        fn show_token_penal_fee(self: @ContractState, token_address: ContractAddress) -> u256 {
            self.calculate_penal_fee(token_address)
        }

        fn owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }

        fn get_contract_details(self: @ContractState) -> (ByteArray, u256) {
            let saving_purpose = self.saving_purpose.read();
            let time_lock = self.time_lock.read();

            (saving_purpose, time_lock)
        }
    }

    #[generate_trait]
    pub impl InternalImpl of InternalTrait {
        fn calculate_penal_fee(self: @ContractState, token_address: ContractAddress) -> u256 {

            let token = IERC20Dispatcher{ contract_address: token_address };

            let token_contract_balance = token.balance_of(get_contract_address());

            let percent = (token_contract_balance * 1500) / 10000; // 15%

            percent
        }

        fn saving_commission(self: @ContractState, token_address: ContractAddress) -> u256 {
            let token = IERC20Dispatcher{ contract_address: token_address };

            let token_contract_balance = token.balance_of(get_contract_address());

            let commission = (token_contract_balance * 100) / 100000; // 0.1%

            commission
        }
    }
}
