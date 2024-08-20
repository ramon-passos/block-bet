export function parseBet(bet) {
  return {
    uuid: bet.uuid,
    timestamp: bet.timestamp,
    value: bet.value.toString(),
    description: bet.description,
    result: bet.result.toString(),
    oracles: parseOracles(bet.oracles),
    owner: parsePunter(bet.owner),
    challenger: parsePunter(bet.challenger),
    status: parseStatus(bet.status),
  }
}

function parsePunter(punter) {
  return {
    punterAddress: punter.punterAddress,
    decision: parseDecision(punter.decision),
    winnerVote: parseWinnerVote(punter.winnerVote),
  }
}

function parseOracles(oracles) {
  return oracles.map(oracle => ({
    oracleAddress: oracle.oracleAddress,
    oracleDecision: parseDecision(oracle.oracleDecision),
  }));
}

function parseDecision(decisionNumber) {
  const decisionMap = {
    0: "UNDEFINED",
    1: "TRUE",
    2: "FALSE",
  };

  return decisionMap[decisionNumber];
}

function parseWinnerVote(winnerVoteNumber) {
  const winnerVoteMap = {
    0: "UNDEFINED",
    1: "OWNER",
    2: "CHALLENGER",
    3: "INVALID",
  };

  return winnerVoteMap[winnerVoteNumber];
}

function parseStatus(statusNumber) {
  const statusMap = {
    0: "OPEN",
    1: "CHALLENGED",
    2: "FINISHED",
    3: "CONTESTED",
    4: "INVALID",
  };

  return statusMap[statusNumber];
}
