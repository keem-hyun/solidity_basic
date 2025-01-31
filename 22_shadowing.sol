 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract A {
    string public name = "Contract A";

    function getName() public view returns (string memory) {
        return name;
    }
}

// 솔리디티 0.6에서는 Shadowing을 지원하지 않는다.

// 이 컨트랙트의 name은 override 되지 않는다.
// contract B is A {
//     string public name = "Contract B";
// }

contract C is A {
    // inherited state variable의 올바른 override 방식
    constructor() {
        name = "Contract C";
    }

    // C.getName은 "Contract C"를 return 한다.
}