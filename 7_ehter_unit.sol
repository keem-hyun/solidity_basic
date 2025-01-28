// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EtherUnits {
    uint256 public oneWei = 1 wei;
    uint256 public oneGwei = 1 gwei;
    uint256 public oneEther = 1 ether;

    bool public isOneWei = oneWei == 1;
    bool public isOneGwei = oneGwei == 1e9;
    bool public isOneEther = oneEther == 1e18;
}
