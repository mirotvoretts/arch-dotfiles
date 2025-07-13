// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CharityCampaign is ReentrancyGuard {
    address public owner;
    string public name;
    string public description;
    uint256 public goal;
    uint256 public deadline;
    uint256 public totalDonated = 0;
    bool public goalReached = false;

    mapping(address => uint256) public donations;

    event Donated(address indexed donor, uint256 amount);
    event Withdrawn(uint256 amount);
    event Refunded(address indexed donor, uint256 amount);

    error CampaignEnded();
    error ZeroDonation();
    error GoalNotReached();
    error NoFundsToWithdraw();

    constructor(
        address _owner,
        string memory _name,
        string memory _description,
        uint256 _goal,
        uint256 _deadline
    ) {
        owner = _owner;
        name = _name;
        description = _description;
        goal = _goal;
        deadline = _deadline;
    }

    function donate() public payable nonReentrant {
        if (block.timestamp >= deadline) revert CampaignEnded();
        if (msg.value == 0) revert ZeroDonation();

        donations[msg.sender] += msg.value;
        totalDonated += msg.value;

        if (totalDonated >= goal) {
            goalReached = true;
        }

        emit Donated(msg.sender, msg.value);
    }

    function withdrawFunds() external nonReentrant {
    require(msg.sender == owner, "Only owner can withdraw");
    require(goalReached, "Goal not reached yet");

    uint256 amount = totalDonated; // безопаснее, чем address(this).balance
    require(amount > 0, "No funds to withdraw");

    totalDonated = 0;

    (bool success,) = owner.call{value: amount}("");
    require(success, "Transfer failed");

    emit Withdrawn(amount);
}

    /**
     * @dev Возврат средств, если цель не достигнута
     */
    function refundIfFailed() external nonReentrant {
        if (block.timestamp < deadline) revert CampaignEnded();
        if (goalReached) revert GoalNotReached();

        uint256 amount = donations[msg.sender];
        if (amount == 0) revert ZeroDonation();

        donations[msg.sender] = 0;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Refund failed");

        emit Refunded(msg.sender, amount);
    }

    function getStatus() external view returns (string memory) {
        if (block.timestamp >= deadline && !goalReached) {
            return "Failed";
        } else if (goalReached) {
            return "Success";
        } else {
            return "Active";
        }
    }

    receive() external payable {
        donate();
    }
}