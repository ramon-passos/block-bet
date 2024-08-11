export class BlockBetService {
  constructor() {
    this.baseUrl = 'http://localhost:8080';
  }

  async getBets(filters) {
    let url = `${this.baseUrl}/bets`;
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

  async getBet(id) {
    const url = `${this.baseUrl}/bets?id=${id}`;
    const result = await fetch(url);

    return result;
  }
  
  // async function createBet() {}

  // async function challengeBet() {}

  // async function voteWinner() {}

  // async function finalizeBet() {}

  // async function constestBet() {}

  // async function auditBet() {}
}
