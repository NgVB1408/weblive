<template>
  <div class="container mx-auto px-4 py-8">
    <!-- Header -->
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-3xl font-bold text-white">Lịch sử cược</h1>
        <p class="text-gray-400">Theo dõi tất cả các cược của bạn</p>
      </div>
      
      <div class="flex gap-4">
        <select v-model="statusFilter" class="input w-auto">
          <option value="">Tất cả trạng thái</option>
          <option value="pending">Đang chờ</option>
          <option value="won">Thắng</option>
          <option value="lost">Thua</option>
          <option value="cancelled">Hủy</option>
        </select>
        
        <select v-model="dateFilter" class="input w-auto">
          <option value="">Tất cả thời gian</option>
          <option value="today">Hôm nay</option>
          <option value="week">Tuần này</option>
          <option value="month">Tháng này</option>
        </select>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
      <div class="card text-center">
        <div class="text-2xl font-bold text-white mb-2">{{ betStats.totalBets }}</div>
        <div class="text-gray-400">Tổng cược</div>
      </div>
      
      <div class="card text-center">
        <div class="text-2xl font-bold text-green-400 mb-2">{{ betStats.wonBets }}</div>
        <div class="text-gray-400">Cược thắng</div>
      </div>
      
      <div class="card text-center">
        <div class="text-2xl font-bold text-red-400 mb-2">{{ betStats.lostBets }}</div>
        <div class="text-gray-400">Cược thua</div>
      </div>
      
      <div class="card text-center">
        <div class="text-2xl font-bold text-yellow-400 mb-2">{{ betStats.winRate }}%</div>
        <div class="text-gray-400">Tỷ lệ thắng</div>
      </div>
    </div>

    <!-- Bet History Table -->
    <div class="card">
      <div v-if="loading" class="text-center py-8">
        <div class="spinner mx-auto mb-4"></div>
        <p class="text-gray-400">Đang tải lịch sử cược...</p>
      </div>

      <div v-else-if="filteredBets.length === 0" class="text-center py-8">
        <svg class="w-16 h-16 mx-auto text-gray-500 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
        </svg>
        <p class="text-gray-400">Chưa có cược nào</p>
      </div>

      <div v-else class="overflow-x-auto">
        <table class="w-full">
          <thead>
            <tr class="border-b border-dark-700">
              <th class="text-left py-4 px-4 text-gray-400">Trận đấu</th>
              <th class="text-left py-4 px-4 text-gray-400">Lựa chọn</th>
              <th class="text-left py-4 px-4 text-gray-400">Số tiền</th>
              <th class="text-left py-4 px-4 text-gray-400">Tỷ lệ</th>
              <th class="text-left py-4 px-4 text-gray-400">Tiền thắng</th>
              <th class="text-left py-4 px-4 text-gray-400">Trạng thái</th>
              <th class="text-left py-4 px-4 text-gray-400">Thời gian</th>
              <th class="text-left py-4 px-4 text-gray-400">Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="bet in filteredBets" :key="bet._id" class="border-b border-dark-700 hover:bg-dark-800">
              <td class="py-4 px-4">
                <div>
                  <div class="font-semibold text-white">{{ bet.match?.title || 'N/A' }}</div>
                  <div class="text-sm text-gray-400">{{ bet.match?.teams?.home?.name }} vs {{ bet.match?.teams?.away?.name }}</div>
                </div>
              </td>
              
              <td class="py-4 px-4">
                <div class="font-medium text-white">{{ bet.bettingOption.name }}</div>
                <div class="text-sm text-gray-400">{{ getBetTypeText(bet.bettingOption.type) }}</div>
              </td>
              
              <td class="py-4 px-4">
                <div class="font-semibold text-white">{{ formatCurrency(bet.amount) }}</div>
              </td>
              
              <td class="py-4 px-4">
                <div class="font-semibold text-yellow-400">{{ formatOdds(bet.bettingOption.odds) }}</div>
              </td>
              
              <td class="py-4 px-4">
                <div class="font-semibold" :class="getWinAmountClass(bet.status)">
                  {{ bet.status === 'won' ? formatCurrency(bet.actualWin) : formatCurrency(bet.potentialWin) }}
                </div>
              </td>
              
              <td class="py-4 px-4">
                <span class="badge" :class="getBetStatusBadge(bet.status)">
                  {{ getBetStatusText(bet.status) }}
                </span>
              </td>
              
              <td class="py-4 px-4">
                <div class="text-sm text-gray-400">{{ formatDate(bet.placedAt) }}</div>
              </td>
              
              <td class="py-4 px-4">
                <div class="flex gap-2">
                  <button
                    v-if="bet.status === 'pending'"
                    @click="cancelBet(bet._id)"
                    class="text-red-400 hover:text-red-300 text-sm"
                  >
                    Hủy
                  </button>
                  <button
                    @click="viewBetDetails(bet)"
                    class="text-blue-400 hover:text-blue-300 text-sm"
                  >
                    Chi tiết
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Bet Details Modal -->
    <div v-if="selectedBet" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-dark-900 rounded-lg p-6 max-w-md w-full mx-4">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-bold text-white">Chi tiết cược</h3>
          <button @click="selectedBet = null" class="text-gray-400 hover:text-white">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
        
        <div class="space-y-4">
          <div>
            <label class="text-sm text-gray-400">Trận đấu</label>
            <div class="text-white font-semibold">{{ selectedBet.match?.title }}</div>
          </div>
          
          <div>
            <label class="text-sm text-gray-400">Lựa chọn</label>
            <div class="text-white font-semibold">{{ selectedBet.bettingOption.name }}</div>
          </div>
          
          <div>
            <label class="text-sm text-gray-400">Số tiền cược</label>
            <div class="text-white font-semibold">{{ formatCurrency(selectedBet.amount) }}</div>
          </div>
          
          <div>
            <label class="text-sm text-gray-400">Tỷ lệ cược</label>
            <div class="text-yellow-400 font-semibold">{{ formatOdds(selectedBet.bettingOption.odds) }}</div>
          </div>
          
          <div>
            <label class="text-sm text-gray-400">Tiền thắng dự kiến</label>
            <div class="text-green-400 font-semibold">{{ formatCurrency(selectedBet.potentialWin) }}</div>
          </div>
          
          <div>
            <label class="text-sm text-gray-400">Trạng thái</label>
            <div>
              <span class="badge" :class="getBetStatusBadge(selectedBet.status)">
                {{ getBetStatusText(selectedBet.status) }}
              </span>
            </div>
          </div>
          
          <div>
            <label class="text-sm text-gray-400">Thời gian đặt cược</label>
            <div class="text-white">{{ formatDate(selectedBet.placedAt) }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useBetStore } from '@/stores/bet'
import { formatCurrency, formatDate, formatOdds, getBetStatusBadge } from '@/utils/helpers'
import { useToast } from 'vue-toastification'

const betStore = useBetStore()
const toast = useToast()

const loading = ref(false)
const statusFilter = ref('')
const dateFilter = ref('')
const selectedBet = ref(null)

const betStats = ref({
  totalBets: 0,
  wonBets: 0,
  lostBets: 0,
  winRate: 0
})

const betHistory = ref([
  {
    _id: '1',
    match: {
      title: 'Manchester United vs Liverpool',
      teams: {
        home: { name: 'Manchester United' },
        away: { name: 'Liverpool' }
      }
    },
    bettingOption: {
      name: 'Manchester United thắng',
      type: 'win',
      odds: 2.5
    },
    amount: 100000,
    potentialWin: 250000,
    actualWin: 250000,
    status: 'won',
    placedAt: new Date()
  },
  {
    _id: '2',
    match: {
      title: 'Real Madrid vs Barcelona',
      teams: {
        home: { name: 'Real Madrid' },
        away: { name: 'Barcelona' }
      }
    },
    bettingOption: {
      name: 'Hòa',
      type: 'draw',
      odds: 3.2
    },
    amount: 50000,
    potentialWin: 160000,
    actualWin: 0,
    status: 'lost',
    placedAt: new Date(Date.now() - 3600000)
  },
  {
    _id: '3',
    match: {
      title: 'Chelsea vs Arsenal',
      teams: {
        home: { name: 'Chelsea' },
        away: { name: 'Arsenal' }
      }
    },
    bettingOption: {
      name: 'Chelsea thắng',
      type: 'win',
      odds: 2.1
    },
    amount: 75000,
    potentialWin: 157500,
    actualWin: 0,
    status: 'pending',
    placedAt: new Date(Date.now() - 7200000)
  }
])

const filteredBets = computed(() => {
  let filtered = betHistory.value

  if (statusFilter.value) {
    filtered = filtered.filter(bet => bet.status === statusFilter.value)
  }

  if (dateFilter.value) {
    const now = new Date()
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    
    filtered = filtered.filter(bet => {
      const betDate = new Date(bet.placedAt)
      
      switch (dateFilter.value) {
        case 'today':
          return betDate >= today
        case 'week':
          const weekAgo = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000)
          return betDate >= weekAgo
        case 'month':
          const monthAgo = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000)
          return betDate >= monthAgo
        default:
          return true
      }
    })
  }

  return filtered
})

const getBetTypeText = (type) => {
  const types = {
    win: 'Thắng',
    lose: 'Thua',
    draw: 'Hòa',
    over: 'Trên',
    under: 'Dưới'
  }
  return types[type] || type
}

const getBetStatusText = (status) => {
  const statuses = {
    pending: 'Đang chờ',
    won: 'Thắng',
    lost: 'Thua',
    cancelled: 'Hủy',
    refunded: 'Hoàn tiền'
  }
  return statuses[status] || status
}

const getWinAmountClass = (status) => {
  const classes = {
    won: 'text-green-400',
    lost: 'text-red-400',
    pending: 'text-yellow-400',
    cancelled: 'text-gray-400'
  }
  return classes[status] || 'text-gray-400'
}

const cancelBet = async (betId) => {
  try {
    const result = await betStore.cancelBet(betId)
    if (result.success) {
      const bet = betHistory.value.find(b => b._id === betId)
      if (bet) {
        bet.status = 'cancelled'
      }
    }
  } catch (error) {
    console.error('Cancel bet error:', error)
  }
}

const viewBetDetails = (bet) => {
  selectedBet.value = bet
}

const loadBetHistory = async () => {
  try {
    loading.value = true
    const result = await betStore.fetchBetHistory()
    if (result) {
      betHistory.value = result.bets || []
      betStats.value = result.stats || betStats.value
    }
  } catch (error) {
    console.error('Load bet history error:', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadBetHistory()
})
</script>
