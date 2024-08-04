<template>
  <button>
    {{ buttonText }}
  </button>
</template>

<script setup>
const props = defineProps({
  buttonText: {
    type: String,
    required: true
  }
});
</script>

<style>
button {
  background-color: blueviolet;
  border: 1px solid white;
  border-radius: 10px;
  font-size: 20px;
  color: white;
  padding: 10px 8px;
  transition: background-color 0.3s ease, transform 0.3s ease;
}

button:hover {
  background-color: white;
  color: black;
  border-color: black;
  transform: scale(1.05);
}

</style>