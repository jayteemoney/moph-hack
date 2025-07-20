// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Payroll is Ownable {
    struct Employee {
        uint256 salary;
        uint256 lastClaimed;
        uint256 vestingDuration;
    }

    IERC20 public token;
    mapping(address => Employee) public employees;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    function addEmployee(address _employee, uint256 _salary, uint256 _vestingDuration) external onlyOwner {
        employees[_employee] = Employee(_salary, block.timestamp, _vestingDuration);
    }

    function claim() external {
        Employee storage emp = employees[msg.sender];
        require(emp.salary > 0, "Not an employee");

        uint256 timePassed = block.timestamp - emp.lastClaimed;
        require(timePassed > 0, "Already claimed");

        uint256 claimable = (emp.salary * timePassed) / emp.vestingDuration;
        require(claimable > 0, "Nothing to claim");

        emp.lastClaimed = block.timestamp;
        token.transfer(msg.sender, claimable);
    }

    function fundPayroll(uint256 amount) external onlyOwner {
        token.transferFrom(msg.sender, address(this), amount);
    }
}