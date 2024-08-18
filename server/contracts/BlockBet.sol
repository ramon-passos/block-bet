// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./DataTypes.sol";
import "./Utils.sol";

contract BlockBet {
    using DataTypes for *;
    using Utils for *;

    DataTypes.Bet[] private bets;
    mapping(address => uint) reputations;
    address public escrow;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event BetCreated(string uuid);

    constructor() {
        escrow = address(this);
    }

    // TODO transfer money in functions that require it

    // TODO consider tax in emit Transfer

    function createBet(
        DataTypes.Decision ownerDecision,
        string memory description
    ) public payable returns (bool sufficient) {
        require(msg.value > 0, "You need to pay your part to create the bet");
        require(Utils.stringLength(description) > 10, "Description too short");

        emit Transfer(msg.sender, escrow, msg.value);
        DataTypes.Punter memory owner = DataTypes.Punter({
            punterAddress: msg.sender,
            decision: ownerDecision,
            winnerVote: DataTypes.WinnerVote.UNDEFINED
        });

        bets.push();
        uint256 newIndex = bets.length - 1;
        bets[newIndex].uuid = Utils.generateUUID(bets.length);
        bets[newIndex].timestamp = block.timestamp;
        bets[newIndex].value = msg.value;
        bets[newIndex].description = description;
        bets[newIndex].result = address(0);
        bets[newIndex].owner = owner;
        bets[newIndex].status = DataTypes.Status.OPEN;

        emit BetCreated(bets[newIndex].uuid);

        return true;
    }

    function challengeBet(
        string memory uuid,
        DataTypes.Decision challengerDecision
    ) public returns (bool sufficient) {
        (DataTypes.Bet memory bet, uint index) = findBet(uuid);
        require(
            bet.status == DataTypes.Status.OPEN,
            "Bet is not open for challenge"
        );
        require(
            msg.sender != bet.owner.punterAddress,
            "Owner cannot challenge own bet"
        );
        require(msg.sender.balance >= bet.value, "Insufficient balance");
        require(
            challengerDecision != DataTypes.Decision.UNDEFINED,
            "Decision must be defined"
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

        bets[index].challenger = challenger;
        bets[index].status = DataTypes.Status.CHALLENGED;

        emit Transfer(msg.sender, escrow, bet.value);

        return true;
    }

    function cancelBet(string memory uuid) public returns (bool sufficient) {
        (DataTypes.Bet memory bet, uint index) = findBet(uuid);
        require(
            bet.status == DataTypes.Status.OPEN,
            "Bet is not open for cancel"
        );
        require(
            msg.sender == bet.owner.punterAddress,
            "Only owner can cancel bet"
        );

        bets[index].status = DataTypes.Status.INVALID;

        emit Transfer(escrow, bet.owner.punterAddress, bet.value);

        return true;
    }

    function voteWinner(
        string memory uuid,
        DataTypes.WinnerVote winnerVote
    ) public returns (DataTypes.Bet memory betReturn) {
        (DataTypes.Bet memory bet, uint index) = findBet(uuid);
        require(
            bet.status == DataTypes.Status.CHALLENGED,
            "Bet is not challenged"
        );
        require(
            msg.sender == bet.owner.punterAddress ||
                msg.sender == bet.challenger.punterAddress,
            "Only owner or challenger can vote"
        );

        if (msg.sender == bet.owner.punterAddress) {
            bets[index].owner.winnerVote = winnerVote;
        } else {
            bets[index].challenger.winnerVote = winnerVote;
        }

        return bet;
    }

    function finalizeBet(
        string memory uuid,
        DataTypes.Status status
    ) public returns (bool sufficient) {
        (DataTypes.Bet memory bet, uint index) = findBet(uuid);
        require(bet.status == status, "Bet status does not match");
        require(
            bet.status == DataTypes.Status.CHALLENGED ||
                bet.status == DataTypes.Status.CONTESTED,
            "Bet is not challenged or contested"
        );
        require(
            bet.owner.winnerVote != DataTypes.WinnerVote.UNDEFINED &&
                bet.challenger.winnerVote != DataTypes.WinnerVote.UNDEFINED,
            "Both owner and challenger must vote"
        );

        if (bet.owner.winnerVote == bet.challenger.winnerVote) {
            bets[index].status = DataTypes.Status.FINISHED;

            if (bet.owner.winnerVote == DataTypes.WinnerVote.OWNER) {
                bets[index].result = bet.owner.punterAddress;
                emit Transfer(escrow, bet.owner.punterAddress, bet.value * 2);
                // TODO increase reputation of owner and challenger
            } else {
                bets[index].result = bet.challenger.punterAddress;
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

            // transfer to oracles based on their reputation?

            if (majorityOraclesVotes == DataTypes.WinnerVote.INVALID) {
                bets[index].status = DataTypes.Status.INVALID;
                emit Transfer(escrow, bet.owner.punterAddress, bet.value);
                emit Transfer(escrow, bet.challenger.punterAddress, bet.value);
                // TODO transfer a part of the money to the oracles
                // TODO decrease reputation of oracles that voted against
                // RISKY: oracles trools can vote for invalid to get money
            } else if (majorityOraclesVotes == DataTypes.WinnerVote.OWNER) {
                bets[index].status = DataTypes.Status.FINISHED;
                bets[index].result = bet.owner.punterAddress;
                emit Transfer(escrow, bet.owner.punterAddress, bet.value * 2);
                // TODO transfer a part of the money to the oracles
                // TODO increase reputation of oracles
                // TODO decrease reputation of challenger
                // TODO decrease reputation of oracles that voted against the majority
            } else if (
                majorityOraclesVotes == DataTypes.WinnerVote.CHALLENGER
            ) {
                bets[index].status = DataTypes.Status.FINISHED;
                bets[index].result = bet.challenger.punterAddress;
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
                bets[index].status = DataTypes.Status.INVALID;
                emit Transfer(escrow, bet.owner.punterAddress, bet.value);
                emit Transfer(escrow, bet.challenger.punterAddress, bet.value);
            }
        }
        return true;
    }

    function contestBet(string memory uuid) public returns (bool sufficient) {
        (DataTypes.Bet memory bet, uint index) = findBet(uuid);
        require(
            bet.status == DataTypes.Status.CHALLENGED,
            "Bet is not challenged"
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

        bets[index].status = DataTypes.Status.CONTESTED;

        return true;
    }

    function auditBet(
        string memory uuid,
        DataTypes.WinnerVote winnerVote
    ) public returns (bool sufficient) {
        (DataTypes.Bet memory bet, uint index) = findBet(uuid);
        require(
            bet.status == DataTypes.Status.CONTESTED,
            "Bet is not contested"
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

        bool hasVoted = false;
        for (uint i = 0; i < bet.oracles.length; i++) {
            if (bet.oracles[i].oracleAddress == msg.sender) {
                hasVoted = true;
                break;
            }
        }

        require(!hasVoted, "Oracle has already voted");

        DataTypes.OracleDecision memory oracleDecision = DataTypes
            .OracleDecision({
                oracleAddress: msg.sender,
                oracleDecision: winnerVote
            });

        for (uint i = 0; i < bet.oracles.length; i++) {
            if (bet.oracles[i].oracleAddress == address(0)) {
                bets[index].oracles[i] = oracleDecision;
                break;
            }
        }

        if (
            bets[index].oracles[DataTypes.MAX_ORACLES - 1].oracleAddress !=
            address(0)
        ) {
            finalizeBet(uuid, DataTypes.Status.CONTESTED);
        }

        return true;
    }

    // TODO implement a search algorithm to find the bet
    function findBet(
        string memory uuid
    ) public view returns (DataTypes.Bet memory bet, uint index) {
        for (uint i = 0; i < bets.length; i++) {
            if (
                keccak256(abi.encodePacked(bets[i].uuid)) ==
                keccak256(abi.encodePacked(uuid))
            ) {
                return (bets[i], i);
            }
        }
        revert("Bet not found");
    }

    function getBets() public view returns (DataTypes.Bet[] memory) {
        return bets;
    }

    function getBet(
        string memory uuid
    ) public view returns (DataTypes.Bet memory bet) {
        (bet, ) = findBet(uuid);
        return bet;
    }

    function getBetsForUser(
        address user
    ) public view returns (DataTypes.Bet[] memory) {
        DataTypes.Bet[] memory userBets;
        uint userBetsIndex = 0;

        for (uint i = 0; i < bets.length; i++) {
            if (
                bets[i].owner.punterAddress == user ||
                bets[i].challenger.punterAddress == user
            ) {
                userBets[userBetsIndex] = bets[i];
                userBetsIndex++;
            }
        }

        return userBets;
    }

    function getMajorityWinnerVote(
        DataTypes.Bet memory bet
    ) private pure returns (DataTypes.WinnerVote) {
        uint ownerVotes = 0;
        uint challengerVotes = 0;

        for (uint i = 0; i < bet.oracles.length; i++) {
            if (bet.oracles[i].oracleDecision == DataTypes.WinnerVote.OWNER) {
                ownerVotes++;
            } else if (
                bet.oracles[i].oracleDecision == DataTypes.WinnerVote.CHALLENGER
            ) {
                challengerVotes++;
            }
        }

        if (ownerVotes > challengerVotes) {
            return DataTypes.WinnerVote.OWNER;
        } else if (challengerVotes > ownerVotes) {
            return DataTypes.WinnerVote.CHALLENGER;
        } else {
            return DataTypes.WinnerVote.INVALID;
        }
    }
}
