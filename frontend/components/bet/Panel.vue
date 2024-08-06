<template>
  <div class="bet-wrapper">
    <section class="bet-info">
      <div class="col">
        <div class="row" id="bet-title">
          <p>titulo teste</p>
        </div>
        <div class="row">
          <div class="col">
            <p>info teste1</p>
          </div>
          <div class="col">
            <p>info teste1</p>
          </div>
        </div>
        <div class="row">
          <Button id="join-bet-id" buttonText="Entrar na aposta" />
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
</script>

<style scoped>
.bet-wrapper {
  background-color: white;
  margin: 10vh 30vh;
}

.bet-info {
  padding: 30px 70px;
  background-color: rgb(233, 240, 238);
  border: 0 solid white;
  display: flex;
}

#bet-title {
  padding-bottom: 20px;
  font-weight: bold;
  font-size: 30px;
}

.row {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
}

.col {
  flex: 1;
  justify-content: center;
}
</style>