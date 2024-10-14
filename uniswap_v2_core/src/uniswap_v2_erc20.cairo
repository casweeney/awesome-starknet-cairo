#[starknet::contract]
mod UniswapV2ERC20 {
    use uniswap_v2_core::interfaces::iuniswap_v2_erc20::IUniswapV2ERC20;
    use starknet::{ContractAddress, get_caller_address};
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess, Map, StoragePathEntry};
    use core::num::traits::Zero;

    #[storage]
    pub struct Storage {
        balances: Map<ContractAddress, u256>,
        allowances: Map<(ContractAddress, ContractAddress), u256>, // Mapping<(owner, spender), amount>
        token_name: ByteArray,
        symbol: ByteArray,
        decimal: u8,
        total_supply: u256,
        owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Transfer: Transfer,
        Approval: Approval,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Transfer {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Approval {
        #[key]
        owner: ContractAddress,
        #[key]
        spender: ContractAddress,
        value: u256
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.token_name.write("Uniswap V2");
        self.symbol.write("UNI-V2");
        self.decimal.write(18);
    }

    #[abi(embed_v0)]
    impl UniswapV2ERC20Impl of IUniswapV2ERC20<ContractState> {
        fn total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }

        fn balance_of(self: @ContractState, owner: ContractAddress) -> u256 {
            let balance = self.balances.entry(owner).read();

            balance
        }

        fn allowance(self: @ContractState, owner: ContractAddress, spender: ContractAddress) -> u256 {
            let allowance = self.allowances.entry((owner, spender)).read();

            allowance
        }

        fn transfer(ref self: ContractState, to: ContractAddress, value: u256) -> bool {
            let sender = get_caller_address();

            let sender_prev_balance = self.balances.entry(sender).read();
            let recipient_prev_balance = self.balances.entry(to).read();

            assert(sender_prev_balance >= value, 'Insufficient amount');

            self.balances.entry(sender).write(sender_prev_balance - value);
            self.balances.entry(to).write(recipient_prev_balance + value);

            assert(self.balances.entry(to).read() > recipient_prev_balance, 'Transaction failed');

            self.emit(Transfer { from: sender, to, amount: value });

            true
        }

        fn transfer_from(ref self: ContractState, from: ContractAddress, to: ContractAddress, value: u256) -> bool {
            let spender = get_caller_address();

            let spender_allowance = self.allowances.entry((from, spender)).read();
            let sender_balance = self.balances.entry(from).read();
            let recipient_balance = self.balances.entry(to).read();

            assert(value <= spender_allowance, 'amount exceeds allowance');
            assert(value <= sender_balance, 'amount exceeds balance');

            self.allowances.entry((from, spender)).write(spender_allowance - value);
            self.balances.entry(from).write(sender_balance - value);
            self.balances.entry(to).write(recipient_balance + value);

            self.emit(Transfer { from, to, amount: value });

            true
        }

        fn approve(ref self: ContractState, spender: ContractAddress, value: u256) -> bool {
            let caller = get_caller_address();

            self.allowances.entry((caller, spender)).write(value);

            self.emit(Approval { owner: caller, spender, value });

            true
        }

        fn name(self: @ContractState) -> ByteArray {
            self.token_name.read()
        }

        fn symbol(self: @ContractState) -> ByteArray {
            self.symbol.read()
        }

        fn decimals(self: @ContractState) -> u8 {
            self.decimal.read()
        }

        fn mint(ref self: ContractState, to: ContractAddress, value: u256) -> bool {
            let previous_total_supply = self.total_supply.read();
            let previous_balance = self.balances.entry(to).read();

            self.total_supply.write(previous_total_supply + value);
            self.balances.entry(to).write(previous_balance + value);

            let zero_address = Zero::zero();

            self.emit(Transfer { from: zero_address, to: to, amount: value });

            true
        }
    }
}