// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/MyNFTCollection.sol";
import "../src/Config.sol";

contract DeployScript is Script {
    C

    function run() external {
        vm.startBroadcast();
        new MyNFTCollection(msg.sender);
        vm.stopBroadcast();
    }
}
