<template>
  <div class="container mx-auto px-4 py-8">
    <!-- Header -->
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-3xl font-bold text-white">Tất cả trận đấu</h1>
        <p class="text-gray-400">Xem và đặt cược trên các trận đấu hấp dẫn</p>
      </div>
      
      <div class="flex gap-4">
        <select v-model="categoryFilter" class="input w-auto">
          <option value="">Tất cả thể loại</option>
          <option value="sports">Thể thao</option>
          <option value="esports">Esports</option>
          <option value="casino">Casino</option>
          <option value="lottery">Xổ số</option>
        </select>
        
        <select v-model="statusFilter" class="input w-auto">
          <option value="">Tất cả trạng thái</option>
          <option value="live">Đang live</option>
          <option value="scheduled">Sắp diễn ra</option>
          <option value="finished">Đã kết thúc</option>
        </select>
      </div>
    </div>

    <!-- Featured Matches -->
    <section v-if="featuredMatches.length > 0" class="mb-12">
      <h2 class="text-2xl font-bold text-white mb-6 flex items-center gap-2">
        <span class="text-yellow-500">⭐</span>
        Trận đấu nổi bật
      </h2>
      
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <MatchCard
          v-for="match in featuredMatches"
          :key="match._id"
          :match="match"
          @click="goToMatch(match._id)"
        />
      </div>
    </section>

    <!-- Live Matches -->
    <section v-if="liveMatches.length > 0" class="mb-12">
      <h2 class="text-2xl font-bold text-white mb-6 flex items-center gap-2">
        <span class="live-dot"></span>
        Trận đấu đang live
      </h2>
      
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <MatchCard
          v-for="match in liveMatches"
          :key="match._id"
          :match="match"
          @click="goToMatch(match._id)"
        />
      </div>
    </section>

    <!-- Upcoming Matches -->
    <section v-if="upcomingMatches.length > 0" class="mb-12">
      <h2 class="text-2xl font-bold text-white mb-6">Trận đấu sắp diễn ra</h2>
      
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <MatchCard
          v-for="match in upcomingMatches"
          :key="match._id"
          :match="match"
          @click="goToMatch(match._id)"
        />
      </div>
    </section>

    <!-- All Matches Table View -->
    <div class="card">
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-xl font-bold text-white">Tất cả trận đấu</h2>
        <div class="flex gap-2">
          <button
            @click="viewMode = 'grid'"
            :class="viewMode === 'grid' ? 'btn btn-primary' : 'btn btn-secondary'"
            class="text-sm"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"></path>
            </svg>
          </button>
          <button
            @click="viewMode = 'list'"
            :class="viewMode === 'list' ? 'btn btn-primary' : 'btn btn-secondary'"
            class="text-sm"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 10h16M4 14h16M4 18h16"></path>
            </svg>
          </button>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="text-center py-12">
        <div class="spinner mx-auto mb-4"></div>
        <p class="text-gray-400">Đang tải trận đấu...</p>
      </div>

      <!-- Grid View -->
      <div v-else-if="viewMode === 'grid'" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <MatchCard
          v-for="match in filteredMatches"
          :key="match._id"
          :match="match"
          @click="goToMatch(match._id)"
        />
      </div>

      <!-- List View -->
      <div v-else class="space-y-4">
        <div
          v-for="match in filteredMatches"
          :key="match._id"
          class="flex items-center justify-between p-4 bg-dark-800 rounded-lg border border-dark-700 hover:border-yellow-500 transition-colors cursor-pointer"
          @click="goToMatch(match._id)"
        >
          <div class="flex items-center gap-4">
            <div class="text-2xl">{{ getCategoryIcon(match.category) }}</div>
            <div>
              <h3 class="font-semibold text-white">{{ match.title }}</h3>
              <p class="text-sm text-gray-400">{{ match.teams.home.name }} vs {{ match.teams.away.name }}</p>
            </div>
          </div>
          
          <div class="flex items-center gap-6">
            <div class="text-center">
              <div class="text-sm text-gray-400">Trạng thái</div>
              <div class="font-semibold" :class="getMatchStatusColor(match.status)">
                {{ getMatchStatusText(match.status) }}
              </div>
            </div>
            
            <div class="text-center">
              <div class="text-sm text-gray-400">Người xem</div>
              <div class="font-semibold text-white">{{ formatNumber(match.stats?.currentViewers || 0) }}</div>
            </div>
            
            <div class="text-center">
              <div class="text-sm text-gray-400">Tổng cược</div>
              <div class="font-semibold text-yellow-500">{{ formatCurrency(match.stats?.totalAmount || 0) }}</div>
            </div>
            
            <div class="text-right">
              <div class="text-sm text-gray-400">Thời gian</div>
              <div class="font-semibold text-white">{{ formatDate(match.startTime, 'HH:mm') }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-if="!loading && filteredMatches.length === 0" class="text-center py-12">
        <svg class="w-16 h-16 mx-auto text-gray-500 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
        </svg>
        <p class="text-gray-400">Không có trận đấu nào phù hợp</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useMatchStore } from '@/stores/match'
import MatchCard from '@/components/MatchCard.vue'
import { formatNumber, formatCurrency, formatDate, getMatchStatusColor, getCategoryIcon } from '@/utils/helpers'

const router = useRouter()
const matchStore = useMatchStore()

const loading = ref(false)
const categoryFilter = ref('')
const statusFilter = ref('')
const viewMode = ref('grid')

const allMatches = ref([])
const featuredMatches = ref([])
const liveMatches = ref([])
const upcomingMatches = ref([])

const filteredMatches = computed(() => {
  let filtered = allMatches.value

  if (categoryFilter.value) {
    filtered = filtered.filter(match => match.category === categoryFilter.value)
  }

  if (statusFilter.value) {
    filtered = filtered.filter(match => match.status === statusFilter.value)
  }

  return filtered
})

const getMatchStatusText = (status) => {
  const statuses = {
    scheduled: 'Sắp diễn ra',
    live: 'Đang live',
    paused: 'Tạm dừng',
    finished: 'Kết thúc',
    cancelled: 'Hủy'
  }
  return statuses[status] || 'Không xác định'
}

const goToMatch = (matchId) => {
  router.push(`/live/${matchId}`)
}

const loadMatches = async () => {
  try {
    loading.value = true
    
    // Load all matches
    const matches = await matchStore.fetchMatches()
    allMatches.value = matches?.matches || []
    
    // Load featured matches
    const featured = await matchStore.getFeaturedMatches()
    featuredMatches.value = featured || []
    
    // Load live matches
    const live = await matchStore.fetchLiveMatches()
    liveMatches.value = live || []
    
    // Load upcoming matches
    const upcoming = await matchStore.fetchUpcomingMatches()
    upcomingMatches.value = upcoming || []
    
  } catch (error) {
    console.error('Load matches error:', error)
  } finally {
    loading.value = false
  }
}

// Watch for filter changes
watch([categoryFilter, statusFilter], () => {
  // Filters are applied in computed property
})

onMounted(() => {
  loadMatches()
})
</script>
