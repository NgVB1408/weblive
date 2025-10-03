<template>
  <div class="min-h-screen bg-dark-950">
    <!-- Header with match info -->
    <div class="bg-dark-900 border-b border-dark-700">
      <div class="container mx-auto px-4 py-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-4">
            <router-link to="/" class="text-yellow-500 hover:text-yellow-400">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
              </svg>
            </router-link>
            <div>
              <h1 class="text-xl font-bold text-white">{{ match?.title || 'Loading...' }}</h1>
              <div class="flex items-center gap-4 text-sm text-gray-400">
                <span>{{ match?.teams?.home?.name }} vs {{ match?.teams?.away?.name }}</span>
                <span v-if="match?.status === 'live'" class="live-indicator">
                  <span class="live-dot"></span>
                  LIVE
                </span>
              </div>
            </div>
          </div>
          
          <div class="flex items-center gap-4">
            <div class="text-right">
              <div class="text-sm text-gray-400">Người xem</div>
              <div class="text-lg font-bold text-yellow-500">{{ formatNumber(viewerCount) }}</div>
            </div>
            <div v-if="authStore.isAuthenticated" class="text-right">
              <div class="text-sm text-gray-400">Số dư</div>
              <div class="text-lg font-bold text-green-400">{{ formatCurrency(authStore.balance) }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="container mx-auto px-4 py-6">
      <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
        <!-- Main Video Area -->
        <div class="lg:col-span-3">
          <div class="space-y-6">
            <!-- Video Player -->
            <div class="card">
              <LivestreamPlayer
                :stream-url="match?.streamUrl || defaultStreamUrl"
                :match="match"
                :viewer-count="viewerCount"
                :is-live="match?.status === 'live'"
                @error="handleVideoError"
              />
            </div>

            <!-- Match Stats -->
            <div v-if="match" class="card">
              <h3 class="text-lg font-bold text-white mb-4">Thống kê trận đấu</h3>
              <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div class="text-center">
                  <div class="text-2xl font-bold text-white">{{ match.stats?.homeBets || 0 }}</div>
                  <div class="text-sm text-gray-400">Cược đội nhà</div>
                </div>
                <div class="text-center">
                  <div class="text-2xl font-bold text-white">{{ match.stats?.awayBets || 0 }}</div>
                  <div class="text-sm text-gray-400">Cược đội khách</div>
                </div>
                <div class="text-center">
                  <div class="text-2xl font-bold text-white">{{ formatCurrency(match.stats?.totalAmount || 0) }}</div>
                  <div class="text-sm text-gray-400">Tổng cược</div>
                </div>
                <div class="text-center">
                  <div class="text-2xl font-bold text-white">{{ match.stats?.totalBets || 0 }}</div>
                  <div class="text-sm text-gray-400">Số cược</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Sidebar -->
        <div class="space-y-6">
          <!-- Betting Panel -->
          <div v-if="match && match.bettingOptions" class="card">
            <h3 class="text-lg font-bold text-white mb-4">Đặt cược</h3>
            <div class="space-y-3">
              <BetButton
                v-for="option in match.bettingOptions"
                :key="option._id"
                :option="option"
                :match="match"
                @bet-placed="handleBetPlaced"
              />
            </div>
          </div>

          <!-- Chat Panel -->
          <div v-if="enableChat" class="card">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-bold text-white">Chat trực tiếp</h3>
              <div class="flex items-center gap-2 text-sm text-gray-400">
                <div class="w-2 h-2 bg-green-500 rounded-full"></div>
                {{ chatStore.messages.length }} tin nhắn
              </div>
            </div>
            
            <div class="chat-container">
              <div class="chat-messages" ref="chatMessages">
                <div
                  v-for="message in chatStore.messages"
                  :key="message.id"
                  class="chat-message"
                >
                  <div class="flex items-start gap-2">
                    <img
                      :src="message.avatar || '/default-avatar.png'"
                      :alt="message.username"
                      class="w-6 h-6 rounded-full"
                    >
                    <div class="flex-1">
                      <div class="flex items-center gap-2">
                        <span class="font-semibold text-white">{{ message.username }}</span>
                        <span class="text-xs text-gray-400">{{ formatTime(message.timestamp) }}</span>
                      </div>
                      <p class="text-gray-300 text-sm">{{ message.message }}</p>
                    </div>
                  </div>
                </div>
              </div>
              
              <div v-if="authStore.isAuthenticated" class="chat-input">
                <form @submit.prevent="sendMessage" class="flex gap-2">
                  <input
                    v-model="chatMessage"
                    type="text"
                    placeholder="Nhập tin nhắn..."
                    class="flex-1 input text-sm"
                    maxlength="200"
                  >
                  <button
                    type="submit"
                    :disabled="!chatMessage.trim()"
                    class="btn btn-primary text-sm"
                  >
                    Gửi
                  </button>
                </form>
              </div>
              
              <div v-else class="chat-input text-center py-4">
                <p class="text-gray-400 text-sm">
                  <router-link to="/auth/login" class="text-yellow-500 hover:text-yellow-400">
                    Đăng nhập
                  </router-link>
                  để tham gia chat
                </p>
              </div>
            </div>
          </div>

          <!-- Quick Stats -->
          <div class="card">
            <h3 class="text-lg font-bold text-white mb-4">Thống kê nhanh</h3>
            <div class="space-y-3">
              <div class="flex justify-between">
                <span class="text-gray-400">Trạng thái:</span>
                <span class="font-semibold" :class="getMatchStatusColor(match?.status)">
                  {{ getMatchStatusText(match?.status) }}
                </span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-400">Bắt đầu:</span>
                <span class="text-white">{{ formatDate(match?.startTime) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-400">Thể loại:</span>
                <span class="text-white">{{ match?.category }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { useMatchStore } from '@/stores/match'
import { useAuthStore } from '@/stores/auth'
import { useChatStore } from '@/stores/chat'
import { useBetStore } from '@/stores/bet'
import LivestreamPlayer from '@/components/LivestreamPlayer.vue'
import BetButton from '@/components/BetButton.vue'
import { formatNumber, formatCurrency, formatDate, getMatchStatusColor, getMatchStatusText } from '@/utils/helpers'
import { useToast } from 'vue-toastification'

const route = useRoute()
const matchStore = useMatchStore()
const authStore = useAuthStore()
const chatStore = useChatStore()
const betStore = useBetStore()
const toast = useToast()

const match = ref(null)
const viewerCount = ref(0)
const chatMessage = ref('')
const enableChat = ref(true)
const defaultStreamUrl = import.meta.env.VITE_DEFAULT_STREAM_URL

const loadMatch = async () => {
  try {
    const matchId = route.params.id
    const matchData = await matchStore.fetchMatch(matchId)
    match.value = matchData
    
    if (matchData) {
      // Join match room for real-time updates
      matchStore.joinMatchRoom(matchId)
      
      // Initialize chat
      chatStore.initChat(matchId)
      
      // Update viewer count
      viewerCount.value = matchData.stats?.currentViewers || 0
    }
  } catch (error) {
    console.error('Load match error:', error)
    toast.error('Không thể tải thông tin trận đấu')
  }
}

const sendMessage = () => {
  if (!chatMessage.value.trim()) return
  
  chatStore.sendMessage(chatMessage.value)
  chatMessage.value = ''
  
  // Scroll to bottom
  nextTick(() => {
    const chatMessages = document.querySelector('.chat-messages')
    if (chatMessages) {
      chatMessages.scrollTop = chatMessages.scrollHeight
    }
  })
}

const handleBetPlaced = (bet) => {
  toast.success('Đặt cược thành công!')
  // Refresh match data to update stats
  loadMatch()
}

const handleVideoError = (error) => {
  console.error('Video error:', error)
  toast.error('Lỗi phát video: ' + error)
}


const formatTime = (timestamp) => {
  return new Date(timestamp).toLocaleTimeString('vi-VN', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

onMounted(() => {
  loadMatch()
})

onUnmounted(() => {
  if (match.value) {
    matchStore.leaveMatchRoom(match.value._id)
    chatStore.clearChat()
  }
})
</script>
