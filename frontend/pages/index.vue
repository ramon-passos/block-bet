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
        <b>Apostas Ativas</b>
      </h1>
      <Button buttonText="Criar minha aposta" buttonRoute="/bet/create">
      </Button>
    </div>
    <div class="sub-header">
      <div class="row">
        <div class="bet-filter" id="active">
          <p>ABERTAS</p>
        </div>
        <div class="bet-filter" id="auditable">
          <p>AUDITÁVEIS</p>
        </div>
      </div>
    </div>
    <HomeDashBoard />
  </section>
  <Footer />
</template>

<script setup>
</script>

<style>
body {
  background-color: #262626;
}

.main-section {
  background-color: white;
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

.sub-header {
  margin-top: 20px;
  margin-left: 20px;
  transition: background-color 0.3s ease, transform 0.3s ease;
}

.bet-filter {
  color: rgb(226, 14, 208);
  border: 2px solid rgb(226, 14, 208);
  border-radius: 10px;
  padding: 5px;
  font-size: 13px;
  margin-right: 20px;
}

.bet-filter:hover {
  background-color: rgb(226, 14, 208);
  color: white;
  cursor: pointer;
}

.row {
  display: flex;
  flex-wrap: wrap;
}

.col {
  flex: 1;
  justify-content: center;
}
</style>