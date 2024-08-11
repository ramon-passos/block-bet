<template>
  <section class="bet" @click="showBet(betData.id)">
    <div class="col">
      <div class="row bet-title">
        <p>
          Titulo Aposta
        </p>
      </div>
      <div class="row bet-data">
        <div class="col data-field" id="id-col">
          <p>
            {{ betData.id }}
          </p>
        </div>
        <div class="col data-field" id="desc-col">
          <p>
            {{ betData.description }}
          </p>
        </div>
        <div class="col data-field" id="status-col">
          <p>
            {{ betData.status }}
          </p>
        </div>
      </div>
    </div>
  </section>
  <hr>
</template>

<script setup>
const router = useRouter();

const props = defineProps({
  betData: {
    type: Object,
    required: true,
  }
});

function showBet(id) {
  router.push(`/bet/show/${id}`);
};
</script>

<style scoped>
.bet {
  background-color: rgb(233, 240, 238);
  padding: 15px 20px;
  margin: 30px 0px;
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
  font-weight: bold;
  padding-bottom: 5px;
}

.bet-data {
  font-size: clamp(15px, 4vw, 18px);
  display: flex;
}

#id-col {
  font-weight: lighter;
  flex: 0.5;
}

#desc-col {
  flex: 8;
}

#status-col {
  flex: 1;
}

hr {
  border: none;
  height: 1px;
  background: linear-gradient(to right, rgb(31, 150, 255), rgb(187, 0, 255), rgb(226, 14, 208));
  width: 80%;
  margin: auto;
}
</style>
