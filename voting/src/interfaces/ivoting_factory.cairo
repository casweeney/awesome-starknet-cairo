use starknet::ContractAddress;

#[starknet::interface]
pub trait IVotingFactory<TContractState> {
    fn create_poll(ref self: TContractState, title: ByteArray, candidates: Span<ByteArray>);

    fn get_voting_polls(self: @TContractState) -> Array<ContractAddress>;
    fn total_voting_poll(self: @TContractState) -> u256;
}