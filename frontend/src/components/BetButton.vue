<template>
  <div class="betting-option">
    <div class="flex items-center justify-between p-4 bg-dark-800 rounded-lg border border-dark-600 hover:border-yellow-500 transition-colors">
      <div class="flex-1">
        <h4 class="font-semibold text-white mb-1">{{ option.name }}</h4>
        <p class="text-sm text-gray-400">{{ option.description || 'Đặt cược cho lựa chọn này' }}</p>
      </div>
      
      <div class="text-right ml-4">
        <div class="text-2xl font-bold text-yellow-500 mb-1">
          {{ formatOdds(option.odds) }}
        </div>
        <div class="text-xs text-gray-400">
          Tỷ lệ cược
        </div>
      </div>
    </div>

    <!-- Betting Form -->
    <div v-if="showBetForm" class="mt-4 p-4 bg-dark-900 rounded-lg border border-dark-700">
      <div class="space-y-4">
        <!-- Amount Input -->
        <div>
          <label class="block text-sm font-medium text-gray-300 mb-2">
            Số tiền cược
          </label>
          <div class="relative">
            <input
              v-model="betAmount"
              type="number"
              :min="option.minBet"
              :max="option.maxBet"
              class="input pr-20"
              placeholder="Nhập số tiền"
              @input="calculatePotentialWin"
            >
            <div class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 text-sm">
              ៛
            </div>
          </div>
          <div class="flex justify-between text-xs text-gray-500 mt-1">
            <span>Min: {{ formatCurrency(option.minBet) }}</span>
            <span>Max: {{ formatCurrency(option.maxBet) }}</span>
          </div>
        </div>

        <!-- Potential Win -->
        <div v-if="potentialWin > 0" class="bg-dark-800 rounded-lg p-3">
          <div class="flex justify-between items-center">
            <span class="text-gray-300">Tiền thắng dự kiến:</span>
            <span class="text-lg font-bold text-green-400">
              {{ formatCurrency(potentialWin) }}
            </span>
          </div>
        </div>

        <!-- Quick Amount Buttons -->
        <div class="grid grid-cols-4 gap-2">
          <button
            v-for="amount in quickAmounts"
            :key="amount"
            @click="setBetAmount(amount)"
            class="btn btn-secondary text-sm py-2"
            :class="{ 'btn-primary': betAmount === amount }"
          >
            {{ formatCurrency(amount) }}
          </button>
        </div>

        <!-- Action Buttons -->
        <div class="flex gap-2">
          <button
            @click="placeBet"
            :disabled="!canPlaceBet || placingBet"
            class="flex-1 btn btn-primary"
          >
            <span v-if="placingBet" class="spinner mr-2"></span>
            {{ placingBet ? 'Đang đặt cược...' : 'Đặt cược' }}
          </button>
          <button
            @click="cancelBet"
            class="btn btn-secondary"
          >
            Hủy
          </button>
        </div>
      </div>
    </div>

    <!-- Place Bet Button -->
    <button
      v-else
      @click="showBetForm = true"
      :disabled="!canBet"
      class="w-full mt-4 btn"
      :class="canBet ? 'btn-primary' : 'btn-secondary opacity-50 cursor-not-allowed'"
    >
      {{ canBet ? 'Đặt cược' : 'Không thể đặt cược' }}
    </button>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useBetStore } from '@/stores/bet'
import { useAuthStore } from '@/stores/auth'
import { formatCurrency, formatOdds, calculatePotentialWin as calcPotentialWin } from '@/utils/helpers'
import { useToast } from 'vue-toastification'

const props = defineProps({
  option: {
    type: Object,
    required: true
  },
  match: {
    type: Object,
    required: true
  }
})

const betStore = useBetStore()
const authStore = useAuthStore()
const toast = useToast()

const showBetForm = ref(false)
const betAmount = ref(0)
const potentialWin = ref(0)
const placingBet = ref(false)

const quickAmounts = [1000, 5000, 10000, 50000]

const canBet = computed(() => {
  return props.option.isActive && 
         props.match.status === 'live' && 
         authStore.isAuthenticated &&
         authStore.balance >= props.option.minBet
})

const canPlaceBet = computed(() => {
  return betAmount.value >= props.option.minBet &&
         betAmount.value <= props.option.maxBet &&
         betAmount.value <= authStore.balance
})

const setBetAmount = (amount) => {
  betAmount.value = amount
  calculatePotentialWin()
}

const calculatePotentialWin = () => {
  if (betAmount.value > 0) {
    potentialWin.value = calcPotentialWin(betAmount.value, props.option.odds)
  } else {
    potentialWin.value = 0
  }
}

const placeBet = async () => {
  if (!canPlaceBet.value) return

  try {
    placingBet.value = true

    const betData = {
      matchId: props.match._id,
      bettingOption: {
        type: props.option.type,
        name: props.option.name,
        odds: props.option.odds
      },
      amount: betAmount.value
    }

    const result = await betStore.placeBet(betData)

    if (result.success) {
      toast.success('Đặt cược thành công!')
      showBetForm.value = false
      betAmount.value = 0
      potentialWin.value = 0
    } else {
      toast.error(result.error)
    }
  } catch (error) {
    console.error('Place bet error:', error)
    toast.error('Có lỗi xảy ra khi đặt cược')
  } finally {
    placingBet.value = false
  }
}

const cancelBet = () => {
  showBetForm.value = false
  betAmount.value = 0
  potentialWin.value = 0
}
</script>
