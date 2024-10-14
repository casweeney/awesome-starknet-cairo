#[starknet::contract]
mod UniswapV2Pair {
    use starknet::ContractAddress;
    use uniswap_v2_core::interfaces::iuniswap_v2_pair::IUniswapV2Pair;

    #[storage]
    pub struct Storage {
        minimum_liquidity: u256,
        factory: ContractAddress,
        token0: ContractAddress,
        token1: ContractAddress,

        reserve0: u256,
        reserve1: u256,
        block_time_stamp_last: u32,

        price0_cumulative_last: u256,
        price1_cumulative_last: u256,
        k_last: u256,

        unlocked: u256,
    }


    #[abi(embed_v0)]
    impl UniswapV2PairImpl of IUniswapV2Pair<ContractState> {
        fn get_reserves(self: @ContractState) -> (u256, u256, u256) {

            (1, 2, 3)
        }

        fn initialize(ref self: ContractState, token0: ContractAddress, token1: ContractAddress) {}

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