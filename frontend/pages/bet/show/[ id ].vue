<template>
    <div>
      <Head>
        <Title>Show bet</Title>
      </Head>
    </div>
    <Navbar />
    <BetPanel 
      :uuid=uuid
    />
    <Footer />
  </template>
  
  <script setup>
    const route = useRoute();
    const uuid = route.params.id;
  </script>
  
  <style scoped>
  </style>
