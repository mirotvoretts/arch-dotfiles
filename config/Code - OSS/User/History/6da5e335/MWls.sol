// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

abstract contract Config {
    uint256 public constant MAX_SUPPLY = 100;
    uint256 public constant MINT_PRICE = 0.001 ether;
    uint256 public constant MAX_PER_TX = 3;
    uint256 public constant MAX_PER_WALLET = 6;
}