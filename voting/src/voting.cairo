#[starknet::contract]
pub mod Voting {
    use crate::interfaces::ivoting::IVoting;
    use starknet::{ContractAddress, get_caller_address};
    use core::starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, 
        Map, StoragePathEntry
    };

    #[storage]
    struct Storage {
        factory: ContractAddress,
        title: ByteArray,
        candidates: Map<u256, Candidate>,
        voters: Map<ContractAddress, Voter>,
        candidates_count: u256,
    }

    #[derive(Drop, Serde, starknet::Store)]
    pub struct Candidate {
        pub id: u256,
        pub name: ByteArray,
        pub vote_count: u256,
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    pub struct Voter {
        pub voted: bool,
        pub vote_for: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, factory: ContractAddress) {
        self.factory.write(factory);
    }

    #[abi(embed_v0)]
    impl VotingImpl of IVoting<ContractState> {
        fn create_poll(ref self: ContractState, title: ByteArray, candidates: Array<ByteArray>) {
            self.title.write(title);
            
            for candidate in candidates.clone() {
                let candidate_count = self.candidates_count.read();
                let id = candidate_count + 1;

                self.candidates.entry(id).write(
                    Candidate {
                        id: id,
                        name: candidate,
                        vote_count: 0
                    }
                );

                self.candidates_count.write(candidate_count + 1);
            };

            self.candidates_count.write(candidates.len().try_into().unwrap());
        }

        fn vote(ref self: ContractState, candidate_id: u256) {
            let caller = get_caller_address();
            assert(self.voters.entry(caller).voted.read() == false, 'already voted');

            let voter = Voter {
                voted: true,
                vote_for: candidate_id
            };

            self.voters.entry(caller).write(voter);

            let candidate = self.candidates.entry(candidate_id).read();
            self.candidates.entry(candidate_id).vote_count.write(candidate.vote_count + 1);
        }

        fn has_voted(self: @ContractState, voter: ContractAddress) -> bool {
            self.voters.entry(voter).voted.read()
        }

        fn factory(self: @ContractState) -> ContractAddress {
            self.factory.read()
        }

        fn winning_candidate(self: @ContractState) -> u256 {
            let mut winning_candidate = 0;
            let mut winning_vote_count = 0;
            let mut i = 1;

            while i < self.candidates_count.read() + 1 {
                let candidate = self.candidates.entry(i).read();
                if candidate.vote_count > winning_vote_count {
                    winning_vote_count = candidate.vote_count;
                    winning_candidate = i;
                }
            };


            winning_candidate
        }

        fn winner_name(self: @ContractState) -> ByteArray {
            let winning_candidate = self.winning_candidate();
            let winner_name = self.candidates.entry(winning_candidate).name.read();
            winner_name
        }

        fn fetch_candidates(self: @ContractState) -> Array<Candidate> {
            let mut candidates: Array<Candidate> = array![];
            let mut i = 1;

            while i < self.candidates_count.read() + 1 {
                let candidate = self.candidates.entry(i).read();
                candidates.append(candidate);
            };

            candidates
        }
    }
}
