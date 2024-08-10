export class BlockBetService {
  async getBets(filters) {
    let url = `http://localhost:8080/bets`;
    const params = new URLSearchParams();

    filters.forEach(([key, values]) => {
      values.forEach((value) => params.append(key, value));
    })

    if (params.toString()) {
      url += `?${params.toString()}`;
    }

    const result = await fetch(url);

    return result;
  }

  // async function createBet() {}

  //async function getBet() {}

  // async function challengeBet() {}

  // async function voteWinner() {}

  // async function finalizeBet() {}

  // async function constestBet() {}

  // async function auditBet() {}
}
