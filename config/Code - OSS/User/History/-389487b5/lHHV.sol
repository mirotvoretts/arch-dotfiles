// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

contract HelloWorld {
    string public str = "Hello World!";

    function getMessage() public view returns(string memory) {
        return str;
    } 
}