// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Variables {
    //state variables
    string public text = "Hello World";
    uint256 public num = 123;

    function doSomething() public {
        // local variables
        uint256 i = 456;

        // global variables
        uint256 Timestamp = block.timestamp;
        address sender = msg.sender;
    }
}
