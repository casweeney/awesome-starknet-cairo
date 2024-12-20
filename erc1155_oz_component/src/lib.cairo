use starknet::ContractAddress;
pub mod ierc1155;
pub mod mock_1155_receiver;

#[starknet::interface]
pub trait IGameAsset<TContractState> {
    fn mint(ref self: TContractState, recipient: ContractAddress, token_ids: Span<u256>, values: Span<u256>);
}

#[starknet::contract]
mod GameAsset {
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc1155::{ERC1155Component, ERC1155HooksEmptyImpl};
    use starknet::ContractAddress;

    component!(path: ERC1155Component, storage: erc1155, event: ERC1155Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc1155: ERC1155Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC1155Event: ERC1155Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, token_uri: ByteArray) {
        self.erc1155.initializer(token_uri);
    }

    #[abi(embed_v0)]
    impl ERC1155Impl = ERC1155Component::ERC1155MixinImpl<ContractState>;

    impl ERC1155InternalImpl = ERC1155Component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl GameAssetImpl of super::IGameAsset<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress, token_ids: Span<u256>, values: Span<u256>) {
            self.erc1155.batch_mint_with_acceptance_check(recipient, token_ids, values, array![].span());
        }
    }
}
