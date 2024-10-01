#[starknet::contract]
mod PiggyBank {
    use piggy_savings::interfaces::piggy_bank_interface::IPiggyBank;
    use core::starknet::{ContractAddress, get_caller_address, get_contract_address};
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess, Map, StoragePathEntry};
    use piggy_savings::interfaces::ierc20::{IERC20Dispatcher, IERC20DispatcherTrait};


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

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, dev_address: ContractAddress, saving_purpose: ByteArray, time_lock: u256,) {
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

            token.transfer(caller, contract_token_balance);

            self.emit(Withdrawn {
                user: caller,
                token: token_address,
                amount: contract_token_balance
            });
        }

        fn emergency_withdrawal(ref self: ContractState) {

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
