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
          <!-- Bet Status -->
          <div class="col" id="status-col">
            <p>{{ StatusEnum[bet.status] }}</p>
          </div>
        </div>

        <!-- Bet Details -->
        <div class="row">
          <div class="col" id="desc-col">
            <div class="row">
              <p>Decisão do criador:&nbsp;{{ bet.owner?.decision }}</p>
            </div>
            <div class="row">
              <p>Voto do criador:&nbsp;{{ bet.owner?.winnerVote }}</p>
            </div>
            <div class="row">
              <p>Decisão do desafiante:&nbsp;{{ bet.challenger?.decision }}</p>
            </div>
            <div class="row">
              <p>Voto do desafiante:&nbsp;{{ bet.challenger?.winnerVote }}</p>
            </div>
          </div>
          <!-- Bet Value -->
          <div class="col" id="value-col">
            <div class="row">
              <h1>Valor:</h1>
            </div>
            <div class="row">
              {{ ethValue(bet.value) }} ETH
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
        <div class="row bet-option" id="audit-bet" v-show="betIsContested(bet.status)">
          <Button buttonText="Auditar aposta" />
        </div>
        <div class="row bet-option" id="decide-bet-answer" v-show="showWinnerVote(bet.status)">
          <div class="row">
            <div class="col" id="decision-col">
              <div class="row">
                <p>Sua decisão:</p>
              </div>
              <div class="row">
                <select v-model="selectedVote">
                  <option disabled selected hidden>Escolha uma das opções</option>
                  <option value="owner">Criador</option>
                  <option value="challenger">Desafiante</option>
                </select>
              </div>
            </div>
          </div>
          <Button buttonText="Confirmar Resultado" :buttonFunction="voteWinner" />
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { BlockBetService } from "@/services/BlockBetService";
import { StatusEnum } from "@/constants/statusEnum";
import Web3 from "web3";
import { injected } from "~/connectors";

const blockBetService = new BlockBetService();
const bet = ref({});
const selectedVote = ref("");
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

const betIsContested = (status) => {
  return status == "CONTESTED";
}

const showWinnerVote = (status) => {
  const ownerAddress = bet.value.owner?.punterAddress;
  const challengerAddress = bet.value.challenger?.punterAddress;
  const isPunter = ownerAddress === account.value || challengerAddress === account.value

  return status == "CHALLENGED" && isPunter;
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
  blockBetService.voteWinner(uuid, account.value, selectedVote.value)
}
</script>

<style scoped>
body {
  height: max-content;
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

.bet-header {
  padding-bottom: 20px;
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
  flex: 1;
}

#status-col {
  justify-content: end;
  display: flex;
  font-weight: bold;
  font-size: 20px;
  color: rgb(226, 14, 208);
}

#desc-col {
  flex: 8;
  font-size: 18px;
  align-self: center;
}

#value-col {
  font-size: 21px;
  display: flex;
  flex-direction: column;
  align-self: start;
  justify-content: center;
}

#value-col h1 {
  font-weight: bold;
}

#value-col div {
  align-self: center;
}

.bet-option {
  padding: 30px 20px 0px 0px;
  justify-content: end;
}

option {
  color: black;
}
</style>