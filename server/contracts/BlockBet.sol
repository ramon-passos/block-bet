// SPDX-License-Identifier: MIT
// Tells the Solidity compiler to compile only from v0.8.13 to v0.9.
// TODO move struct and enum to separate files
pragma solidity ^0.8.13;

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
    WinnerVote oracleDecision;
}

struct Bet {
    string uuid;
    uint256 timestamp;
    uint value;
    string description;
    address result;
    OracleDecision[4] oracles;
    Punter owner;
    Punter challenger;
    Status status;
}

contract BlockBet {
    Bet[] private openBets;
    Bet[] private challengedBets;
    Bet[] private finishedBets;
    Bet[] private contestedBets;
    Bet[] private invalidBets;
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

        emit Transfer(msg.sender, escrow, value);
        Punter memory owner = Punter({
            punterAddress: msg.sender,
            decision: ownerDecision,
            winnerVote: WinnerVote.UNDEFINED
        });
        openBets.push();
        uint256 newIndex = openBets.length - 1;
        openBets[newIndex].uuid = generateUUID();
        openBets[newIndex].timestamp = block.timestamp;
        openBets[newIndex].value = value;
        openBets[newIndex].description = description;
        openBets[newIndex].result = address(0);
        openBets[newIndex].owner = owner;
        openBets[newIndex].status = Status.OPEN;
        return true;
    }

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

    // // TODO implement a search algorithm to find the bet
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

        moveBet(bet, index, Status.OPEN, Status.CHALLENGED);

        uint256 newBetIndex = challengedBets.length - 1;

        challengedBets[newBetIndex].challenger = challenger;

        emit Transfer(msg.sender, escrow, bet.value);

        return true;
    }

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

        moveBet(bet, index, Status.CHALLENGED, Status.FINISHED);

        uint256 newIndex = finishedBets.length - 1;

        if (bet.owner.winnerVote == WinnerVote.OWNER) {
            challengedBets[newIndex].result = bet.owner.punterAddress;
        } else {
            challengedBets[newIndex].result = bet.challenger.punterAddress;
        }
        return true;
    }

    function contestBet(string memory uuid) public returns (bool sufficient) {
        (Bet memory bet, uint index) = findBet(uuid, finishedBets);
        require(
            keccak256(abi.encodePacked(bet.uuid)) ==
                keccak256(abi.encodePacked(uuid)),
            "Bet does not exist"
        );
        require(bet.status == Status.CHALLENGED, "Bet is not challenged");
        require(
            msg.sender == bet.owner.punterAddress ||
                msg.sender == bet.challenger.punterAddress,
            "Only owner or challenger can contest bet"
        );
        require(
            bet.challenger.winnerVote != WinnerVote.UNDEFINED &&
                bet.owner.winnerVote != WinnerVote.UNDEFINED,
            "Both owner and challenger must vote"
        );
        require(
            bet.challenger.winnerVote != bet.owner.winnerVote,
            "Owner and challenger must vote differently"
        );

        moveBet(bet, index, Status.CHALLENGED, Status.CONTESTED);

        return true;
    }

    // Function to allow oracles to audit the bet
    // function auditBet(
    //     string memory uuid,
    //     WinnerVote winnerVote
    // ) public returns (bool sufficient) {
    //     (Bet memory bet, ) = findBet(uuid, contestedBets);
    //     require(
    //         keccak256(abi.encodePacked(bet.uuid)) ==
    //             keccak256(abi.encodePacked(uuid)),
    //         "Bet does not exist"
    //     );
    //     require(bet.status == Status.CONTESTED, "Bet is not contested");
    //     require(
    //         oracles[msg.sender].oracleDecision != WinnerVote.UNDEFINED,
    //         "Oracle must vote"
    //     );

    //     OracleDecision memory oracleDecision = OracleDecision({
    //         orableAddress: msg.sender,
    //         oracleDecision: winnerVote
    //     });

    //     oracles[msg.sender] = oracleDecision;

    //     return true;
    // }

    // TODO move this utility functions to a separate file

    function moveBet(
        Bet memory bet,
        uint index,
        Status fromStatus,
        Status toStatus
    ) public returns (bool sufficient) {
        Bet[] storage fromArray;
        Bet[] storage toArray;
        if (fromStatus == Status.OPEN) {
            fromArray = openBets;
        } else if (fromStatus == Status.CHALLENGED) {
            fromArray = challengedBets;
        } else if (fromStatus == Status.FINISHED) {
            fromArray = finishedBets;
        } else if (fromStatus == Status.CONTESTED) {
            fromArray = contestedBets;
        } else {
            revert("Invalid from status");
        }

        if (toStatus == Status.CHALLENGED) {
            toArray = challengedBets;
        } else if (toStatus == Status.FINISHED) {
            toArray = finishedBets;
        } else if (toStatus == Status.CONTESTED) {
            toArray = contestedBets;
        } else {
            revert("Invalid to status");
        }

        toArray.push();
        uint256 newIndex = toArray.length - 1;
        toArray[newIndex].uuid = bet.uuid;
        toArray[newIndex].timestamp = bet.timestamp;
        toArray[newIndex].value = bet.value;
        toArray[newIndex].description = bet.description;
        toArray[newIndex].result = bet.result;
        toArray[newIndex].owner = bet.owner;
        toArray[newIndex].challenger = bet.challenger;
        toArray[newIndex].status = toStatus;
        removeElementArray(index, fromArray);
        return true;
    }

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
