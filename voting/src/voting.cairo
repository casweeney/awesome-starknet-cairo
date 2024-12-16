#[starknet::contract]
mod Voting {
    use crate::interfaces::ivoting::IVoting;
    use starknet::{ContractAddress, get_caller_address};
    use core::starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, 
        Map, StoragePathEntry,
        MutableVecTrait, Vec
    };

    #[storage]
    struct Storage {
        factory: ContractAddress,
        title: ByteArray,
        candidates: Vec<Candidate>,
        voters: Map<ContractAddress, Voter>,
        candidates_count: u256,
    }

    #[derive(Drop, Serde, starknet::Store)]
    pub struct Candidate {
        pub name: ByteArray,
        pub vote_count: u256,
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    pub struct Voter {
        pub voted: bool,
        pub vote: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, factory: ContractAddress) {
        self.factory.write(factory);
    }

    #[abi(embed_v0)]
    impl VotingImpl of IVoting<ContractState> {
        fn create_poll(ref self: ContractState, title: ByteArray, candidates: Array<ByteArray>) {
            self.title.write(title);

            for candidate in candidates {
                self.candidates.append().write(
                    Candidate {
                        name: candidate,
                        vote_count: 0
                    }
                );
            }

            self.candidates_count.write(candidates.len());
        }

        fn vote(ref self: ContractState, candidate: u256) {
            let caller = get_caller_address();
            assert(self.voters.entry(caller).voted.read() == false, 'already voted');

            let voter = Voter {
                voted: true,
                vote: candidate
            };

            self.voters.entry(caller).write(voter);

            // TODO Increment Candidate VoteCount
        }

        fn has_voted(self: @ContractState, voter: ContractAddress) -> bool {
            self.voters.entry(voter).voted.read()
        }

        fn factory(self: @ContractState) -> ContractAddress {
            self.factory.read()
        }

        fn winning_candidate(self: @ContractState) -> u256 {
            // TODO Get winning candidate
            8
        }

        fn winner_name(self: @ContractState) -> ByteArray {
            // TODO Get winner name
            ""
        }
    }
}
