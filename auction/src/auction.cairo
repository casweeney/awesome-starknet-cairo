#[starknet::contract]
mod Auction {
    use starknet::event::EventEmitter;
use crate::interfaces::iauction::IAuction;
    use crate::interfaces::ierc721::{IERC721Dispatcher, IERC721DispatcherTrait};
    use crate::interfaces::ierc20::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::{ContractAddress, get_caller_address, get_contract_address, get_block_timestamp, contract_address_const};
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess, Map, StoragePathEntry};

    const DAY_IN_SECONDS: u64 = 86400;
    const SEVEN_DAYS_IN_SECONDS: u64 = 7 * DAY_IN_SECONDS;

    #[storage]
    struct Storage {
        accepted_erc20_token: ContractAddress,
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

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Start: Start,
        Bid: Bid,
        Withdraw: Withdraw,
        End: End
    }

    #[derive(Drop, starknet::Event)]
    struct Start {}

    #[derive(Drop, starknet::Event)]
    struct Bid {
        sender: ContractAddress,
        amount: u256
    }

    #[derive(Drop, starknet::Event)]
    struct Withdraw {
        bidder: ContractAddress,
        amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct End {
        winner: ContractAddress,
        amount: u256
    }

    #[constructor]
    fn constructor(ref self: ContractState, nft_address: ContractAddress, accepted_erc20_token: ContractAddress, nft_id: u256, starting_bid: u256) {
        let caller = get_caller_address();
        self.accepted_erc20_token.write(accepted_erc20_token);
        self.nft.write(nft_address);
        self.nft_id.write(nft_id);
        self.seller.write(caller);
        self.highest_bid.write(starting_bid);
    }

    #[abi(embed_v0)]
    impl AuctionImpl of IAuction<ContractState> {
        fn start(ref self: ContractState) {
            let caller = get_caller_address();
            let this_contract = get_contract_address();

            assert(self.started.read() == false, 'Already started');
            assert(caller == self.seller.read(), 'Not Seller');

            let nft = IERC721Dispatcher { contract_address: self.nft.read() };
            nft.transfer_from(caller, this_contract, self.nft_id.read());

            self.started.write(true);
            self.end_at.write((get_block_timestamp() + SEVEN_DAYS_IN_SECONDS).try_into().unwrap());

            self.emit(Start{});
        }

        fn bid(ref self: ContractState, amount: u256) {
            assert(self.started.read(), 'Not Started');
            assert(get_block_timestamp().try_into().unwrap() < self.end_at.read(), 'Ended');
            assert(amount > self.highest_bid.read(), 'Amount < highest');

            if self.highest_bidder.read() != self.zero_address() {
                let prev_bid = self.bids.entry(self.highest_bidder.read()).read();
                self.bids.entry(self.highest_bidder.read()).write(prev_bid + self.highest_bid.read());
            }

            let caller = get_caller_address();
            self.highest_bidder.write(caller);
            self.highest_bid.write(amount);

            self.emit(Bid{
                sender: caller,
                amount
            });
        }

        fn withdraw(ref self: ContractState) {
            let caller = get_caller_address();
            let balance = self.bids.entry(caller).read();
            self.bids.entry(caller).write(0);
            IERC20Dispatcher { contract_address: self.accepted_erc20_token.read() }.transfer(caller, balance);
            self.emit(Withdraw {
                bidder: caller,
                amount: balance
            });
        }

        fn end(ref self: ContractState) {
            assert(self.started.read(), 'Not Started');
            assert(get_block_timestamp().try_into().unwrap() >= self.end_at.read(), 'Not Ended');
            assert(self.ended.read() == false, 'Ended');

            self.ended.write(true);

            let nft = IERC721Dispatcher { contract_address: self.nft.read() };

            if self.highest_bidder.read() != self.zero_address() {
                nft.transfer_from(get_contract_address(), self.highest_bidder.read(), self.nft_id.read());
            } else {
                nft.transfer_from(get_contract_address(), self.seller.read(), self.nft_id.read());
            }

            self.emit(End {
                winner: self.highest_bidder.read(),
                amount: self.highest_bid.read()
            });
        }

        fn accepted_erc20_token(self: @ContractState) -> ContractAddress {
            self.accepted_erc20_token.read()
        }

        fn nft(self: @ContractState) -> ContractAddress {
            self.nft.read()
        }

        fn nft_id(self: @ContractState) -> u256 {
            self.nft_id.read()
        }

        fn seller(self: @ContractState) -> ContractAddress {
            self.seller.read()
        }

        fn end_at(self: @ContractState) -> u256 {
            self.end_at.read()
        }

        fn started(self: @ContractState) -> bool {
            self.started.read()
        }

        fn ended(self: @ContractState) -> bool {
            self.ended.read()
        }

        fn highest_bidder(self: @ContractState) -> ContractAddress {
            self.highest_bidder.read()
        }

        fn highest_bid(self: @ContractState) -> u256 {
            self.highest_bid.read()
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn zero_address(self: @ContractState) -> ContractAddress {
            contract_address_const::<0>()
        }
    }
}
