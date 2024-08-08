<template>
  <section class="bet" @click="showBet">
    <div class="col">
      <div class="row bet-title">
        <p>
          Titulo Aposta
        </p>
      </div>
      <div class="row bet-data">
        <div class="col data-field" id="id-col">
          <p>Id_Aposta</p>
        </div>
        <div class="col data-field" id="desc-col">
          <p>
            Descricao Aposta Lorem Ipsum
          </p>
        </div>
        <div class="col data-field" id="status-col">
          <p>
            Status_Aposta
          </p>
        </div>
      </div>
    </div>
  </section>
  <hr>
</template>

<script setup>
const router = useRouter();

function showBet() {
  router.push('/bet/show');
};
</script>

<style scoped>
.bet {
  height: fit-content;
  background-color: rgb(233, 240, 238);
  padding: 15px 20px;
  margin: 30px 0px;
  border: 0 solid white;
  border-radius: 15px;
  transition: background-color 0.3s ease, transform 0.3s ease;
}

.bet:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
}

.bet-title {
  font-weight: bold;
  padding-bottom: 5px;
}

.bet-data {
  display: flex;
}

#id-col {
  font-weight: lighter;
}

#desc-col {
  flex: 5;
}

hr {
  border: none;
  height: 1px;
  background: linear-gradient(to right, rgb(31, 150, 255), rgb(187, 0, 255), rgb(226, 14, 208));
  width: 80%;
  margin: auto;
}
</style>
