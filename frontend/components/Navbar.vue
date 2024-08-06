<template>
  <nav class="navbar">
    <div class="navbar-content">
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


</script>

<style scoped>
.navbar {
  height: 120px;
  width: 100%;
  margin: 0;
  background-color: #262626;
  display: flex;
  justify-content: center;
  align-items: center;
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

.navbar p {
  color: white;
  font-size: 30px;
  font-weight: 800;
}

#logo-nav {
  height: 80px
}

#link {
  font-size: 16px;
  width: max-content;
  position: absolute;
  margin-left: 500px;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  border-bottom: 2px solid blueviolet;
  padding-bottom: 5px;
  transition: 0.2s ease;
}

#link:hover {
  color: blueviolet;
}
</style>