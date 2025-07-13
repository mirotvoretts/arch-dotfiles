// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CharityCampaign is ReentrancyGuard {
    address public owner;
    string public name;
    string public description;

    struct CampaignData {
        uint goal;
        uint deadline;
        uint totalDonated;
        bool goalReached;
    }

    CampaignData public campaignData;

    ///@notice address => amount
    mapping(address => uint) public donations;

    event Donated(address indexed donor, uint128 amount);
    event Withdrawn(uint amount);
    event Refunded(address indexed donor, uint128 amount);

    error NotVerified();
    error CampaignEnded();
    error ZeroDonation();
    error GoalNotReached();
    error NoRefundAvailable();

    constructor(
        address _owner,
        string memory _name,
        string memory _description,
        uint _goal,
        uint _deadline
    ) {
        owner = _owner;
        name = _name;
        description = _description;
        campaignData = CampaignData({
            goal: _goal,
            deadline: _deadline,
            totalDonated: 0,
            goalReached: false
        });
    }

    function donate() external payable nonReentrant {
        if (block.timestamp >= campaignData.deadline) revert CampaignEnded();
        if (msg.value == 0) revert ZeroDonation();

        uint128 amount = uint128(msg.value);
        donations[msg.sender] += amount;
        campaignData.totalDonated += amount;

        if (campaignData.totalDonated >= campaignData.goal) {
            campaignData.goalReached = true;
        }

        emit Donated(msg.sender, amount);
    }

    function withdrawFunds() external {
        if (msg.sender != owner) revert NotVerified();
        if (!campaignData.goalReached) revert GoalNotReached();

        uint balance = uint128(address(this).balance);
        if (balance == 0) revert ZeroDonation();

        (bool success,) = owner.call{value: balance}("");
        require(success, "Transfer failed");

        emit Withdrawn(balance);
    }

    function refundIfFailed() external nonReentrant {
        if (block.timestamp < campaignData.deadline) revert CampaignEnded();
        if (campaignData.goalReached) revert GoalNotReached();

        uint amount = donations[msg.sender];
        if (amount == 0) revert ZeroDonation();

        donations[msg.sender] = 0;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Refund failed");

        emit Refunded(amount);
    }

    receive() external payable {
        
    }
}