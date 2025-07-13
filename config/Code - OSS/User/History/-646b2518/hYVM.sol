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

    /// @dev campaignId => donations
    mapping(uint => Donation[]) public donations;
    /// @dev campaignId => campaign
    mapping(uint => Campaign) public campaigns;
    uint public campaignsCount = 0;

    event Donated(address _campaign, address _donor);

    error CampaignIsNotActive();

    constructor(address initialOwner) Ownable(initialOwner) {
    }

    // @dev _fee - 
    function donate(uint _campaignId, uint _fee) external payable {
        require(campaigns[_campaignId].isActive, CampaignIsNotActive());
        Campaign storage campaign = campaigns[_campaignId];
        uint donationAmount = 
        campaign.currentAmount += msg.value;
        
    }


}
