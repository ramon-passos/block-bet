<template>
  <div class="sub-header">
    <div class="row">
      <HomeFilter
        @filter-selected="handleFilter"
        @filter-unselected="removeFilter"
        filterText="ABERTAS"
        filterType="status"
        filter="open"
      />
      <HomeFilter
        @filter-selected="handleFilter"
        @filter-unselected="removeFilter"
        filterText="AUDITÁVEIS"
        filterType="status"
        filter="auditable"
      />
    </div>
  </div>
  <section class="dashboard-panel">
    <ul>
      <li v-for="bet in bets" :key="bet.id">
        <HomeDashBoardItem :bet_data="bet">
        </HomeDashBoardItem>
      </li>
    </ul>
    <HomePagination
      onClick="onClickHandler"
      :numPages=totalPages
    >
    </HomePagination>
  </section>
</template>

<script setup>
import { BlockBetService } from '@/services/BlockBetService';
const blockBetService = new BlockBetService();
const bets = ref([]);
const filters = ref({});

const currentPage = ref(1);
const itemsPerPage = ref(5);
const pageData = ref([]);
const totalPages = ref(1);

function handleFilter(key, value) {
  if (!filters.value[key]) {
    filters.value[key] = [];
  }

  if (!filters.value[key].includes(value)) {
    filters.value[key].push(value);
  }
  fetchData();
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

  fetchData();
}

function fetchData() {
  blockBetService.getBets(Object.entries(filters.value))
    .then((response) => response.json())
    .then((data) => {
      bets.value = data;
      totalPages.value = data.length + 1/ itemsPerPage.value;
    });

  console.log(totalPages.value);
}
function onClickHanlder(page) {
  currentPage.value = page;
  scrollToTop();
}

function dataPerPage() {
  for (bet in bets) {

  }
}

const scrollToTop = () => {
  window.scrollTo({ top: 0, behavior: 'smooth' });
};

onMounted(() => {
  scrollToTop();
  fetchData();
});
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