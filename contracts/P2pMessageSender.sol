// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract P2pMessageSender {
    event Message(address indexed sender, string indexed hash, string text);

    function send(string calldata text) external {
        emit Message(msg.sender, text, text);
    }
}