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
})

const emit = defineEmits(["filterSelected", "filterUnselected"])

const isActive = ref(false)

const backgroundColor = computed(() => isActive.value ? "rgb(226, 14, 208)" : "rgb(233, 240, 238)")
const color = computed(() => isActive.value ? "rgb(233, 240, 238)" : "rgb(59, 59, 59)")

function applyFilter() {
  isActive.value = !isActive.value
  if (isActive.value) {
    emit("filterSelected", props.filterType, props.filter)
  } else {
    emit("filterUnselected", props.filterType, props.filter)
  }
}
</script>

<style scoped>
.bet-filter {
  font-family: Gabarito, sans-serif;
  border: 1px solid #161616;
  border-radius: 10px;
  padding: 5px 10px;
  margin-top: 5px;
  font-size: 13px;
  margin-right: 20px;
  transition: transform 0.3s ease;
}

.bet-filter:hover {
  cursor: pointer;
  transform: scale(1.02);
}
</style>