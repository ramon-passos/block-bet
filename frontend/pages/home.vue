<template>
  <div>
    <Head>
      <Title>Home</Title>
    </Head>
  </div>

  <Navbar />
  <section class="main-section">
    <div class="main-section-header">
      <h1>
        Apostas Ativas
      </h1>
      <Button buttonText="Criar minha aposta" />
    </div>
    <DashBoard />
  </section>
</template>

<script setup>
import Navbar from '~~/components/Navbar.vue';
import DashBoard from '~~/components/DashBoard.vue';
import Button from '~~/components/Button.vue';
</script>

<style>
body {
  height: 1500px;
}

.main-section {
  display: grid;
  justify-content: center;
}

.main-section h1 {
  font-size: 36px;
  font-weight: 400;
  padding-top: 50px;
  z-index: 2;
  display: flex;
  justify-content: center;
}

.main-section-header {
  width: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.main-section-header button {
  margin-left: auto;
}
</style>