// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint256 public constant TRANSFER_BALANCE = 10e18; //0.1 ether same values 10**17
    uint256 public constant STARTING_BALANCE = 10 ether;
    uint256 public GAS_PRICE;

    address USER = makeAddr("user");

    function setUp() external {
        // fundMe = new FundMe(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF);
        DeployFundMe deplayFundMe = new DeployFundMe();
        fundMe = deplayFundMe.run(); //this will return a fresh deployed fundme contract from the script

        //using deal cheatcode to give prank user some balance
        //giving them fake money so that they can fund the contract
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinDollaIsFive() public view {
        assertEq(fundMe.minUSD(), 5e18);
        console.log("Min USD is set to 5 ETH");
    }

    function testOwnerIsSender() public view {
        console.log("Owner: ", fundMe.getOwner());
        console.log("Sender: ", msg.sender);
        // assertEq(fundMe.owner(), address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testIsPriceFeedVersionAccurate() public view {
        uint256 actualVersion = fundMe.getVersion();
        assertEq(actualVersion, 4); // Assuming the expected version is 4
        console.log("Price Feed Version: ", actualVersion);
    }

    function testFundFailsWithoutEnufETH() public {
        vm.expectRevert(); //this means the next line should revert
        // uint256 notEnoughETH = 1e16; // 0.01 ETH
        fundMe.fundMe(); //send 0 value
    }

    function testFundUpdatesFundedDataStructure() public {
        //creating a new fake address to send all our transactions, hence we use a foundry cheatcode named as prank

        vm.prank(USER); //this means the txn will be send by user

        fundMe.fundMe{value: TRANSFER_BALANCE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, TRANSFER_BALANCE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        // vm.prank(USER);
        // fundMe.fundMe{value: TRANSFER_BALANCE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
        console.log("Funder at index 0: ", funder);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fundMe{value: TRANSFER_BALANCE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdrawFund();
        console.log("User tried to withdraw funds, but failed as expected");
    }

    function testWithdrawWithaSingleFunder() public funded {
        //withdrawing funds with actual owner

        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act

        uint256 startingGas = gasleft();  //this function will tell us how much gas is left
        console.log("Starting gas: ", startingGas);

        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdrawFund();

        uint256 gasEnd = gasleft();
        console.log("Ending gas: ", gasEnd);

        uint256 gasUsed = startingGas - gasEnd;
        console.log("Gas used for withdrawal: ", gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        console.log("we have withdrawn all the money from the contract");

        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
        console.log("Owner's balance after withdrawal: ", endingOwnerBalance);
    }

    function testWithdrawwFromMultipleFunders() public funded {
        //Arrange

        uint160 numberofFunders = 10;
        uint160 startingFunderIndex = 1; //starting from 0 is not a good practice
        for (uint160 i = startingFunderIndex; i < numberofFunders; i++) {
            //steps
            /**
             * first we will prankthe user i.e. USER
             * then we will fund the contract with some value using deal ch
             * cheatcode by foundry
             *
             * but heres a catch, we can use hoax cheatcode to do the both above works i.e. creaing a fake address and funding it with some value
             *
             * then we will fund the fundMe
             */

            hoax(address(i), TRANSFER_BALANCE);
            console.log("Funding address: ", address(i));

            fundMe.fundMe{value: TRANSFER_BALANCE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //ACT
        vm.startPrank(fundMe.getOwner());
        fundMe.withdrawFund();
        vm.stopPrank();

        //ASSERT
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
        console.log(
            "Owner's balance after withdrawal: ",
            fundMe.getOwner().balance
        );
    }


    function testWithdrawwFromMultipleFundersButCheap() public funded {
        //Arrange

        uint160 numberofFunders = 10;
        uint160 startingFunderIndex = 1; //starting from 0 is not a good practice
        for (uint160 i = startingFunderIndex; i < numberofFunders; i++) {
            //steps
            /**
             * first we will prankthe user i.e. USER
             * then we will fund the contract with some value using deal ch
             * cheatcode by foundry
             *
             * but heres a catch, we can use hoax cheatcode to do the both above works i.e. creaing a fake address and funding it with some value
             *
             * then we will fund the fundMe
             */

            hoax(address(i), TRANSFER_BALANCE);
            console.log("Funding address: ", address(i));

            fundMe.fundMe{value: TRANSFER_BALANCE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //ACT
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //ASSERT
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
        console.log(
            "Owner's balance after withdrawal: ",
            fundMe.getOwner().balance
        );
    }
}
