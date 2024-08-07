<template>
  <div class="bet-filter">
    <p>{{ filterText }}</p>
  </div>
</template>

<script setup>
const props = defineProps({
  filterText: {
    type: String,
    required: true
  }
});
</script>

<style scoped>
.bet-filter {
  color: rgb(226, 14, 208);
  border: 2px solid rgb(226, 14, 208);
  border-radius: 10px;
  padding: 5px 10px;
  font-size: 13px;
  margin-right: 20px;
}

.bet-filter:hover {
  background-color: rgb(226, 14, 208);
  color: white;
  cursor: pointer;
}
</style>