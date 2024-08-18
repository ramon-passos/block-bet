// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library DataTypes {
    uint constant MAX_ORACLES = 1;

    enum Decision {
        UNDEFINED,
        TRUE,
        FALSE
    }

    enum WinnerVote {
        UNDEFINED,
        OWNER,
        CHALLENGER,
        INVALID
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
        address oracleAddress;
        WinnerVote oracleDecision;
    }

    struct OraclesMajority {
        WinnerVote winnerVote;
        address[] oraclesWinner;
        address[] oraclesLoser;
    }

    struct Bet {
        string uuid;
        uint256 timestamp;
        uint value;
        string description;
        address result;
        OracleDecision[MAX_ORACLES] oracles;
        Punter owner;
        Punter challenger;
        Status status;
    }
}
