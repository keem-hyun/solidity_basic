// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ForLoopExample {
    uint256[] public numbers = [1, 2, 3, 4];

    function sumNumbers() public view returns (uint) {
        uint sum = 0;
        for (uint i = 0; i < numbers.length; i++) {
            sum += numbers[i];
        }
        return sum;
    }
}