use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait};

use piggy_savings::interfaces::piggy_bank_factory_interface::IPiggyBankFactoryDispatcher;
use piggy_savings::interfaces::piggy_bank_factory_interface::IPiggyBankFactoryDispatcherTrait;

fn deploy_contract(name: ByteArray) -> (ContractAddress, ContractAddress) {
    let owner: ContractAddress = starknet::contract_address_const::<0x123456789>();

    let mut constructor_calldata = ArrayTrait::new();
    constructor_calldata.append(owner.into());

    let contract = declare(name).unwrap();
    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();

    (contract_address, owner)
}

#[test]
fn test_constructor() {

    let (contract_address, owner) = deploy_contract("PiggyBankFactory");

    let piggy_factory = IPiggyBankFactoryDispatcher { contract_address };

    let contract_owner = piggy_factory.owner();

    assert(contract_owner == owner, 'Owner failed to set');
}

// #[test]
// #[feature("safe_dispatcher")]
// fn test_cannot_increase_balance_with_zero_value() {
//     let contract_address = deploy_contract("HelloStarknet");

//     let safe_dispatcher = IHelloStarknetSafeDispatcher { contract_address };

//     let balance_before = safe_dispatcher.get_balance().unwrap();
//     assert(balance_before == 0, 'Invalid balance');

//     match safe_dispatcher.increase_balance(0) {
//         Result::Ok(_) => core::panic_with_felt252('Should have panicked'),
//         Result::Err(panic_data) => {
//             assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
//         }
//     };
// }
