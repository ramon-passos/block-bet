const BlockBet = artifacts.require("BlockBet");


contract('BlockBet', (accounts) => {
  it('should create a bet', async () => {
    const blockBetInstance = await BlockBet.deployed();
    const result = await blockBetInstance.createBet(1, 'sample description', { from: accounts[0], value: 100 });
    const logs = result.logs
    const createdUuid = logs.find(log => log.event === 'BetCreated').args.uuid;
    const fooundBet = await blockBetInstance.getBet.call(createdUuid, 0);
    
    console.log("============DEBUG===============")
    const gasPrice = Number((await web3.eth.getTransaction(result.tx)).gasPrice)
    const gasUsed = result.receipt.gasUsed
    const weiSpent = gasUsed * gasPrice
    const contractAccount = result.receipt.to
    const contractBalance = Number(await web3.eth.getBalance(contractAccount))
    console.log(
      JSON.stringify(
        {
          gasPrice,
          gasUsed,
          weiSpent,
          account: accounts[0],
          contractAccount,
          contractBalance,
        },
        null,
        2
      )
    )
    console.log("============DEBUG===============")

    assert.equal(fooundBet.uuid, createdUuid, "Bet amount is incorrect");
    assert.equal(contractBalance, 100, "Contract ballance is incorrect");
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