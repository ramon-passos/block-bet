<template>
  <div>
    <Head>
      <Title>Show bet</Title>
    </Head>
  </div>
  <div class="col">
    <BetPanel :uuid=uuid />
  </div>

</template>

<script setup>
const route = useRoute();
const uuid = route.params.id;
</script>

<style scoped>
.col {
  margin: 0 auto;
}
</style>
