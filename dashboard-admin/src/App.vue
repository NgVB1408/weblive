<template>
  <div id="app" class="min-h-screen bg-gray-100">
    <router-view />
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

onMounted(() => {
  // Initialize admin authentication
  if (localStorage.getItem('admin_token')) {
    authStore.setAdminAuth()
  }
})
</script>
