const BlockBet = artifacts.require("BlockBet");

contract("BlockBet", (accounts) => {
  let blockBetInstance;
  before(async () => {
    blockBetInstance = await BlockBet.deployed();
  });
  describe("createBet", () => {
    it("should create a bet with the correct values", async () => {
      const result = await blockBetInstance.createBet(1, "sample description", {
        from: accounts[0],
        value: 100,
      });
      const logs = result.logs;
      const createdUuid = logs.find((log) => log.event === "BetCreated").args
        .uuid;
      const fooundBet = await blockBetInstance.getBet.call(createdUuid);
      const gasPrice = Number(
        (await web3.eth.getTransaction(result.tx)).gasPrice
      );
      const gasUsed = result.receipt.gasUsed;
      const weiSpent = gasUsed * gasPrice;
      const contractAccount = result.receipt.to;
      const contractBalance = Number(
        await web3.eth.getBalance(contractAccount)
      );
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
      );
      assert.equal(fooundBet.uuid, createdUuid, "Bet amount is incorrect");
      assert.equal(contractBalance, 100, "Contract ballance is incorrect");
    });
  });
  it("should throw an error if the bet value is 0", async () => {
    const blockBetInstance = await BlockBet.deployed();
    try {
      await blockBetInstance.createBet(1, "sample description", {
        from: accounts[0],
        value: 0,
      });
      assert.fail();
    } catch (error) {
      assert.ok(error.message.includes("Bet value must be greater than 0"));
    }
  });
  describe("challengeBet", () => {
    let createdUuid;
    beforeEach(async () => {
      const result = await blockBetInstance.createBet(1, "sample description", {
        from: accounts[0],
        value: 100,
      });
      const logs = result.logs;
      createdUuid = logs.find((log) => log.event === "BetCreated").args.uuid;
    });
    it("should challenge a bet successfully", async () => {
      const result = await blockBetInstance.challengeBet(createdUuid, {
        from: accounts[1],
        value: 100,
      });
      const foundBet = await blockBetInstance.getBet.call(createdUuid);
      const contractAccount = result.receipt.to;
      const contractBalance = Number(
        await web3.eth.getBalance(contractAccount)
      );
      assert.equal(
        foundBet.challenger.punterAddress,
        accounts[1],
        "Challenger address is incorrect"
      );
      assert.equal(
        foundBet.challenger.decision,
        2,
        "Challenger decision is incorrect"
      );
      assert.equal(contractBalance, 300, "Contract ballance is incorrect");
    });
    it("should throw an error if the bet is already challenged", async () => {
      await blockBetInstance.challengeBet(createdUuid, {
        from: accounts[1],
        value: 100,
      });
      try {
        await blockBetInstance.challengeBet(createdUuid, {
          from: accounts[2],
          value: 100,
        });
        assert.fail();
      } catch (error) {
        assert.ok(error.message.includes("Bet is not open for challenge"));
      }
    });
    it("should throw an error if owner try to challenge the bet", async () => {
      try {
        await blockBetInstance.challengeBet(createdUuid, {
          from: accounts[0],
          value: 100,
        });
        assert.fail();
      } catch (error) {
        assert.ok(error.message.includes("Owner cannot challenge own bet"));
      }
    });
    it("should throw an error if bet is not found", async () => {
      try {
        await blockBetInstance.challengeBet("falseUuid", {
          from: accounts[0],
          value: 100,
        });
        assert.fail();
      } catch (error) {
        assert.ok(error.message.includes("Bet not found"));
      }
    });
  });
  describe("voteWinner", () => {
    let createdUuid;
    beforeEach(async () => {
      const beforeBalance = await web3.eth.getBalance(accounts[0]);
      const beforeBalanceEth = web3.utils.fromWei(beforeBalance, "ether");
      console.log({ beforeBalanceEth });

      const result = await blockBetInstance.createBet(1, "sample description", {
        from: accounts[0],
        value: 100,
      });
      const logs = result.logs;
      createdUuid = logs.find((log) => log.event === "BetCreated").args.uuid;
      await blockBetInstance.challengeBet(createdUuid, {
        from: accounts[1],
        value: 100,
      });
    });
    it("should vote for the winner successfully", async () => {
      await blockBetInstance.voteWinner(createdUuid, 1, { from: accounts[0] });
      const foundBet = await blockBetInstance.getBet.call(createdUuid);
      assert.equal(
        foundBet.owner.winnerVote,
        1,
        "Owner winner vote is incorrect"
      );
    });
    it("should vote in the same result and finalize bet", async () => {
      await blockBetInstance.voteWinner(createdUuid, 1, { from: accounts[0] });
      await blockBetInstance.voteWinner(createdUuid, 1, { from: accounts[1] });

      const afterBalance = await web3.eth.getBalance(accounts[0]);
      const afterBalanceEth = web3.utils.fromWei(afterBalance, "ether");
      console.log({ afterBalanceEth });
      const foundBet = await blockBetInstance.getBet.call(createdUuid);
      assert.equal(foundBet.status, 2, "Bet is not finalized");
    });

    it("should throw an error if account is not owner or challanger", async () => {
      try {
        await blockBetInstance.voteWinner(createdUuid, 1, {
          from: accounts[2],
        });
        assert.fail();
      } catch (error) {
        assert.ok(error.message.includes("Only owner or challenger can vote"));
      }
    });

    it("should throw an error if the challenger try to vote again", async () => {
      try {
        await blockBetInstance.voteWinner(createdUuid, 1, {
          from: accounts[1],
        });
        await blockBetInstance.voteWinner(createdUuid, 1, {
          from: accounts[1],
        });
        assert.fail();
      } catch (error) {
        console.log(error.message);
        assert.ok(error.message.includes("Challenger has already voted"));
      }
    });

    it("should throw an error if the owner try to vote again", async () => {
      try {
        await blockBetInstance.voteWinner(createdUuid, 1, {
          from: accounts[0],
        });
        await blockBetInstance.voteWinner(createdUuid, 1, {
          from: accounts[0],
        });
        assert.fail();
      } catch (error) {
        assert.ok(error.message.includes("Owner has already voted"));
      }
    });
  });
  describe("auditBet", () => {
    let createdUuid;

    beforeEach(async () => {
      const result = await blockBetInstance.createBet(1, "sample description", {
        from: accounts[0],
        value: 100,
      });
      const logs = result.logs;
      createdUuid = logs.find((log) => log.event === "BetCreated").args.uuid;
      await blockBetInstance.challengeBet(createdUuid, {
        from: accounts[1],
        value: 100,
      });
      await blockBetInstance.voteWinner(createdUuid, 1, { from: accounts[0] });
      await blockBetInstance.voteWinner(createdUuid, 2, { from: accounts[1] });
    });
    it("should audit a bet with the correct values", async () => {
      const vote = 1;
      await blockBetInstance.auditBet(createdUuid, vote, {
        from: accounts[2],
      });
      const foundBet = await blockBetInstance.getBet.call(createdUuid);
      const oracle = foundBet.oracles[0];
      assert.equal(
        oracle.oracleAddress,
        accounts[2],
        "Oracle address is incorrect"
      );
      assert.equal(oracle.oracleDecision, vote, "Oracle decision is incorrect");
    });
    it("should finalize bet if all oracles have voted", async () => {
      await blockBetInstance.auditBet(createdUuid, 1, { from: accounts[2] });
      await blockBetInstance.auditBet(createdUuid, 1, { from: accounts[3] });
      await blockBetInstance.auditBet(createdUuid, 1, { from: accounts[4] });
      await blockBetInstance.auditBet(createdUuid, 1, { from: accounts[5] });
      await blockBetInstance.auditBet(createdUuid, 1, { from: accounts[6] });

      const foundBet = await blockBetInstance.getBet.call(createdUuid);

      assert.equal(foundBet.status, 2, "Bet status is incorrect");
      assert.equal(foundBet.result, accounts[0]);
    });
    it("should throw an error if the oracle try to audit the bet again", async () => {
      try {
        await blockBetInstance.auditBet(createdUuid, 1, { from: accounts[2] });
        await blockBetInstance.auditBet(createdUuid, 1, { from: accounts[2] });
        assert.fail();
      } catch (error) {
        assert.ok(error.message.includes("Oracle has already voted"));
      }
    });
    it("should throw an error if the owner try to audit the bet", async () => {
      try {
        await blockBetInstance.auditBet(createdUuid, 1, { from: accounts[0] });
        assert.fail();
      } catch (error) {
        assert.ok(error.message.includes("Only oracles can audit bet"));
      }
    });
    it("should throw an error if the challenger try to audit the bet", async () => {
      try {
        await blockBetInstance.auditBet(createdUuid, 1, { from: accounts[1] });
        assert.fail();
      } catch (error) {
        assert.ok(error.message.includes("Only oracles can audit bet"));
      }
    });
  });
  describe("finalizeBet", () => {
    let createdUuid;

    beforeEach(async () => {
      const result = await blockBetInstance.createBet(1, "sample description", {
        from: accounts[0],
        value: 100,
      });
      const logs = result.logs;
      createdUuid = logs.find((log) => log.event === "BetCreated").args.uuid;
      await blockBetInstance.challengeBet(createdUuid, {
        from: accounts[1],
        value: 100,
      });
    });
    it("should finalize a bet if challanger and owner vote for the same result", async () => {
      await blockBetInstance.voteWinner(createdUuid, 1, { from: accounts[0] });
      await blockBetInstance.voteWinner(createdUuid, 1, { from: accounts[1] });
      const foundBet = await blockBetInstance.getBet.call(createdUuid);
      assert.equal(foundBet.status, 2, "Bet status is incorrect");
      assert.equal(foundBet.result, accounts[0]);
    });
    it("should finalize a bet if all oracles vote", async () => {
      await blockBetInstance.voteWinner(createdUuid, 1, { from: accounts[0] });
      await blockBetInstance.voteWinner(createdUuid, 2, { from: accounts[1] });
      await blockBetInstance.auditBet(createdUuid, 1, { from: accounts[2] });
      await blockBetInstance.auditBet(createdUuid, 1, { from: accounts[3] });
      await blockBetInstance.auditBet(createdUuid, 1, { from: accounts[4] });
      await blockBetInstance.auditBet(createdUuid, 1, { from: accounts[5] });
      await blockBetInstance.auditBet(createdUuid, 1, { from: accounts[6] });
      const foundBet = await blockBetInstance.getBet.call(createdUuid);
      assert.equal(foundBet.status, 2, "Bet status is incorrect");
    });
    it("should finalize a bet and invalid it", async () => {
      await blockBetInstance.voteWinner(createdUuid, 1, { from: accounts[0] });
      await blockBetInstance.voteWinner(createdUuid, 2, { from: accounts[1] });
      await blockBetInstance.auditBet(createdUuid, 3, { from: accounts[2] });
      await blockBetInstance.auditBet(createdUuid, 3, { from: accounts[3] });
      await blockBetInstance.auditBet(createdUuid, 3, { from: accounts[4] });
      await blockBetInstance.auditBet(createdUuid, 3, { from: accounts[5] });
      await blockBetInstance.auditBet(createdUuid, 3, { from: accounts[6] });
      const foundBet = await blockBetInstance.getBet.call(createdUuid);
      assert.equal(foundBet.status, 4, "Bet status is incorrect");
    });
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
  };
}

function parsePunter(punter) {
  return {
    punterAddress: punter.punterAddress,
    decision: parseDecision(punter.decision),
    winnerVote: parseWinnerVote(punter.winnerVote),
  };
}

function parseOracles(oracles) {
  return oracles.map((oracle) => ({
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

  return decisionMap[Number(decisionNumber)];
}

function parseWinnerVote(winnerVoteNumber) {
  const winnerVoteMap = {
    0: "UNDEFINED",
    1: "OWNER",
    2: "CHALLENGER",
  };
  return winnerVoteMap[Number(winnerVoteNumber)];
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
