use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, start_cheat_caller_address, stop_cheat_caller_address};

#[starknet::interface]
pub trait IERC721<TContractState> {
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;
    fn safe_transfer_from(
        ref self: TContractState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );
    fn transfer_from(ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn approve(ref self: TContractState, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TContractState, operator: ContractAddress, approved: bool);
    fn get_approved(self: @TContractState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(self: @TContractState, owner: ContractAddress, operator: ContractAddress) -> bool;

    // IERC721Metadata
    fn name(self: @TContractState) -> ByteArray;
    fn symbol(self: @TContractState) -> ByteArray;
    fn token_uri(self: @TContractState, token_id: u256) -> ByteArray;

    // NFT contract
    fn mint(ref self: TContractState, recipient: ContractAddress, token_id: u256);
}

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let token_uri: ByteArray = "https://dummy_uri.com/your_id";
    let mut constructor_calldata: Array<felt252> = ArrayTrait::new();
    token_uri.serialize(ref constructor_calldata);

    let contract = declare(name).unwrap();
    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();
    
    contract_address
}

#[test]
fn test_constructor() {
    let contract_address = deploy_contract("CasOnStark");

    let erc721_token = IERC721Dispatcher { contract_address };

    let token_name = erc721_token.name();
    let token_symbol = erc721_token.symbol();

    assert(token_name == "Make it Work", 'wrong token name');
    assert(token_symbol == "MIW", 'wrong token symbol');
}

#[test]
fn test_mint() {
    let contract_address = deploy_contract("CasOnStark");

    let erc721_token = IERC721Dispatcher { contract_address };

    let token_recipient: ContractAddress = starknet::contract_address_const::<0x123456711>();

    erc721_token.mint(token_recipient, 1);

    assert(erc721_token.owner_of(1) == token_recipient, 'wrong token id');
    assert(erc721_token.balance_of(token_recipient) > 0, 'mint failed');
}

#[test]
fn test_approve() {
    let contract_address = deploy_contract("CasOnStark");
    let erc721_token = IERC721Dispatcher { contract_address };

    let owner: ContractAddress = 0x07ab19dfcc6981ad7beba769a71a2d1cdd52b3d8a1484637bbb79f18a170cd51.try_into().unwrap();

    erc721_token.mint(owner, 1);


    let recipient: ContractAddress = 0x03af13f04C618e7824b80b61e141F5b7aeDB07F5CCe3aD16Dbd8A4BE333A3Ffa.try_into().unwrap();

    start_cheat_caller_address(contract_address, owner);
    erc721_token.approve(recipient, 1);
    stop_cheat_caller_address(contract_address);

    assert(erc721_token.get_approved(1) == recipient, 'incorrect approval');
}

#[test]
fn test_transfer() {
    let contract_address = deploy_contract("CasOnStark");
    let erc721_token = IERC721Dispatcher { contract_address };

    let owner: ContractAddress = 0x07ab19dfcc6981ad7beba769a71a2d1cdd52b3d8a1484637bbb79f18a170cd51.try_into().unwrap();
    let recipient: ContractAddress = 0x03af13f04C618e7824b80b61e141F5b7aeDB07F5CCe3aD16Dbd8A4BE333A3Ffa.try_into().unwrap();

    start_cheat_caller_address(contract_address, owner);

    erc721_token.mint(owner, 1);

    assert(erc721_token.balance_of(owner) > 0, 'mint failed');
    assert(erc721_token.balance_of(owner) == 1, 'wrong mint count');

    erc721_token.transfer_from(owner, recipient, 1);

    stop_cheat_caller_address(contract_address);

    assert(erc721_token.balance_of(owner) == 0, 'transfer failed');
    assert(erc721_token.balance_of(recipient) == 1, 'token transfer failed');

    assert(erc721_token.owner_of(1) == recipient, 'failed to transfer');
}