<template>
	<div>
		<Navbar :toggleSidebar="toggleSidebar" />
		<div class="row">
			<SideBar :isSidebarOpen="isSidebarOpen" :toggleSidebar="toggleSidebar" />
			<slot />
		</div>
		<Footer>
		</Footer>
	</div>
</template>

<script setup>
const isSidebarOpen = ref(false)

const toggleSidebar = () => {
  isSidebarOpen.value = !isSidebarOpen.value
}
</script>

<style scoped>
.row {
	background-color: #1b1b1b;
}

.sidebar {
  color: #1b1b1b;
  background-color: rgb(231, 230, 233);
}
</style>