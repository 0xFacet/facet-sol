// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { FacetScript } from "../src/foundry-utils/FacetScript.sol";
import { Example } from "../src/Example.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployExample is FacetScript {
    function setUp() public override {
        super.setUp();
    }

    function run() public broadcast {
        // Get the address where the contract will be deployed
        address deployAddress = nextL2Address();
        console.log("Contract will be deployed at:", deployAddress);
        
        sendFacetTransactionFoundry({
            gasLimit: 5_000_000,
            data: abi.encodePacked(
                type(Example).creationCode,
                abi.encode(123, "hello!")
            )
        });
        
        bytes memory setNumberCalldata = abi.encodeWithSelector(
            Example.setNumber.selector,
            123
        );
        
        sendFacetTransactionFoundry({
            to: deployAddress,
            gasLimit: 5_000_000,
            data: setNumberCalldata
        });
    }
} 