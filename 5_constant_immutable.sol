// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Constants {
    address public constant MY_ADDRESS = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;
    uint256 public constant MY_UINT = 123;

    address public immutable IM_MY_ADDRESS;
    uint256 public immutable IM_MY_UINT;

    constructor(uint256 _myUint) {
        IM_MY_ADDRESS = msg.sender;
        IM_MY_UINT = _myUint;
    }
}
