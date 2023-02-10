// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;
    mapping(address => uint256) public balances;
    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 72 hours;
    bool openForWithdraw = false;

    event Stake(address staker, uint256 amount);

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    modifier notCompleted() {
        require(
            !exampleExternalContract.completed(),
            "The process has been completed!"
        );
        _;
    }

    function stake() public payable {
        require(timeLeft() > 0, "Deadline has been hit!");
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    function execute() public notCompleted {
        require(timeLeft() == 0, "The deadline hasn't been hit!");
        if (address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdraw = true;
        }
    }

    function withdraw() public notCompleted {
        require(openForWithdraw, "Withdraw is not allowed!");
        payable(msg.sender).transfer(balances[msg.sender]);
    }

    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    receive() external payable {
        stake();
    }

    // KJ
}
