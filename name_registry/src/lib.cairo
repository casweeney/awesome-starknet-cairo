use core::starknet::ContractAddress;

#[starknet::interface]
pub trait INameRegistry<TContractState> {
    fn store_name(ref self: TContractState, name: felt252, registration_type: NameRegistry::RegistrationType);
    fn get_name(self: @TContractState, address: ContractAddress) -> felt252;
    fn get_owner(self: @TContractState) -> NameRegistry::Person;
    fn get_owner_name(self: @TContractState) -> felt252;
    fn get_registration_info(self: @TContractState, address: ContractAddress) -> NameRegistry::RegistrationInfo;
}

#[starknet::contract]
mod NameRegistry {
    use starknet::event::EventEmitter;
use core::starknet::{ContractAddress, get_caller_address};
    use core::starknet::storage::{Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        names: Map::<ContractAddress, felt252>,
        owner: Person,
        registrations: Map<ContractAddress, RegistrationNode>,
        total_names: u128,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        StoredName: StoredName,
    }
    #[derive(Drop, starknet::Event)]
    struct StoredName {
        #[key]
        user: ContractAddress,
        name: felt252,
    }

    #[derive(Drop, Serde, starknet::Store)]
    pub struct Person {
        address: ContractAddress,
        name: felt252,
    }

    #[starknet::storage_node]
    struct RegistrationNode {
        count: u64,
        info: RegistrationInfo,
        history: Map<u64, RegistrationInfo>,
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    pub struct RegistrationInfo {
        name: felt252,
        registration_type: RegistrationType,
        registration_date: u64,
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    pub enum RegistrationType {
        finite: u64,
        inifite
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: Person) {
        self.names.entry(owner.address).write(owner.name);
        self.total_names.write(1);
        self.owner.write(owner);
    }

    #[abi(embed_v0)]
    impl NameRegistry of super::INameRegistry<ContractState> {
        fn store_name(ref self: ContractState, name: felt252, registration_type: RegistrationType) {
            let caller = get_caller_address();
            self._store_name(caller, name, registration_type);
        }

        fn get_name(self: @ContractState, address: ContractAddress) -> felt252 {
            self.names.entry(address).read()
        }

        fn get_owner(self: @ContractState) -> Person {
            self.owner.read()
        }

        fn get_owner_name(self: @ContractState) -> felt252 {
            self.owner.name.read()
        }

        fn get_registration_info(self: @ContractState, address: ContractAddress) -> RegistrationInfo {
            self.registrations.entry(address).info.read()
        }
    }

    // Standalone public function
    #[external(v0)]
    fn get_contract_name(self: @ContractState) -> felt252 {
        'Name Registry'
    }

    #[generate_trait]
    impl InternalFunction of InternalFunctionsTrait {
        fn _store_name(ref self: ContractState, user: ContractAddress, name: felt252, registration_type: RegistrationType) {
            let total_names = self.total_names.read();

            self.names.entry(user).write(name);

            let registration_info = RegistrationInfo {
                name,
                registration_type,
                registration_date: starknet::get_block_timestamp(),
            };

            let mut registration_node = self.registrations.entry(user);
            registration_node.info.write(registration_info);

            let count = registration_node.count.read();
            registration_node.history.entry(count).write(registration_info);
            registration_node.count.write(count + 1);

            self.total_names.write(total_names + 1);

            self.emit(StoredName {user, name});
        }
    }

    // Free function
    fn get_owner_storage_address(self: @ContractState) -> felt252 {
        self.owner.__base_address__
    }
}