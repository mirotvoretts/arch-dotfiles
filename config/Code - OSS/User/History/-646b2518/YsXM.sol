//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DonationPool is Ownable {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint targetAmount;
        uint currentAmount;
        bool isActive;
        bool isVerified;
    }

    struct Donation {
        address donor;
        uint amount;
        uint fee;
        uint timestamp;
    }

    /// @notice campaignId => donations
    mapping(uint => Donation[]) public donations;
    /// @notice campaignId => campaign
    mapping(uint => Campaign) public campaigns;
    uint public campaignsCount = 0;

    event Donated(uint _campaignId, address _donor);

    error CampaignIsNotActive();

    constructor(address initialOwner) Ownable(initialOwner) {
    }
    
    /// @dev _fee - expecting a percentage fee
    /// @notice I want to give users the ability to specify a donation fee from 0 to 25 percent (for example) so that we can make money too
    function donate(uint _campaignId, uint _fee) external payable {
        require(campaigns[_campaignId].isActive, CampaignIsNotActive());
        Campaign storage campaign = campaigns[_campaignId];
        uint donationAmount = msg.value * (1 - _fee / 100);
        campaign.currentAmount += donationAmount;
        donations[_campaignId].push(Donation(msg.sender, donationAmount, _fee, block.timestamp));
        emit Donated(_campaignId, msg.sender);
    }

    function withdraw(uint _campaignId, address payable _recipient) external {

    }
}
