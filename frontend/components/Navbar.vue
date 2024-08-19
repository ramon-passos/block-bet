<template>
  <nav class="navbar">
    <div class="left">
      <button @click="toggleSidebar">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="white"
          class="w-6 h-6">
          <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 5.25h16.5M3.75 12h16.5M3.75 18.75h16.5" />
        </svg>
      </button>
    </div>
    <div class="center">
      <NuxtLink to="/">
        <div class="logo-wrapper">
          <p>Block</p>
          <img id='logo-nav' src="/logo.png">
          <p>Bet&nbsp;&nbsp;</p>
        </div>
      </NuxtLink>
    </div>
    <div class="right">
      <NuxtLink to="/wallet">
        <p id="link">Conectar minha carteira</p>
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
.navbar {
  height: 120px;
  width: 100%;
  background-color: #1f1e1e;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
  box-sizing: border-box;
}

.navbar .left,
.navbar .right {
  display: flex;
  align-items: center;
  margin: 0 40px;
}

.navbar .center {
  flex: 1;
  display: flex;
  justify-content: center;
}

.logo-wrapper {
  display: flex;
  align-items: center;
  gap: 4px;
  width: 80px;
}

.logo-wrapper p {
  color: white;
  font-size: 30px;
  font-weight: 900;
  font-family: Lexend, sans-serif;
}

#logo-nav {
  height: 80px;
}

#link {
  font-family: Gabarito, sans-serif;
  font-size: 16px;
  color: white;
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