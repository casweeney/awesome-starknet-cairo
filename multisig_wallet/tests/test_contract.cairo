use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use multisig_wallet::interfaces::imultisig_wallet::{IMultisigWalletDispatcher, IMultisigWalletDispatcherTrait};
// use multisig_wallet::interfaces::ierc20::{IERC20Dispatcher, IERC20DispatcherTrait};

fn deploy_mock_token() -> ContractAddress {
    let mut constructor_calldata = ArrayTrait::new();

    let contract = declare("MockToken").unwrap().contract_class();
    let (erc20_contract_address, _) = contract.deploy(@constructor_calldata).unwrap();

    erc20_contract_address
}

fn setup_multisig_wallet() -> ContractAddress {
    // let mut constructor_calldata = ArrayTrait::new();
    let mut constructor_calldata: Array<felt252> = ArrayTrait::new();

    let signer1: ContractAddress = starknet::contract_address_const::<0x123456789>();
    let signer2: ContractAddress = starknet::contract_address_const::<0x123006789>();
    let signer3: ContractAddress = starknet::contract_address_const::<0x123116789>();

    let quorum: u256 = 3;
    let valid_signers: Array<ContractAddress> = array![signer1, signer2, signer3];

    quorum.serialize(ref constructor_calldata);
    valid_signers.serialize(ref constructor_calldata);

    let contract = declare("MultisigWallet").unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();
    contract_address
}

#[test]
fn test_constructor() {
    let multisi_contract_address = setup_multisig_wallet();
    let multisig_wallet = IMultisigWalletDispatcher { contract_address: multisi_contract_address };

    assert!(multisig_wallet.quorum() == 3, "wrong quorum");
    assert!(multisig_wallet.no_of_valid_signers() == 3, "wrong quorum");
}