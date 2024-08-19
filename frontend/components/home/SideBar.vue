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
  color: #1b1b1b;
  font-size: 24px;
  font-weight: 800;
  padding-bottom: 10px;
}

p {
  color: #1b1b1b;
  font-size: 19px;
  font-weight: 600;
}

hr {
  width: 80%;
  border: none;
  height: 2px;
  background: linear-gradient(to right, rgb(31, 150, 255), blueviolet, rgb(226, 14, 208));
}

.row {
  padding-bottom: 10px;
}
</style>