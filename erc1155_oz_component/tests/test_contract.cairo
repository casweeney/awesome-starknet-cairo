use starknet::ContractAddress;
use snforge_std::{declare, ContractClassTrait};
use erc1155_oz_component::ierc1155::{IERC1155Dispatcher, IERC1155DispatcherTrait};

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let token_uri: ByteArray = "https://dummy_uri.com/your_id";
    let mut constructor_calldata: Array<felt252> = ArrayTrait::new();
    token_uri.serialize(ref constructor_calldata);

    let contract = declare(name).unwrap();
    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();
    
    contract_address
}

// #[test]
// fn test_constructor() {
//     let contract_address = deploy_contract("GameAsset");

//     let erc1155_token = IERC1155Dispatcher { contract_address };

//     assert(1 == 1, 'got here');

//     let recipient: ContractAddress = starknet::contract_address_const::<0x123456789>();

//     let token_ids = array![1_u256, 2_u256, 3_u256].span();
//     let values = array![10_u256, 20_u256, 30_u256].span();

//     erc1155_token.mint(recipient, token_ids, values);

//     let token_uri = erc1155_token.uri(1_u256);
//     assert(token_uri == "https://dummy_uri.com/your_id", 'wrong token uri');
// }

#[test]
fn test_mint() {
    let contract_address = deploy_contract("GameAsset");
    
    let game_asset = IERC1155Dispatcher { contract_address };
    
    let recipient: ContractAddress = starknet::contract_address_const::<0x123456789>();
    let token_ids = array![1_u256, 2_u256, 3_u256].span();
    let values = array![10_u256, 20_u256, 30_u256].span();
    
    game_asset.mint(recipient, token_ids, values);
    

    assert(game_asset.balance_of(recipient, 1_u256) == 10_u256, 'Wrong balance for token 1');
    assert(game_asset.balance_of(recipient, 2_u256) == 20_u256, 'Wrong balance for token 2');
    assert(game_asset.balance_of(recipient, 3_u256) == 30_u256, 'Wrong balance for token 3');
}
