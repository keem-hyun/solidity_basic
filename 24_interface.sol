// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 간단한 Counter를 구현한 contract
contract Counter {
    uint256 public count;

    function increment() external {
        count += 1;
    }
}

// Counter 계약의 interface로 호출 가능한 function들을 정의
interface ICounter {
    function count() external view returns (uint256);
    function increment() external;
}

// ICounter interface를 사용하여 Counter contract과 상호 작용하는 contract
contract MyContract {
    function incrementCounter(address _counter) external {
        ICounter(_counter).increment();
    }

    function getCount(address _counter) external view returns (uint256) {
        return ICounter(_counter).count();
    }
}

interface UniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface UniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract UniswapExample {
    // UniswapV2Factory contract, DAI, WETH address
    address private factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // DAI, WETH pair의 reserve를 조회하여 반환한다.
    function getTokenReserves() external view returns (uint256, uint256) {
        // getPair function을 호출하여 DAI, WETH 페어의 address를 가져온다.
        address pair = UniswapV2Factory(factory).getPair(dai, weth);
        (uint256 reserve0, uint256 reserve1, ) = UniswapV2Pair(pair).getReserves();
        return (reserve0, reserve1);
    }
}