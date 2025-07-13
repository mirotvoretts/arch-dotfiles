// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract TodoList {
    struct Task {
        string description;
        bool isCompleted;
    }

    Task[] public tasks;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function completeTask(uint _taskId) public {
        require(_taskId < tasks.length);
        tasks[_taskId].isCompleted = true;
    }
}