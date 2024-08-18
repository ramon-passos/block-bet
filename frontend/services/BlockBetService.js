import Web3 from "web3";

export class BlockBetService {
  constructor() {
    this.baseUrl = 'http://localhost:8080';
    this.web3 = new Web3("http://localhost:8545");
    this.abi = this._getAbi();
    this.contractAddress = '0xacb42380cf2523ba70d34e6b941ecbdf5e270083';
    this.contract = new this.web3.eth.Contract(this.abi, this.contractAddress);
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
    const translatedValue = this._translate_value(value, valueType);
    const call = this.contract.methods.createBet(this._translate_decision(decision), description)
    const data = await call.encodeABI();
    const gasEstimate = await call.estimateGas({ from: account, value: translatedValue })

    this.web3.eth.sendTransaction({
      data,      
      from: account,
      to: this.contractAddress,
      value: translatedValue,
      gas: gasEstimate,
    })
    .on('transactionHash', function(hash){
      console.log("Transaction hash:", hash);
    })
    .on('receipt', function(receipt){
        console.log("Transaction was mined, receipt:", receipt);
    })
    .on('error', function(error){
        console.error("Error occurred:", error);
    });

    return data;
  }

  // async function challengeBet() {}

  // async function voteWinner() {}

  // async function finalizeBet() {}

  // async function constestBet() {}

  // async function auditBet() {}

  _getAbi() {
    return [];
  }

  _translate_decision(decision) {
    return decision ? 1 : 0;
  }

  _translate_value(value, valueType) {
    return this.web3.utils.toWei(value.toString(), valueType);
  }
}
