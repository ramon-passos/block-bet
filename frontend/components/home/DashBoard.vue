<template>
  <div class="sub-header">
    <div class="row">
      <HomeFilter
        @filterSelected="handleFilter"
        @filterUnselected="removeFilter"
        filterText="ABERTAS"
        filterType="status"
        filter="open"
      />
      <HomeFilter
        @filterSelected="handleFilter"
        @filterUnselected="removeFilter"
        filterText="DESAFIADAS"
        filterType="status"
        filter="challenged"
      />
      <HomeFilter
        @filterSelected="handleFilter"
        @filterUnselected="removeFilter"
        filterText="CONTESTADAS"
        filterType="status"
        filter="contested"
      />
      <HomeFilter
        @filterSelected="handleFilter"
        @filterUnselected="removeFilter"
        filterText="FINALIZADAS"
        filterType="status"
        filter="finished"
      />
      <HomeFilter
        @filterSelected="handleFilter"
        @filterUnselected="removeFilter"
        filterText="INVÁLIDAS"
        filterType="status"
        filter="invalid"
      />
    </div>
  </div>
  <section class="dashboard-panel">
    <ul>
      <li v-for="bet in betsPerPage" :key="bet.id">
        <HomeDashBoardItem :betData="bet"> </HomeDashBoardItem>
      </li>
    </ul>
    <div v-show="betsPerPage.length == 0">
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

async function fetchData() {
  const response = await blockBetService.getBets(Object.entries(filters.value));
  const data = await response.json();
  bets.value = data;
  setDataPerPage();
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

onMounted(() => {
  fetchData();
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
</script>

<style scoped>
.sub-header {
  margin-top: 20px;
  margin-left: 20px;
  transition: background-color 0.3s ease, transform 0.3s ease;
}

.dashboard-panel {
  min-height: 600px;
  min-width: 900px;
  max-width: 60%;
  display: grid;
  padding-bottom: 30px;
}
</style>