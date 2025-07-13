// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

contract HelloWorld {
    string const public str = "Hello World!";

    function getMessage() public view returns(string memory) {
        return str;
    }

    function setMessage(string memory _str) public {
        str = _str;
    }
}