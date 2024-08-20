<template>
  <div :class="{ sidebar: true, 'sidebar-open': isSidebarOpen, 'sidebar-closed': !isSidebarOpen }">
    <section class="side-options-section">
      <!-- Conteúdo da sidebar -->
      <section class="personal-options-section">
        <h2>Minhas apostas</h2>
        <div class="row">
          <p>Abertas</p>
        </div>
        <div class="row">
          <p>Desafiadas</p>
        </div>
        <div class="row">
          <p>Contestadas</p>
        </div>
      </section>
      <hr>
      <section class="general-options-section">
        <h2>Outros</h2>
        <div class="row">
          <p>Minha reputação</p>
        </div>
        <div class="row">
          <p>Apostas auditadas</p>
        </div>
        <div class="row">
          <p>Teste</p>
        </div>
      </section>
      <hr>
      <section class="category-section">
        <h2>Categorias</h2>
        <div class="row">
          <p>Esportes</p>
        </div>
        <div class="row">
          <p>Jogos eletrônicos</p>
        </div>
        <div class="row">
          <p>Política</p>
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
.sidebar {
  top: 0;
  left: 0;
  background-color: #333;
  overflow: hidden;
  color: white;
  transform: translateX(-100%); /* Começa fora da tela */
  transition: transform 0.4s ease, width 0.4s ease; /* Animação suave */
  padding-bottom: 40px;
}

.sidebar-open {
  transform: translateX(0); /* Move a sidebar para a tela */
  width: 350px;
  min-width: 350px;
}

.sidebar-closed {
  width: 0px;
  overflow: hidden;
  transform: translateX(-100%); /* Move a sidebar para fora da tela */
}

section {
  margin-top: 40px;
  margin-bottom: 20px;
}

.side-options-section {
  margin-left: 50px;
}

h2 {
  color: #1b1b1b;
  font-size: 24px;
  font-weight: 800;
  padding-bottom: 10px;
  font-family: 'Bebas Neue', sans-serif;
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