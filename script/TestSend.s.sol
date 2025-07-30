// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console.sol";
import "forge-std/console2.sol";
import "forge-std/Script.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/utils/RateLimiter.sol";
import { MessagingFee } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

import { SendParam } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";
import "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";

import "../src/wHYPEOFT.sol";
import "forge-std/Test.sol";
import "../utils/L2Constants.sol";

// forge script script/TestSend.s.sol:TestSend --rpc-url "source chain" --private-key "dev wallet"
contract TestSend is Script, L2Constants {

    function run() public {
        vm.startBroadcast();

        /*//////////////////////////////////////////////////////////////
                         Current Send Parameters
        //////////////////////////////////////////////////////////////*/
    
        uint32 DST_EID = HYPE_EID;

        /*//////////////////////////////////////////////////////////////
                    
        //////////////////////////////////////////////////////////////*/

        IOFT SENDING_OFT = IOFT(OFT_ADDRESS);
        IERC20 SENDING_ERC20 = IERC20(OFT_ADDRESS);

        // If sending from L1, the OFT adapter is the OFT
        if (block.chainid == 999) {
            SENDING_OFT = IOFT(OFT_ADAPTER_ADDRESS);
            SENDING_ERC20 = IERC20(WRAPPED_HYPE_ADDRESS);
        }
    
        // Define the SendParam struct (script deployer is the recipient)
        SendParam memory param = SendParam({
            dstEid: DST_EID,
            to: _toBytes32(msg.sender),
            amountLD: 50000000000000,
            minAmountLD: 50000000000000,
            extraOptions: "",
            composeMsg: "",
            oftCmd: ""
        });

        MessagingFee memory fee = SENDING_OFT.quoteSend(param, false);
        SENDING_ERC20.approve(address(SENDING_OFT), 50000000000000);

        try SENDING_OFT.send{value: fee.nativeFee }(
            param, 
            fee,
            msg.sender
        ) {
            console.log("Success");
        } catch Error(string memory reason) {
            console.log("Error: ", reason);
        } catch (bytes memory lowLevelData) {
            console.logBytes(lowLevelData);
        }
    }

    function _toBytes32(address addr) public pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}
