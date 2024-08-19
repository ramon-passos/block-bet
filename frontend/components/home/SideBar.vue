<template>
  <div v-if="isSidebarOpen" class="sidebar">
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
      <section class="category-section">
        <h2>Categorias</h2>
        <div class="row">
          <p>
            Esportes
          </p>
        </div>
        <div class="row">
          <p>
            Jogos eletrônicos
          </p>
        </div>
        <div class="row">
          <p>
            Política
          </p>
        </div>
      </section>
      <hr>
    </section>
  </div>
</template>

<script setup>
const props = defineProps({
	isSidebarOpen: {
		type: Boolean,
		required: true
	},
	toggleSidebar: {
		type: Function,
		required: true
	}
})
</script>

<style scoped>
section {
  margin-top: 40px;
  margin-bottom: 20px;
}

.sidebar {
  flex: 1;
  top: 0;
  left: 0;
  min-width: 350px;
  background-color: #333;
  color: white;
  transition: transform 0.3s ease;
}

.sidebar.closed {
  transform: translateX(-100%);
}

.side-options-section {
  margin-left: 50px;
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