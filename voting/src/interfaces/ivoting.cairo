use starknet::ContractAddress;

#[starknet::interface]
pub trait IVoting<TContractState> {
    fn create_poll(ref self: TContractState, title: ByteArray, candidates: Array<ByteArray>);
    fn vote(ref self: TContractState, candidate: u256);

    fn has_voted(self: @TContractState, voter: ContractAddress) -> bool;
    fn factory(self: @TContractState) -> ContractAddress;
    fn winning_candidate(self: @TContractState) -> u256;
    fn winner_name(self: @TContractState) -> ByteArray;
}