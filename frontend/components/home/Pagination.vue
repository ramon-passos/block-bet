<template>
  <div class="pagination">
    <div class="row" v-for="page in totalPages" :key="page">
      <HomeSinglePage
        :page="page"
        :currentPage="activePage"
        @changeCurrentPage="pageHandler"
      />
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  totalPages: {
    type: Number,
    required: true,
  },
});

const emit = defineEmits(["sendActivePage"])

const activePage = ref(1);

function pageHandler(page) {
  activePage.value = page;
  emit("sendActivePage", activePage.value)
}
</script>

<style scoped>
.pagination {
  color: rgb(31, 150, 255);
  display: flex;
  justify-content: center;
  margin-top: 30px;
  font-size: 20px;
  gap: 20px;
}

.row {
  display: flex;
  justify-content: center;
}
</style>