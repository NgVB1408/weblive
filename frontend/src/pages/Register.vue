<template>
  <div>
    <h2 class="text-2xl font-bold text-white mb-6">Đăng ký tài khoản</h2>
    
    <form @submit.prevent="handleRegister" class="space-y-4">
      <!-- First Name & Last Name -->
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-300 mb-2">
            Họ
          </label>
          <input
            v-model="form.firstName"
            type="text"
            required
            class="input"
            placeholder="Nhập họ"
          >
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-300 mb-2">
            Tên
          </label>
          <input
            v-model="form.lastName"
            type="text"
            required
            class="input"
            placeholder="Nhập tên"
          >
        </div>
      </div>

      <!-- Username -->
      <div>
        <label class="block text-sm font-medium text-gray-300 mb-2">
          Tên đăng nhập
        </label>
        <input
          v-model="form.username"
          type="text"
          required
          class="input"
          placeholder="Nhập tên đăng nhập"
        >
      </div>

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

      <!-- Phone -->
      <div>
        <label class="block text-sm font-medium text-gray-300 mb-2">
          Số điện thoại
        </label>
        <input
          v-model="form.phone"
          type="tel"
          class="input"
          placeholder="Nhập số điện thoại"
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

      <!-- Confirm Password -->
      <div>
        <label class="block text-sm font-medium text-gray-300 mb-2">
          Xác nhận mật khẩu
        </label>
        <input
          v-model="form.confirmPassword"
          type="password"
          required
          class="input"
          placeholder="Nhập lại mật khẩu"
        >
      </div>

      <!-- Terms & Conditions -->
      <div class="flex items-start">
        <input
          v-model="form.acceptTerms"
          type="checkbox"
          required
          class="w-4 h-4 text-yellow-500 bg-dark-800 border-dark-600 rounded focus:ring-yellow-500 focus:ring-2 mt-1"
        >
        <label class="ml-2 text-sm text-gray-300">
          Tôi đồng ý với 
          <a href="#" class="text-yellow-500 hover:text-yellow-400">Điều khoản sử dụng</a>
          và 
          <a href="#" class="text-yellow-500 hover:text-yellow-400">Chính sách bảo mật</a>
        </label>
      </div>

      <!-- Submit Button -->
      <button
        type="submit"
        :disabled="authStore.loading"
        class="w-full btn btn-primary"
      >
        <span v-if="authStore.loading" class="spinner mr-2"></span>
        {{ authStore.loading ? 'Đang đăng ký...' : 'Đăng ký' }}
      </button>
    </form>

    <!-- Login Link -->
    <div class="mt-6 text-center">
      <p class="text-gray-400">
        Đã có tài khoản?
        <router-link 
          to="/auth/login" 
          class="text-yellow-500 hover:text-yellow-400 font-medium"
        >
          Đăng nhập ngay
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
  firstName: '',
  lastName: '',
  username: '',
  email: '',
  phone: '',
  password: '',
  confirmPassword: '',
  acceptTerms: false
})

const handleRegister = async () => {
  // Validate form
  if (form.password !== form.confirmPassword) {
    toast.error('Mật khẩu xác nhận không khớp')
    return
  }

  if (!form.acceptTerms) {
    toast.error('Vui lòng đồng ý với điều khoản sử dụng')
    return
  }

  try {
    const result = await authStore.register({
      firstName: form.firstName,
      lastName: form.lastName,
      username: form.username,
      email: form.email,
      phone: form.phone,
      password: form.password
    })

    if (result.success) {
      toast.success('Đăng ký thành công!')
      router.push('/')
    } else {
      toast.error(result.error)
    }
  } catch (error) {
    console.error('Register error:', error)
    toast.error('Đăng ký thất bại. Vui lòng thử lại.')
  }
}
</script>
