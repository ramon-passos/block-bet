const BlockBet = artifacts.require("BlockBet");


contract('BlockBet', (accounts) => {
  it('should create a bet', async () => {
    const blockBetInstance = await BlockBet.deployed();
    const { logs } = await blockBetInstance.createBet('10', 1, 'sample description', { from: accounts[0] });
    const createdUuid = logs.find(log => log.event === 'BetCreated').args.uuid;

    const bets = await blockBetInstance.getBets.call({from: accounts[0]});
    const parsedBets = bets.map(bet => parseBet(bet));
    console.log(JSON.stringify({parsedBets}, null, 2))
    
    const fooundBet = await blockBetInstance.getBet.call(createdUuid, 0);

    //console.log(JSON.stringify({fooundBet})); 
    console.log(JSON.stringify({uuid: fooundBet.uuid}))

    assert.equal(fooundBet.uuid, createdUuid, "Bet amount is incorrect");
  });
});

function parseBet(bet) {
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
    punterAddress: punter.PunterAddress,
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
    1: "FALSE",
  };

  return decisionMap[decisionNumber];
}

function parseWinnerVote(winnerVoteNumber) {
  const winnerVoteMap = {
    0: "UNDEFINED",
    1: "OWNER",
    2: "CHALLENGER",
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