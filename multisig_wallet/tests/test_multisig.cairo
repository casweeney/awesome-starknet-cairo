use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address, stop_cheat_caller_address};

use multisig_wallet::interfaces::imultisig_wallet::{IMultisigWalletDispatcher, IMultisigWalletDispatcherTrait};
use multisig_wallet::interfaces::ierc20::{IERC20Dispatcher, IERC20DispatcherTrait};

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

#[test]
fn test_init_transfer() {
    let multisi_contract_address = setup_multisig_wallet();
    let multisig_wallet = IMultisigWalletDispatcher { contract_address: multisi_contract_address };

    let mock_token_address = deploy_mock_token();
    let mock_token = IERC20Dispatcher {contract_address: mock_token_address};

    let mint_amount: u256 = 1000000_u256;

    mock_token.mint(multisi_contract_address, mint_amount);

    assert!(mock_token.balance_of(multisi_contract_address) == mint_amount, "wrong token balance");

    let signer1: ContractAddress = starknet::contract_address_const::<0x123456789>();
    let recipient: ContractAddress = starknet::contract_address_const::<0x003456700>();
    let trf_amount: u256 = 100_u256;

    start_cheat_caller_address(multisi_contract_address, signer1);

    multisig_wallet.init_transfer(mock_token_address, recipient, trf_amount);

    assert!(multisig_wallet.tx_count() == 1, "wrong transaction count");

    stop_cheat_caller_address(multisi_contract_address);
}

#[test]
fn test_approve_transaction() {
    let multisi_contract_address = setup_multisig_wallet();
    let multisig_wallet = IMultisigWalletDispatcher { contract_address: multisi_contract_address };

    let mock_token_address = deploy_mock_token();
    let mock_token = IERC20Dispatcher {contract_address: mock_token_address};

    let mint_amount: u256 = 1000000_u256;

    mock_token.mint(multisi_contract_address, mint_amount);

    assert!(mock_token.balance_of(multisi_contract_address) == mint_amount, "wrong token balance");

    let signer1: ContractAddress = starknet::contract_address_const::<0x123456789>();
    let signer2: ContractAddress = starknet::contract_address_const::<0x123006789>();
    let signer3: ContractAddress = starknet::contract_address_const::<0x123116789>();

    let recipient: ContractAddress = starknet::contract_address_const::<0x003456700>();
    let trf_amount: u256 = 100_u256;

    start_cheat_caller_address(multisi_contract_address, signer1);
    multisig_wallet.init_transfer(mock_token_address, recipient, trf_amount);
    stop_cheat_caller_address(multisi_contract_address);

    start_cheat_caller_address(multisi_contract_address, signer2);
    multisig_wallet.approve_transaction(1);
    stop_cheat_caller_address(multisi_contract_address);

    start_cheat_caller_address(multisi_contract_address, signer3);
    multisig_wallet.approve_transaction(1);
    stop_cheat_caller_address(multisi_contract_address);

    assert!(mock_token.balance_of(recipient) == trf_amount, "transfer failed");
}