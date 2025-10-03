<template>
  <div 
    class="card-hover"
    @click="$emit('click')"
  >
    <!-- Match Header -->
    <div class="flex items-center justify-between mb-4">
      <div class="flex items-center gap-2">
        <span class="text-2xl">{{ getCategoryIcon(match.category) }}</span>
        <div>
          <h3 class="font-semibold text-white">{{ match.title }}</h3>
          <p class="text-sm text-gray-400">{{ match.category }}</p>
        </div>
      </div>
      
      <!-- Status Badge -->
      <div class="flex items-center gap-2">
        <span 
          v-if="match.status === 'live'"
          class="live-indicator"
        >
          <span class="live-dot"></span>
          LIVE
        </span>
        <span 
          v-else-if="match.status === 'scheduled'"
          class="badge badge-info"
        >
          Sắp diễn ra
        </span>
        <span 
          v-else-if="match.status === 'finished'"
          class="badge badge-warning"
        >
          Kết thúc
        </span>
      </div>
    </div>

    <!-- Teams -->
    <div class="flex items-center justify-between mb-4">
      <div class="flex items-center gap-3">
        <img 
          :src="match.teams.home.logo || '/default-team.png'" 
          :alt="match.teams.home.name"
          class="w-8 h-8 rounded-full bg-dark-700"
        >
        <span class="font-medium text-white">{{ match.teams.home.name }}</span>
      </div>
      
      <div class="text-center">
        <div class="text-2xl font-bold text-yellow-500">VS</div>
        <div class="text-xs text-gray-400">vs</div>
      </div>
      
      <div class="flex items-center gap-3">
        <span class="font-medium text-white">{{ match.teams.away.name }}</span>
        <img 
          :src="match.teams.away.logo || '/default-team.png'" 
          :alt="match.teams.away.name"
          class="w-8 h-8 rounded-full bg-dark-700"
        >
      </div>
    </div>

    <!-- Match Info -->
    <div class="space-y-2 mb-4">
      <div class="flex items-center justify-between text-sm">
        <span class="text-gray-400">Thời gian:</span>
        <span class="text-white">
          {{ formatDate(match.startTime, 'HH:mm') }}
        </span>
      </div>
      
      <div class="flex items-center justify-between text-sm">
        <span class="text-gray-400">Người xem:</span>
        <span class="text-white flex items-center gap-1">
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path d="M10 12a2 2 0 100-4 2 2 0 000 4z"></path>
            <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd"></path>
          </svg>
          {{ formatNumber(match.stats?.currentViewers || 0) }}
        </span>
      </div>
      
      <div class="flex items-center justify-between text-sm">
        <span class="text-gray-400">Tổng cược:</span>
        <span class="text-white">
          {{ formatCurrency(match.stats?.totalAmount || 0) }}
        </span>
      </div>
    </div>

    <!-- Betting Options Preview -->
    <div v-if="match.bettingOptions && match.bettingOptions.length > 0" class="mb-4">
      <h4 class="text-sm font-medium text-gray-400 mb-2">Tỷ lệ cược</h4>
      <div class="grid grid-cols-2 gap-2">
        <div 
          v-for="option in match.bettingOptions.slice(0, 2)" 
          :key="option._id"
          class="bg-dark-800 rounded-lg p-2 text-center"
        >
          <div class="text-xs text-gray-400 mb-1">{{ option.name }}</div>
          <div class="text-yellow-500 font-bold">{{ formatOdds(option.odds) }}</div>
        </div>
      </div>
    </div>

    <!-- Action Button -->
    <div class="flex gap-2">
      <button 
        v-if="match.status === 'live'"
        class="flex-1 btn btn-primary text-sm"
        @click.stop="goToMatch"
      >
        Xem trực tiếp
      </button>
      <button 
        v-else-if="match.status === 'scheduled'"
        class="flex-1 btn btn-secondary text-sm"
        @click.stop="goToMatch"
      >
        Xem chi tiết
      </button>
      <button 
        v-else
        class="flex-1 btn btn-secondary text-sm opacity-50 cursor-not-allowed"
        disabled
      >
        Đã kết thúc
      </button>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { formatDate, formatNumber, formatCurrency, formatOdds, getCategoryIcon } from '@/utils/helpers'

const router = useRouter()

defineProps({
  match: {
    type: Object,
    required: true
  }
})

defineEmits(['click'])

const goToMatch = () => {
  router.push(`/live/${props.match._id}`)
}
</script>
