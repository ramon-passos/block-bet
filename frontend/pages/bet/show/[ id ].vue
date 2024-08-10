<template>
    <div>
      <Head>
        <Title>Show bet</Title>
      </Head>
    </div>
    <Navbar />
    <BetPanel 
      :id=id
    />
    <Footer />
  </template>
  
  <script setup>
    const route = useRoute();
    const id = Number(route.params.id);
  </script>
  
  <style scoped>
  </style>
