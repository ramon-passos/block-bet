<template>
  <div
    class="bet-filter"
    @click="applyFilter"
    :style="{ backgroundColor: backgroundColor, color: color }"
  >
    <p>{{ filterText }}</p>
  </div>
</template>

<script setup>
const props = defineProps({
  filterText: {
    type: String,
    required: true,
  },
  filter: {
    type: String,
    required: true,
  },
  filterType: {
    type: String,
    required: true,
  },
});

let isActive = false;

const emit = defineEmits(["filter-selected", "filter-unselected"]);
const { filter, filterType } = props;

function applyFilter() {
  changeColor();
  if (isActive) {
    emit("filter-selected", filterType, filter);
  } else {
    emit("filter-unselected", filterType, filter);
  }
}

const backgroundColor = ref("white");
const color = ref("rgb(226, 14, 208)");

function changeColor() {
  isActive = !isActive;

  if (isActive) {
    backgroundColor.value = "rgb(226, 14, 208)";
    color.value = "white";
  } else {
    backgroundColor.value = "white";
    color.value = "rgb(226, 14, 208)";
  }
}
</script>

<style scoped>
.bet-filter {
  background-color: white;
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