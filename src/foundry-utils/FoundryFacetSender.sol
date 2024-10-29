// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibFacet } from "../utils/LibFacet.sol";
import { JSONParserLib } from "../../lib/solady/src/utils/JSONParserLib.sol";
import { LibRLP } from "../../lib/solady/src/utils/LibRLP.sol";
import { console } from "forge-std/Test.sol";
import { Script } from "forge-std/Script.sol";

abstract contract FoundryFacetSender is Script {
    int256 public deployerNonce;
    
    modifier broadcast() {
        vm.startBroadcast(msg.sender);
        _;
        vm.stopBroadcast();
    }

    function setUp() public virtual {
        deployerNonce = getL2Nonce();
    }
    
    function sendFacetTransactionFoundry(
        bytes memory to,
        uint256 value,
        uint256 maxFeePerGas,
        uint256 gasLimit,
        bytes memory data
    ) internal {
        bytes memory payload = LibFacet.prepareFacetTransaction({
            to: to,
            value: value,
            maxFeePerGas: maxFeePerGas,
            gasLimit: gasLimit,
            data: data
        });

        (bool success, ) = LibFacet.facetInboxAddress.call(payload);
        require(success, "Facet transaction failed");
    }

    function sendFacetTransactionFoundry(
        uint256 gasLimit,
        bytes memory data
    ) internal {
        sendFacetTransactionFoundry({
            to: bytes(''),
            gasLimit: gasLimit,
            value: 0,
            maxFeePerGas: 10_000 gwei,
            data: data
        });
    }

    function sendFacetTransactionFoundry(
        address to,
        uint256 gasLimit,
        bytes memory data
    ) internal {
        sendFacetTransactionFoundry({
            to: abi.encodePacked(to),
            gasLimit: gasLimit,
            value: 0,
            maxFeePerGas: 10_000 gwei,
            data: data
        });
    }
    
    function nextL2Address() internal returns (address) {
        require(deployerNonce >= 0, "L2 RPC not set");
        
        address addr = LibRLP.computeAddress(msg.sender, uint256(deployerNonce));
        deployerNonce++;
        return addr;
    }
    
    function getL2Nonce() internal returns (int256) {
        // Try to get L2_RPC, returns empty string if not set
        string memory rpcUrl = vm.envOr("L2_RPC", string(""));
        
        // If RPC URL is not set, return 0
        if (bytes(rpcUrl).length == 0) {
            return -1;
        }

        // Store the current fork ID
        uint256 originalFork = vm.activeFork();

        // Create and select the L2 fork
        uint256 l2Fork = vm.createFork(rpcUrl);
        vm.selectFork(l2Fork);

        // Construct the JSON string for the RPC parameters
        string memory params = string(abi.encodePacked(
            "[\"",
            vm.toString(msg.sender), // Address of the message sender
            "\", \"",
            "latest",                // Block number
            "\"]"
        ));

        // Perform the RPC call to get the nonce
        bytes memory returnData = vm.rpc(
            "eth_getTransactionCount", // RPC method for getting nonce
            params                     // JSON string parameters
        );

        // Convert the returned hex string to a uint256
        uint256 nonce = JSONParserLib.parseUintFromHex(vm.toString(returnData));

        // Log the nonce
        console.log("Nonce of", msg.sender, ":", nonce);

        // Switch back to the original fork
        vm.selectFork(originalFork);

        return int256(nonce);
    }
}
