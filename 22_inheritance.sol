// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract A {
    function foo() public pure virtual returns (string memory) {
        return "A";
    }
}

// Contract를 상속할 때에는 is 키워드를 사용한다.
contract B is A {
    // A.foo()함수를 override
    function foo() public pure virtual override returns (string memory) {
        return "B";
    }
}

contract C is A {
    // A.foo() 함수를 override
    function foo() public pure virtual override returns (string memory) {
        return "C";
    }
}

// Contract는 여러 개의 parent contract를 상속받을 수 있다.
// 다중 상속 받은 contract의 함수 중 같은 이름을 가진 함수가 존재하면
// 오른쪽에서 왼쪽으로 컨트랙트의 함수를 적용한다.

contract D is B, C {
    // D.foo() 함수는 "C"를 return한다.
    // 왜냐하면 C는 foo()함수를 포함하는 가장 오른쪽 parent contract이기 때문이다.
    function foo() public pure override(B, C) returns (string memory) {
        return super.foo();
    }
}

contract E is C, B {
    // E.foo() 함수는 "B"를 return한다.
    // 왜냐하면 B는 foo()함수를 포함하는 가장 오른쪽 parent contract이기 때문이다.
    function foo() public pure override(C, B) returns (string memory) {
        return super.foo();
    }
}

// 상속은 가장 상위의 parent 컨트랙트에서 child 컨트랙트 순으로 적어주어야 한다.
// 즉, 자신의 상위(parent)에 있는 컨트랙트를 먼저 적어주어야 한다.
// A와 B를 바꾸어서 적으면 컴파일 에러가 발생한다.
contract F is A, B {
    function foo() public pure override(A, B) returns (string memory) {
        return super.foo();
    }
}