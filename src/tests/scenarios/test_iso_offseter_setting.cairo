// Core deps

use debug::PrintTrait;

// Starknet deps

use starknet::ContractAddress;
use starknet::deploy_syscall;
use starknet::testing::{set_caller_address, set_contract_address, set_block_timestamp};

// External deps

use openzeppelin::account::account::Account;
use openzeppelin::token::erc20::erc20::ERC20;
use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
use openzeppelin::token::erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait};
use cairo_erc_3525::presets::erc3525_mintable_burnable::{
    IExternalDispatcher as IERC3525Dispatcher, IExternalDispatcherTrait as IERC3525DispatcherTrait
};

// Components

use carbon::components::absorber::interface::{IAbsorberDispatcher, IAbsorberDispatcherTrait};
use carbon::components::access::interface::{ICertifierDispatcher, ICertifierDispatcherTrait};
use carbon::components::access::interface::{IMinterDispatcher, IMinterDispatcherTrait};
use carbon::components::farm::interface::{IFarmDispatcher, IFarmDispatcherTrait};
use carbon::components::offset::interface::{IOffsetDispatcher, IOffsetDispatcherTrait};

// Contracts

use carbon::contracts::project::{
    Project, IExternalDispatcher as IProjectDispatcher,
    IExternalDispatcherTrait as IProjectDispatcherTrait
};
use carbon::contracts::offseter::Offseter;
use carbon::contracts::minter::Minter;

// Constants

const NAME: felt252 = 'NAME';
const SYMBOL: felt252 = 'SYMBOL';
const DECIMALS: u8 = 6;
const SLOT: u256 = 1;
const SLOT2: u256 = 2;
const TON_EQUIVALENT: u64 = 1_000_000;
const PROJECT_VALUE: u256 = 17600_000_000;

const MAX_VALUE_PER_TX: u256 = 25_000_000;
const MIN_VALUE_PER_TX: u256 = 1_000_000;
const MAX_VALUE: u256 = 17600_000_000;
const UNIT_PRICE: u256 = 10;
const RESERVED_VALUE: u256 = 25_000_000;
const ALLOCATION: felt252 = 5;
const BILLION: u256 = 1_000_000_000_000;

const PRICE: u256 = 22;
const VALUE: u256 = 100_000_000;
const MIN_CLAIMABLE: u256 = 1;

// Signers
#[derive(Drop)]
struct Signers {
    owner: ContractAddress,
    anyone: ContractAddress,
}

#[derive(Drop)]
struct Contracts {
    project: ContractAddress,
    offseter: ContractAddress,
}

fn deploy_account(public_key: felt252) -> ContractAddress {
    let mut calldata = array![public_key];
    let (address, _) = deploy_syscall(
        Account::TEST_CLASS_HASH.try_into().expect('Class hash conversion failed'),
        0,
        calldata.span(),
        false
    )
        .expect('Account deploy failed');
    address
}

fn deploy_erc20(owner: ContractAddress) -> ContractAddress {
    let billion = 1000000000000;
    let mut calldata = array![NAME, SYMBOL, billion, 0, owner.into()];
    let (address, _) = deploy_syscall(
        ERC20::TEST_CLASS_HASH.try_into().expect('Class hash conversion failed'),
        0,
        calldata.span(),
        false
    )
        .expect('ERC20 deploy failed');
    address
}

fn deploy_project(owner: ContractAddress) -> ContractAddress {
    let mut calldata = array![NAME, SYMBOL, DECIMALS.into(), owner.into()];
    let (address, _) = deploy_syscall(
        Project::TEST_CLASS_HASH.try_into().expect('Class hash conversion failed'),
        0,
        calldata.span(),
        false
    )
        .expect('Project deploy failed');

    // [Setup] Project
    set_contract_address(owner);
    let absorber = IAbsorberDispatcher { contract_address: address };
    absorber.set_project_value(SLOT, PROJECT_VALUE);
    address
}

fn deploy_offseter(project: ContractAddress, owner: ContractAddress) -> ContractAddress {
    let mut calldata: Array<felt252> = array![
        project.into(),
        SLOT.low.into(),
        SLOT.high.into(),
        MIN_CLAIMABLE.low.into(),
        MIN_CLAIMABLE.high.into(),
        owner.into()
    ];
    let (address, _) = deploy_syscall(
        Offseter::TEST_CLASS_HASH.try_into().expect('Class hash conversion failed'),
        0,
        calldata.span(),
        false
    )
        .expect('Offseter deploy failed');
    address
}

fn deploy_minter(
    project: ContractAddress, erc20: ContractAddress, owner: ContractAddress
) -> ContractAddress {
    let public_sale_open: bool = false;
    let mut calldata: Array<felt252> = array![
        project.into(),
        SLOT.low.into(),
        SLOT.high.into(),
        erc20.into(),
        public_sale_open.into(),
        MAX_VALUE_PER_TX.low.into(),
        MAX_VALUE_PER_TX.high.into(),
        MIN_VALUE_PER_TX.low.into(),
        MIN_VALUE_PER_TX.high.into(),
        MAX_VALUE.low.into(),
        MAX_VALUE.high.into(),
        UNIT_PRICE.low.into(),
        UNIT_PRICE.high.into(),
        RESERVED_VALUE.low.into(),
        RESERVED_VALUE.high.into(),
        owner.into(),
    ];
    let (address, _) = deploy_syscall(
        Minter::TEST_CLASS_HASH.try_into().expect('Class hash conversion failed'),
        0,
        calldata.span(),
        false
    )
        .unwrap();
    //.expect('Minter deploy failed');
    address
}

fn setup_project(project: ContractAddress, signers: @Signers) {
    // Prank caller as owner
    set_contract_address(*signers.owner);
    // Grant certifier rights to owner
    let project = ICertifierDispatcher { contract_address: project };
    project.set_certifier(SLOT, *signers.owner);
    // Setup absorptions
    let project = IAbsorberDispatcher { contract_address: project.contract_address };
    let times: Array<u64> = array![
        1667314458,
        1698850458,
        1730472858,
        1762008858,
        1793544858,
        1825080858,
        1856703258,
        1888239258,
        1919775258,
        1951311258,
        1982933658,
        2046005658,
        2109164058,
        2172236058,
        2235394458,
        2266930458,
        2330002458,
        2361624858,
        2393160858,
        2424696858,
        2456232858,
        2487855258,
        2582463258,
        2614085658
    ];
    let absorptions: Array<u64> = array![
        0,
        4719000,
        12584000,
        25168000,
        40898000,
        64493000,
        100672000,
        147862000,
        202917000,
        265837000,
        333476000,
        478192000,
        629200000,
        773916000,
        915486000,
        983125000,
        1108965000,
        1164020000,
        1223794000,
        1280422000,
        1335477000,
        1387386000,
        1528956000,
        1573000000
    ];
    project.set_absorptions(SLOT, times.span(), absorptions.span(), TON_EQUIVALENT);
}

fn setup_project_apr(project: ContractAddress, signers: @Signers, n: u64) {
    // Prank caller as owner
    set_contract_address(*signers.owner);
    // Grant certifier rights to owner
    let project = ICertifierDispatcher { contract_address: project };
    project.set_certifier(SLOT, *signers.owner);
    // Setup absorptions
    let project = IAbsorberDispatcher { contract_address: project.contract_address };

    let (times, absorptions) = get_test_absorptions(n);
    project.set_absorptions(SLOT, times, absorptions, TON_EQUIVALENT);
}

fn get_test_absorptions(n: u64) -> (Span<u64>, Span<u64>) {
    let mut times: Array<u64> = Default::default();
    let mut absorptions: Array<u64> = Default::default();
    let mut i = 1;
    loop {
        if i > n {
            break;
        }
        times.append(i * 10);
        absorptions.append((i - 1) * 1000);
        i += 1;
    };
    (times.span(), absorptions.span())
}

fn get_test_prices(n: u64) -> (Span<u64>, Span<u256>) {
    let mut times: Array<u64> = Default::default();
    let mut prices: Array<u256> = Default::default();
    let mut i = 1;
    loop {
        if i > n {
            break;
        }
        times.append(i * 10 + 5);
        prices.append((i * 10).into());
        i += 1;
    };
    (times.span(), prices.span())
}



fn setup_offseter(project: ContractAddress, offseter: ContractAddress, signers: @Signers) {
    set_contract_address(*signers.owner);
    let farmer = IFarmDispatcher { contract_address: offseter };
    // Owner approve offseter to spend his tokens
    let project = IERC721Dispatcher { contract_address: project };
    project.set_approval_for_all(offseter, true);
    // Anyone approve offseter to spend his tokens
    set_contract_address(*signers.anyone);
    project.set_approval_for_all(offseter, true);
}

fn setup_minter(project: ContractAddress, minter: ContractAddress, signers: @Signers) {
    let project = IERC721Dispatcher { contract_address: project };
    // Owner approve minter to spend his tokens
    set_contract_address(*signers.owner);
    project.set_approval_for_all(minter, true);
    // Anyone approve minter to spend his tokens
    set_contract_address(*signers.anyone);
    project.set_approval_for_all(minter, true);
}

fn setup() -> (Signers, Contracts) {
    // Deploy
    let signers = Signers { owner: deploy_account('OWNER'), anyone: deploy_account('ANYONE'), };
    let project = deploy_project(signers.owner);
    let offseter = deploy_offseter(project, signers.owner);

    // Setup
    setup_project(project, @signers);
    setup_offseter(project, offseter, @signers);

    // Return
    let contracts = Contracts { project: project, offseter: offseter, };
    (signers, contracts)
}



#[test]
#[available_gas(400_000_000)]
fn test_offseter_iso_banegas_farm_deposit_withdraw_value() {
    let (signers, contracts) = setup();
    // Instantiate contracts
    let farmer = IFarmDispatcher { contract_address: contracts.offseter };
    let offseter = IOffsetDispatcher { contract_address: contracts.offseter };
    let minter = IMinterDispatcher { contract_address: contracts.project };
    let project = IProjectDispatcher { contract_address: contracts.project };
    let absorber = IAbsorberDispatcher { contract_address: contracts.project };
    let erc3525 = IERC3525Dispatcher { contract_address: contracts.project };

    // Prank caller as owner
    set_contract_address(signers.owner);

    // Grant minter rights to owner, mint 1 token to anyone and revoke rights
    minter.add_minter(SLOT, signers.owner);
    let token_id = project.mint(signers.anyone, SLOT, VALUE);
    minter.revoke_minter(SLOT, signers.owner);

    // Setup project value
    let project_value = erc3525.total_value(SLOT);
    absorber.set_project_value(SLOT, project_value);

    // Prank caller as anyone
    set_contract_address(signers.anyone);

    // At t = 0
    set_block_timestamp(0);
    // Anyone deposits value 100_000_000
    farmer.deposit(token_id, VALUE);
    let deposited = farmer.get_deposited_of(signers.anyone);
    assert(deposited == VALUE, 'Wrong strat deposited');
    // Claimable is 0
    let claimable = offseter.get_claimable_of(signers.anyone);
    assert(claimable == 0, 'Wrong start claim should be 0');
    // Claimed is 0
    let claimed = offseter.get_claimed_of(signers.anyone);
    assert(claimed == 0, 'Wrong start claimed should be 0');

    // At t = Aug 01 2023 07:00:00 GMT+0000 (2h before first absorption date)
    set_block_timestamp(1667307258); 
    // Claimable is 0
    let claimable = offseter.get_claimable_of(signers.anyone);
    assert(claimable == 0, 'Wrong claimable: should be 0');
    // Claimed is 0
    let claimed = offseter.get_claimed_of(signers.anyone);
    assert(claimed == 0, 'Wrong claimed: should be 0');


    // At t = Sep 01 2023 07:00:00 GMT+0000 (1 year after first absorption)
    set_block_timestamp(1693551600);
    // Claimable is 8781856 * 10 (UNIT_PRICE)
    let claimable = offseter.get_claimable_of(signers.anyone);
    claimable.print();
    assert(claimable == 0x3be846, 'Wrong claimable:need 0x3be846');
    // Claimed is 0
    let claimed = offseter.get_claimed_of(signers.anyone);
    assert(claimed == 0, 'Wrong claimed');
}


#[test]
#[available_gas(400_000_000)]
fn deposit_and_withdraw_value_in_offseter() {
    let (signers, contracts) = setup();
    // Instantiate contracts
    let farmer = IFarmDispatcher { contract_address: contracts.offseter };
    let offseter = IOffsetDispatcher { contract_address: contracts.offseter };
    let minter = IMinterDispatcher { contract_address: contracts.project };
    let project = IProjectDispatcher { contract_address: contracts.project };
    let absorber = IAbsorberDispatcher { contract_address: contracts.project };
    let erc3525 = IERC3525Dispatcher { contract_address: contracts.project };

    // Prank caller as owner
    set_contract_address(signers.owner);

    // Grant minter rights to owner, mint 1 token to anyone and revoke rights
    minter.add_minter(SLOT, signers.owner);
    let token_id = project.mint(signers.anyone, SLOT, VALUE);
    minter.revoke_minter(SLOT, signers.owner);

    // Setup project value
    let project_value = erc3525.total_value(SLOT);
    absorber.set_project_value(SLOT, project_value);

    // Prank caller as anyone
    set_contract_address(signers.anyone);

    // At t = 0
    set_block_timestamp(0);
    // Anyone deposits value 100_000_000 in offseter
    farmer.deposit(token_id, VALUE);
    let deposited = farmer.get_deposited_of(signers.anyone);
    assert(deposited == VALUE, 'Wrong strat deposited');
    


    // At t = Sep 01 2023 07:00:00 GMT+0000 (1 y  after first absorption)
    set_block_timestamp(1693551600);

    // Then `get_claimable_of` should be different from 0
    let claimable = offseter.get_claimable_of(signers.anyone);
    assert(claimable != 0, 'Wrong claimable should not be 0');

    // withdraw VALUE from offseter 
    farmer.withdraw_to_token(token_id, VALUE);
    // balance should be egal to value deposited
    //get value on token_id for anyone
    let value = erc3525.total_value(SLOT);
    value.print();
    assert(VALUE == value, 'Balance shld be = to value depo');
}

#[test]
#[available_gas(4000_000_000)]
fn deposit_and_withdraw_value_in_offseter_multiple_user() {
    let (signers, contracts) = setup();
    // Instantiate contracts
    let farmer = IFarmDispatcher { contract_address: contracts.offseter };
    let offseter = IOffsetDispatcher { contract_address: contracts.offseter };
    let minter = IMinterDispatcher { contract_address: contracts.project };
    let project = IProjectDispatcher { contract_address: contracts.project };
    let absorber = IAbsorberDispatcher { contract_address: contracts.project };
    let erc3525 = IERC3525Dispatcher { contract_address: contracts.project };

    // Prank caller as owner
    set_contract_address(signers.owner);

    // Grant minter rights to owner, mint 1 token to anyone and revoke rights
    minter.add_minter(SLOT, signers.owner);
    let token_id1 = project.mint(signers.anyone, SLOT, VALUE);
    // let token_id2 = project.mint(signers.anyone2, SLOT, VALUE);
    let token_id3 = project.mint(signers.owner, SLOT, VALUE);
    minter.revoke_minter(SLOT, signers.owner);

    // Setup project value
    let project_value = erc3525.total_value(SLOT);
    absorber.set_project_value(SLOT, project_value);

    
    // Prank caller as owner
    set_contract_address(signers.owner);

    // owner deposits value 100_000_000 in offseter
    farmer.deposit(token_id3, VALUE);
    let deposited2 = farmer.get_deposited_of(signers.owner);
    assert(deposited2 == VALUE, 'Wrong deposit for owner');
    
    // Prank caller as anyone
    set_contract_address(signers.anyone);

    // At t = 0
    set_block_timestamp(0);
    // Anyone deposits value 100_000_000 in offseter
    farmer.deposit(token_id1, VALUE);
    let deposited1 = farmer.get_deposited_of(signers.anyone);
    assert(deposited1 == VALUE, 'Wrong deposit anyone');


    // At t = Sep 01 2023 07:00:00 GMT+0000 (1 month after first price at 22)
    set_block_timestamp(1693551600);

    // Then `get_claimable_of` should be different from 0 for both users
    let claimable1 = offseter.get_claimable_of(signers.anyone);
    assert(claimable1 != 0, 'Wrong claimable  anyone');
    let claimable2 = offseter.get_claimable_of(signers.owner);
    assert(claimable2 != 0, 'Wrong claimable  owner');

    // withdraw VALUE from offseter for both users
    
     // Prank caller as owner
    set_contract_address(signers.owner);

    farmer.withdraw_to_token(token_id3, VALUE);
    
    // Prank caller as anyone
    set_contract_address(signers.anyone);

    farmer.withdraw_to_token(token_id1, VALUE);

   

}

#[test]
#[available_gas(400_000_000)]
fn deposit_and_withdraw_portion_value_in_offseter() {
    let (signers, contracts) = setup();
    // Instantiate contracts
    let farmer = IFarmDispatcher { contract_address: contracts.offseter };
    let offseter = IOffsetDispatcher { contract_address: contracts.offseter };
    let minter = IMinterDispatcher { contract_address: contracts.project };
    let project = IProjectDispatcher { contract_address: contracts.project };
    let absorber = IAbsorberDispatcher { contract_address: contracts.project };
    let erc3525 = IERC3525Dispatcher { contract_address: contracts.project };

    // Prank caller as owner
    set_contract_address(signers.owner);

    // Grant minter rights to owner, mint 1 token to anyone and revoke rights
    minter.add_minter(SLOT, signers.owner);
    let token_id = project.mint(signers.anyone, SLOT, VALUE);
    minter.revoke_minter(SLOT, signers.owner);

    // Setup project value
    let project_value = erc3525.total_value(SLOT);
    absorber.set_project_value(SLOT, project_value);

    // Prank caller as anyone
    set_contract_address(signers.anyone);

    // At t = 0
    set_block_timestamp(0);
    // Anyone deposits value 100_000_000 in offseter
    farmer.deposit(token_id, VALUE/2);
    let deposited = farmer.get_deposited_of(signers.anyone);
    assert(deposited == VALUE/2, 'Wrong strat deposited');
    



 


    // At t = Sep 01 2023 07:00:00 GMT+0000 (1 y after first absorption)
    set_block_timestamp(1693551600);

    // Then `get_claimable_of` should be different from 0
    let claimable = offseter.get_claimable_of(signers.anyone);
    assert(claimable != 0, 'Wrong claimable should not be 0');

    // withdraw VALUE from offseter 
    farmer.withdraw_to_token(token_id, VALUE/2);
    // balance should be egal to value deposited
    //get value on token_id for anyone
    let value = erc3525.total_value(SLOT);
    value.print();
    assert(VALUE == value, 'Balance shld be = to value depo');
}





#[test]
#[available_gas(4000_000_000)]
fn deposit_and_withdraw_value_in_offseter_multiple_user_diff_order() {
    let (signers, contracts) = setup();
    // Instantiate contracts
    let farmer = IFarmDispatcher { contract_address: contracts.offseter };
    let offseter = IOffsetDispatcher { contract_address: contracts.offseter };
    let minter = IMinterDispatcher { contract_address: contracts.project };
    let project = IProjectDispatcher { contract_address: contracts.project };
    let absorber = IAbsorberDispatcher { contract_address: contracts.project };
    let erc3525 = IERC3525Dispatcher { contract_address: contracts.project };

    // Prank caller as owner
    set_contract_address(signers.owner);

    // Grant minter rights to owner, mint 1 token to anyone and revoke rights
    minter.add_minter(SLOT, signers.owner);
    let token_id1 = project.mint(signers.anyone, SLOT, VALUE);
    // let token_id2 = project.mint(signers.anyone2, SLOT, VALUE);
    let token_id3 = project.mint(signers.owner, SLOT, VALUE);
    minter.revoke_minter(SLOT, signers.owner);

    // Setup project value
    let project_value = erc3525.total_value(SLOT);
    absorber.set_project_value(SLOT, project_value);

    
    // Prank caller as owner
    set_contract_address(signers.owner);

    // owner deposits value 100_000_000 in offseter
    farmer.deposit(token_id3, VALUE);
    let deposited2 = farmer.get_deposited_of(signers.owner);
    assert(deposited2 == VALUE, 'Wrong deposit for owner');
    
    // Prank caller as anyone
    set_contract_address(signers.anyone);

    // At t = 0
    set_block_timestamp(0);
    // Anyone deposits value 100_000_000 in offseter
    farmer.deposit(token_id1, VALUE);
    let deposited1 = farmer.get_deposited_of(signers.anyone);
    assert(deposited1 == VALUE, 'Wrong deposit anyone');


    // At t = Sep 01 2023 07:00:00 GMT+0000 (1 month after first price at 22)
    set_block_timestamp(1693551600);

    // Then `get_claimable_of` should be different from 0 for both users
    let claimable1 = offseter.get_claimable_of(signers.anyone);
    assert(claimable1 != 0, 'Wrong claimable  anyone');
    let claimable2 = offseter.get_claimable_of(signers.owner);
    assert(claimable2 != 0, 'Wrong claimable  owner');

    // withdraw VALUE from offseter for both users
    // Prank caller as anyone
    set_contract_address(signers.anyone);

    farmer.withdraw_to_token(token_id1, VALUE);

    // Prank caller as owner
    set_contract_address(signers.owner);

    farmer.withdraw_to_token(token_id3, VALUE);

}