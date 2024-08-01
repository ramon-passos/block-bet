// SPDX-License-Identifier: MIT
// Tells the Solidity compiler to compile only from v0.8.13 to v0.9.
pragma solidity ^0.8.13;

contract BlockBet {
    struct Punter {
        address punter_address;
        bool decision;
        bool winner_vote;
    }

    struct OracleDecision {
        address oracle_address;
        bool oracle_decision;
    }

    struct Bet {
        uint value;
        string description;
        address result;
        bool invalid;
        Punter owner;
        Punter challenger;
        Punter[] punter_votes;
        OracleDecision[] oracles;
    }

	Bet bets;
    mapping (address => uint) reputations;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

	constructor() {
		bets[tx.origin] = 10000;
	}

    function createBet(uint value, string description) public returns(bool sufficient) {
        if (bets[msg.sender] < value) return false;
        bets[msg.sender] -= value;
        bets[receiver] += value;
        emit Transfer(msg.sender, receiver, value);
        return true;
    }

    function getBet() public returns(Bet bet) {

    }

    function challengeBet() {

    }

    function setDecision() {

    }

    function auditBet() {

    }
}

