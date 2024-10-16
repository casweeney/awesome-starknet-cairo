#[starknet::contract]
mod UniswapV2Pair {
    use starknet::{ContractAddress, get_caller_address};
    use uniswap_v2_core::interfaces::iuniswap_v2_pair::IUniswapV2Pair;
    use uniswap_v2_core::uniswap_v2_erc20::UniswapV2ERC20;
    use uniswap_v2_core::interfaces::ierc20::IERC20;
    use uniswap_v2_core::interfaces::iuniswap_v2_factory::IUniswapV2Factory;
    use core::traits::Into;


    #[storage]
    pub struct Storage {
        minimum_liquidity: u256,
        factory: ContractAddress,
        token0: ContractAddress,
        token1: ContractAddress,

        reserve0: u256,
        reserve1: u256,
        block_timestamp_last: u32,

        price0_cumulative_last: u256,
        price1_cumulative_last: u256,
        k_last: u256,

        unlocked: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Mint: Mint,
        Burn: Burn,
        Swap: Swap,
        Sync: Sync,
    }

    #[derive(Drop, starknet::Event)]
    struct Mint {
        #[key]
        sender: ContractAddress,
        amount0: u256,
        amount1: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Burn {
        #[key]
        sender: ContractAddress,
        amount0: u256,
        amount1: u256,
        to: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct Swap {
        #[key]
        sender: ContractAddress,
        amount0_in: u256,
        amount1_in: u256,
        amount0_out: u256,
        amount1_out: u256,
        #[key]
        to: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct Sync {
        reserve0: u256,
        reserve1: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let caller = get_caller_address();
        self.minimum_liquidity.write(10 * 10 * 10);
        self.factory.write(caller);
        self.unlocked.write(1);
    }


    #[abi(embed_v0)]
    impl UniswapV2PairImpl of IUniswapV2Pair<ContractState> {
        fn get_reserves(self: @ContractState) -> (u256, u256, u32) {
            (self.reserve0.read(), self.reserve1.read(), self.block_timestamp_last.read())
        }

        fn initialize(ref self: ContractState, token0: ContractAddress, token1: ContractAddress) {
            let caller = get_caller_address();
            assert!(caller == self.factory.read(), "UniswapV2: FORBIDDEN");

            self.token0.write(token0);
            self.token1.write(token1);
        }

        fn mint(ref self: ContractState, to: ContractAddress) -> u256 {

            2
        }

        fn burn(ref self: ContractState, to: ContractAddress) -> (u256, u256) {

            (2, 3)
        }

        fn swap(ref self: ContractState, amount0_out: u256, amount1_out: u256, to: ContractAddress) {}

        fn skim(ref self: ContractState, to: ContractAddress) {}

        fn sync(ref self: ContractState) {}
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn update(ref self: ContractState, balance0: u256, balance1: u256, reserve0: u256, reserve1: u256) {

        }

        fn mint_fee(ref self: ContractState, reserve0: u256, reserve1: u256) -> bool {

            true
        }

        fn safe_transfer(ref self: ContractState, token: ContractAddress, to: ContractAddress, value: u256) {

        }
    }
}