use starknet::{ContractAddress, ClassHash};

#[starknet::interface]
pub trait IVotingFactory<TContractState> {
    fn create_poll(ref self: TContractState, voting_poll_classhash: ClassHash, title: ByteArray, candidates: Array<ByteArray>);

    fn get_voting_polls(self: @TContractState) -> Array<ContractAddress>;
    fn total_voting_poll(self: @TContractState) -> u256;
}