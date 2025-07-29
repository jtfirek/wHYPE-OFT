// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Script.sol";

import "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";

import "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";
import "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/interfaces/IOAppOptionsType3.sol";

import "../utils/LayerZeroHelpers.sol";
import "../interfaces/ICreate3Deployer.sol";

import "../src/wHYPEOFT.sol";

// forge script script/DeployConfigureOFT.s.sol:DeployOFTScript --rpc-url "deployment rpc"  --verify --etherscan-api-key "etherscan key"
contract DeployOFTScript is Script, L2Constants {
    using OptionsBuilder for bytes;

    ICreate3Deployer private CREATE3 = ICreate3Deployer(L2_CREATE3_DEPLOYER);

    EnforcedOptionParam[] public enforcedOptions;

    OFT oftDeployment;

    function run() public {
        vm.startBroadcast();

        deployOFT();

        configurePeer();
        configureEnforcedOptions();
        configureDVN();

        vm.stopBroadcast();
    }

    function deployOFT() internal {
        console.log("Deploying OFT contract...");

        bytes memory implCreationCode = abi.encodePacked(type(wHYPEOFT).creationCode, abi.encode(TOKEN_NAME, TOKEN_SYMBOL, DEPLOYMENT_ENDPOINT, msg.sender));

        address oftDeploymentAddress = CREATE3.deployCreate3(keccak256("wHYPE-OFT"), implCreationCode);
        require(oftDeploymentAddress == OFT_ADDRESS, "OFT deployment address mismatch");

        oftDeployment = OFT(oftDeploymentAddress);
    }

    function configurePeer() internal {
        console.log("Configuring peers...");

        // Setting L1 peer
        oftDeployment.setPeer(HYPE_EID, LayerZeroHelpers._toBytes32(OFT_ADAPTER_ADDRESS));

        // Iterating through all existing Chains to set peers 
        for (uint256 i = 0; i < Chains.length; i++) {
            oftDeployment.setPeer(Chains[i].EID, LayerZeroHelpers._toBytes32(OFT_ADDRESS));
        }

    }

    function configureDVN() internal {
        console.log("Configuring DVNs...");
        // `setConfig` be called for each other chain in the mesh network

        // Set DVN for L1
        _setDVN(HYPE_EID);

        // Iterate over each L2 and set the config
        for (uint256 i = 0; i < Chains.length; i++) {
            _setDVN(Chains[i].EID);
        }
    }

    function configureEnforcedOptions() internal {
        console.log("Configuring enforced options...");

        _appendEnforcedOptions(HYPE_EID);
        for (uint256 i = 0; i < Chains.length; i++) {
            _appendEnforcedOptions(Chains[i].EID);
        }

        oftDeployment.setEnforcedOptions(enforcedOptions);
    }

    // Configures the deployment chain's DVN for the given destination chain
    function _setDVN(uint32 dstEid) public {
        SetConfigParam[] memory params = new SetConfigParam[](1);
        address[] memory requiredDVNs = new address[](3);

        // sorting the DVNs to prevent LZ_ULN_Unsorted() errors
        requiredDVNs[0] = DEPLOYMENT_BITGO_DVN;
        requiredDVNs[1] = DEPLOYMENT_P2P_DVN;
        requiredDVNs[2] = DEPLOYMENT_USDT0_DVN;

        for (uint i = 0; i < requiredDVNs.length - 1; i++) {
            for (uint j = 0; j < requiredDVNs.length - i - 1; j++) {
                if (requiredDVNs[j] > requiredDVNs[j + 1]) {
                    address temp = requiredDVNs[j];
                    requiredDVNs[j] = requiredDVNs[j + 1];
                    requiredDVNs[j + 1] = temp;
                }
            }
        }

        UlnConfig memory ulnConfig = UlnConfig({
            confirmations: 15,
            requiredDVNCount: 3,
            optionalDVNCount: 0,
            optionalDVNThreshold: 0,
            requiredDVNs: requiredDVNs,
            optionalDVNs: new address[](0)
        });

        params[0] = SetConfigParam(dstEid, 2, abi.encode(ulnConfig));
        ILayerZeroEndpointV2(DEPLOYMENT_ENDPOINT).setConfig(OFT_ADDRESS, DEPLOYMENT_SEND_LIB_302, params);
        ILayerZeroEndpointV2(DEPLOYMENT_ENDPOINT).setConfig(OFT_ADDRESS, DEPLOYMENT_RECEIVE_LIB_302, params);
    }

    // Configures the enforced options for the given destination chain
    function _appendEnforcedOptions(uint32 dstEid) internal {
        enforcedOptions.push(EnforcedOptionParam({
            eid: dstEid,
            msgType: 1,
            options: OptionsBuilder.newOptions().addExecutorLzReceiveOption(170_000, 0)
        }));
        enforcedOptions.push(EnforcedOptionParam({
            eid: dstEid,
            msgType: 2,
            options: OptionsBuilder.newOptions().addExecutorLzReceiveOption(170_000, 0)
        }));
    }
}
