<template>
  <div>
    <Head>
      <Title>Home</Title>
    </Head>
  </div>

  <Navbar />
  <div class="row">
    <div class="col sidebar">
      <HomeSideBar />
    </div>
    <div class="col" id="main-sec">
      <section class="main-section">
        <div class="main-section-header">
          <h1>
            <b>Apostas Ativas</b>
          </h1>
          <Button buttonText="Criar minha aposta" buttonRoute="/bet/create">
          </Button>
        </div>
        <HomeDashBoard />
      </section>
    </div>
  </div>
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
  padding: 0px 200px;
  padding-bottom: 30px;
}

#main-sec {
  flex: 5;
}

.main-section h1 {
  font-size: 36px;
  font-weight: 400;
  padding-top: 50px;
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

.row {
  display: flex;
  flex-wrap: wrap;
}

.col {
  flex: 1;
  justify-content: center;
}
</style>