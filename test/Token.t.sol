// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token public token;

    function setUp() public {
        token = new Token();
        token.setNumber(0);
    }

    function testIncrement() public {
        token.increment();
        assertEq(token.number(), 1);
    }

    function testSetNumber(uint256 x) public {
        token.setNumber(x);
        assertEq(token.number(), x);
    }
}
