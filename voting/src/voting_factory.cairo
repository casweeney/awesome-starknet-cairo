#[starknet::contract]
mod VotingFactory {
    use crate::interfaces::ivoting_factory::IVotingFactory;
    use starknet::ContractAddress;
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

    #[abi(embed_v0)]
    impl VotingFactoryImpl of IVotingFactory<ContractState> {
        fn create_poll(ref self: ContractState, title: ByteArray, candidates: Span<ByteArray>) {
            
        }

        fn get_voting_polls(self: @ContractState) -> Array<ContractAddress> {

        }

        fn total_voting_poll(self: @ContractState) -> u256 {

            8
        }
    }
}
