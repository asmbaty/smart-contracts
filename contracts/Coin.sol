// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.5;

contract Coin {
    address public minter;
    mapping (address => uint) public balances;

    /// events
    event Sent(address from, address to, uint amount);

    // modifiers
    modifier onlyMinter() {
        require(msg.sender == minter);
        _;
    }

    constructor() {
        minter = msg.sender;
    }

    function mint(address receiver, uint amount) public onlyMinter {
        balances[receiver] += amount;
    }

    // errors
    error InsufficientBalance(uint requested, uint available);

    function send(address receiver, uint amount) public {
        if(amount > balances[msg.sender]) {
            revert InsufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            });
        }

        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}