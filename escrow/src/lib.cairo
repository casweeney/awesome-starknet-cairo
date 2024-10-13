use starknet::ContractAddress;
pub mod ierc20;

#[starknet::interface]
pub trait IEscrow<TContractState> {
    fn transact(ref self: TContractState, token: ContractAddress, amount: u256, fee: u256);
    fn refund_user(ref self: TContractState, transaction_id: u256);
    fn verify_transaction(ref self: TContractState, transaction_id: u256);
    fn withdraw(ref self: TContractState, token: ContractAddress);
    fn change_admin(ref self: TContractState, new_admin: ContractAddress);
    fn get_all_transaction(self: @TContractState) -> Array<Escrow::Transaction>;
}

#[starknet::contract]
mod Escrow {
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use core::starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, 
        Map, StoragePathEntry,
        MutableVecTrait, Vec, VecTrait
    };
    use core::{num::traits::Zero};
    use escrow::ierc20::{IERC20Dispatcher, IERC20DispatcherTrait};

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

    #[derive(Drop, Copy, Serde, starknet::Store)]
    pub struct Transaction {
        id: u256,
        transaction_owner: ContractAddress,
        token: ContractAddress,
        amount: u256,
        fee: u256,
        payment_status: PaymentStatus,
        is_verified: bool,
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    enum PaymentStatus {
        Pending,
        Comfirmed,
        Refunded,
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress, treasury: ContractAddress, fee_treasury: ContractAddress) {
        assert!(admin.is_non_zero(), "Zero address detected for admin");
        assert!(treasury.is_non_zero(), "Zero address detected for treasury");
        assert!(fee_treasury.is_non_zero(), "Zero address detected for fee treasury");

        self.admin.write(admin);
        self.treasury.write(treasury);
        self.fee_treasury.write(fee_treasury);
    }

    #[abi(embed_v0)]
    impl EscrowImpl of super::IEscrow<ContractState> {
        fn transact(ref self: ContractState, token: ContractAddress, amount: u256, fee: u256) {
            assert!(self.admin.read().is_non_zero(), "Zero address detected for admin");
            assert!(self.treasury.read().is_non_zero(), "Zero address detected for treasury");
            assert!(self.fee_treasury.read().is_non_zero(), "Zero address detected for fee treasury");

            assert!(amount > 0, "can't transact zero value");
            assert!(fee > 0, "can't pay zero fee");

            let caller = get_caller_address();
            let this_contract = get_contract_address();
            let total_deposit = amount + fee;
            let token_contract = IERC20Dispatcher { contract_address: token };

            let transfer = token_contract.transfer_from(caller, this_contract, total_deposit);

            assert!(transfer, "transfer failed");

            let transaction_id = self.last_transaction_id.read() + 1;

            let transaction = Transaction {
                id: transaction_id,
                transaction_owner: caller,
                token,
                amount,
                fee,
                payment_status: PaymentStatus::Pending,
                is_verified: false,
            };

            self.last_transaction_id.write(self.last_transaction_id.read() + 1);
            self.total_deposit.write(self.total_deposit.read() + total_deposit);
            self.total_amount.write(self.total_amount.read() + amount);
            self.total_fee.write(self.total_fee.read() + fee);

            self.transactions.entry(transaction_id).write(transaction.clone());

            self.transaction_record.append().write(transaction.clone());
        }

        fn refund_user(ref self: ContractState, transaction_id: u256) {

        }

        fn verify_transaction(ref self: ContractState, transaction_id: u256) {

        }

        fn withdraw(ref self: ContractState, token: ContractAddress) {

        }

        fn change_admin(ref self: ContractState, new_admin: ContractAddress) {

        }

        fn get_all_transaction(self: @ContractState) -> Array<Transaction> {

        }
    }
}
