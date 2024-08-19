import Web3 from "web3";
import { abi } from "@/contract/abi";
import { contractAddress } from "@/contract/address";
import { parseBet } from "./betTranslator";

export class BlockBetService {
  constructor() {
    this.baseUrl = 'http://localhost:8080';
    this.web3 = new Web3("http://localhost:8545");
    this.abi = abi;
    this.contractAddress = contractAddress;
    this.contract = new this.web3.eth.Contract(this.abi, this.contractAddress);
  }

  async getBets(filters) {
    const bets = await this.contract.methods.getBets().call()
    const parsedBets = bets.map(parseBet);
    const isFilterEmpty = filters === undefined;

    if (isFilterEmpty) return parsedBets;

    const result = parsedBets.filter(bet => {
      return filters.includes(bet.status);
    });

    return result;
  }

  async getBet(uuid) {
    const bet = await this.contract.methods.getBet(uuid).call();
    const parsedBet = parseBet(bet);

    return parsedBet;
  }

  async createBet(betData, account) {
    const { description, value, valueType, decision } = betData;
    const translatedValue = this.translate_value(value, valueType);
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

  async cancelBet(uuid, account) {
    const result = await this.contract.methods.cancelBet(uuid).send({ from: account });

    return result
  }

  // async function challengeBet() {}

  // async function voteWinner() {}

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
