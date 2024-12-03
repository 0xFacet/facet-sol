// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { FacetScript } from "../src/foundry-utils/FacetScript.sol";
import { Script, console } from "forge-std/Script.sol";

contract ExampleContract {
    uint256 public number;
    string public greeting;

    constructor(uint256 newNumber, string memory newGreeting) {
        number = newNumber;
        greeting = newGreeting;
    }

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }
}

// Run with: `L2_RPC=https://sepolia.facet.org forge script -vvv 'script/DeployExample.s.sol' --tc DeployExample --rpc-url <YOUR L1 RPC> --broadcast --private-key <YOUR PRIVATE KEY>`

contract DeployExample is FacetScript {
    function setUp() public override {
        super.setUp();
    }

    function run() public broadcast {
        address deployAddress = nextL2Address();
        console.log("Contract will be deployed at:", deployAddress);
        
        // Deploy the contract
        sendFacetTransactionFoundry({
            gasLimit: 5_000_000,
            data: abi.encodePacked(
                type(ExampleContract).creationCode,
                abi.encode(123, "hello!")
            )
        });
        
        bytes memory setNumberCalldata = abi.encodeWithSelector(
            ExampleContract.setNumber.selector,
            123
        );
        
        // Call the setNumber function
        sendFacetTransactionFoundry({
            to: deployAddress,
            gasLimit: 5_000_000,
            data: setNumberCalldata
        });
    }
}
