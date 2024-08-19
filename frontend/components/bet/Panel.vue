<template>
  <div class="bet-wrapper">
    <section class="bet-info">
      <div class="col">
        <div class="row bet-header">
          <div class="col" id="bet-identifier">
            <div class="row" id="bet-title">
              <h1>Aposta #{{ bet.id }}</h1>
            </div>
            <div class="row" id="bet-subtitle">
              <div class="col">
                <h3>{{ bet.uuid }}</h3>
                <div class="row">
                  <p>Criada por:&nbsp;</p>
                  <p>{{ bet.owner?.punterAddress }}</p>
                </div>
              </div>
            </div>
          </div>
          <div class="col" id="status-col">
            <p>{{ StatusEnum[bet.status] }}</p>
          </div>
        </div>
        <div class="row">
          <div class="col" id="desc-col">
            <div class="row">
              <p>{{ bet.description }}</p>
            </div>
            <div class="row">
              <p>Decisão do criador:&nbsp;</p>
              <p>{{ bet.owner?.decision }}</p>
            </div>
          </div>
          <div class="col" id="value-col">
            <div class="row">
              <p>Valor:</p>
            </div>
            <div class="row">
              {{ bet.value }}
            </div>
          </div>
        </div>
        <div class="row bet-option" id="join-bet" v-show="shouldShowJoinButton(bet.status)">
          <Button buttonText="Entrar na aposta">
          </Button>
        </div>
        <div class="row bet-option" id="cancel-bet" v-show="betIsCancelable(bet.status)">
          <Button buttonText="Cancelar minha aposta">
          </Button>
        </div>
        <div class="row bet-option" id="audit-bet" v-show="betIsContested(bet.status)">
          <Button buttonText="Auditar aposta">
          </Button>
        </div>
        <div class="row bet-option" id="decide-bet-answer" v-show="betIsChallenged(bet.status)">
          <Button buttonText="Dar minha decisão">
          </Button>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { BlockBetService } from "@/services/BlockBetService";
import { StatusEnum } from "@/constants/statusEnum";

const blockBetService = new BlockBetService();
const bet = ref({});

const props = defineProps({
  id: {
    type: Number,
    required: true,
  },
});

const { id } = props;
const { account } = useWeb3();
const ownerAddress = ref("");

onMounted(() => {
  getBet();
});

const getBet = () => {
  blockBetService
    .getBet(id)
    .then((response) => response.json())
    .then((data) => {
      bet.value = data[0];
    });

  ownerAddress.value = bet.value.owner?.punterAddress;
}

const betIsOpen = (status) => {
  return status == "open";
}

const shouldShowJoinButton = (status) => {
  return betIsOpen(status) && ownerAddress.value != account._value;
}

const betIsCancelable = (status) => {
  return betIsOpen(status) && ownerAddress.value == account._value;
}

const betIsContested = (status) => {
  return status == "contested";
}

const betIsChallenged = (status) => {
  return status == "challenged";
}
</script>

<style scoped>
.bet-wrapper {
  background-color: white;
  display: flex;
  justify-content: center;
  padding: 50px;
}

.bet-info {
  width: 70%;
  margin: 0;
  padding: 30px 70px;
  background-color: rgb(233, 240, 238);
  border: 1 solid white;
  box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
  border-radius: 15px;
  display: flex;
}

.bet-header {
  padding-bottom: 20px;
}

#bet-title {
  font-weight: bold;
  font-size: 30px;
}

#bet-identifier {
  flex: 8;
}

#status-col {
  display: flex-end;
  justify-self: end;
  font-weight: bold;
  font-size: 20px;
  color: rgb(226, 14, 208);
}

#desc-col {
  font-size: 18px;
  align-self: center;
}

#value-col {
  font-size: 21px;
  display: flex;
  flex-direction: column;
  align-self: center;
  justify-content: center;
}

#value-col div {
  align-self: center;
}

.bet-option {
  padding: 30px 20px 0px 0px;
  justify-content: end;
}
</style>