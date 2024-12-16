use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use voting::interfaces::ivoting::{IVotingDispatcher, IVotingDispatcherTrait};
use voting::interfaces::ivoting_factory::{IVotingFactoryDispatcher, IVotingFactoryDispatcherTrait};

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}

#[test]
fn test_create_poll() {
    let contract_address = deploy_contract("VotingFactory");
    let factory_contract = IVotingFactoryDispatcher { contract_address };

    let voting_poll_clash = declare("Voting").unwrap().contract_class();
    let title = "2027 Election";
    let candidates: Array<ByteArray> = array!["Peter Obi", "Tinubu", "Atiku"];

    factory_contract.create_poll(*voting_poll_clash.class_hash, title, candidates);

    assert(factory_contract.total_voting_poll() == 1, 'wrong poll count');
}