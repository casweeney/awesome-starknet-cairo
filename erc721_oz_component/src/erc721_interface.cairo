#[starknet::interface]
pub trait ERC721ABI {
    // IERC721
    fn balance_of(account: ContractAddress) -> u256;
    fn owner_of(token_id: u256) -> ContractAddress;
    fn safe_transfer_from(
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );
    fn transfer_from(from: ContractAddress, to: ContractAddress, token_id: u256);
    fn approve(to: ContractAddress, token_id: u256);
    fn set_approval_for_all(operator: ContractAddress, approved: bool);
    fn get_approved(token_id: u256) -> ContractAddress;
    fn is_approved_for_all(owner: ContractAddress, operator: ContractAddress) -> bool;

    // IERC721Metadata
    fn name() -> ByteArray;
    fn symbol() -> ByteArray;
    fn token_uri(token_id: u256) -> ByteArray;
}