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
              <h3>{{ bet.uuid }}</h3>
            </div>
          </div>
          <div class="col" id="status-col">
            <p>{{ StatusEnum[bet.status] }}</p>
          </div>
        </div>
        <div class="row">
          <div class="col" id="desc-col">
            <p>{{ bet.description }}</p>
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
        <div class="row" id="join-bet-row" v-if="betIsOpen(bet.status)">
          <Button id="join-bet-id" buttonText="Entrar na aposta" />
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

onMounted(() => {
  getBet();
});

function getBet() {
  blockBetService
    .getBet(id)
    .then((response) => response.json())
    .then((data) => {
      bet.value = data[0];
    });
}

function betIsOpen(status) {
  if (status == "open") {
    return true;
  }
  return false;
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
  display: flex;
  justify-content: end;
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

#join-bet-row {
  padding: 30px 20px 0px 0px;
  justify-content: end;
}
</style>