<template>
  <button @click="goToDestination">
    {{ buttonText }}
  </button>
</template>

<script setup>
const props = defineProps({
  buttonText: {
    type: String,
    required: true
  },
  buttonRoute: {
    type: String,
  }
});

const router = useRouter();

function goToDestination() {
  router.push(props.buttonRoute);
};
</script>

<style scoped>
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
  cursor: pointer;
}
</style>