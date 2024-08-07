<template>
  <div class="bet-wrapper">
    <section class="bet-info">
      <div class="col">
        <div class="row" id="bet-title">
          <h1>Aposta #X</h1>
        </div>
        <div class="row">
          <div class="col">
            <p>info teste1</p>
          </div>
          <div class="col">
            <p>info teste1</p>
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