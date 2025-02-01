// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 현재 디렉토리에서 Foo.sol을 임포트
import "./29_import_foo.sol";

// 특정 심볼만 임포트하고 별칭(alias)을 사용할 수 있다
import {Unauthorized, add as func, Point} from "./29_import_foo.sol";

contract Import {
    // Foo 계약 초기화
    Foo public foo = new Foo();

    // Foo 계약의 name 값을 가져오는 함수
    function getFooName() public view returns (string memory) {
        return foo.name();
    }
}