// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/MyNFTCollection.sol";

contract MyNFTCollectionTest is Test {
    MyNFTCollection public nft;
    address payable public owner = payable(address(this));
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    
    uint256 public constant TEST_FUNDS = 1 ether;

    receive() external payable {}
    fallback() external payable {}

    function setUp() public {
        nft = new MyNFTCollection(owner, 100);
    }

    function test_SuccessfulMint() public {
        vm.deal(user1, TEST_FUNDS);
        uint256 mintAmount = nft.MAX_PER_TX();
        
        vm.prank(user1);
        nft.mint{value: nft.MINT_PRICE() * mintAmount}(mintAmount, user1);
        
        assertEq(nft.balanceOf(user1), mintAmount, "User NFT balance mismatch");
        assertEq(nft.totalSupply(), mintAmount, "Total supply mismatch");
        assertEq(address(nft).balance, nft.MINT_PRICE() * mintAmount, "Contract balance mismatch");
    }

    function test_RevertWhen_MintLimitPerTx() public {
        vm.deal(user1, TEST_FUNDS);
        vm.prank(user1);
        
        vm.expectRevert(abi.encodeWithSignature("InvalidAmount()"));
        nft.mint{value: nft.MINT_PRICE() * 4}(4, user1);
    }

    function testRevert_ExceedsWalletLimit() public {
        uint256 mintsAmount = nft.MAX_PER_TX();
        vm.deal(user1, TEST_FUNDS);
        vm.startPrank(user1);
        nft.mint{value: nft.MINT_PRICE() * mintsAmount}(mintsAmount, user1);
        nft.mint{value: nft.MINT_PRICE() * mintsAmount}(mintsAmount, user1);

        vm.expectRevert(IncorrectETHValue);
        nft.mint{value: nft.MINT_PRICE()}(1, user1);
        vm.stopPrank();
    }

    function testRevert_MintUnderpayment() public {
        vm.deal(user1, TEST_FUNDS);
        vm.prank(user1);
        vm.expectRevert(MyNFTCollection.IncorrectETHValue.selector);
        nft.mint{value: nft.MINT_PRICE() - 1}(1, user1);
    }

    function test_MintToDifferentRecipient() public {
        vm.deal(user1, TEST_FUNDS);
        vm.prank(user1);
        nft.mint{value: nft.MINT_PRICE() * nft.MAX_PER_TX()}(nft.MAX_PER_TX(), user2);
        
        assertEq(nft.balanceOf(user2), nft.MAX_PER_TX(), "Recipient should have NFTs");
        assertEq(nft.balanceOf(user1), 0, "Sender should not receive NFTs");
    }

    function testRvert_MintZeroAmount() public {
        vm.deal(user1, TEST_FUNDS);
        vm.prank(user1);
        vm.expectRevert(MyNFTCollection.InvalidAmount.selector);
        nft.mint{value: 0}(0, user1);
    }

    function test_BalanceOfAfterMultipleMints() public {
        vm.deal(user1, TEST_FUNDS);
        vm.prank(user1);
        nft.mint{value: nft.MINT_PRICE() * (nft.MAX_PER_TX() - 1)}(nft.MAX_PER_TX() - 1, user1);

        vm.prank(user1);
        nft.mint{value: nft.MINT_PRICE()}(1, user1);
        
        assertEq(nft.balanceOf(user1), nft.MAX_PER_TX(), "Accumulated balance mismatch");
    }

    function testRevert_WithdrawAsNotOwner() public {
        uint256 contractBalance = 0.5 ether;
        
        vm.deal(address(nft), contractBalance);
        
        vm.prank(user1);
        vm.expectRevert();
        nft.withdraw(contractBalance, payable(owner));
    }

    function test_WithdrawAsOwner() public {
        uint256 initialBalance = owner.balance;
        uint256 contractBalance = 0.5 ether;
        
        vm.deal(address(nft), contractBalance);
        assertEq(address(nft).balance, contractBalance, "Contract should have correct balance");
        
        vm.prank(owner);
        nft.withdraw(contractBalance, payable(owner));

        assertEq(owner.balance, initialBalance + contractBalance, "Owner should receive funds");
        assertEq(address(nft).balance, 0, "Contract balance should be zero");
    }

    function testRevert_WithdrawZeroAmount() public {
        vm.deal(address(nft), 1 ether);
        vm.prank(owner);
        vm.expectRevert(MyNFTCollection.InvalidAmount.selector);
        nft.withdraw(0, payable(owner));
    } 

    function testRevert_WithdrawToZeroAddress() public {
        vm.deal(address(nft), 1 ether);
        vm.prank(owner);
        vm.expectRevert(MyNFTCollection.ZeroAddress.selector);
        nft.withdraw(0.1 ether, payable(address(0)));
    }
}
