// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Mapping {
    mapping(address => uint256) public myMapp;

    function get(address _addr) public view returns (uint256) {
        return myMapp[_addr];
    }

    function set(address _addr, uint256 _i) public {
        myMapp[_addr] = _i;
    }

    function remove(address _addr) public {
        delete myMapp[_addr];
    }
}