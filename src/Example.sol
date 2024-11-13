// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Example {
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
