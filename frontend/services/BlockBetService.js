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
    const call = contract.methods.createBet(1, description)
    const data = await call.encodeABI();
    const gasEstimate = await contract.methods.createBet(1, description).estimateGas({
      from: account,
      value: translatedValue,
    })

    console.log({gasEstimate})

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
    return []
  }
}
