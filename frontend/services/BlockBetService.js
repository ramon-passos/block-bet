import Web3 from "web3";

export class BlockBetService {
  constructor() {
    this.baseUrl = 'http://localhost:8080';
    this.web3 = new Web3("http://localhost:8545");
    this.abi = this._getAbi();
    this.contractAddress = '0xacb42380cf2523ba70d34e6b941ecbdf5e270083';
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
  
  async createBet(betData, account) {
    const { description, value, valueType, decision } = betData;

    console.log(JSON.stringify(betData, null, 2));

    const translatedValue = this.web3.utils.toWei(value.toString(), valueType);
    const contract = new this.web3.eth.Contract(this.abi, this.contractAddress);
    const walletData = { from: account, value: translatedValue };
    const data = await contract.methods.createBet(1, description).encodeABI();

    return data;
  }

  // async function challengeBet() {}

  // async function voteWinner() {}

  // async function finalizeBet() {}

  // async function constestBet() {}

  // async function auditBet() {}

  _getAbi() {
    return []
  }
}
