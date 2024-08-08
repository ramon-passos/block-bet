// SPDX-License-Identifier: MIT
// Tells the Solidity compiler to compile only from v0.8.13 to v0.9.
// TODO move struct and enum to separate files
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

    //Bet[] private bets;
    Bet[] private openBets;
    Bet[] private challengedBets;
    Bet[] private finishedBets;
    Bet[] private contestedBets;
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
        openBets.push(newBet);

        return true;
    }

    function getBet(
        string memory uuid,
        Status status
    ) public view returns (Bet memory bet) {
        if (status == Status.OPEN) {
            (bet, ) = findBet(uuid, openBets);
            return bet;
        } else if (status == Status.CHALLENGED) {
            (bet, ) = findBet(uuid, challengedBets);
            return bet;
        } else if (status == Status.FINISHED) {
            (bet, ) = findBet(uuid, finishedBets);
            return bet;
        } else if (status == Status.CONTESTED) {
            (bet, ) = findBet(uuid, contestedBets);
            return bet;
        } else {
            Bet[] memory allBets = getBets();
            (bet, ) = findBet(uuid, allBets);
            return bet;
        }
    }

    // TODO implement a search algorithm to find the bet
    function findBet(
        string memory uuid,
        Bet[] memory betsArray
    ) public pure returns (Bet memory bet, uint index) {
        for (uint i = 0; i < betsArray.length; i++) {
            if (
                keccak256(abi.encodePacked(betsArray[i].uuid)) ==
                keccak256(abi.encodePacked(uuid))
            ) {
                return (betsArray[i], i);
            }
        }
        revert("Bet not found");
    }

    function getBets() public view returns (Bet[] memory) {
        uint totalLength = openBets.length +
            challengedBets.length +
            finishedBets.length +
            contestedBets.length;
        Bet[] memory allBets = new Bet[](totalLength);

        uint index = 0;

        for (uint i = 0; i < openBets.length; i++) {
            allBets[index] = openBets[i];
            index++;
        }

        for (uint i = 0; i < challengedBets.length; i++) {
            allBets[index] = challengedBets[i];
            index++;
        }

        for (uint i = 0; i < finishedBets.length; i++) {
            allBets[index] = finishedBets[i];
            index++;
        }

        for (uint i = 0; i < contestedBets.length; i++) {
            allBets[index] = contestedBets[i];
            index++;
        }

        return allBets;
    }

    //TODO: Use getBet to check if bet exists instead of looping through all bets

    function challengeBet(
        string memory uuid,
        Decision challengerDecision
    ) public returns (bool sufficient) {
        (Bet memory bet, uint index) = findBet(uuid, openBets);
        require(
            keccak256(abi.encodePacked(bet.uuid)) ==
                keccak256(abi.encodePacked(uuid)),
            "Bet does not exist"
        );
        require(bet.status == Status.OPEN, "Bet is not open for challenge");
        require(
            msg.sender != bet.owner.punterAddress,
            "Owner cannot challenge own bet"
        );
        require(msg.sender.balance >= bet.value, "Insufficient balance");
        require(
            challengerDecision != Decision.UNDEFINED,
            "Decision must be defined"
        );
        require(
            bet.owner.decision != Decision.UNDEFINED,
            "Owner decision must be defined"
        );
        require(
            bet.owner.decision != challengerDecision,
            "Challenger decision must be different from owner"
        );

        Punter memory challenger = Punter({
            punterAddress: msg.sender,
            decision: challengerDecision,
            winnerVote: WinnerVote.UNDEFINED
        });

        emit Transfer(msg.sender, escrow, bet.value);

        bet.challenger = challenger;
        bet.status = Status.CHALLENGED;

        removeElementArray(index, openBets);

        challengedBets.push(bet);

        return true;
    }

    //TODO: Use getBet to check if bet exists instead of looping through all bets
    function voteWinner(
        string memory uuid,
        WinnerVote winnerVote
    ) public view returns (bool sufficient) {
        (Bet memory bet, ) = findBet(uuid, challengedBets);
        require(
            keccak256(abi.encodePacked(bet.uuid)) ==
                keccak256(abi.encodePacked(uuid)),
            "Bet does not exist"
        );
        require(bet.status == Status.CHALLENGED, "Bet is not challenged");
        require(
            msg.sender == bet.owner.punterAddress ||
                msg.sender == bet.challenger.punterAddress,
            "Only owner or challenger can vote"
        );
        if (msg.sender == bet.owner.punterAddress) {
            bet.owner.winnerVote = winnerVote;
        } else {
            bet.challenger.winnerVote = winnerVote;
        }
        return true;
    }

    // //TODO: Use getBet to check if bet exists instead of looping through all bets
    function finalizeBet(string memory uuid) public returns (bool sufficient) {
        (Bet memory bet, uint index) = findBet(uuid, challengedBets);
        require(
            keccak256(abi.encodePacked(bet.uuid)) ==
                keccak256(abi.encodePacked(uuid)),
            "Bet does not exist"
        );
        require(bet.status == Status.CHALLENGED, "Bet is not challenged");
        require(
            msg.sender == bet.owner.punterAddress ||
                msg.sender == bet.challenger.punterAddress,
            "Only owner or challenger can finish bet"
        );
        require(
            bet.owner.winnerVote != WinnerVote.UNDEFINED &&
                bet.challenger.winnerVote != WinnerVote.UNDEFINED,
            "Both owner and challenger must vote"
        );
        require(
            bet.owner.winnerVote == bet.challenger.winnerVote,
            "Owner and challenger must vote the same"
        );

        if (bet.owner.winnerVote == WinnerVote.OWNER) {
            bet.result = bet.owner.punterAddress;
        } else {
            bet.result = bet.challenger.punterAddress;
        }

        bet.status = Status.FINISHED;

        removeElementArray(index, challengedBets);

        finishedBets.push(bet);

        return true;
    }

    /*
    // Function to allow the owner or challenger to contest the result of a bet
    function contestBet () {}

    // Function to allow oracles to audit the bet
    function auditBet() {

    } */

    // TODO move this utility functions to a separate file

    function generateUUID() private view returns (string memory) {
        bytes32 uuid = keccak256(
            abi.encodePacked(block.timestamp, msg.sender, openBets.length)
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

    function removeElementArray(uint index, Bet[] storage array) internal {
        require(index < array.length, "Index out of bounds");

        for (uint i = index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }

        array.pop();
    }
}
