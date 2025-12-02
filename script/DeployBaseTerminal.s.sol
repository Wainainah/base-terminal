// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/BaseTerminal.sol";

contract DeployBaseTerminal is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        BaseTerminal terminal = new BaseTerminal();
        
        console.log("BaseTerminal deployed to:", address(terminal));

        vm.stopBroadcast();
    }
}
