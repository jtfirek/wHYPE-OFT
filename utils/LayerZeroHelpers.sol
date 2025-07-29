// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import { OptionsBuilder } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";
import "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";

import "./L2Constants.sol";

library LayerZeroHelpers {
    using OptionsBuilder for bytes;


    // Converts an address to bytes32
    function _toBytes32(address addr) public pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    // get a dead ULN (unreachable path)
    function _getDeadUln() public pure returns (bytes memory) {
        address[] memory requiredDVNs = new address[](1);
        requiredDVNs[0] = 0x000000000000000000000000000000000000dEaD;
        

        UlnConfig memory ulnConfig = UlnConfig({
            confirmations: 15,
            requiredDVNCount: 1,
            optionalDVNCount: 0,
            optionalDVNThreshold: 0,
            requiredDVNs: requiredDVNs,
            optionalDVNs: new address[](0)
        });

        return abi.encode(ulnConfig);
    }

    function getDVNConfig(uint32 eid, address[3] memory lzDvn) internal pure returns (SetConfigParam[] memory) {
        SetConfigParam[] memory params = new SetConfigParam[](1);
        address[] memory requiredDVNs = new address[](3);
        requiredDVNs[0] = lzDvn[0];
        requiredDVNs[1] = lzDvn[1];
        requiredDVNs[2] = lzDvn[2];
        
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

        params[0] = SetConfigParam(eid, 2, abi.encode(ulnConfig));

        return params;
    }

    function getDVNConfigWithBlockConfirmations(uint32 eid, address[3] memory lzDvn, uint64 numConfirmations) internal pure returns (SetConfigParam[] memory) {
        SetConfigParam[] memory params = new SetConfigParam[](1);
        address[] memory requiredDVNs = new address[](3);
        requiredDVNs[0] = lzDvn[0];
        requiredDVNs[1] = lzDvn[1];
        requiredDVNs[2] = lzDvn[2];

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
            confirmations: numConfirmations,
            requiredDVNCount: 3,
            optionalDVNCount: 0,
            optionalDVNThreshold: 0,
            requiredDVNs: requiredDVNs,
            optionalDVNs: new address[](0)
        });

        params[0] = SetConfigParam(eid, 2, abi.encode(ulnConfig));

        return params;
    }

}
