<template>
  <div class="bet-wrapper">
    <section class="bet-info">
      <div class="col">
        <div class="row" id="bet-title">
          <h1>Aposta #{{ bet.id }}</h1>
        </div>
        <div class="row">
          <div class="col">
            <p>{{ bet.description }}</p>
          </div>
          <div class="col">
            <p>{{ bet.status }}</p>
          </div>
        </div>
        <div class="row" id="join-bet-row">
          <Button id="join-bet-id" buttonText="Entrar na aposta" />
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { BlockBetService } from '@/services/BlockBetService';

const blockBetService = new BlockBetService();
const bet = ref({});

const props = defineProps({
  id: {
    type: Number,
    required: true,
  }
});

const { id } = props;

onMounted(() => {
  getBet();
});


function getBet(){
  blockBetService.getBet(id)
    .then(response => response.json())
    .then(data => {
      bet.value = data;
    });
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

#bet-title {
  padding-bottom: 20px;
  font-weight: bold;
  font-size: 30px;
}

#join-bet-row {
  justify-content: end;
}
</style>