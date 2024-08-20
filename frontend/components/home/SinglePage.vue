<template>
  <div
    class="number"
    :style="{ backgroundColor: backgroundColor, color: color }"
    @click="emitPageChange"
  >
    <p>{{ page }}</p>
  </div>
</template>

<script setup>
const props = defineProps({
  page: {
    type: Number,
    required: true,
  },
  currentPage: {
    type: Number,
    required: true,
  },
});

const backgroundColor = computed(() =>
  props.page === props.currentPage ? "white" : "rgb(59, 59, 59)"
);
const color = computed(() =>
  props.page === props.currentPage ? "rgb(59, 59, 59)" : "white"
);

const emit = defineEmits(["changeCurrentPage"]);

function emitPageChange() {
  emit("changeCurrentPage", props.page);
}
</script>

<style>
.number {
  background-color: rgb(59, 59, 59);
  font-weight: 500;
  width: 40px;
  height: 40px;
  display: flex;
  justify-content: center;
  align-content: center;
  border: 1px solid white;
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