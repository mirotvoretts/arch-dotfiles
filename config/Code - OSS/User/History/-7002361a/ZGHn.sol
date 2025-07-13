//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PlatformRegistry is Ownable {
    struct CampaignInfo {
        address campaignAddress;
        uint targetAmount;
        uint currentAmount;
        bool isActive;
    }

    uint8 private feePercentage;

    /// @notice address => isFeeCollector
    mapping(address => bool) feeCollectors;
    /// @notice organizationAddress => isVerified
    mapping(address => bool) verifiedOrgranizations;
    /// @notice organizationAddress => campaigns
    mapping(address => CampaignInfo[]) organizationCampaign;

    error OrganizationIsNotVerified();
    error InvalidFeePercentage();

    event OrganizationIsVerified(
        address _organizationAddress,
        bool _isVerified
    );
    event CampaignCreated(address _campaignAddress, address _creator);

    modifier onlyVerified(address _organizationAddress) {
        require(
            verifiedOrgranizations[_organizationAddress],
            OrganizationIsNotVerified()
        );
        _;
    }

    modifier onlyFeeCollectors() {
        require(feeCollectors[msg.sender]);
        _;
    }

    constructor(
        address initialOwner,
        uint8 _feePercentage
    ) Ownable(initialOwner) {
        require(
            0 <= _feePercentage && _feePercentage <= 30,
            InvalidFeePercentage()
        );
        feePercentage = _feePercentage;
        feeCollectors[msg.sender] = true;
    }

    function verify(
        address _organizationAddress,
        bool _isVerified
    ) external onlyOwner {
        verifiedOrgranizations[_organizationAddress] = _isVerified;
        emit OrganizationIsVerified(_organizationAddress, _isVerified);
    }

    /// @dev in future we will more params ^_^
    /// @return address of created campaign charity
    function createCampaign(
        uint _targetAmount
    ) external onlyVerified(msg.sender) returns (address) {
        // TODO: here create CharityCampaign contract instance; replace `msg.sender` with `address(charityCampaign)`

        CampaignInfo memory info = CampaignInfo({
            campaignAddress: msg.sender,
            targetAmount: _targetAmount,
            currentAmount: 0,
            isActive: true
        });

        organizationCampaign[msg.sender].push(info);
        emit CampaignCreated(msg.sender, msg.sender); // replace only first arg with `address(charityCampaign)`

        return msg.sender;
    }

    function addFeeCollector(address _address) external onlyOwner {
        feeCollectors[_address] = true;
    }

    function setFeePercentage(uint8 _feePercentage) external onlyFeeCollectors {
        require(
            0 <= _feePercentage && _feePercentage <= 30,
            InvalidFeePercentage()
        );
        feePercentage = _feePercentage;
    }
}
