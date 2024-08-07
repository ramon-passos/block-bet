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
        CONTESTED,
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

    struct Bet {
        string uuid;
        uint value;
        string description;
        address result;
        Punter owner;
        Punter challenger;
        //OracleDecision[] oracles;
        Status status;
    }

    Bet[] private bets;
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
            // oracles: [],
            status: Status.OPEN
        });

        emit Transfer(msg.sender, escrow, value);
        bets.push(newBet);

        return true;
    }

    function getBet(string memory uuid) public view returns (Bet memory bet) {
        for (uint i = 0; i < bets.length; i++) {
            if (
                keccak256(abi.encodePacked(bets[i].uuid)) ==
                keccak256(abi.encodePacked(uuid))
            ) {
                return bets[i];
            }
        }
    }

    function getBets() public view returns (Bet[] memory) {
        return bets;
    }

    //TODO: Use getBet to check if bet exists instead of looping through all bets

    function challengeBet(
        string memory uuid,
        Decision challengerDecision
    ) public returns (bool sufficient) {
        for (uint i = 0; i < bets.length; i++) {
            if (
                keccak256(abi.encodePacked(bets[i].uuid)) ==
                keccak256(abi.encodePacked(uuid))
            ) {
                require(
                    bets[i].status == Status.OPEN,
                    "Bet is not open for challenge"
                );
                require(
                    msg.sender != bets[i].owner.punterAddress,
                    "Owner cannot challenge own bet"
                );
                require(
                    msg.sender.balance >= bets[i].value,
                    "Insufficient balance"
                );
                require(
                    challengerDecision != Decision.UNDEFINED,
                    "Decision must be defined"
                );
                require(
                    bets[i].owner.decision != Decision.UNDEFINED,
                    "Owner decision must be defined"
                );
                require(
                    bets[i].owner.decision != challengerDecision,
                    "Challenger decision must be different from owner"
                );

                Punter memory challenger = Punter({
                    punterAddress: msg.sender,
                    decision: challengerDecision,
                    winnerVote: WinnerVote.UNDEFINED
                });

                emit Transfer(msg.sender, escrow, bets[i].value);

                bets[i].challenger = challenger;
                bets[i].status = Status.CHALLENGED;

                return true;
            }
        }
    }

    //TODO: Use getBet to check if bet exists instead of looping through all bets
    function voteWinner(
        string memory uuid,
        WinnerVote winnerVote
    ) public returns (bool sufficient) {
        for (uint i = 0; i < bets.length; i++) {
            if (
                keccak256(abi.encodePacked(bets[i].uuid)) ==
                keccak256(abi.encodePacked(uuid))
            ) {
                require(
                    bets[i].status == Status.CHALLENGED,
                    "Bet is not challenged"
                );
                require(
                    msg.sender == bets[i].owner.punterAddress ||
                        msg.sender == bets[i].challenger.punterAddress,
                    "Only owner or challenger can vote"
                );

                if (msg.sender == bets[i].owner.punterAddress) {
                    bets[i].owner.winnerVote = winnerVote;
                } else {
                    bets[i].challenger.winnerVote = winnerVote;
                }

                return true;
            }
        }
    }

    //TODO: Use getBet to check if bet exists instead of looping through all bets
    function finalizeBet(string memory uuid) public returns (bool sufficient) {
        for (uint i = 0; i < bets.length; i++) {
            if (
                keccak256(abi.encodePacked(bets[i].uuid)) ==
                keccak256(abi.encodePacked(uuid))
            ) {
                require(
                    bets[i].status == Status.CHALLENGED,
                    "Bet is not challenged"
                );
                require(
                    msg.sender == bets[i].owner.punterAddress ||
                        msg.sender == bets[i].challenger.punterAddress,
                    "Only owner or challenger can finish bet"
                );
                require(
                    bets[i].owner.winnerVote != WinnerVote.UNDEFINED &&
                        bets[i].challenger.winnerVote != WinnerVote.UNDEFINED,
                    "Both owner and challenger must vote"
                );
                require(
                    bets[i].owner.winnerVote == bets[i].challenger.winnerVote,
                    "Owner and challenger must vote the same"
                );

                if (bets[i].owner.winnerVote == WinnerVote.OWNER) {
                    bets[i].result = bets[i].owner.punterAddress;
                } else {
                    bets[i].result = bets[i].challenger.punterAddress;
                }

                bets[i].status = Status.FINISHED;

                return true;
            }
        }
    }

    /*
    function auditBet() {

    } */

    function generateUUID() private view returns (string memory) {
        bytes32 uuid = keccak256(
            abi.encodePacked(block.timestamp, msg.sender, bets.length)
        );
        return toHexString(uuid);
    }

    function toHexString(bytes32 data) private pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(64);
        for (uint i = 0; i < 32; i++) {
            str[i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[1 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function stringLength(string memory str) private pure returns (uint) {
        return bytes(str).length;
    }
}
