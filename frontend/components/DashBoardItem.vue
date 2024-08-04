<template>
  <section class="bet">
    <div class="row">
      <div class="bet_title">
        <p>
          Titulo Aposta
        </p>
      </div>
    </div>
    <div class="row">
      <div class="bet_data">
        <div class="col">
          <div class="data_field">
            <p>Id_Aposta</p>
          </div>
        </div>
        <div class="col">
          <div class="data_field">
            <p>Texto Aposta</p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
export default defineComponent({
  name: "DashBoardItem",
  setup() {

  },
})
</script>

<style>
.bet {
  height: fit-content;
  background-color: rgb(233, 240, 238);
  padding: 10px 20px 10px 20px;
  margin: 30px 0px 30px 0px;
  border: 0 solid white;
  border-radius: 15px;
}

.row {
  display: flex;
}

.column {
  display: inline !important;
}
</style>
