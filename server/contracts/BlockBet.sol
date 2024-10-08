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
    uint public oraclesPorcentage = 10;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event BetCreated(string uuid);

    constructor() {
        escrow = address(this);
    }

    // TODO consider tax in emit Transfer
    // TODO decrease and increase reputation

    function createBet(
        DataTypes.Decision ownerDecision,
        string memory description
    ) public payable returns (bool sufficient) {
        require(msg.value > 0, "Bet value must be greater than 0");
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
        string memory uuid
    ) public payable returns (bool sufficient) {
        (DataTypes.Bet memory bet, uint index) = findBet(uuid);
        require(
            bet.status == DataTypes.Status.OPEN,
            "Bet is not open for challenge"
        );
        require(
            msg.sender != bet.owner.punterAddress,
            "Owner cannot challenge own bet"
        );
        require(
            msg.value == bet.value,
            "Value sent does not match the bet value"
        );

        DataTypes.Decision challengerDecision;

        if (bet.owner.decision == DataTypes.Decision.TRUE) {
            challengerDecision = DataTypes.Decision.FALSE;
        } else {
            challengerDecision = DataTypes.Decision.TRUE;
        }

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

        Utils.transferValues(escrow, bet.owner.punterAddress, bet.value);

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
            require(
                bet.owner.winnerVote == DataTypes.WinnerVote.UNDEFINED,
                "Owner has already voted"
            );
            bets[index].owner.winnerVote = winnerVote;
        } else {
            require(
                bet.challenger.winnerVote == DataTypes.WinnerVote.UNDEFINED,
                "Challenger has already voted"
            );
            bets[index].challenger.winnerVote = winnerVote;
        }

        bool hasVoted = bets[index].owner.winnerVote !=
            DataTypes.WinnerVote.UNDEFINED &&
            bets[index].challenger.winnerVote != DataTypes.WinnerVote.UNDEFINED;
        bool isContested = bets[index].owner.winnerVote !=
            bets[index].challenger.winnerVote;
        if (hasVoted && !isContested) {
            finalizeBet(uuid);
        } else if (hasVoted && isContested) {
            contestBet(uuid);
        }
        return bet;
    }

    function finalizeBet(string memory uuid) private returns (bool sufficient) {
        (DataTypes.Bet memory bet, uint index) = findBet(uuid);
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
                Utils.transferValues(
                    escrow,
                    bet.owner.punterAddress,
                    bet.value * 2
                );

                // TODO increase reputation of owner and challenger
            } else {
                bets[index].result = bet.challenger.punterAddress;
                Utils.transferValues(
                    escrow,
                    bet.challenger.punterAddress,
                    bet.value * 2
                );

                // TODO increase reputation of owner and challenger
            }
        } else {
            transferMoneyContestedBets(
                index,
                getMajorityWinnerVote(bets[index])
            );
        }
        return true;
    }

    function contestBet(string memory uuid) private returns (bool sufficient) {
        (DataTypes.Bet memory bet, uint index) = findBet(uuid);
        require(
            bet.status == DataTypes.Status.CHALLENGED,
            "Bet is not challenged"
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
            finalizeBet(uuid);
        }

        return true;
    }

    // TODO implement a search algorithm to find the bet
    function findBet(
        string memory uuid
    ) private view returns (DataTypes.Bet memory bet, uint index) {
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
    ) private pure returns (DataTypes.OraclesMajority memory) {
        uint ownerVotes = 0;
        uint challengerVotes = 0;
        uint invalidVotes = 0;
        uint maxOracles = DataTypes.MAX_ORACLES;
        address[] memory oraclesOwner = new address[](maxOracles);
        address[] memory oraclesChallenger = new address[](maxOracles);
        address[] memory oraclesInvalid = new address[](maxOracles);
        address[] memory oraclesLoser = new address[](maxOracles);
        DataTypes.OraclesMajority memory oraclesMajority;

        for (uint i = 0; i < bet.oracles.length; i++) {
            DataTypes.OracleDecision memory oracle = bet.oracles[i];
            if (oracle.oracleDecision == DataTypes.WinnerVote.OWNER) {
                oraclesOwner[ownerVotes] = oracle.oracleAddress;
                ownerVotes++;
            } else if (
                oracle.oracleDecision == DataTypes.WinnerVote.CHALLENGER
            ) {
                oraclesChallenger[challengerVotes] = oracle.oracleAddress;
                challengerVotes++;
            } else {
                oraclesInvalid[challengerVotes] = oracle.oracleAddress;
                invalidVotes++;
            }
        }

        if (ownerVotes > challengerVotes && ownerVotes > invalidVotes) {
            for (uint i = 0; i < challengerVotes; i++) {
                oraclesLoser[i] = oraclesChallenger[i];
            }
            for (uint i = 0; i < invalidVotes; i++) {
                oraclesLoser[challengerVotes + i] = oraclesInvalid[i];
            }
            oraclesMajority.winnerVote = DataTypes.WinnerVote.OWNER;
            oraclesMajority.oraclesWinner = oraclesOwner;
            oraclesMajority.oraclesLoser = oraclesLoser;
            return oraclesMajority;
        } else if (
            challengerVotes > ownerVotes && challengerVotes > invalidVotes
        ) {
            for (uint i = 0; i < ownerVotes; i++) {
                oraclesLoser[i] = oraclesOwner[i];
            }
            for (uint i = 0; i < invalidVotes; i++) {
                oraclesLoser[ownerVotes + i] = oraclesInvalid[i];
            }
            oraclesMajority.winnerVote = DataTypes.WinnerVote.CHALLENGER;
            oraclesMajority.oraclesWinner = oraclesChallenger;
            oraclesMajority.oraclesLoser = oraclesLoser;
            return oraclesMajority;
        } else {
            for (uint i = 0; i < ownerVotes; i++) {
                oraclesLoser[i] = oraclesOwner[i];
            }
            for (uint i = 0; i < challengerVotes; i++) {
                oraclesLoser[ownerVotes + i] = oraclesChallenger[i];
            }
            oraclesMajority.winnerVote = DataTypes.WinnerVote.INVALID;
            oraclesMajority.oraclesWinner = oraclesInvalid;
            oraclesMajority.oraclesLoser = oraclesLoser;
            return oraclesMajority;
        }
    }

    // TODO: decrease and increase reputation
    function transferMoneyContestedBets(
        uint index,
        DataTypes.OraclesMajority memory oraclesMajority
    ) private {
        DataTypes.Bet memory bet = bets[index];
        uint256 oracleShare = ((bet.value * 2) * oraclesPorcentage) / 100;
        uint256 refundAmount = (bet.value * 2) - oracleShare;
        uint numberOfOraclesWinner = oraclesMajority.oraclesWinner.length;
        if (oraclesMajority.winnerVote == DataTypes.WinnerVote.OWNER) {
            Utils.transferValues(escrow, bet.owner.punterAddress, refundAmount);
            bets[index].result = bet.owner.punterAddress;
            bets[index].status = DataTypes.Status.FINISHED;
        } else if (
            oraclesMajority.winnerVote == DataTypes.WinnerVote.CHALLENGER
        ) {
            Utils.transferValues(
                escrow,
                bet.challenger.punterAddress,
                refundAmount
            );
            bets[index].result = bet.challenger.punterAddress;
            bets[index].status = DataTypes.Status.FINISHED;
        } else {
            // RISKY: oracles trools can vote for invalid to get money
            Utils.transferValues(
                escrow,
                bet.owner.punterAddress,
                refundAmount / 2
            );
            Utils.transferValues(
                escrow,
                bet.challenger.punterAddress,
                refundAmount / 2
            );
            bets[index].status = DataTypes.Status.INVALID;
        }
        uint256 individualOracleShare = oracleShare / numberOfOraclesWinner;
        for (uint i = 0; i < numberOfOraclesWinner; i++) {
            Utils.transferValues(
                escrow,
                oraclesMajority.oraclesWinner[i],
                individualOracleShare
            );
        }
    }
}
