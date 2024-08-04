<template>
  <section class="dashboard-panel">
    <DashBoardItem />
    <hr>
    <DashBoardItem />
  </section>
</template>

<script>
import DashBoardItem from './DashBoardItem.vue';

export default {
  name: "DashBoard",
}
</script>

<style>
hr {
  border: none;
  height: 1px;
  background-color: black;
  width: 80%;
  margin: auto;
}

.dashboard-panel {
  min-height: 600px;
  min-width: 900px;
  max-width: 60%;
  z-index: 1;
}
</style>