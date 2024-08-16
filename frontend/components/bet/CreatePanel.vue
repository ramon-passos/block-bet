<template>
  <div class="bet-wrapper">
    <section class="bet-info row">
      <div class="col">
        <div class="row create-bet-header">
          <h1>Criar Aposta</h1>
        </div>
        <div class="row bet-header">
          <div class="col" id="desc-col">
            <h1 id="bet-title">No que você quer apostar?</h1>
            <h3 id="bet-subtitle">
              (Formule uma afirmação que pode ser respondida com sim ou não.)
            </h3>
            <div class="row">
              <input
                type="text"
                placeholder="Insira uma afirmação em que deseja apostar"
                v-model="betText"
              />
            </div>
          </div>
        </div>
        <div class="row">
          <div class="col" id="value-col">
            <div class="row">
              <p>Valor:</p>
            </div>
            <div class="row">
              <input
                v-model="betValue"
                type="number"
                placeholder="Valor da aposta"
              />
            </div>
          </div>
          <div class="col" id="unity-col">
            <div class="row">
              <h2>Unidade usada:</h2>
            </div>
            <div class="row">
              <select v-model="selectedUnit" name="" id="">
                <option value="" disabled selected hidden>
                  Escolha uma unidade
                </option>
                <option :value="unit" v-for="unit in ethUnits" :key="unit">
                  {{ unit }}
                </option>
              </select>
            </div>
          </div>
        </div>
        <div class="row">
          <div class="col" id="decision-col">
            <div class="row">
              <p>Sua decisão:</p>
            </div>
            <div class="row">
              <select v-model="selectedDecision" name="" id="">
                <option value="" disabled selected hidden>Escolha</option>
                <option value="true">Vai acontecer</option>
                <option value="false">Não vai acontecer</option>
              </select>
            </div>
          </div>
        </div>
        <div v-if="hasErrors" class="error-messages">
          <ul>
            <li v-for="(error, index) in errors.value" :key="index">
              {{ error }}
            </li>
          </ul>
        </div>
        <div class="row" id="join-bet-row">
          <Button buttonText="Criar minha aposta" :buttonFunction="printDados">
          </Button>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { BlockBetService } from "@/services/BlockBetService";
import { ethUnits } from "@/constants/ethUnits";

const blockBetService = new BlockBetService();

const betText = ref("");
const betValue = ref(0);
const selectedDecision = ref("");
const selectedUnit = ref("");
const errors = ref([]);

const hasErrors = computed(() => {
  return errors.value.length > 0;
});

function printDados() {
  errors.value = [];

  if (!betText.value) {
    errors.value.push("Esta afirmação está inválida");
  }
  if (betValue.value <= 0 || betValue.value == null) {
    errors.value.push("Este valor está inválido");
  }
  if (!selectedDecision.value) {
    errors.value.push("A decisão é obrigatória");
  }
  if (!selectedUnit.value) {
    errors.value.push("A unidade da moeda é obrigatória");
  }

  if (hasErrors.value) {
    console.log(errors.value);
    return;
  }

  console.log(
    betText.value,
    betValue.value,
    selectedDecision.value,
    selectedUnit.value
  );
}
</script>

<style scoped>
.row {
  gap: 50px;
}

.row input {
  flex: 1;
}

.create-bet-header {
  justify-content: center;
  font-size: 38px;
  font-weight: 700;
  padding-bottom: 10px;
}

.bet-wrapper {
  background-color: white;
  display: flex;
  justify-content: center;
  flex-direction: column;
  padding: 50px;
}

.bet-info {
  width: 70%;
  margin: 0 auto;
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

#bet-subtitle {
  font-size: 20px;
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
  font-size: 22px;
  align-self: center;
}

#value-col,
#unity-col,
#decision-col {
  font-size: 22px;
  display: flex;
  flex-direction: column;
  padding-bottom: 20px;
}

#value-col div {
  align-self: left;
}

input,
select {
  border-radius: 10px;
  padding: 3px 10px;
  margin-top: 6px;
}

#join-bet-row {
  padding: 30px 20px 0px 0px;
  justify-content: end;
}

.error-messages {
  color: red;
  margin-top: 10px;
  font-size: 14px;
}
</style>