//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {Fund_FundMe, Withdraw_FundMe} from "../../script/Interactions.s.sol";

contract FundMeIntegrationTest is Test {
    FundMe fundMe;
    uint256 public constant TRANSFER_BALANCE = 10e18; //0.1 ether same values 10**17
    uint256 public constant STARTING_BALANCE = 10 ether;
    uint256 public GAS_PRICE;

    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run(); //this will return a fresh deployed fundme contract from the script
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        Fund_FundMe fundFundMe = new Fund_FundMe();
        // vm.prank(USER);
        // vm.deal(USER, TRANSFER_BALANCE); 
        fundFundMe.fund_FundMe(address(fundMe));

        // address funder = fundMe.getFunder(0);
        // assertEq(funder, USER);

        Withdraw_FundMe withdrawFundMe = new Withdraw_FundMe();
        withdrawFundMe.withdrawFunds(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
        
}
