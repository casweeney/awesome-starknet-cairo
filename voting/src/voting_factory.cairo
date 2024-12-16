#[starknet::contract]
mod VotingFactory {
    use crate::interfaces::ivoting_factory::IVotingFactory;
    use crate::interfaces::ivoting::{IVotingDispatcher, IVotingDispatcherTrait};
    use starknet::{ContractAddress, syscalls::deploy_syscall, ClassHash, get_caller_address, get_contract_address};
    use core::starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, 
        Map, StoragePathEntry,
    };

    #[storage]
    struct Storage {
        voting_polls: Map<u256, ContractAddress>,
        voting_polls_count: u256,
    }

    #[abi(embed_v0)]
    impl VotingFactoryImpl of IVotingFactory<ContractState> {
        fn create_poll(ref self: ContractState, voting_poll_classhash: ClassHash, title: ByteArray, candidates: Array<ByteArray>) {
            let mut constructor_calldata = array![];

            let this_contract = get_contract_address();
            this_contract.serialize(ref constructor_calldata);

            let (voting_poll_contract, _) = deploy_syscall(voting_poll_classhash, 0, constructor_calldata.span(), false).unwrap();

            let polls_count = self.voting_polls_count.read();
            self.voting_polls_count.write(polls_count + 1);

            self.voting_polls.entry(polls_count + 1).write(voting_poll_contract);

            IVotingDispatcher{contract_address: voting_poll_contract}.create_poll(title, candidates);
        }

        fn get_voting_polls(self: @ContractState) -> Array<ContractAddress> {
            let mut voting_polls: Array<ContractAddress> = array![];
            let mut i = 1;

            while i < self.voting_polls_count.read() + 1 {
                let poll = self.voting_polls.entry(i).read();
                voting_polls.append(poll);
            };

            voting_polls
        }

        fn total_voting_poll(self: @ContractState) -> u256 {
            self.voting_polls_count.read()
        }
    }
}
