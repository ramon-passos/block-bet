<template>
  <div class="sub-header">
    <div class="row">
      <HomeFilter
        @filterSelected="handleFilter"
        @filterUnselected="removeFilter"
        filterText="ABERTAS"
        filterType="status"
        filter="OPEN"
      />
      <HomeFilter
        @filterSelected="handleFilter"
        @filterUnselected="removeFilter"
        filterText="DESAFIADAS"
        filterType="status"
        filter="CHALLENGED"
      />
      <HomeFilter
        @filterSelected="handleFilter"
        @filterUnselected="removeFilter"
        filterText="CONTESTADAS"
        filterType="status"
        filter="CONTESTED"
      />
      <HomeFilter
        @filterSelected="handleFilter"
        @filterUnselected="removeFilter"
        filterText="FINALIZADAS"
        filterType="status"
        filter="FINISHED"
      />
      <HomeFilter
        @filterSelected="handleFilter"
        @filterUnselected="removeFilter"
        filterText="INVÁLIDAS"
        filterType="status"
        filter="INVALID"
      />
    </div>
  </div>
  <section class="dashboard-panel col">
    <ul>
      <li v-for="bet in betsPerPage" :key="bet.id">
        <HomeDashBoardItem :betData="bet"> </HomeDashBoardItem>
      </li>
    </ul>
    <div class="loader-div" v-show="betsPerPage.length == 0">
      <Loader />
    </div>
    <HomePagination
      :totalPages="totalPages"
      :currentPage="currentPage"
      @sendActivePage="handlePageData"
    >
    </HomePagination>
  </section>
</template>

<script setup>
import { BlockBetService } from "@/services/BlockBetService";

const blockBetService = new BlockBetService();
const bets = ref([]);
const filters = ref({});
const currentPage = ref(1);
const itemsPerPage = 5;
const betsPerPage = ref([]);
const totalPages = computed(() => Math.ceil(bets.value.length / itemsPerPage));

const calculateOffset = (page) => (page - 1) * itemsPerPage;

onMounted(() => {
  const isAvailable = bets.value.length > 0;
  if (!isAvailable) {
    startPolling();
  }
});

watch(
  filters,
  () => {
    currentPage.value = 1;
    fetchData();
  },
  { deep: true }
);

watch(
  currentPage,
  () => {
    setDataPerPage();
  }
);

function fetchData() {
  blockBetService.getBets(filters.value.status)
    .then(data => {
      bets.value = data;
      setDataPerPage();
    })
}

function setDataPerPage() {
  const offset = calculateOffset(currentPage.value);
  betsPerPage.value = bets.value.slice(offset, offset + itemsPerPage);
}

function handlePageData(page) {
  currentPage.value = page;
  scrollToTop();
  setDataPerPage();
}

const scrollToTop = () => {
  window.scrollTo({ top: 0, behavior: "smooth" });
};

function startPolling() {
  const interval = setInterval(() => {
    const isAvailable = bets.value.length > 0;
    if (isAvailable) {
      clearInterval(interval);
    } else {
      console.log("Polling... API not available yet");
      fetchData();
    }
  }, 500);
}

function handleFilter(key, value) {
  if (!filters.value[key]) {
    filters.value[key] = [];
  }

  if (!filters.value[key].includes(value)) {
    filters.value[key].push(value);
  }
}

function removeFilter(key, value) {
  if (filters.value[key]) {
    const index = filters.value[key].indexOf(value);
    if (index > -1) {
      filters.value[key].splice(index, 1);
    }
    if (filters.value[key].length === 0) {
      delete filters.value[key];
    }
  }
}
</script>

<style scoped>
.sub-header {
  margin-top: 20px;
  margin-left: 20px;
  transition: background-color 0.3s ease, transform 0.3s ease;
}

.dashboard-panel {
  justify-content: center;
  padding: 30px 0px;
  box-sizing: border-box;
}

.dashboard-panel ul {
  width: 100%;
  padding: 0;
  margin: 0;
  list-style-type: none;
}

.loader-div {
  align-content: center;
}
</style>