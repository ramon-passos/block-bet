<template>
	<div v-if="isSidebarOpen" class="sidebar">
		<button @click="toggleSidebar">Fechar</button>
		<p>ettestetetetestetetes</p>
		<p>ettestetetetestetetes</p>
		<p>ettestetetetestetetes</p>
		<p>ettestetetetestetetes</p>
		<p>ettestetetetestetetes</p>
	</div>
</template>

<script setup>
const props = defineProps({
	isSidebarOpen: {
		type: Boolean,
		required: true
	},
	toggleSidebar: {
		type: Function,
		required: true
	}
})
</script>

<style scoped>
.sidebar {
	position: fixed;
	top: 0;
	left: 0;
	width: 250px;
	height: 100%;
	background-color: #ff0000;
	color: white;
	padding: 1rem;
	transition: transform 0.3s ease;
}

.sidebar.closed {
	transform: translateX(-100%);
}
</style>
  