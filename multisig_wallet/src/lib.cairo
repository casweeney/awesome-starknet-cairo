use starknet::ContractAddress;

#[starknet::interface]
pub trait IMultisigWallet<TContractState> {
    fn init_transfer(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn approve_transaction(ref self: TContractState, tx_id: u256);
}

#[starknet::contract]
mod HelloStarknet {
    use starknet::{ContractAddress, contract_address_const};
    use core::starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, 
        Map, StoragePathEntry,
        MutableVecTrait, Vec, VecTrait
    };

    #[storage]
    struct Storage {
        quorum: u256,
        no_of_valid_signers: u256,
        tx_count: u256,
        is_valid_signer: Map<ContractAddress, bool>,
        transactions: Map<u256, Transaction>,
        has_signed: Map<(ContractAddress, u256), bool>,
        transaction_signers: Map<u256, Vec<ContractAddress>>
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    pub struct Transaction {
        pub id: u256,
        pub amount: u256,
        pub initiator: ContractAddress,
        pub recipient: ContractAddress,
        pub is_completed: bool,
        pub timestamp: u256,
        pub no_of_approval: u256,
        pub token_address: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, quorum: u256, valid_signers: Array<ContractAddress>) {
        assert!(quorum > 1, "few quorum");
        assert!(valid_signers.len().try_into().unwrap() >= quorum, "valid signers less than quorum");

        for i in 0..valid_signers.len() {
            let signer = *valid_signers.at(i);

            assert!(signer != self.zero_address(), "zero address not allowed");

            self.is_valid_signer.entry(signer).write(true);
        };

        self.quorum.write(quorum);
        self.no_of_valid_signers.write(valid_signers.len().try_into().unwrap());
    }

    #[abi(embed_v0)]
    impl MultisigWallet of super::IMultisigWallet<ContractState> {
        fn init_transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) {

        }

        fn approve_transaction(ref self: ContractState, tx_id: u256) {

        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn zero_address(self: @ContractState) -> ContractAddress {
            contract_address_const::<0>()
        }
    }
}
