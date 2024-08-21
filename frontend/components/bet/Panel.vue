<template>
  <div class="bet-wrapper">
    <section class="bet-info">
      <!-- Bet Header -->
      <div class="col">
        <div class="row bet-header">
          <!-- Bet Identifier -->
          <div class="col" id="bet-identifier">
            <div class="row" id="bet-title">
              <h1>{{ bet.description }}</h1>
            </div>
            <div class="row" id="bet-subtitle">
              <div class="col">
                <div class="row">
                  <h3>{{ bet.uuid }}</h3>
                </div>
                <div class="row">
                  <p>Criada por:&nbsp;</p>
                  <p>{{ bet.owner?.punterAddress }}</p>
                </div>
              </div>
            </div>
          </div>

          <div class="col">
            <!-- Bet Status -->
            <div class="row" id="status-row">
              <p>{{ StatusEnum[bet.status] }}</p>
            </div>
            <div class="row" id="value-row">
              <!-- Bet Value -->
              <div class="col">
                <div class="row">
                  <h1>Valor:</h1>
                </div>
                <div class="row">
                  {{ ethValue(bet.value) }} ETH
                </div>
              </div>
            </div>
           </div>
        </div>
        <hr>
        <!-- Bet Details -->
        <div class="row">
          <div class="col" id="descision-info-col">
            <div class="row">
              <div class="col">
                <p>Decisão do criador: {{ DecisionEnum[bet.owner?.decision] }}</p>
              </div>
              <div class="col">
                <p>Voto do criador: {{ VoteEnum[bet.owner?.winnerVote] }}</p>
              </div>
            </div>
            <div class="row">
              <div class="col">
                <p>Decisão do desafiante: {{ DecisionEnum[bet.challenger?.decision] }}</p>
              </div>
              <div class="col">
                <p>Voto do desafiante: {{ VoteEnum[bet.challenger?.winnerVote] }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Bet Actions -->
        <div class="row bet-option" id="join-bet" v-show="shouldShowJoinButton(bet.status)">
          <Button buttonText="Entrar na aposta" :buttonFunction="challengeBet" />
        </div>
        <div class="row bet-option" id="cancel-bet" v-show="betIsCancelable(bet.status)">
          <Button buttonText="Cancelar minha aposta" :buttonFunction="cancelBet" />
        </div>
        <div class="row bet-option" id="audit-bet" v-show="showAuditInput(bet.status)">
          <div class="row">
            <h1>Decida quem dos envolvidos ganhou:</h1>
          </div>
          
          <div class="row">
            <div class="col">
              <p>Quem realmente venceu a aposta?</p>
              <select v-model="selectedWinner">
                <option value="" disabled selected hidden>Escolha uma das opções</option>
                <option value="owner">Criador</option>
                <option value="challenger">Desafiante</option>
              </select>
            </div>
            
            <div class="col action-button">
              <Button buttonText="Auditar aposta" :buttonFunction="auditBet"/>
            </div>
          </div>
        </div>
        <div class="col bet-option" id="decide-bet-answer" v-show="showWinnerVote(bet.status)">
          <div class="row">
            <h1>Agora que o evento ocorreu, dê sua decisão:</h1>
          </div>
          
          <div class="row">
            <div class="col">
              <p>Quem venceu a aposta?</p>
              <select v-model="selectedVote">
                <option value="" disabled selected hidden>Escolha uma das opções</option>
                <option value="owner">Criador</option>
                <option value="challenger">Desafiante</option>
              </select>
            </div>
            
            <div class="col action-button">
              <Button buttonText="Confirmar Resultado" :buttonFunction="voteWinner" />
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { BlockBetService } from "@/services/BlockBetService";
import { StatusEnum } from "@/constants/statusEnum";
import { VoteEnum } from "@/constants/voteEnum";
import { DecisionEnum } from "@/constants/decisionEnum";
import Web3 from "web3";
import { injected } from "~/connectors";

const blockBetService = new BlockBetService();
const bet = ref({});
const selectedVote = ref("");
const selectedWinner = ref("");

const props = defineProps({
  uuid: {
    type: Number,
    required: true,
  },
});

const { uuid } = props;
const { account, activate } = useWeb3();
const router = useRouter();

useEagerConnect();
await activate(injected);

onMounted(() => {
  getBet();
});

const betIsOpen = (status) => {
  return status == "OPEN";
}

const shouldShowJoinButton = (status) => {
  const ownerAddress = bet.value.owner?.punterAddress
  return betIsOpen(status) && ownerAddress !== account.value;
}

const betIsCancelable = (status) => {
  const ownerAddress = bet.value.owner?.punterAddress
  return betIsOpen(status) && ownerAddress === account.value;
}

const showAuditInput = (status) => {
  const ownerAddress = bet.value.owner?.punterAddress;
  const challengerAddress = bet.value.challenger?.punterAddress;
  const isNotAPunter = ownerAddress !== account.value && challengerAddress !== account.value

  const voted = bet.value.oracles?.some(({oracleAddress, oracleDecision}) => oracleAddress === account.value && oracleDecision !== "UNDEFINED");

  return status == "CONTESTED" && isNotAPunter && !voted;
}

const showWinnerVote = (status) => {
  const ownerAddress = bet.value.owner?.punterAddress;
  const challengerAddress = bet.value.challenger?.punterAddress;

  const isChallenger = challengerAddress === account.value;
  const isOwner = ownerAddress === account.value;
  
  const ownerVoted = isOwner && bet.value.owner?.winnerVote !== "UNDEFINED"
  const challengerVoted = isChallenger && bet.value.challenger?.winnerVote !== "UNDEFINED";

  const isPunter = isChallenger || isOwner;
  const voted = ownerVoted || challengerVoted;

  return status == "CHALLENGED" && isPunter && !voted;
}

function ethValue(value) {
  return Web3.utils.fromWei(value?.toString() || '0', "ether");
}

function getBet() {
  blockBetService
    .getBet(uuid)
    .then(data => {
      bet.value = data;
    });
}

function cancelBet() {
  blockBetService.cancelBet(uuid, bet.value.owner?.punterAddress).then(data => {
    console.log(data);
  });

  router.push("/");
}

function challengeBet() {
  blockBetService.challengeBet(uuid, account.value, bet.value.value).then(data => {
    console.log(data);
  });

  router.push("/");
}

function voteWinner() {
  blockBetService.voteWinner(uuid, account.value, selectedVote.value).then(data => {
    console.log(data);
  }); 
}

function auditBet() {
  blockBetService.auditBet(uuid, account.value, selectedWinner.value).then(data => {
    console.log(data);
  });
}

watch(
  bet,
  () => {
    getBet();
  }
)
</script>

<style scoped>
body {
  height: max-content;
}

hr {
  justify-content: center;
  width: 90%;
  border: none;
  height: 2px;
  background: linear-gradient(to right, rgb(31, 150, 255), blueviolet, rgb(226, 14, 208));
  margin: 30px auto;
}

.bet-wrapper {
  background-color: #1b1b1b;
  display: flex;
  justify-content: center;
  padding: 50px;
}

.bet-info {
  color: white;
  width: 70vw;
  max-width: 100%;
  margin: 0;
  padding: 30px 70px;
  background-color: rgb(59, 59, 59);
  border: 1 solid white;
  box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
  border-radius: 15px;
}

#bet-title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(1.5rem, 3vw, 2rem);
  width: min-content;
  max-width: 80%;
  overflow: hidden;
  text-overflow: clip;
  white-space: nowrap;
}

#bet-subtitle {
  font-size: clamp(15px, 18px, 20px);
  width: min-content;
  max-width: 80%;
  overflow: hidden;
  text-overflow: clip;
  white-space: nowrap;
}

#bet-identifier {
  flex: 8;
}

#status-row {
  justify-content: center;
  display: flex;
  font-weight: bold;
  font-size: 20px;
  color: rgb(226, 14, 208);
}

#descision-info-col {
  flex: 8;
  font-size: 18px;
  align-self: center;
}

#decision-col {
  justify-content: center;
}

#value-row {
  justify-content: end;
  display: flex;
  font-size: 21px;
  padding-top: 30px;
  flex-direction: column;
  align-self: start;
}

#value-row h1 {
  font-weight: bold;
}

#value-row div {
  justify-content: center;
  align-self: center;
}

.bet-option {
  padding: 30px 20px 0px 0px;
}

#decide-bet-answer {
  width: 100%;
  font-size: 20px;
}

.action-button {
  display: flex;
  justify-content: flex-end;
}

#decide-bet-answer h1 {
  font-size: 25px;
  font-weight: normal;
  margin: auto;
  padding-bottom: 20px;
}

#decide-bet-answer select {
  color: black;
  padding-right: 50px;
}

input,
select {
  border-radius: 10px;
  padding: 3px 10px;
  margin-top: 6px;
  background-color: rgb(231, 230, 233);
}

option {
  color: black;
}
</style>