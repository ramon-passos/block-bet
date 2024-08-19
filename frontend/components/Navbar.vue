<template>
  <nav class="navbar">
    <div class="navbar-content">
      <button @click="toggleSidebar">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
          <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 5.25h16.5M3.75 12h16.5M3.75 18.75h16.5" />
        </svg>
      </button>
      <NuxtLink to="/">
        <div class="logo-wrapper">
          <p>Block</p>
          <img id='logo-nav' src="/logo.png">
          <p>Bet&nbsp;&nbsp;</p>
        </div>
      </NuxtLink>
      <NuxtLink to="/wallet">
        <p id="link">
          Conectar minha carteira
        </p>
      </NuxtLink>
    </div>
  </nav>
</template>

<script setup>
const props = defineProps({
  toggleSidebar: {
    type: Function,
    required: true
  },
})
</script>

<style scoped>
@font-face {
  font-family: 'FonteLogo';
  src: url('~/assets/fonts/fonte-logo.ttf') format('ttf');
}

.navbar {
  height: 120px;
  width: 100%;
  margin: 0;
  background-color: #1f1e1e;
  display: flex;
  justify-content: center;
  align-items: center;
  box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
}

.navbar-content {
  position: relative;
  display: flex;
  align-items: center;
}

.logo-wrapper {
  width: fit-content;
  display: flex;
  justify-content: space-evenly;
  align-items: center;
  gap: 4px;
}

.logo-wrapper p {
  color: white;
  font-size: 30px;
  font-weight: 900;
  font-family: Lexend, sans-serif
}

#logo-nav {
  height: 80px
}

#link {
  font-family: Gabarito, sans-serif;
  font-size: 16px;
  color: white;
  width: max-content;
  position: absolute;
  margin-left: 500px;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  padding-bottom: 5px;
  border-bottom: 2px solid transparent;
  border-image: linear-gradient(to right, rgb(31, 150, 255), blueviolet, rgb(226, 14, 208)) 1 0 0;
  border-image-slice: 1;
  transition: 0.2s ease;
}

#link:hover {
  color: rgb(31, 150, 255);
  border-bottom: 2px solid rgb(31, 150, 255);
}
</style>