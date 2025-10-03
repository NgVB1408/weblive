<template>
  <div class="container mx-auto px-4 py-8">
    <!-- Hero Section -->
    <section class="text-center mb-12">
      <h1 class="text-4xl md:text-6xl font-bold gradient-text mb-4">
        Livestream Betting
      </h1>
      <p class="text-xl text-gray-400 mb-8">
        Xem trực tiếp và đặt cược trên các trận đấu hấp dẫn
      </p>
    </section>

    <!-- Live Matches -->
    <section class="mb-12">
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-2xl font-bold text-white flex items-center gap-2">
          <span class="live-dot"></span>
          Trận đấu đang live
        </h2>
        <router-link 
          to="/matches" 
          class="text-yellow-500 hover:text-yellow-400 transition-colors"
        >
          Xem tất cả →
        </router-link>
      </div>
      
      <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="i in 3" :key="i" class="card skeleton h-48"></div>
      </div>
      
      <div v-else-if="liveMatches.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <MatchCard 
          v-for="match in liveMatches" 
          :key="match._id"
          :match="match"
          @click="goToMatch(match._id)"
        />
      </div>
      
      <div v-else class="text-center py-12">
        <p class="text-gray-500">Không có trận đấu nào đang live</p>
      </div>
    </section>

    <!-- Upcoming Matches -->
    <section class="mb-12">
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-2xl font-bold text-white">
          Trận đấu sắp diễn ra
        </h2>
        <router-link 
          to="/matches" 
          class="text-yellow-500 hover:text-yellow-400 transition-colors"
        >
          Xem tất cả →
        </router-link>
      </div>
      
      <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="i in 3" :key="i" class="card skeleton h-48"></div>
      </div>
      
      <div v-else-if="upcomingMatches.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <MatchCard 
          v-for="match in upcomingMatches" 
          :key="match._id"
          :match="match"
          @click="goToMatch(match._id)"
        />
      </div>
      
      <div v-else class="text-center py-12">
        <p class="text-gray-500">Không có trận đấu nào sắp diễn ra</p>
      </div>
    </section>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useMatchStore } from '@/stores/match'
import MatchCard from '@/components/MatchCard.vue'

const router = useRouter()
const matchStore = useMatchStore()

const liveMatches = ref([])
const upcomingMatches = ref([])
const loading = ref(true)

onMounted(async () => {
  try {
    loading.value = true
    
    // Fetch live matches
    const live = await matchStore.fetchLiveMatches()
    liveMatches.value = live || []
    
    // Fetch upcoming matches
    const upcoming = await matchStore.fetchUpcomingMatches()
    upcomingMatches.value = upcoming || []
    
  } catch (error) {
    console.error('Error fetching matches:', error)
  } finally {
    loading.value = false
  }
})

const goToMatch = (matchId) => {
  router.push(`/live/${matchId}`)
}
</script>
