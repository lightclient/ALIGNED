// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {AlignmentToken} from "../src/Token.sol";

address constant aa = address(0xaa);
address constant bb = address(0xbb);

contract TokenTest is Test {
    AlignmentToken public token;

    function setUp() public {
        token = new AlignmentToken();
    }

    function testName() public {
        assertEq(token.name(), "Alignment");
        assertEq(token.symbol(), "ALIGN");
    }

    function testTransfer() public {
            assertEq(token.balanceOf(aa), 0);
            token.transfer(aa, 42);
            assertEq(token.balanceOf(aa), 42);
    }

    function testIncentives() public {
            assertEq(token.balanceOf(aa), 0);
            token.aligned(aa, 100);
            assertEq(token.balanceOf(aa), 100);

            token.unaligned(aa, 99);
            assertEq(token.balanceOf(aa), 1);

            vm.prank(bb);
            vm.expectRevert();
            token.aligned(aa, 1);
    }

    function testExcommunication() public {
            token.transfer(aa, 42);
            assertEq(token.balanceOf(aa), 42);

            token.excommunicate(aa);
            assertEq(token.isUnaligned(aa), true);

            vm.expectRevert("recipient is unaligned");
            token.transfer(aa, 42);

            vm.prank(aa);
            vm.expectRevert("sender is unaligned");
            token.transfer(bb, 42);

            vm.deal(aa, 10 ether);
            vm.prank(aa);
            token.reconcile{value: 10 ether}();
            assertEq(token.isUnaligned(aa), false);

            assertEq(token.balanceOf(aa), 0);
            token.transfer(aa, 42);
            assertEq(token.balanceOf(aa), 42);
    }

    function testOrdained() public {
            assertFalse(token.hasRole(token.MINISTER_OF_ALIGNMENT(), aa));
            token.ordain(aa);
            assertTrue(token.hasRole(token.MINISTER_OF_ALIGNMENT(), aa));

            vm.prank(aa);
            token.aligned(aa, 100);

            vm.expectRevert("the ordained may not be penalized");
            token.unaligned(aa, 10);

            vm.expectRevert("the ordained may not be penalized");
            token.excommunicate(aa);

            token.revokeRole(token.MINISTER_OF_ALIGNMENT(), aa);
            assertFalse(token.hasRole(token.MINISTER_OF_ALIGNMENT(), aa));
    }
}
