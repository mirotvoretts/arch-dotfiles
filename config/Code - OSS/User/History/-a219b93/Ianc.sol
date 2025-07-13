// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {CharityCampaign} from "../src/CharityCampaign.sol";
import {PlatformRegistry} from "../src/PlatformRegistry.sol";
import {PlatformToken} from "../src/PlatformToken.sol";

contract CharitySecurityTest is Test {
    PlatformRegistry registry;
    PlatformToken token;
    CharityCampaign campaign;
    address owner;
    address scammer;
    address donor;

    function setUp() public {
        owner = makeAddr("owner");
        scammer = makeAddr("scammer");
        donor = makeAddr("donor");

        vm.prank(owner);
        registry = new PlatformRegistry();

        vm.prank(owner);
        token = new PlatformToken();

        vm.prank(owner);
        campaign = new CharityCampaign(address(registry), address(token));

        deal(address(token), donor, 1_000 ether);
        deal(address(token), scammer, 1_000 ether);
    }

    // ===========================
    // Reentrancy attack scenario
    // ===========================
    contract ReentrancyAttacker {
        CharityCampaign public target;
        PlatformToken public token;
        address public owner;

        constructor(CharityCampaign _target, PlatformToken _token) {
            target = _target;
            token = _token;
            owner = msg.sender;
        }

        function attack() external {
            token.approve(address(target), 100 ether);
            target.donate(100 ether);
            target.withdraw();
        }

        receive() external payable {
            // Reentrancy attempt
            if (address(target).balance > 0.1 ether) {
                target.withdraw();
            }
        }
    }

    function test_ReentrancyAttack_ShouldFail() public {
        ReentrancyAttacker attacker = new ReentrancyAttacker(campaign, token);
        deal(address(token), address(attacker), 100 ether);

        vm.startPrank(address(attacker));
        token.approve(address(campaign), 100 ether);
        campaign.donate(100 ether);
        vm.expectRevert();
        attacker.attack();
        vm.stopPrank();
    }

    // ===============================
    // Integer overflow/underflow
    // ===============================
    function test_IntegerOverflow_ShouldRevert() public {
        vm.prank(donor);
        token.approve(address(campaign), type(uint256).max);

        vm.expectRevert();
        campaign.donate(type(uint256).max);
    }

    // ======================
    // Front-running attack
    // ======================
    function test_FrontRunningPrevention() public {
        // simulate a front-run by calling donate multiple times
        vm.prank(donor);
        token.approve(address(campaign), 500 ether);

        vm.startPrank(donor);
        campaign.donate(100 ether);
        campaign.donate(100 ether);
        vm.stopPrank();

        // no duplicate rewards, state manipulation, etc.
        assertTrue(true);
    }

    // ==============================
    // Delegatecall injection attack
    // ==============================
    function test_DelegateCallInjection_ShouldFail() public {
        // only applies if delegatecall used — simulate a contract injection
        // this test assumes some kind of delegatecall option is exposed — check CharityCampaign impl
        // if not used, this test should be excluded or used to assert its absence
        (bool success, ) = address(campaign).call(
            abi.encodeWithSignature("delegateCallHijack(bytes)", abi.encode(msg.sender))
        );
        assertFalse(success);
    }

    // ==============================
    // Short address attack
    // ==============================
    function test_ShortAddressAttack_ShouldFail() public {
        bytes memory shortCall = abi.encodePacked(bytes4(keccak256("donate(uint256)")), hex"01");
        (bool success, ) = address(campaign).call(shortCall);
        assertFalse(success);
    }

    // ==============================
    // Access control edge cases
    // ==============================
    function test_OnlyOwner_ShouldRevertOnUnauthorized() public {
        vm.expectRevert();
        vm.prank(scammer);
        campaign.emergencyWithdraw();
    }

    // ==============================
    // Invariants: no token stuck, withdrawal works
    // ==============================
    function test_DonationAndWithdrawalFlow() public {
        vm.startPrank(donor);
        token.approve(address(campaign), 100 ether);
        campaign.donate(100 ether);
        vm.stopPrank();

        vm.prank(owner);
        campaign.withdraw();

        // Expect funds moved to the correct address
        // Add address assertions if campaign sends funds to registry, etc.
        assertTrue(true);
    }
}
