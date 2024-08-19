<template>
  <div>
    <Head>
      <Title>Home</Title>
    </Head>
  </div>

  <Navbar :toggleSidebar="toggleSidebar" />
  <div class="row">
    <HomeSideBar :isSidebarOpen="isSidebarOpen" :toggleSidebar="toggleSidebar" />
    <section class="main-section col">
      <div class="row main-section-header">
        <h1>
          <b>Apostas Ativas</b>
        </h1>
        <div class="row main-section-subheader">
          <div class="bet-info">
            <p id="id-info" @click="openModal">Como funcionam as apostas?</p>
            <div v-if="isModalOpen" class="overlay" @click="closeModal"></div>
            <div v-if="isModalOpen" class="modal">
              <div class="row">
                <h2>Regras para as apostas:</h2>
                <button @click="closeModal" style="font-weight: 700; font-size: 20px;">
                  &times;
                </button>
              </div>
              <div class="row">
                <p>
                  Aqui estão as informações sobre como funcionam as apostas no
                  site...
                </p>
              </div>
            </div>
          </div>
          <Button buttonText="Criar minha aposta" :buttonFunction="goToDestination">
          </Button>
        </div>
      </div>
      <HomeDashBoard />
    </section>
  </div>
  <Footer> </Footer>
</template>

<script setup>
const router = useRouter();

function goToDestination() {
  router.push("/bet/create");
}

const isModalOpen = ref(false);

const openModal = () => {
  isModalOpen.value = true;
};

const closeModal = () => {
  isModalOpen.value = false;
};

const isSidebarOpen = ref(false)

const toggleSidebar = () => {
  isSidebarOpen.value = !isSidebarOpen.value
}
</script>

<style scoped>
body {
  background-color: #1b1b1b;
}

.sidebar {
  color: #1b1b1b;
  background-color: rgb(231, 230, 233);
}

.main-section {
  background-color: #1b1b1b;
  padding: 0px 400px;
  flex: 5;
}

.main-section h1 {
  color: rgb(240, 240, 240);
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
  align-items: center;
}

.main-section-header button {
  margin-left: auto;
}

.main-section-subheader {
  width: 100%;
  justify-content: space-between;
  align-items: end;
}

.bet-info {
  text-decoration: underline;
  color: rgb(31, 150, 255);
  padding-right: 400px;
}

#id-info:hover {
  text-decoration: underline;
  color: rgb(4, 94, 172);
  cursor: pointer;
}

.overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  z-index: 10;
}

.modal {
  font-size: 18px;
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background-color: white;
  padding: 20px;
  box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.25);
  z-index: 11;
  max-width: 600px;
  width: 90%;
  border-radius: 10px;
}

.modal .row {
  padding: 5px 10px;
}

.modal button:hover {
  text-decoration: underline;
}

.modal h2 {
  align-self: center;
}
</style>