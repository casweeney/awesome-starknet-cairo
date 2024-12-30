use starknet::ContractAddress;
use crate::voting::Voting::Candidate;

#[starknet::interface]
pub trait IVoting<TContractState> {
    fn create_poll(ref self: TContractState, title: ByteArray, candidates: Array<ByteArray>);
    fn vote(ref self: TContractState, candidate_id: u256);

    fn has_voted(self: @TContractState, voter: ContractAddress) -> bool;
    fn factory(self: @TContractState) -> ContractAddress;
    fn winning_candidate(self: @TContractState) -> u256;
    fn winner_name(self: @TContractState) -> ByteArray;
    fn fetch_candidates(self: @TContractState) -> Array<Candidate>;
}