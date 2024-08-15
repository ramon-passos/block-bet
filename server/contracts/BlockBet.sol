// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./DataTypes.sol";
import "./Utils.sol";

contract BlockBet {
    using DataTypes for *;
    using Utils for *;

    DataTypes.Bet[] private openBets;
    DataTypes.Bet[] private challengedBets;
    DataTypes.Bet[] private finishedBets;
    DataTypes.Bet[] private contestedBets;
    DataTypes.Bet[] private invalidBets;
    mapping(address => uint) reputations;
    address public escrow;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event BetCreated(string uuid);

    constructor() {
        escrow = address(this);
    }

    function createBet(
        DataTypes.Decision ownerDecision,
        string memory description
    ) public payable returns (bool sufficient) {
        require(msg.value > 0, "You need pay your part to create the bet");
        require(Utils.stringLength(description) > 10, "Description too short");

        emit Transfer(msg.sender, escrow, msg.value);
        DataTypes.Punter memory owner = DataTypes.Punter({
            punterAddress: msg.sender,
            decision: ownerDecision,
            winnerVote: DataTypes.WinnerVote.UNDEFINED
        });
        openBets.push();
        uint256 newIndex = openBets.length - 1;
        openBets[newIndex].uuid = Utils.generateUUID(openBets.length);
        openBets[newIndex].timestamp = block.timestamp;
        openBets[newIndex].value = msg.value;
        openBets[newIndex].description = description;
        openBets[newIndex].result = address(0);
        openBets[newIndex].owner = owner;
        openBets[newIndex].status = DataTypes.Status.OPEN;

        emit BetCreated(openBets[newIndex].uuid);

        return true;
    }

    // function invalidBet(string memory uuid) public returns (bool sufficient) {
    //     (DataTypes.Bet memory bet, uint index) = findBet(uuid, openBets);
    //     require(
    //         keccak256(abi.encodePacked(bet.uuid)) ==
    //             keccak256(abi.encodePacked(uuid)),
    //         "DataTypes.Bet does not exist"
    //     );
    //     require(
    //         bet.status == DataTypes.Status.OPEN || bet.status == DataTypes.Status.CONTESTED,
    //         "DataTypes.Bet is not open or contested"
    //     );
    //     require(
    //         msg.sender == bet.owner.punterAddress ||

    //     moveBet(bet, index, DataTypes.Status.OPEN, DataTypes.Status.INVALID);

    //     return true;
    // }

    function challengeBet(
        string memory uuid,
        DataTypes.Decision challengerDecision
    ) public returns (bool sufficient) {
        (DataTypes.Bet memory bet, uint index) = findBet(uuid, openBets);
        require(
            keccak256(abi.encodePacked(bet.uuid)) ==
                keccak256(abi.encodePacked(uuid)),
            "DataTypes.Bet does not exist"
        );
        require(
            bet.status == DataTypes.Status.OPEN,
            "DataTypes.Bet is not open for challenge"
        );
        require(
            msg.sender != bet.owner.punterAddress,
            "Owner cannot challenge own bet"
        );
        require(msg.sender.balance >= bet.value, "Insufficient balance");
        require(
            challengerDecision != DataTypes.Decision.UNDEFINED,
            "DataTypes.Decision must be defined"
        );
        require(
            bet.owner.decision != DataTypes.Decision.UNDEFINED,
            "Owner decision must be defined"
        );
        require(
            bet.owner.decision != challengerDecision,
            "Challenger decision must be different from owner"
        );

        DataTypes.Punter memory challenger = DataTypes.Punter({
            punterAddress: msg.sender,
            decision: challengerDecision,
            winnerVote: DataTypes.WinnerVote.UNDEFINED
        });

        moveBet(bet, index, DataTypes.Status.OPEN, DataTypes.Status.CHALLENGED);

        uint256 newBetIndex = challengedBets.length - 1;

        challengedBets[newBetIndex].challenger = challenger;

        emit Transfer(msg.sender, escrow, bet.value);

        return true;
    }

    function voteWinner(
        string memory uuid,
        DataTypes.WinnerVote winnerVote
    ) public returns (DataTypes.Bet memory betReturn) {
        (DataTypes.Bet memory bet, uint index) = findBet(uuid, challengedBets);
        require(
            keccak256(abi.encodePacked(bet.uuid)) ==
                keccak256(abi.encodePacked(uuid)),
            "DataTypes.Bet does not exist"
        );
        require(
            bet.status == DataTypes.Status.CHALLENGED,
            "DataTypes.Bet is not challenged"
        );
        require(
            msg.sender == bet.owner.punterAddress ||
                msg.sender == bet.challenger.punterAddress,
            "Only owner or challenger can vote"
        );
        if (msg.sender == bet.owner.punterAddress) {
            challengedBets[index].owner.winnerVote = winnerVote;
        } else {
            challengedBets[index].challenger.winnerVote = winnerVote;
        }
        return bet;
    }

    function finalizeBet(
        string memory uuid,
        DataTypes.Status status
    ) public returns (bool sufficient) {
        // TODO finalize contested bet too
        DataTypes.Bet memory bet;
        uint index;
        if (status == DataTypes.Status.CHALLENGED) {
            (bet, index) = findBet(uuid, challengedBets);
        } else if (status == DataTypes.Status.CONTESTED) {
            (bet, index) = findBet(uuid, contestedBets);
        } else {
            revert("Invalid status");
        }
        require(
            keccak256(abi.encodePacked(bet.uuid)) ==
                keccak256(abi.encodePacked(uuid)),
            "DataTypes.Bet does not exist"
        );
        require(
            bet.status == DataTypes.Status.CHALLENGED ||
                bet.status == DataTypes.Status.CONTESTED,
            "DataTypes.Bet is not challenged or contested"
        );
        //TODO check this condition
        // require(
        //     msg.sender == bet.owner.punterAddress ||
        //         msg.sender == bet.challenger.punterAddress,
        //     "Only owner or challenger can finish bet"
        // );
        require(
            bet.owner.winnerVote != DataTypes.WinnerVote.UNDEFINED &&
                bet.challenger.winnerVote != DataTypes.WinnerVote.UNDEFINED,
            "Both owner and challenger must vote"
        );
        if (bet.owner.winnerVote == bet.challenger.winnerVote) {
            moveBet(
                bet,
                index,
                DataTypes.Status.CHALLENGED,
                DataTypes.Status.FINISHED
            );

            uint256 newIndex = finishedBets.length - 1;

            if (bet.owner.winnerVote == DataTypes.WinnerVote.OWNER) {
                challengedBets[newIndex].result = bet.owner.punterAddress;
                emit Transfer(escrow, bet.owner.punterAddress, bet.value * 2);
                // TODO increase reputation of owner and challenger
            } else {
                challengedBets[newIndex].result = bet.challenger.punterAddress;
                emit Transfer(
                    escrow,
                    bet.challenger.punterAddress,
                    bet.value * 2
                );
                // TODO increase reputation of owner and challenger
            }
        } else {
            DataTypes.WinnerVote majorityOraclesVotes = getMajorityWinnerVote(
                bet
            );

            if (majorityOraclesVotes == DataTypes.WinnerVote.INVALID) {
                moveBet(
                    bet,
                    index,
                    DataTypes.Status.CONTESTED,
                    DataTypes.Status.INVALID
                );
                emit Transfer(escrow, bet.owner.punterAddress, bet.value);
                emit Transfer(escrow, bet.challenger.punterAddress, bet.value);
                // TODO transfer a part of the money to the oracles
                // TODO decrease reputation of oracles that voted against the majority
            } else if (majorityOraclesVotes == DataTypes.WinnerVote.OWNER) {
                moveBet(
                    bet,
                    index,
                    DataTypes.Status.CONTESTED,
                    DataTypes.Status.FINISHED
                );
                uint256 newIndex = finishedBets.length - 1;
                finishedBets[newIndex].result = bet.owner.punterAddress;
                emit Transfer(escrow, bet.owner.punterAddress, bet.value * 2);
                // TODO transfer a part of the money to the oracles
                // TODO increase reputation of oracles
                // TODO decrease reputation of challenger
                // TODO decrease reputation of oracles that voted against the majority
            } else if (
                majorityOraclesVotes == DataTypes.WinnerVote.CHALLENGER
            ) {
                moveBet(
                    bet,
                    index,
                    DataTypes.Status.CONTESTED,
                    DataTypes.Status.FINISHED
                );
                uint256 newIndex = finishedBets.length - 1;
                finishedBets[newIndex].result = bet.challenger.punterAddress;
                emit Transfer(
                    escrow,
                    bet.challenger.punterAddress,
                    bet.value * 2
                );
                // TODO transfer a part of the money to the oracles
                // TODO increase reputation of oracles
                // TODO decrease reputation of owner
                // TODO decrease reputation of oracles that voted against the majority
            } else {
                moveBet(
                    bet,
                    index,
                    DataTypes.Status.CONTESTED,
                    DataTypes.Status.INVALID
                );
                emit Transfer(escrow, bet.owner.punterAddress, bet.value);
                emit Transfer(escrow, bet.challenger.punterAddress, bet.value);
            }
        }
        return true;
    }

    function contestBet(string memory uuid) public returns (bool sufficient) {
        (DataTypes.Bet memory bet, uint index) = findBet(uuid, challengedBets);
        require(
            keccak256(abi.encodePacked(bet.uuid)) ==
                keccak256(abi.encodePacked(uuid)),
            "DataTypes.Bet does not exist"
        );
        require(
            bet.status == DataTypes.Status.CHALLENGED,
            "DataTypes.Bet is not challenged"
        );
        require(
            msg.sender == bet.owner.punterAddress ||
                msg.sender == bet.challenger.punterAddress,
            "Only owner or challenger can contest bet"
        );
        require(
            bet.challenger.winnerVote != DataTypes.WinnerVote.UNDEFINED &&
                bet.owner.winnerVote != DataTypes.WinnerVote.UNDEFINED,
            "Both owner and challenger must vote"
        );
        require(
            bet.challenger.winnerVote != bet.owner.winnerVote,
            "Owner and challenger must vote differently"
        );

        moveBet(
            bet,
            index,
            DataTypes.Status.CHALLENGED,
            DataTypes.Status.CONTESTED
        );

        return true;
    }

    function auditBet(
        string memory uuid,
        DataTypes.WinnerVote winnerVote
    ) public returns (bool sufficient) {
        (DataTypes.Bet memory bet, uint index) = findBet(uuid, contestedBets);
        require(
            keccak256(abi.encodePacked(bet.uuid)) ==
                keccak256(abi.encodePacked(uuid)),
            "DataTypes.Bet does not exist"
        );
        require(
            bet.status == DataTypes.Status.CONTESTED,
            "DataTypes.Bet is not contested"
        );
        require(
            msg.sender != bet.owner.punterAddress &&
                msg.sender != bet.challenger.punterAddress,
            "Only oracles can audit bet"
        );
        require(
            winnerVote != DataTypes.WinnerVote.UNDEFINED,
            "Winner vote must be defined"
        );

        DataTypes.OracleDecision memory oracleDecision = DataTypes
            .OracleDecision({
                oracleAddress: msg.sender,
                oracleDecision: winnerVote
            });

        for (uint i = 0; i < bet.oracles.length; i++) {
            if (bet.oracles[i].oracleAddress == address(0)) {
                contestedBets[index].oracles[i] = oracleDecision;
                break;
            }
        }
        if (
            bet.oracles[DataTypes.MAX_ORACLES - 1].oracleAddress != address(0)
        ) {
            finalizeBet(uuid, DataTypes.Status.CONTESTED);
        }

        return true;
    }

    // TODO function to return bets for a specific user

    // TODO function to cancel a open bet

    // TODO function to invalid a bet

    // TODO move this utility functions to a separate file

    // TODO transfer money in functions that require it

    // TODO consider tax in emit Transfer

    function findBet(
        string memory uuid,
        DataTypes.Bet[] memory betsArray
    ) public pure returns (DataTypes.Bet memory bet, uint index) {
        for (uint i = 0; i < betsArray.length; i++) {
            if (
                keccak256(abi.encodePacked(betsArray[i].uuid)) ==
                keccak256(abi.encodePacked(uuid))
            ) {
                return (betsArray[i], i);
            }
        }
        revert("DataTypes.Bet not found");
    }

    function getBet(
        string memory uuid,
        DataTypes.Status status
    ) public view returns (DataTypes.Bet memory bet) {
        if (status == DataTypes.Status.OPEN) {
            (bet, ) = findBet(uuid, openBets);
            return bet;
        } else if (status == DataTypes.Status.CHALLENGED) {
            (bet, ) = findBet(uuid, challengedBets);
            return bet;
        } else if (status == DataTypes.Status.FINISHED) {
            (bet, ) = findBet(uuid, finishedBets);
            return bet;
        } else if (status == DataTypes.Status.CONTESTED) {
            (bet, ) = findBet(uuid, contestedBets);
            return bet;
        } else {
            DataTypes.Bet[] memory allBets = getBets();
            (bet, ) = findBet(uuid, allBets);
            return bet;
        }
    }

    // // TODO implement a search algorithm to find the bet
    function getBets() public view returns (DataTypes.Bet[] memory) {
        uint totalLength = openBets.length +
            challengedBets.length +
            finishedBets.length +
            contestedBets.length;
        DataTypes.Bet[] memory allBets = new DataTypes.Bet[](totalLength);

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

    function moveBet(
        DataTypes.Bet memory bet,
        uint index,
        DataTypes.Status fromStatus,
        DataTypes.Status toStatus
    ) public returns (bool sufficient) {
        DataTypes.Bet[] storage fromArray;
        DataTypes.Bet[] storage toArray;
        if (fromStatus == DataTypes.Status.OPEN) {
            fromArray = openBets;
        } else if (fromStatus == DataTypes.Status.CHALLENGED) {
            fromArray = challengedBets;
        } else if (fromStatus == DataTypes.Status.FINISHED) {
            fromArray = finishedBets;
        } else if (fromStatus == DataTypes.Status.CONTESTED) {
            fromArray = contestedBets;
        } else {
            revert("Invalid from status");
        }

        if (toStatus == DataTypes.Status.CHALLENGED) {
            toArray = challengedBets;
        } else if (toStatus == DataTypes.Status.FINISHED) {
            toArray = finishedBets;
        } else if (toStatus == DataTypes.Status.CONTESTED) {
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
        Utils.removeElementArray(index, fromArray);
        return true;
    }

    function getMajorityWinnerVote(
        DataTypes.Bet memory bet
    ) private pure returns (DataTypes.WinnerVote) {
        uint ownerVotes = 0;
        uint challengerVotes = 0;
        uint invalidVotes = 0;
        for (uint i = 0; i < DataTypes.MAX_ORACLES; i++) {
            if (bet.oracles[i].oracleDecision == DataTypes.WinnerVote.OWNER) {
                ownerVotes++;
            } else if (
                bet.oracles[i].oracleDecision == DataTypes.WinnerVote.CHALLENGER
            ) {
                challengerVotes++;
            } else if (
                bet.oracles[i].oracleDecision == DataTypes.WinnerVote.INVALID
            ) {
                invalidVotes++;
            }
        }
        if (ownerVotes > challengerVotes && ownerVotes > invalidVotes) {
            return DataTypes.WinnerVote.OWNER;
        } else if (
            challengerVotes > ownerVotes && challengerVotes > invalidVotes
        ) {
            return DataTypes.WinnerVote.CHALLENGER;
        } else if (
            invalidVotes > ownerVotes && invalidVotes > challengerVotes
        ) {
            return DataTypes.WinnerVote.INVALID;
        } else {
            return DataTypes.WinnerVote.UNDEFINED;
        }
    }
}
