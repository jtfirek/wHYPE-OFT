// SPDX-License-Identifier: UNLICENSEDde
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Script.sol";

import "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";

import "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";
import "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/interfaces/IOAppOptionsType3.sol";

import "../src/wHYPEOFT.sol";

import "../utils/L2Constants.sol";

// forge script script/OFTOwnershipTransfer.s.sol:OFTOwnershipTransfer --rpc-url "deployment rpc" 
contract OFTOwnershipTransfer is Script, L2Constants {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UNPAUSER_ROLE = keccak256("UNPAUSER_ROLE");

    using OptionsBuilder for bytes;
    address scriptDeployer;

    function run() public {
        vm.startBroadcast();

        wHYPEOFT oft = wHYPEOFT(OFT_ADAPTER_ADDRESS);

        oft.setDelegate(HYPE_CONTRACT_CONTROLLER);
        
        // transfer ownership to the contract controller
        oft.transferOwnership(HYPE_CONTRACT_CONTROLLER);

        console.log("OFT new owner: %s", oft.owner());


        vm.stopBroadcast();
    }
}
