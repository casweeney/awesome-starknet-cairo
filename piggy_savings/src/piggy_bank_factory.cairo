#[starknet::contract]
mod PiggyBankFactory {
    use piggy_savings::interfaces::piggy_bank_factory_interface::IPiggyBankFactory;
    use starknet::{ContractAddress, syscalls::deploy_syscall, ClassHash, get_caller_address};
    use core::starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, 
        Map, StoragePathEntry,
        MutableVecTrait, Vec, VecTrait
    };

    #[storage]
    struct Storage {
        owner: ContractAddress,
        piggy_banks: Vec<ContractAddress>,
        user_piggy_banks: Map<ContractAddress, Vec<ContractAddress>>,
        total_piggy_banks: u256,
    }

    #[abi(embed_v0)]
    impl PiggyBankFactoryImpl of IPiggyBankFactory<ContractState> {
        fn create_piggy_bank(ref self: ContractState, piggy_bank_classhash: ClassHash, dev_address: ContractAddress, saving_purpose: ByteArray, time_lock: u256) {
            let mut payload = array![];

            let caller = get_caller_address();
            piggy_bank_classhash.serialize(ref payload);
            caller.serialize(ref payload);
            dev_address.serialize(ref payload);
            saving_purpose.serialize(ref payload);
            time_lock.serialize(ref payload);

            let (piggy_bank_contract, _) = deploy_syscall(piggy_bank_classhash, 0, payload.span(), false).unwrap();

            self.total_piggy_banks.write(self.total_piggy_banks.read() + 1);
            
            self.piggy_banks.append().write(piggy_bank_contract);

            let user_banks = self.user_piggy_banks.entry(caller);

            loop {
                let mut i = 0;

                if i > self.piggy_banks.len() {
                    break;
                }

                let mut bank_contract = self.piggy_banks.at(i).read();

                user_banks.append().write(bank_contract);

                i += 1;
            }
        }

        fn get_all_piggy_banks(self: @ContractState) -> Array<ContractAddress> {
            let mut bank_contracts_array = array![];

            for index in 0..self.piggy_banks.len() {
                bank_contracts_array.append(self.piggy_banks.at(index).read());
            };

            bank_contracts_array
        }

        fn total_bank_count(self: @ContractState) -> u256 {
            self.total_piggy_banks.read()
        }

        fn get_user_banks(self: @ContractState, user_address: ContractAddress) -> Array<ContractAddress> {
            let stored_addresses = self.user_piggy_banks.entry(user_address);

            let mut user_banks_array = array![];
            let mut index = 0;

            loop {
                if index > stored_addresses.len() {
                    break;
                }

                let mut bank_contract = stored_addresses.at(index).read();

                user_banks_array.append(bank_contract);

                index += 1;
            };

            user_banks_array
        }
        
        fn user_bank_count(self: @ContractState, user_address: ContractAddress) -> u256 {
            let stored_addresses = self.user_piggy_banks.entry(user_address);

            let mut user_banks_array = array![];
            let mut index = 0;

            loop {
                if index > stored_addresses.len() {
                    break;
                }

                let mut bank_contract = stored_addresses.at(index).read();

                user_banks_array.append(bank_contract);

                index += 1;
            };

            user_banks_array.len().into()
        }
    }
}