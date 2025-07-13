pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/MyNFTCollection.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();
        new MyNFTCollection("ipfs://Qm.../");
        vm.stopBroadcast();
    }
}
