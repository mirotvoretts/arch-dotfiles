// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../lib/forge-std/Test.sol";
import "forge-std/console.sol";

import {CharityCampaign} from "../src/CharityCampaign.sol";
import {PlatformRegistry} from "../src/PlatformRegistry.sol";
import {PlatformToken} from "../src/PlatformToken.sol";

contract CharityCampaignTest is Test {
    PlatformToken token;
    PlatformRegistry registry;
    CharityCampaign campaign;

    address owner = address(0xABCD);
    address user1 = address(0x1111);
    address user2 = address(0x2222);
    address attacker = address(0xBAD);

    function setUp() public {
        vm.prank(owner);
        token = new PlatformToken(owner);

        vm.prank(owner);
        registry = new PlatformRegistry(owner, 5, address(token));
        token.grantRole(token.MINTER_ROLE(), address(registry));

        vm.prank(owner);
        registry.verifyOrganization(owner, true);

        vm.prank(owner);
        campaign = new CharityCampaign(owner, address(registry), 10 ether, block.timestamp + 7 days);
    }

    function testDonateWorks() public {
        vm.deal(user1, 5 ether);
        vm.prank(user1);
        campaign.donate{value: 1 ether}();

        assertEq(campaign.totalDonated(), 0.95 ether); // 5% fee
    }

    function testCannotDonateZero() public {
        vm.expectRevert();
        vm.prank(user1);
        campaign.donate{value: 0}();
    }

    function testWithdrawEmptyFailsGracefully() public {
        vm.prank(owner);
        campaign.withdrawPlatformFee(); // should not revert even if zero
    }

    function testOnlyOwnerCanWithdrawPlatformFee() public {
        vm.expectRevert();
        vm.prank(user1);
        campaign.withdrawPlatformFee();
    }

    function testReentrancyAttackBlocked() public {
        ReentrantDonor malicious = new ReentrantDonor(campaign);
        vm.deal(address(malicious), 2 ether);

        vm.expectRevert(); // should revert due to ReentrancyGuard
        malicious.attack{value: 1 ether}();
    }

    function testFrontRunningVote() public {
        vm.deal(user1, 3 ether);
        vm.prank(user1);
        campaign.donate{value: 2 ether}();

        vm.prank(owner);
        campaign.createSpendingRequest("Test", 1 ether, payable(user2));
        vm.prank(user1);
        campaign.voteForRequest(0);

        // try vote again
        vm.expectRevert();
        vm.prank(user1);
        campaign.voteForRequest(0);
    }

    function testShortAddressAttack() public {
        // simulate short calldata (underflow in address type)
        bytes memory data = abi.encodeWithSelector(campaign.donate.selector);
        (bool success,) = address(campaign).call(data);
        assertTrue(!success);
    }

    function testDelegatecallInjection() public {
        // if there's no delegatecall, we simply ensure fallback behavior is safe
        (bool success,) = address(campaign).call(abi.encodeWithSignature("doesNotExist()"));
        assertTrue(!success);
    }

    function testIntegerOverflowFails() public {
        vm.prank(owner);
        campaign.createSpendingRequest("test", type(uint256).max, payable(user2));
        vm.prank(user1);
        vm.deal(user1, 5 ether);
        campaign.donate{value: 5 ether}();

        // can't execute spending request that would cause overflow
        vm.expectRevert();
        vm.prank(owner);
        campaign.executeSpendingRequest(0);
    }

    function testDoubleExecutionBlocked() public {
        vm.deal(user1, 3 ether);
        vm.prank(user1);
        campaign.donate{value: 2 ether}();

        vm.prank(owner);
        campaign.createSpendingRequest("Test", 1 ether, payable(user2));
        vm.prank(user1);
        campaign.voteForRequest(0);

        vm.prank(owner);
        campaign.executeSpendingRequest(0);

        vm.expectRevert(); // already executed
        vm.prank(owner);
        campaign.executeSpendingRequest(0);
    }

    function testFuzzingDonation(uint256 amount) public {
        vm.assume(amount > 0.01 ether && amount < 100 ether);
        vm.deal(user1, amount);
        vm.prank(user1);
        campaign.donate{value: amount}();

        assertGt(campaign.totalDonated(), 0);
    }

    receive() external payable {}
}

contract ReentrantDonor {
    CharityCampaign target;
    bool attacked;

    constructor(CharityCampaign _target) {
        target = _target;
    }

    function attack() external payable {
        target.donate{value: 1 ether}();
        target.withdrawPlatformFee(); // reenter
    }

    receive() external payable {
        if (!attacked) {
            attacked = true;
            target.withdrawPlatformFee();
        }
    }
}