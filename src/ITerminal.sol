// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ITerminal {
    event Bid(address indexed bidder, uint256 amount, uint256 newPot, uint256 timestamp);
    event PotClaimed(address indexed winner, uint256 amount, uint256 timestamp);
    event TimerReset(uint256 newExpiry);

    error GameNotActive();
    error GameActive();
    error InsufficientFee();
    error TransferFailed();

    function bid() external payable;
    function claim() external;
    function bump() external;
}
