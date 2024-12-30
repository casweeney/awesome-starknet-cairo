use starknet::ContractAddress;

#[starknet::interface]
pub trait IAuction<TContractState> {
    fn start(ref self: TContractState);
    fn bid(ref self: TContractState, amount: u256);
    fn withdraw(ref self: TContractState);
    fn end(ref self: TContractState);

    fn accepted_erc20_token(self: @TContractState) -> ContractAddress;
    fn nft(self: @TContractState) -> ContractAddress;
    fn nft_id(self: @TContractState) -> u256;
    fn seller(self: @TContractState) -> ContractAddress;
    fn end_at(self: @TContractState) -> u256;
    fn started(self: @TContractState) -> bool;
    fn ended(self: @TContractState) -> bool;
    fn highest_bidder(self: @TContractState) -> ContractAddress;
    fn highest_bid(self: @TContractState) -> u256;
}