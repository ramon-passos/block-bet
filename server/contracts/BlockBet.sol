// SPDX-License-Identifier: MIT
// Tells the Solidity compiler to compile only from v0.8.13 to v0.9.
pragma solidity ^0.8.13;

contract BlockBet {
    enum Decision {
        UNDEFINED,
        TRUE,
        FALSE
    }

    enum WinnerVote {
        UNDEFINED,
        OWNER,
        CHALLENGER
    }

    enum Status {
        OPEN,
        CHALLENGED,
        FINISHED,
        INVALID
    }

    struct Punter {
        address punterAddress;
        Decision decision;
        WinnerVote winnerVote;
    }

    struct OracleDecision {
        address orableAddress;
        bool oracleDecision;
    }

    //

    struct Bet {
        string uuid;
        uint value;
        string description;
        address result;
        Punter owner;
        Punter challenger;
        Punter[] punterVotes;
        OracleDecision[] oracles;
        Status status;
    }

    Bet[] bets;
    mapping(address => uint) reputations;
    address public escrow;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    constructor() {
        escrow = address(this);
    }

    function createBet(
        uint value,
        Decision ownerDecision,
        string memory description
    ) public returns (bool sufficient) {
        require(value > 0, "Value must be greater than 0");
        require(msg.sender.balance >= value, "Insufficient balance");
        require(stringLength(description) > 10, "Description too short");

        Punter memory owner = Punter({
            punterAddress: msg.sender,
            decision: ownerDecision,
            winnerVote: WinnerVote.UNDEFINED
        });

        Punter memory emptyChallenger = Punter({
            punterAddress: address(0),
            decision: Decision.UNDEFINED,
            winnerVote: WinnerVote.UNDEFINED
        });

        Bet memory newBet = Bet({
            uuid: generateUUID(),
            value: value,
            description: description,
            result: address(0),
            owner: owner,
            challenger: emptyChallenger,
            punterVotes: new Punter[](0),
            oracles: new OracleDecision[](0),
            status: Status.OPEN
        });

        emit Transfer(msg.sender, escrow, value);
        bets.push(newBet);

        return true;
    }

    function getBet(string memory uuid) public returns (Bet memory bet) {
        for (uint i = 0; i < bets.length; i++) {
            if (
                keccak256(abi.encodePacked(bets[i].uuid)) ==
                keccak256(abi.encodePacked(uuid))
            ) {
                return bets[i];
            }
        }
    }

    function getBets() public returns (Bet[] memory bets) {
        return bets;
    }

    /*

    function challengeBet() {

    }

    function setDecision() {

    }

    function auditBet() {

    } */

    function generateUUID() private returns (string memory) {}

    function stringLength(string memory str) private returns (uint) {
        return bytes(str).length;
    }
}
