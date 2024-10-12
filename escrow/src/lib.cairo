use starknet::ContractAddress;

#[starknet::interface]
pub trait IEscrow<TContractState> {
    fn transact(ref self: TContractState, token: ContractAddress, amount: u256, fee: u256);
    fn refund_user(ref self: TContractState, transaction_id: u256);
    fn verify_transaction(ref self: TContractState, transaction_id: u256);
    fn withdraw(ref self: TContractState, token: ContractAddress);
    fn get_all_transaction(self: @TContractState) -> Array<Escrow::Transaction>;
}

#[starknet::contract]
mod Escrow {
    use starknet::ContractAddress;
    use core::starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, 
        Map, StoragePathEntry,
        MutableVecTrait, Vec, VecTrait
    };

    #[storage]
    struct Storage {
        admin: ContractAddress,
        treasury: ContractAddress,
        fee_treasury: ContractAddress,
        last_transaction_id: u256,
        total_deposit: u256,
        total_amount: u256,
        total_fee: u256,
        transactions: Map<u256, Transaction>, 
        transaction_record: Vec<Transaction>
    }

    pub struct Transaction {
        id: u256,
        transaction_owner: ContractAddress,
        token: ContractAddress,
        amount: u256,
        fee: u256,
        payment_status: PaymentStatus,
        is_verified: bool,
    }

    enum PaymentStatus {
        Pending,
        Comfirmed,
        Refunded,
    }

    #[abi(embed_v0)]
    impl EscrowImpl of super::IEscrow<ContractState> {
        fn transact(ref self: ContractState, token: ContractAddress, amount: u256, fee: u256) {

        }

        fn refund_user(ref self: ContractState, transaction_id: u256) {

        }

        fn verify_transaction(ref self: ContractState, transaction_id: u256) {

        }

        fn withdraw(ref self: ContractState, token: ContractAddress) {

        }

        fn get_all_transaction(self: @ContractState) -> Array<Transaction> {

        }
    }
}
