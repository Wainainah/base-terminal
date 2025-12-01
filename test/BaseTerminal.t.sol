// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BaseTerminal.sol";

contract BaseTerminalTest is Test {
    BaseTerminal public terminal;

    function setUp() public {
        terminal = new BaseTerminal();
    }

    function testInitialState() public {
        assertTrue(terminal.gameActive());
        assertEq(terminal.potBalance(), 0);
    }

    function testBid() public {
        vm.deal(address(1), 1 ether);
        vm.prank(address(1));
        terminal.bid{value: 0.01 ether}();

        assertEq(terminal.currentLeader(), address(1));
        assertEq(terminal.potBalance(), 0.01 ether);
    }

    function testFailBidInsufficient() public {
        vm.deal(address(1), 1 ether);
        vm.prank(address(1));
        terminal.bid{value: 0.0001 ether}();
    }
}
