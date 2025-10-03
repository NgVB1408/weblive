<template>
  <nav class="fixed top-0 left-0 right-0 z-50 bg-dark-900 border-b border-dark-700">
    <div class="container mx-auto px-4">
      <div class="flex items-center justify-between h-16">
        <!-- Logo -->
        <router-link to="/" class="flex items-center gap-2">
          <div class="w-8 h-8 bg-gradient-to-r from-yellow-500 to-orange-500 rounded-lg flex items-center justify-center">
            <span class="text-white font-bold text-sm">LB</span>
          </div>
          <span class="text-xl font-bold gradient-text">Livestream Betting</span>
        </router-link>

        <!-- Desktop Navigation -->
        <div class="hidden md:flex items-center gap-6">
          <router-link 
            to="/" 
            class="text-gray-300 hover:text-white transition-colors"
            :class="{ 'text-yellow-500': $route.name === 'Home' }"
          >
            Trang chủ
          </router-link>
          <router-link 
            to="/matches" 
            class="text-gray-300 hover:text-white transition-colors"
            :class="{ 'text-yellow-500': $route.name === 'Matches' }"
          >
            Trận đấu
          </router-link>
        </div>

        <!-- User Menu -->
        <div class="flex items-center gap-4">
          <template v-if="authStore.isAuthenticated">
            <!-- Balance -->
            <div class="hidden sm:flex items-center gap-2 bg-dark-800 px-3 py-2 rounded-lg">
              <span class="text-sm text-gray-400">Số dư:</span>
              <span class="text-yellow-500 font-semibold">
                {{ formatCurrency(authStore.balance, authStore.currency) }}
              </span>
            </div>

            <!-- User Menu -->
            <div class="relative">
              <button 
                @click="toggleUserMenu"
                class="flex items-center gap-2 bg-dark-800 px-3 py-2 rounded-lg hover:bg-dark-700 transition-colors"
              >
                <img 
                  :src="authStore.userAvatar" 
                  :alt="authStore.username"
                  class="w-6 h-6 rounded-full"
                >
                <span class="text-sm font-medium">{{ authStore.username }}</span>
                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd"></path>
                </svg>
              </button>

              <!-- Dropdown Menu -->
              <div 
                v-if="showUserMenu"
                class="absolute right-0 mt-2 w-48 bg-dark-800 rounded-lg shadow-lg border border-dark-700 py-1"
              >
                <router-link 
                  to="/profile"
                  class="flex items-center gap-2 px-4 py-2 text-sm text-gray-300 hover:bg-dark-700 hover:text-white transition-colors"
                >
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"></path>
                  </svg>
                  Hồ sơ
                </router-link>
                <router-link 
                  to="/wallet"
                  class="flex items-center gap-2 px-4 py-2 text-sm text-gray-300 hover:bg-dark-700 hover:text-white transition-colors"
                >
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M4 4a2 2 0 00-2 2v1h16V6a2 2 0 00-2-2H4zM18 9H2v5a2 2 0 002 2h12a2 2 0 002-2V9zM4 13a1 1 0 011-1h1a1 1 0 110 2H5a1 1 0 01-1-1zm5-1a1 1 0 100 2h1a1 1 0 100-2H9z"></path>
                  </svg>
                  Ví
                </router-link>
                <router-link 
                  to="/bets"
                  class="flex items-center gap-2 px-4 py-2 text-sm text-gray-300 hover:bg-dark-700 hover:text-white transition-colors"
                >
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M3 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd"></path>
                  </svg>
                  Lịch sử cược
                </router-link>
                <hr class="my-1 border-dark-700">
                <button 
                  @click="handleLogout"
                  class="flex items-center gap-2 px-4 py-2 text-sm text-red-400 hover:bg-dark-700 hover:text-red-300 transition-colors w-full text-left"
                >
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M3 3a1 1 0 00-1 1v12a1 1 0 102 0V4a1 1 0 00-1-1zm10.293 9.293a1 1 0 001.414 1.414l3-3a1 1 0 000-1.414l-3-3a1 1 0 10-1.414 1.414L14.586 9H7a1 1 0 100 2h7.586l-1.293 1.293z" clip-rule="evenodd"></path>
                  </svg>
                  Đăng xuất
                </button>
              </div>
            </div>
          </template>

          <template v-else>
            <!-- Auth Buttons -->
            <router-link 
              to="/auth/login"
              class="btn btn-secondary"
            >
              Đăng nhập
            </router-link>
            <router-link 
              to="/auth/register"
              class="btn btn-primary"
            >
              Đăng ký
            </router-link>
          </template>

          <!-- Mobile Menu Button -->
          <button 
            @click="toggleMobileMenu"
            class="md:hidden p-2 text-gray-400 hover:text-white"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
            </svg>
          </button>
        </div>
      </div>

      <!-- Mobile Menu -->
      <div v-if="showMobileMenu" class="md:hidden border-t border-dark-700 py-4">
        <div class="flex flex-col gap-4">
          <router-link 
            to="/" 
            class="text-gray-300 hover:text-white transition-colors"
            @click="closeMobileMenu"
          >
            Trang chủ
          </router-link>
          <router-link 
            to="/matches" 
            class="text-gray-300 hover:text-white transition-colors"
            @click="closeMobileMenu"
          >
            Trận đấu
          </router-link>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { formatCurrency } from '@/utils/helpers'

const router = useRouter()
const authStore = useAuthStore()

const showUserMenu = ref(false)
const showMobileMenu = ref(false)

const toggleUserMenu = () => {
  showUserMenu.value = !showUserMenu.value
}

const toggleMobileMenu = () => {
  showMobileMenu.value = !showMobileMenu.value
}

const closeMobileMenu = () => {
  showMobileMenu.value = false
}

const handleLogout = async () => {
  await authStore.logout()
  showUserMenu.value = false
  router.push('/')
}

// Close dropdown when clicking outside
document.addEventListener('click', (e) => {
  if (!e.target.closest('.relative')) {
    showUserMenu.value = false
  }
})
</script>
