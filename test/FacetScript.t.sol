// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import { FacetScript } from "../src/foundry-utils/FacetScript.sol";

contract TestScript is FacetScript {
}

contract FacetScriptTest is Test {
    TestScript script;

    function setUp() public {
        // Clear L2_RPC env var before each test
        vm.setEnv("L2_RPC", "");
        script = new TestScript();
        script.setUp();
    }

    function testNoRpcUrl() public {
        // Clear L2_RPC env var again just to be sure
        vm.setEnv("L2_RPC", "");
        
        // Should return -1 when L2_RPC is not set
        assertEq(script.deployerNonce(), -1);
    }

    function testWithRpcUrl() public {
        // Set the RPC URL
        vm.setEnv("L2_RPC", "https://example.com");
        
        // Create a new script instance to trigger setUp
        script = new TestScript();
        
        // Should be >= 0 when L2_RPC is set
        assertGe(script.deployerNonce(), 0);
    }

    function testNextL2Address() public {
        vm.setEnv("L2_RPC", "https://example.com");
        script = new TestScript();
        
        address addr1 = script.nextL2Address();
        address addr2 = script.nextL2Address();
        
        // Ensure addresses are different
        assertNotEq(addr1, addr2);
    }
} 