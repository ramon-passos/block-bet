<template>
  <section class="bet" @click="showBet(betData.uuid)">
    <div class="col">
      <div class="row bet-title">
        <p>
          {{ betData.description }}
        </p>
      </div>
      <div class="row bet-data">
        <div class="col data-field" id="value-col">
          <p>
            Valor apostado: {{ ethValue(betData.value) }} ETH
          </p>
        </div>
        <div class="col data-field" id="decision-col">
          <p>
            Decisão do criador: {{ DecisionEnum[betData.owner?.decision] }}
          </p>
        </div>
        <div class="col data-field" id="decision-col" v-if="betData.status == 'OPEN'">
          <p>
            Decisão do desafiante: {{ DecisionEnum[betData.challenger?.decision] }}
          </p>
        </div>
        <div class="col data-field" id="status-col">
          <p>
            {{ StatusEnum[betData.status] }}
          </p>
        </div>
      </div>
      <div class="row bet-data" id="contested-warning" v-if="betData.status == 'CONTESTED'">
        <p>
          A aposta está sendo auditada pelos oráculos da rede.
        </p>
      </div>
    </div>
  </section>
  <hr>
</template>

<script setup>
import { DecisionEnum } from "@/constants/decisionEnum";
import { StatusEnum } from "@/constants/statusEnum";
import Web3 from "web3";

const ethValue = (value) => Web3.utils.fromWei(value, "ether");
const router = useRouter();

const props = defineProps({
  betData: {
    type: Object,
    required: true,
  }
});

function showBet(uuid) {
  router.push(`/bet/show/${uuid}`);
};
</script>

<style scoped>
.bet {
  width: 80%;
  color: white;
  background-color: rgb(59, 59, 59);
  padding: 15px 20px;
  margin: 30px auto;
  border: 0 solid white;
  border-radius: 15px;
  transition: background-color 0.3s ease, transform 0.3s ease;
  box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2);
}

.bet:hover {
  transform: scale(1.05);
}

.bet-title {
  font-size: clamp(16px, 4vw, 24px);
  font-family: 'Bebas Neue', sans-serif;
  padding-bottom: 20px;
}

.bet-data {
  font-size: clamp(15px, 4vw, 18px);
  display: flex;
}

#id-col {
  font-weight: lighter;
  flex: 0.5;
}

#value-col, #decision-col  {
  flex: 4;
  padding-right: 30px;
}

#status-col {
  color: rgb(226, 14, 208);
  flex: 1;
  display: flex;
  justify-content: flex-end;
  padding-right: 10px;
}

#contested-warning {
  padding-top: 10px;
  color: rgb(226, 14, 208);
}

hr {
  border: none;
  height: 1px;
  background: linear-gradient(to right, rgb(31, 150, 255), blueviolet, rgb(226, 14, 208));
  width: 80%;
  margin: auto;
}
</style>
