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

#[test]
fn test_voting_poll_constructor() {
    let contract_address = deploy_contract("VotingFactory");
    let factory_contract = IVotingFactoryDispatcher { contract_address };

    let voting_poll_clash = declare("Voting").unwrap().contract_class();
    let title = "2027 Election";
    let candidates: Array<ByteArray> = array!["Candidate 1", "Candidate 2", "Candidate 3"];

    factory_contract.create_poll(*voting_poll_clash.class_hash, title, candidates);

    let polls = factory_contract.get_voting_polls();

    let voting_poll_contract = IVotingDispatcher { contract_address: *polls.at(0) };

    assert( voting_poll_contract.factory() == contract_address, 'wrong factory address');
}