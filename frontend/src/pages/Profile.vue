<template>
  <div class="container mx-auto px-4 py-8">
    <!-- Profile Header -->
    <div class="bg-gradient-to-r from-dark-900 to-dark-800 rounded-lg p-6 mb-8">
      <div class="flex items-center justify-between">
        <div class="flex items-center space-x-4">
          <img 
            :src="authStore.userAvatar" 
            :alt="authStore.username"
            class="w-16 h-16 rounded-full border-2 border-yellow-500"
          >
          <div>
            <h1 class="text-2xl font-bold text-white">{{ authStore.username }}</h1>
            <p class="text-gray-400">{{ authStore.user?.email }}</p>
            <div class="flex items-center gap-2 mt-1">
              <span class="badge" :class="getRoleBadge(authStore.user?.role)">
                {{ getRoleText(authStore.user?.role) }}
              </span>
              <span v-if="authStore.user?.isVerified" class="badge badge-success">
                Đã xác thực
              </span>
            </div>
          </div>
        </div>
        
        <div class="text-right">
          <div class="text-sm text-gray-400">Số dư hiện tại</div>
          <div class="text-2xl font-bold text-yellow-500">
            {{ formatCurrency(authStore.balance, authStore.currency) }}
          </div>
        </div>
      </div>
    </div>

    <!-- Profile Content -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <!-- Profile Information -->
      <div class="lg:col-span-2">
        <div class="card">
          <h2 class="text-xl font-bold text-white mb-6">Thông tin cá nhân</h2>
          
          <form @submit.prevent="updateProfile" class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-300 mb-2">
                  Họ
                </label>
                <input
                  v-model="profileForm.firstName"
                  type="text"
                  class="input"
                >
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-300 mb-2">
                  Tên
                </label>
                <input
                  v-model="profileForm.lastName"
                  type="text"
                  class="input"
                >
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-300 mb-2">
                Email
              </label>
              <input
                v-model="profileForm.email"
                type="email"
                class="input"
                disabled
              >
              <p class="text-xs text-gray-500 mt-1">Email không thể thay đổi</p>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-300 mb-2">
                Số điện thoại
              </label>
              <input
                v-model="profileForm.phone"
                type="tel"
                class="input"
              >
            </div>

            <div class="flex gap-4">
              <button
                type="submit"
                :disabled="updating"
                class="btn btn-primary"
              >
                <span v-if="updating" class="spinner mr-2"></span>
                {{ updating ? 'Đang cập nhật...' : 'Cập nhật' }}
              </button>
              <button
                type="button"
                @click="resetForm"
                class="btn btn-secondary"
              >
                Hủy
              </button>
            </div>
          </form>
        </div>

        <!-- Change Password -->
        <div class="card mt-6">
          <h2 class="text-xl font-bold text-white mb-6">Đổi mật khẩu</h2>
          
          <form @submit.prevent="changePassword" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-300 mb-2">
                Mật khẩu hiện tại
              </label>
              <input
                v-model="passwordForm.currentPassword"
                type="password"
                class="input"
                required
              >
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-300 mb-2">
                Mật khẩu mới
              </label>
              <input
                v-model="passwordForm.newPassword"
                type="password"
                class="input"
                required
              >
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-300 mb-2">
                Xác nhận mật khẩu mới
              </label>
              <input
                v-model="passwordForm.confirmPassword"
                type="password"
                class="input"
                required
              >
            </div>

            <button
              type="submit"
              :disabled="changingPassword"
              class="btn btn-primary"
            >
              <span v-if="changingPassword" class="spinner mr-2"></span>
              {{ changingPassword ? 'Đang đổi mật khẩu...' : 'Đổi mật khẩu' }}
            </button>
          </form>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="space-y-6">
        <!-- Quick Stats -->
        <div class="card">
          <h3 class="text-lg font-bold text-white mb-4">Thống kê nhanh</h3>
          <div class="space-y-3">
            <div class="flex justify-between">
              <span class="text-gray-400">Tổng cược:</span>
              <span class="text-white font-semibold">{{ formatCurrency(betStats.totalBets) }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-400">Cược thắng:</span>
              <span class="text-green-400 font-semibold">{{ betStats.wonBets }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-400">Tỷ lệ thắng:</span>
              <span class="text-yellow-400 font-semibold">{{ betStats.winRate }}%</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-400">Lợi nhuận:</span>
              <span class="text-blue-400 font-semibold">{{ formatCurrency(betStats.profit) }}</span>
            </div>
          </div>
        </div>

        <!-- Quick Actions -->
        <div class="card">
          <h3 class="text-lg font-bold text-white mb-4">Thao tác nhanh</h3>
          <div class="space-y-2">
            <router-link to="/wallet" class="btn btn-secondary w-full text-center">
              Quản lý ví
            </router-link>
            <router-link to="/bets" class="btn btn-secondary w-full text-center">
              Lịch sử cược
            </router-link>
            <button @click="logout" class="btn btn-danger w-full">
              Đăng xuất
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useBetStore } from '@/stores/bet'
import { formatCurrency } from '@/utils/helpers'
import { useToast } from 'vue-toastification'

const router = useRouter()
const authStore = useAuthStore()
const betStore = useBetStore()
const toast = useToast()

const updating = ref(false)
const changingPassword = ref(false)

const profileForm = reactive({
  firstName: '',
  lastName: '',
  email: '',
  phone: ''
})

const passwordForm = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const betStats = ref({
  totalBets: 0,
  wonBets: 0,
  winRate: 0,
  profit: 0
})

const getRoleBadge = (role) => {
  const badges = {
    admin: 'badge-danger',
    moderator: 'badge-warning',
    user: 'badge-info'
  }
  return badges[role] || 'badge-info'
}

const getRoleText = (role) => {
  const texts = {
    admin: 'Quản trị viên',
    moderator: 'Điều hành viên',
    user: 'Người dùng'
  }
  return texts[role] || 'Người dùng'
}

const resetForm = () => {
  profileForm.firstName = authStore.user?.firstName || ''
  profileForm.lastName = authStore.user?.lastName || ''
  profileForm.email = authStore.user?.email || ''
  profileForm.phone = authStore.user?.phone || ''
}

const updateProfile = async () => {
  try {
    updating.value = true
    const result = await authStore.updateProfile(profileForm)
    
    if (result.success) {
      toast.success('Cập nhật thông tin thành công!')
    } else {
      toast.error(result.error)
    }
  } catch (error) {
    console.error('Update profile error:', error)
    toast.error('Có lỗi xảy ra khi cập nhật thông tin')
  } finally {
    updating.value = false
  }
}

const changePassword = async () => {
  if (passwordForm.newPassword !== passwordForm.confirmPassword) {
    toast.error('Mật khẩu xác nhận không khớp')
    return
  }

  try {
    changingPassword.value = true
    const result = await authStore.changePassword({
      currentPassword: passwordForm.currentPassword,
      newPassword: passwordForm.newPassword
    })
    
    if (result.success) {
      toast.success('Đổi mật khẩu thành công!')
      passwordForm.currentPassword = ''
      passwordForm.newPassword = ''
      passwordForm.confirmPassword = ''
    } else {
      toast.error(result.error)
    }
  } catch (error) {
    console.error('Change password error:', error)
    toast.error('Có lỗi xảy ra khi đổi mật khẩu')
  } finally {
    changingPassword.value = false
  }
}

const logout = async () => {
  await authStore.logout()
  router.push('/')
}

const loadBetStats = async () => {
  try {
    const stats = await betStore.fetchBetStats()
    if (stats) {
      betStats.value = stats
    }
  } catch (error) {
    console.error('Load bet stats error:', error)
  }
}

onMounted(() => {
  resetForm()
  loadBetStats()
})
</script>
