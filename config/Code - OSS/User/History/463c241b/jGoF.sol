// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/forge-std/src/Test.sol";
import {PlatformRegistry} from "../contracts/PlatformRegistry.sol";
import {CharityCampaign} from "../contracts/CharityCampaign.sol";
import {PlatformToken} from "../contracts/PlatformToken.sol";

contract PlatformRegistryTest is Test {
    PlatformRegistry public registry;
    PlatformToken public token;

    address public owner = address(1);
    address public org1 = address(2);
    address public org2 = address(3);
    address public donor1 = address(4);
    address public donor2 = address(5);
    address public feeRecipient = address(6);

    uint public initialFee = 5; // 10%

    function setUp() public {
        vm.startPrank(owner);
        token = new PlatformToken(owner);
        registry = new PlatformRegistry(owner, initialFee, address(token));
        registry.setFeeAddress(feeRecipient);
        vm.stopPrank();

        // Verify org1
        vm.prank(owner);
        registry.verifyOrganization(org1, true);
    }

    function test_InitialSetup() public {
        assertEq(registry.owner(), owner);
        assertEq(registry.getFeePercentage(), initialFee);
        assertEq(registry.getFeeAddress(), feeRecipient);
        assertTrue(registry.verifiedOrganizations(org1));
        assertFalse(registry.verifiedOrganizations(org2));
    }

    function test_VerifyOrganization() public {
        vm.prank(owner);
        registry.verifyOrganization(org2, true);

        assertTrue(registry.verifiedOrganizations(org2));

        vm.expectEmit(true, true, true, true);
        emit PlatformRegistry.OrganizationVerified(org2, false);
        vm.prank(owner);
        registry.verifyOrganization(org2, false);

        assertFalse(registry.verifiedOrganizations(org2));
    }

    function test_OnlyOwnerCanVerify() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(org1);
        registry.verifyOrganization(org2, true);
    }

    function test_SetFeePercentage() public {
        uint newFee = 15;

        vm.prank(owner);
        registry.setFeePercentage(newFee);

        assertEq(registry.getFeePercentage(), newFee);

        vm.expectRevert(
            abi.encodeWithSelector(
                PlatformRegistry.InvalidFeePercentage.selector
            )
        );
        vm.prank(owner);
        registry.setFeePercentage(registry.MAX_FEE_PERCENTAGE() + 1);
    }

    function test_SetFeeAddress() public {
        address newAddr = address(7);

        vm.prank(owner);
        registry.setFeeAddress(newAddr);

        assertEq(registry.getFeeAddress(), newAddr);

        vm.expectRevert(
            abi.encodeWithSelector(PlatformRegistry.AddressZero.selector)
        );
        vm.prank(owner);
        registry.setFeeAddress(address(0));
    }

    function test_WithdrawFees() public {
        uint amount = 1 ether;
        vm.deal(address(registry), amount);

        uint prevBalance = feeRecipient.balance;

        vm.prank(owner);
        registry.withdrawFees(payable(feeRecipient), amount);

        assertEq(feeRecipient.balance, prevBalance + amount);
    }

    function test_CreateCampaign() public {
        uint goal = 10 ether;
        uint duration = 30 days;

        vm.prank(org1);
        address campaignAddr = registry.createCampaign(goal, duration);

        assertTrue(registry.isCampaign(campaignAddr));

        PlatformRegistry.CampaignInfo memory info = registry.getCampaignInfo(0);
        assertEq(info.campaignAddress, campaignAddr);
        assertEq(info.owner, org1);
        assertEq(info.goal, goal);
        assertEq(info.deadline, block.timestamp + duration);
    }

    function test_OnlyVerifiedCanCreateCampaign() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                PlatformRegistry.OrganizationIsNotVerified.selector
            )
        );
        vm.prank(org2);
        registry.createCampaign(10 ether, 30 days);
    }

    function test_RewardDonor() public {
        // Create campaign first
        vm.prank(org1);
        address campaignAddr = registry.createCampaign(10 ether, 30 days);

        CharityCampaign campaign = CharityCampaign(payable(campaignAddr));

        uint donationAmount = 1 ether;
        vm.deal(donor1, donationAmount);

        vm.prank(donor1);
        campaign.donate{value: donationAmount}();

        uint expectedReward = (((donationAmount * 90) / 100) *
            registry.TOKEN_REWARD_RATE()) / 1 ether;

        assertEq(token.balanceOf(donor1), expectedReward);
    }
}

contract CharityCampaignTest is Test {
    PlatformRegistry public registry;
    PlatformToken public token;
    CharityCampaign public campaign;

    address public owner = address(1);
    address public org1 = address(2);
    address public donor1 = address(3);
    address public donor2 = address(4);
    address public recipient = address(5);
    address public feeRecipient = address(6);

    uint public goal = 10 ether;
    uint public duration = 30 days;
    uint public deadline;

    function setUp() public {
        vm.startPrank(owner);
        token = new PlatformToken(owner);
        registry = new PlatformRegistry(owner, 10, address(token)); // 10% fee
        registry.setFeeAddress(feeRecipient);
        registry.verifyOrganization(org1, true);
        vm.stopPrank();

        // Create campaign
        vm.prank(org1);
        address campaignAddr = registry.createCampaign(goal, duration);
        campaign = CharityCampaign(payable(campaignAddr));

        deadline = block.timestamp + duration;
    }

    function test_Donate() public {
        uint donationAmount = 1 ether;
        vm.deal(donor1, donationAmount);

        uint feeAmount = (donationAmount * 10) / 100;
        uint netAmount = donationAmount - feeAmount;

        uint prevFeeBalance = feeRecipient.balance;
        uint prevCampaignBalance = address(campaign).balance;

        vm.prank(donor1);
        campaign.donate{value: donationAmount}();

        assertEq(address(campaign).balance, prevCampaignBalance + netAmount);
        assertEq(feeRecipient.balance, prevFeeBalance + feeAmount);
        assertEq(campaign.donations(donor1), netAmount);
        assertEq(campaign.totalDonated(), netAmount);
    }

    function test_DonateAfterDeadline() public {
        vm.warp(deadline + 1);

        vm.expectRevert(
            abi.encodeWithSelector(CharityCampaign.CampaignHasEnded.selector)
        );
        vm.deal(donor1, 1 ether);
        vm.prank(donor1);
        campaign.donate{value: 1 ether}();
    }

    function test_DonateAfterGoalReached() public {
        // Reach goal
        vm.deal(donor1, goal);
        vm.prank(donor1);
        campaign.donate{value: goal}();

        assertTrue(campaign.goalReached());

        vm.expectRevert(
            abi.encodeWithSelector(CharityCampaign.GoalAlreadyReached.selector)
        );
        vm.deal(donor2, 1 ether);
        vm.prank(donor2);
        campaign.donate{value: 1 ether}();
    }

    function test_CreateSpendingRequest() public {
        // First reach goal
        vm.deal(donor1, goal);
        vm.prank(donor1);
        campaign.donate{value: goal}();

        string memory description = "Test request";
        uint amount = 5 ether;

        vm.prank(org1);
        campaign.createSpendingRequest(description, amount, payable(recipient));

        (
            bytes32 descHash,
            uint reqAmount,
            address reqRecipient,
            bool executed,
            uint votes
        ) = campaign.spendingRequests(0);

        assertEq(reqAmount, amount);
        assertEq(reqRecipient, recipient);
        assertFalse(executed);
        assertEq(votes, 0);
    }

    function test_VoteForRequest() public {
        // Setup: reach goal and create request
        vm.deal(donor1, 6 ether);
        vm.deal(donor2, 4 ether);

        vm.prank(donor1);
        campaign.donate{value: 6 ether}();

        vm.prank(donor2);
        campaign.donate{value: 4 ether}();

        vm.prank(org1);
        campaign.createSpendingRequest("Test", 5 ether, payable(recipient));

        // Test voting
        vm.prank(donor1);
        campaign.voteForRequest(0);

        assertTrue(campaign.requestVoters(0, donor1));

        vm.expectRevert(
            abi.encodeWithSelector(CharityCampaign.AlreadyVoted.selector)
        );
        vm.prank(donor1);
        campaign.voteForRequest(0);
    }

    function test_ExecuteRequest() public {
        // Setup: reach goal, create request, and get enough votes
        vm.deal(donor1, 6 ether);
        vm.deal(donor2, 4 ether);

        vm.prank(donor1);
        campaign.donate{value: 6 ether}();

        vm.prank(donor2);
        campaign.donate{value: 4 ether}();

        vm.prank(org1);
        campaign.createSpendingRequest("Test", 5 ether, payable(recipient));

        vm.prank(donor1);
        campaign.voteForRequest(0);

        vm.prank(donor2);
        campaign.voteForRequest(0);

        // Execute
        uint prevRecipientBalance = recipient.balance;
        uint prevCampaignBalance = address(campaign).balance;

        vm.prank(org1);
        campaign.executeRequest(0);

        assertEq(recipient.balance, prevRecipientBalance + 5 ether);
        assertEq(address(campaign).balance, prevCampaignBalance - 5 ether);
        assertEq(campaign.totalSpent(), 5 ether);
    }

    function test_RefundIfFailed() public {
        // Donate but don't reach goal
        uint donation = 5 ether;
        vm.deal(donor1, donation);
        vm.prank(donor1);
        campaign.donate{value: donation}();

        // Fast forward past deadline
        vm.warp(deadline + 1);

        uint prevBalance = donor1.balance;

        vm.prank(donor1);
        campaign.refundIfFailed();

        assertEq(donor1.balance, prevBalance + ((donation * 90) / 100)); // minus 10% fee
        assertEq(campaign.donations(donor1), 0);
    }

    function test_ReceiveFallback() public {
        uint amount = 1 ether;
        vm.deal(donor1, amount);

        vm.prank(donor1);
        (bool success, ) = address(campaign).call{value: amount}("");

        assertTrue(success);
        assertEq(campaign.donations(donor1), (amount * 90) / 100); // minus 10% fee
    }
}
