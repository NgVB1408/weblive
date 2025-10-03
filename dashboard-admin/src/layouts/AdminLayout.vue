<template>
  <div class="min-h-screen bg-gray-100">
    <!-- Sidebar -->
    <div class="fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg transform transition-transform duration-300 ease-in-out"
         :class="{ '-translate-x-full': !sidebarOpen, 'translate-x-0': sidebarOpen }">
      <!-- Sidebar Header -->
      <div class="flex items-center justify-between h-16 px-4 bg-gray-800">
        <div class="flex items-center">
          <div class="w-8 h-8 bg-gradient-to-r from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
            <span class="text-white font-bold text-sm">AD</span>
          </div>
          <span class="ml-2 text-xl font-bold text-white">Admin Panel</span>
        </div>
        <button @click="toggleSidebar" class="text-gray-400 hover:text-white">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>

      <!-- Sidebar Navigation -->
      <nav class="mt-5 px-2">
        <div class="space-y-1">
          <router-link
            v-for="item in navigation"
            :key="item.name"
            :to="item.href"
            class="group flex items-center px-2 py-2 text-sm font-medium rounded-md transition-colors"
            :class="[
              $route.path === item.href
                ? 'bg-gray-900 text-white'
                : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
            ]"
          >
            <component :is="item.icon" class="mr-3 h-5 w-5" />
            {{ item.name }}
          </router-link>
        </div>
      </nav>
    </div>

    <!-- Main Content -->
    <div class="flex-1 flex flex-col min-h-screen" :class="{ 'ml-64': sidebarOpen }">
      <!-- Top Navigation -->
      <header class="bg-white shadow-sm border-b border-gray-200">
        <div class="flex items-center justify-between h-16 px-4">
          <div class="flex items-center">
            <button @click="toggleSidebar" class="text-gray-500 hover:text-gray-600">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
              </svg>
            </button>
            <h1 class="ml-4 text-xl font-semibold text-gray-900">
              {{ $route.meta.title || 'Dashboard' }}
            </h1>
          </div>

          <!-- User Menu -->
          <div class="flex items-center space-x-4">
            <!-- Notifications -->
            <button class="relative p-2 text-gray-400 hover:text-gray-500">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-5 5-5-5h5v-5a7.5 7.5 0 1 1 15 0v5z"></path>
              </svg>
              <span class="absolute top-0 right-0 block h-2 w-2 rounded-full bg-red-400"></span>
            </button>

            <!-- Admin Profile -->
            <div class="flex items-center space-x-3">
              <div class="text-right">
                <p class="text-sm font-medium text-gray-900">Admin User</p>
                <p class="text-xs text-gray-500">Administrator</p>
              </div>
              <button @click="handleLogout" class="text-gray-400 hover:text-gray-600">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                </svg>
              </button>
            </div>
          </div>
        </div>
      </header>

      <!-- Page Content -->
      <main class="flex-1 p-6">
        <router-view />
      </main>
    </div>

    <!-- Mobile Sidebar Overlay -->
    <div v-if="sidebarOpen" @click="toggleSidebar" class="fixed inset-0 z-40 bg-gray-600 bg-opacity-75 lg:hidden"></div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const sidebarOpen = ref(true)

const navigation = [
  {
    name: 'Dashboard',
    href: '/admin',
    icon: 'svg'
  },
  {
    name: 'Users',
    href: '/admin/users',
    icon: 'svg'
  },
  {
    name: 'Matches',
    href: '/admin/matches',
    icon: 'svg'
  },
  {
    name: 'Bets',
    href: '/admin/bets',
    icon: 'svg'
  },
  {
    name: 'Transactions',
    href: '/admin/transactions',
    icon: 'svg'
  },
  {
    name: 'API Logs',
    href: '/admin/logs',
    icon: 'svg'
  },
  {
    name: 'Settings',
    href: '/admin/settings',
    icon: 'svg'
  }
]

const toggleSidebar = () => {
  sidebarOpen.value = !sidebarOpen.value
}

const handleLogout = () => {
  authStore.logout()
  router.push('/admin/login')
}
</script>
