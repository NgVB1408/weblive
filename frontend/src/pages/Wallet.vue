<template>
  <div class="container mx-auto px-4 py-8">
    <!-- Wallet Header -->
    <div class="bg-gradient-to-r from-dark-900 to-dark-800 rounded-lg p-6 mb-8">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-3xl font-bold text-white mb-2">Ví điện tử</h1>
          <p class="text-gray-400">Quản lý số dư và giao dịch</p>
        </div>
        <div class="text-right">
          <div class="text-sm text-gray-400">Số dư hiện tại</div>
          <div class="text-4xl font-bold text-yellow-500">
            {{ formatCurrency(authStore.balance, authStore.currency) }}
          </div>
        </div>
      </div>
    </div>

    <!-- Wallet Actions -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
      <!-- Deposit -->
      <div class="card">
        <div class="flex items-center mb-4">
          <div class="w-12 h-12 bg-green-500 rounded-lg flex items-center justify-center mr-4">
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
            </svg>
          </div>
          <div>
            <h3 class="text-lg font-bold text-white">Nạp tiền</h3>
            <p class="text-gray-400">Thêm tiền vào ví</p>
          </div>
        </div>
        
        <form @submit.prevent="handleDeposit" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2">
              Số tiền nạp
            </label>
            <input
              v-model="depositForm.amount"
              type="number"
              :min="1000"
              class="input"
              placeholder="Nhập số tiền"
              required
            >
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2">
              Phương thức
            </label>
            <select v-model="depositForm.method" class="input" required>
              <option value="">Chọn phương thức</option>
              <option value="bank">Chuyển khoản ngân hàng</option>
              <option value="momo">Ví MoMo</option>
              <option value="zalopay">Ví ZaloPay</option>
            </select>
          </div>
          
          <button
            type="submit"
            :disabled="depositing"
            class="w-full btn btn-success"
          >
            <span v-if="depositing" class="spinner mr-2"></span>
            {{ depositing ? 'Đang xử lý...' : 'Nạp tiền' }}
          </button>
        </form>
      </div>

      <!-- Withdraw -->
      <div class="card">
        <div class="flex items-center mb-4">
          <div class="w-12 h-12 bg-red-500 rounded-lg flex items-center justify-center mr-4">
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4m16 0l-4-4m4 4l-4 4"></path>
            </svg>
          </div>
          <div>
            <h3 class="text-lg font-bold text-white">Rút tiền</h3>
            <p class="text-gray-400">Rút tiền từ ví</p>
          </div>
        </div>
        
        <form @submit.prevent="handleWithdraw" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2">
              Số tiền rút
            </label>
            <input
              v-model="withdrawForm.amount"
              type="number"
              :min="1000"
              :max="authStore.balance"
              class="input"
              placeholder="Nhập số tiền"
              required
            >
            <p class="text-xs text-gray-500 mt-1">
              Số dư khả dụng: {{ formatCurrency(authStore.balance) }}
            </p>
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2">
              Số tài khoản
            </label>
            <input
              v-model="withdrawForm.accountNumber"
              type="text"
              class="input"
              placeholder="Nhập số tài khoản"
              required
            >
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2">
              Tên ngân hàng
            </label>
            <select v-model="withdrawForm.bank" class="input" required>
              <option value="">Chọn ngân hàng</option>
              <option value="vietcombank">Vietcombank</option>
              <option value="techcombank">Techcombank</option>
              <option value="bidv">BIDV</option>
              <option value="agribank">Agribank</option>
            </select>
          </div>
          
          <button
            type="submit"
            :disabled="withdrawing"
            class="w-full btn btn-danger"
          >
            <span v-if="withdrawing" class="spinner mr-2"></span>
            {{ withdrawing ? 'Đang xử lý...' : 'Rút tiền' }}
          </button>
        </form>
      </div>
    </div>

    <!-- Transaction History -->
    <div class="card">
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-xl font-bold text-white">Lịch sử giao dịch</h2>
        <div class="flex gap-2">
          <select v-model="transactionFilter" class="input w-auto">
            <option value="">Tất cả</option>
            <option value="deposit">Nạp tiền</option>
            <option value="withdraw">Rút tiền</option>
            <option value="bet">Cược</option>
            <option value="win">Thắng cược</option>
          </select>
        </div>
      </div>

      <div v-if="loading" class="text-center py-8">
        <div class="spinner mx-auto mb-4"></div>
        <p class="text-gray-400">Đang tải lịch sử...</p>
      </div>

      <div v-else-if="transactions.length === 0" class="text-center py-8">
        <svg class="w-16 h-16 mx-auto text-gray-500 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
        </svg>
        <p class="text-gray-400">Chưa có giao dịch nào</p>
      </div>

      <div v-else class="space-y-4">
        <div
          v-for="transaction in filteredTransactions"
          :key="transaction._id"
          class="flex items-center justify-between p-4 bg-dark-800 rounded-lg border border-dark-700"
        >
          <div class="flex items-center">
            <div class="w-10 h-10 rounded-full flex items-center justify-center mr-4"
                 :class="getTransactionIconClass(transaction.type)">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path v-if="transaction.type === 'deposit'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                <path v-else-if="transaction.type === 'withdraw'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4m16 0l-4-4m4 4l-4 4"></path>
                <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"></path>
              </svg>
            </div>
            <div>
              <h4 class="font-semibold text-white">{{ getTransactionTitle(transaction.type) }}</h4>
              <p class="text-sm text-gray-400">{{ formatDate(transaction.createdAt) }}</p>
            </div>
          </div>
          
          <div class="text-right">
            <div class="font-bold" :class="getTransactionAmountClass(transaction.type)">
              {{ transaction.type === 'deposit' ? '+' : '-' }}{{ formatCurrency(transaction.amount) }}
            </div>
            <div class="text-sm" :class="getTransactionStatusClass(transaction.status)">
              {{ getTransactionStatusText(transaction.status) }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { formatCurrency, formatDate } from '@/utils/helpers'
import { useToast } from 'vue-toastification'

const authStore = useAuthStore()
const toast = useToast()

const loading = ref(false)
const depositing = ref(false)
const withdrawing = ref(false)
const transactionFilter = ref('')

const depositForm = reactive({
  amount: '',
  method: ''
})

const withdrawForm = reactive({
  amount: '',
  accountNumber: '',
  bank: ''
})

const transactions = ref([
  {
    _id: '1',
    type: 'deposit',
    amount: 500000,
    status: 'completed',
    createdAt: new Date()
  },
  {
    _id: '2',
    type: 'bet',
    amount: 100000,
    status: 'completed',
    createdAt: new Date(Date.now() - 3600000)
  },
  {
    _id: '3',
    type: 'win',
    amount: 250000,
    status: 'completed',
    createdAt: new Date(Date.now() - 7200000)
  }
])

const filteredTransactions = computed(() => {
  if (!transactionFilter.value) return transactions.value
  return transactions.value.filter(t => t.type === transactionFilter.value)
})

const getTransactionIconClass = (type) => {
  const classes = {
    deposit: 'bg-green-500 text-white',
    withdraw: 'bg-red-500 text-white',
    bet: 'bg-yellow-500 text-white',
    win: 'bg-blue-500 text-white'
  }
  return classes[type] || 'bg-gray-500 text-white'
}

const getTransactionTitle = (type) => {
  const titles = {
    deposit: 'Nạp tiền',
    withdraw: 'Rút tiền',
    bet: 'Đặt cược',
    win: 'Thắng cược'
  }
  return titles[type] || 'Giao dịch'
}

const getTransactionAmountClass = (type) => {
  const classes = {
    deposit: 'text-green-400',
    withdraw: 'text-red-400',
    bet: 'text-yellow-400',
    win: 'text-blue-400'
  }
  return classes[type] || 'text-gray-400'
}

const getTransactionStatusClass = (status) => {
  const classes = {
    completed: 'text-green-400',
    pending: 'text-yellow-400',
    failed: 'text-red-400'
  }
  return classes[status] || 'text-gray-400'
}

const getTransactionStatusText = (status) => {
  const texts = {
    completed: 'Hoàn thành',
    pending: 'Đang xử lý',
    failed: 'Thất bại'
  }
  return texts[status] || 'Không xác định'
}

const handleDeposit = async () => {
  try {
    depositing.value = true
    
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // Update balance
    authStore.updateBalance(authStore.balance + parseInt(depositForm.amount))
    
    // Add transaction
    transactions.value.unshift({
      _id: Date.now().toString(),
      type: 'deposit',
      amount: parseInt(depositForm.amount),
      status: 'completed',
      createdAt: new Date()
    })
    
    toast.success('Nạp tiền thành công!')
    depositForm.amount = ''
    depositForm.method = ''
  } catch (error) {
    console.error('Deposit error:', error)
    toast.error('Có lỗi xảy ra khi nạp tiền')
  } finally {
    depositing.value = false
  }
}

const handleWithdraw = async () => {
  if (parseInt(withdrawForm.amount) > authStore.balance) {
    toast.error('Số tiền rút vượt quá số dư')
    return
  }

  try {
    withdrawing.value = true
    
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // Update balance
    authStore.updateBalance(authStore.balance - parseInt(withdrawForm.amount))
    
    // Add transaction
    transactions.value.unshift({
      _id: Date.now().toString(),
      type: 'withdraw',
      amount: parseInt(withdrawForm.amount),
      status: 'pending',
      createdAt: new Date()
    })
    
    toast.success('Yêu cầu rút tiền đã được gửi!')
    withdrawForm.amount = ''
    withdrawForm.accountNumber = ''
    withdrawForm.bank = ''
  } catch (error) {
    console.error('Withdraw error:', error)
    toast.error('Có lỗi xảy ra khi rút tiền')
  } finally {
    withdrawing.value = false
  }
}

onMounted(() => {
  // Load transaction history
  loading.value = true
  setTimeout(() => {
    loading.value = false
  }, 1000)
})
</script>
