#[starknet::contract]
mod Auction {
    use crate::interfaces::iauction::IAuction;
    use crate::interfaces::ierc721::{IERC721Dispatcher, IERC721DispatcherTrait};
    use starknet::ContractAddress;
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess, Map, StoragePathEntry};

    #[storage]
    struct Storage {
        nft: ContractAddress,
        nft_id: u256,
        seller: ContractAddress,
        end_at: u256,
        started: bool,
        ended: bool,
        highest_bidder: ContractAddress,
        highest_bid: u256,
        bids: Map<ContractAddress, u256>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, nft_address: ContractAddress, nft_id: u256, starting_bid: u256) {

    }

    #[abi(embed_v0)]
    impl AuctionImpl of IAuction<ContractState> {
        fn start(ref self: ContractState) {

        }

        fn bid(ref self: ContractState, amount: u256) {

        }

        fn withdraw(ref self: ContractState) {

        }

        fn end(ref self: ContractState) {

        }

        fn nft(self: @ContractState) -> ContractAddress {

        }

        fn nft_id(self: @ContractState) -> u256 {

        }

        fn seller(self: @ContractState) -> ContractAddress {

        }

        fn end_at(self: @ContractState) -> u256 {

        }

        fn started(self: @ContractState) -> bool {

        }

        fn ended(self: @ContractState) -> bool {

        }

        fn highest_bidder(self: @ContractState) -> ContractAddress {

        }

        fn highest_bid(self: @ContractState) -> u256 {

        }
    }
}
