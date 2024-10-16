use starknet::ContractAddress;

use snforge_std::{
    declare,
    ContractClassTrait,
    start_cheat_caller_address,
    stop_cheat_caller_address,
    spy_events,
    EventSpyAssertionsTrait
};

use testing_cairo_contracts::IPizzaFactoryDispatcher;
use testing_cairo_contracts::IPizzaFactoryDispatcherTrait;
use testing_cairo_contracts::PizzaFactory;

// Imports for testing internal functions
use testing_cairo_contracts::PizzaFactory::{InternalTrait};
use testing_cairo_contracts::IPizzaFactory;


fn deploy_pizza_factory(name: ByteArray) -> (IPizzaFactoryDispatcher, ContractAddress, ContractAddress) {
    let contract = declare(name).unwrap();
    let owner: ContractAddress = starknet::contract_address_const::<0x123456789>();

    let mut constructor_calldata = ArrayTrait::new();
    constructor_calldata.append(owner.into());

    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();

    let dispatcher = IPizzaFactoryDispatcher { contract_address };

    (dispatcher, contract_address, owner)
}

/////////////// TESTING CONSTRUCTOR ////////////////////
#[test]
fn test_constructor() {
    let (pizza_factory, _, owner) = deploy_pizza_factory("PizzaFactory");

    let pepperoni_count = pizza_factory.get_pepperoni_count();
    let pineapple_count = pizza_factory.get_pineapple_count();

    assert(pepperoni_count == 10, 'Invalid pepperoni count');
    
    assert(pineapple_count == 10, 'Initial pineapple count');

    assert_eq!(pizza_factory.get_owner(), owner);
}


/////////////// MOCKING CALLER ////////////////////
#[test]
fn test_change_owner_should_change_owner() {
    let (pizza_factory, pizza_factory_address, owner) = deploy_pizza_factory("PizzaFactory");

    let new_owner: ContractAddress = starknet::contract_address_const::<0x123456711>();

    assert_eq!(pizza_factory.get_owner(), owner);

    start_cheat_caller_address(pizza_factory_address, owner);

    pizza_factory.change_owner(new_owner);

    assert_eq!(pizza_factory.get_owner(), new_owner);
}

#[test]
#[should_panic(expected: ("Only the owner can set ownership",))]
fn test_change_owner_should_panic_when_not_owner() {
    let (pizza_factory, pizza_factory_address, _) = deploy_pizza_factory("PizzaFactory");

    let not_owner: ContractAddress = starknet::contract_address_const::<0x100336711>();

    start_cheat_caller_address(pizza_factory_address, not_owner);

    pizza_factory.change_owner(not_owner);

    stop_cheat_caller_address(pizza_factory_address);
}

#[test]
#[should_panic(expected: ("Only the owner can make pizza",))]
fn test_make_pizza_should_panic_when_not_owner() {
    let (pizza_factory, pizza_factory_address, _) = deploy_pizza_factory("PizzaFactory");

    let not_owner: ContractAddress = starknet::contract_address_const::<0x100336711>();

    start_cheat_caller_address(pizza_factory_address, not_owner);

    pizza_factory.make_pizza();
}


/////////////// Capturing Events with spy_events ////////////////////
#[test]
fn test_make_pizza_should_increment_pizza_counter() {
    // Setup
    let (pizza_factory, pizza_factory_address, owner) = deploy_pizza_factory("PizzaFactory");

    start_cheat_caller_address(pizza_factory_address, owner);

    let mut spy = spy_events();

    // When
    pizza_factory.make_pizza();

    // Then
    let expected_event = PizzaFactory::Event::PizzaEmission(PizzaFactory::PizzaEmission { counter: 1 });
    

    

    assert_eq!(pizza_factory.count_pizza(), 1);

    spy.assert_emitted(@array![(pizza_factory_address, expected_event)]);

    spy
        .assert_emitted(
            @array![
                (
                    pizza_factory_address,
                    PizzaFactory::Event::PizzaEmission(
                        PizzaFactory::PizzaEmission { counter: 1 }
                    )
                )
            ]
        );
}


/////////////// Testing Internal Functions ////////////////////
#[test]
fn test_internal() {
    let mut state = PizzaFactory::contract_state_for_testing();

    let new_owner: ContractAddress = starknet::contract_address_const::<0x123456711>();

    state.set_owner(new_owner);

    let owner = state.get_owner();

    assert(owner == new_owner, 'Owner failed to set');
}
