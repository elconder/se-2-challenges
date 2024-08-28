// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
	ExampleExternalContract public exampleExternalContract;

	mapping(address => uint256) public balances;

	uint256 public constant threshold = 1 ether;
	uint256 public deadline = block.timestamp + 72 hours;
	bool public openForWithdraw;

	event Stake(address, uint256);

	constructor(address exampleExternalContractAddress) {
		exampleExternalContract = ExampleExternalContract(
			exampleExternalContractAddress
		);
	}

	function stake() external payable {
		require(block.timestamp < deadline, "Staking period has ended");

		balances[msg.sender] += msg.value;

		emit Stake(msg.sender, msg.value);
	}

	function execute() external notCompleted {
		console.log("@@@@@ balance = ", address(this).balance);

		require(
			block.timestamp >= deadline,
			"Deadline has not been reached yet"
		);

		if (address(this).balance >= threshold) {
			console.log("@@@@@ balance >= threshold");
			exampleExternalContract.complete{ value: address(this).balance }();
		} else {
			openForWithdraw = true;
			console.log("@@@@@ openForWithdraw = true");
		}
	}

	function timeLeft() public view returns (uint256) {
		if (block.timestamp >= deadline) {
			return 0;
		} else {
			return deadline - block.timestamp;
		}
	}

	function withdraw() external notCompleted {
		require(openForWithdraw, "Withdrawls are not allowed");
		uint256 userStake = balances[msg.sender];
		require(userStake > 0, "You have no funds to withdraw");

		balances[msg.sender] = 0;
		payable(msg.sender).transfer(userStake);
	}

	receive() external payable {
		this.stake();
	}

	modifier notCompleted() {
		require(
			!exampleExternalContract.completed(),
			"ExampleExternalContract is already completed"
		);
		_;
	}
}
