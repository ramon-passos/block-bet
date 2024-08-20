<template>
  <button @click="buttonFunction">
    {{ buttonText }}
  </button>
</template>

<script setup>
const props = defineProps({
  buttonText: {
    type: String,
    required: true
  },
  buttonFunction: {
    type: Function,
  }
});
</script>

<style scoped>
button {
  font-family: Gabarito, sans-serif;
  background-color: blueviolet;
  border: 1px solid rgb(59, 59, 59);
  border-radius: 10px;
  font-size: 20px;
  color: white;
  padding: 10px 8px;
  transition: background-color 0.3s ease, transform 0.3s ease;
}

button:hover {
  background-color: white;
  color: blueviolet;
  border-color: black;
  transform: scale(1.05);
  cursor: pointer;
}
</style>