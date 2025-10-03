<template>
  <div>
    <h2 class="text-2xl font-bold text-white mb-6">Đăng nhập</h2>
    
    <form @submit.prevent="handleLogin" class="space-y-4">
      <!-- Email -->
      <div>
        <label class="block text-sm font-medium text-gray-300 mb-2">
          Email
        </label>
        <input
          v-model="form.email"
          type="email"
          required
          class="input"
          placeholder="Nhập email của bạn"
        >
      </div>

      <!-- Password -->
      <div>
        <label class="block text-sm font-medium text-gray-300 mb-2">
          Mật khẩu
        </label>
        <input
          v-model="form.password"
          type="password"
          required
          class="input"
          placeholder="Nhập mật khẩu"
        >
      </div>

      <!-- Remember Me -->
      <div class="flex items-center justify-between">
        <label class="flex items-center">
          <input
            v-model="form.rememberMe"
            type="checkbox"
            class="w-4 h-4 text-yellow-500 bg-dark-800 border-dark-600 rounded focus:ring-yellow-500 focus:ring-2"
          >
          <span class="ml-2 text-sm text-gray-300">Ghi nhớ đăng nhập</span>
        </label>
        
        <a href="#" class="text-sm text-yellow-500 hover:text-yellow-400">
          Quên mật khẩu?
        </a>
      </div>

      <!-- Submit Button -->
      <button
        type="submit"
        :disabled="authStore.loading"
        class="w-full btn btn-primary"
      >
        <span v-if="authStore.loading" class="spinner mr-2"></span>
        {{ authStore.loading ? 'Đang đăng nhập...' : 'Đăng nhập' }}
      </button>
    </form>

    <!-- Register Link -->
    <div class="mt-6 text-center">
      <p class="text-gray-400">
        Chưa có tài khoản?
        <router-link 
          to="/auth/register" 
          class="text-yellow-500 hover:text-yellow-400 font-medium"
        >
          Đăng ký ngay
        </router-link>
      </p>
    </div>
  </div>
</template>

<script setup>
import { reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'vue-toastification'

const router = useRouter()
const authStore = useAuthStore()
const toast = useToast()

const form = reactive({
  email: '',
  password: '',
  rememberMe: false
})

const handleLogin = async () => {
  try {
    const result = await authStore.login({
      email: form.email,
      password: form.password
    })

    if (result.success) {
      toast.success('Đăng nhập thành công!')
      
      // Redirect to intended page or home
      const redirect = router.currentRoute.value.query.redirect || '/'
      router.push(redirect)
    } else {
      toast.error(result.error)
    }
  } catch (error) {
    console.error('Login error:', error)
    toast.error('Đăng nhập thất bại. Vui lòng thử lại.')
  }
}
</script>
