import Web3 from "web3";
import { abi } from "@/contract/abi";
import { parseBet } from "./betTranslator";

export class BlockBetService {
  constructor() {
    this.baseUrl = 'http://localhost:8080';
    this.web3 = new Web3("http://localhost:8545");
    this.abi = abi;
    this.contractAddress = '0x613b7e806dd8930753b5f152b3e5ef7f20e51703';
    this.contract = new this.web3.eth.Contract(this.abi, this.contractAddress);
  }

  async getBets(filters) {
    const bets = await this.contract.methods.getBets().call()
    const parsedBets = bets.map(parseBet);

    if (filters.length === 0) return parsedBets;
    
    const result = parsedBets.filter(bet => {
      console.log(bet.status);
      console.log(filters)
      return filters.includes(bet.satus);
    });

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

  // async function cancelBet() {}

  // async function auditBet() {}

  translate_value(value, valueType) {
    return this.web3.utils.toWei(value.toString(), valueType);
  }

  _getAbi() {
    return [];
  }

  _translate_decision(decision) {
    return decision ? 1 : 0;
  }
}
