    // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Script.sol";

import "../interfaces/ICreate3Deployer.sol";
import "../src/wHYPEOFTAdapter.sol";
import "../utils/L2Constants.sol";


contract DeployOFTAdapterScript is Script, L2Constants {
     ICreate3Deployer private CREATE3 = ICreate3Deployer(L2_CREATE3_DEPLOYER);

    function run() public {
        vm.startBroadcast();

        new wHYPEOFTAdapter(WRAPPED_HYPE_ADDRESS, HYPE_ENDPOINT, msg.sender);

        vm.stopBroadcast();
    }
       
} 
