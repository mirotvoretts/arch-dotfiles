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
        uint timestamp;
    }

    /// @dev id => campaign
    mapping(uint => Campaign) public campaigns;
    uint public campaignsCount = 0;

    event CampaignCreated();

    error CampaignIsNotActive();

    constructor(address initialOwner) Ownable(initialOwner) {
    }

    function donate(uint _campaignId) external payable {
        require(campaigns[_campaignId].isActive, CampaignIsNotActive());
    }
}
