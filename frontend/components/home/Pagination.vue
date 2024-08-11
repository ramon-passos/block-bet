<template>
  <div class="pagination">
    <div class="row" v-for="page in numPages" :key="page">
      <div class="number">
        <p>{{ page }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  numPages: {
    type: Number,
    required: true,
  },
});
</script>

<style scoped>
.pagination {
  color: blueviolet;
  display: flex;
  justify-content: center;
  margin-top: 30px;
  font-size: 20px;
}

.number {
  margin-right: 18px;
  font-weight: 500;
  width: 40px;
  height: 40px;
  display: flex;
  justify-content: center;
  align-content: center;
  border: 1px solid blueviolet;
  border-radius: 50%;
  transition: background-color 0.3s ease;
}

.number:hover {
  background-color: rgb(233, 240, 238);
  cursor: pointer;
}

.number p {
  align-self: center;
}
</style>