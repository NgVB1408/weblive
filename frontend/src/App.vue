<template>
  <div id="app" class="min-h-screen bg-dark-950">
    <router-view />
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import socketService from '@/config/socket'

const authStore = useAuthStore()

onMounted(() => {
  // Initialize socket connection if user is authenticated
  if (authStore.isAuthenticated) {
    socketService.connect()
  }
})
</script>

<style>
/* Global styles are imported in main.js */
</style>
