<template>
  <section class="side-options-section">
    <section class="personal-options-section">
      <h2>Minhas apostas</h2>
      <div class="row">
        <p>
          Abertas
        </p>
      </div>
      <div class="row">
        <p>
          Desafiadas
        </p>
      </div>
      <div class="row">
        <p>
          Contestadas
        </p>
      </div>
    </section>
    <hr>
    <section class="general-options-section">
      <h2>Outros</h2>
      <div class="row">
        <p>
          Minha reputação
        </p>
      </div>
      <div class="row">
        <p>
          Apostas auditadas
        </p>
      </div>
      <div class="row">
        <p>
          Teste
        </p>
      </div>
    </section>
    <hr>
  </section>
</template>

<script setup>
</script>

<style scoped>
.side-options-section {
  margin-top: 45px;
  margin-left: 50px;
}

.personal-options-section {
  margin-bottom: 20px;
}

.general-options-section {
  margin-top: 45px;
  margin-bottom: 20px;
}

h2 {
  color: white;
  font-size: 18px;
  font-weight: 600;
  padding-bottom: 10px;
}

p {
  color: white;
  font-size: 17px;
  text-decoration: underline;
}

hr {
  width: 80%;
  border: none;
  height: 1px;
  background-color: rgb(31, 150, 255);
}

.row {
  padding-bottom: 10px;
}
</style>