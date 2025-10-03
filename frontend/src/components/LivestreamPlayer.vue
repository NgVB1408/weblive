<template>
  <div class="video-container">
    <!-- Video Player -->
    <video
      ref="videoPlayer"
      class="w-full h-full"
      controls
      autoplay
      muted
      playsinline
    >
      <source :src="streamUrl" type="application/x-mpegURL">
      Your browser does not support the video tag.
    </video>

    <!-- Video Overlay -->
    <div class="video-overlay">
      <!-- Live Indicator -->
      <div v-if="isLive" class="absolute top-4 left-4">
        <div class="live-indicator">
          <span class="live-dot"></span>
          LIVE
        </div>
      </div>

      <!-- Viewer Count -->
      <div v-if="viewerCount > 0" class="absolute top-4 right-4">
        <div class="bg-black bg-opacity-50 text-white px-3 py-1 rounded-full text-sm">
          <svg class="w-4 h-4 inline mr-1" fill="currentColor" viewBox="0 0 20 20">
            <path d="M10 12a2 2 0 100-4 2 2 0 000 4z"></path>
            <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd"></path>
          </svg>
          {{ formatNumber(viewerCount) }} người xem
        </div>
      </div>

      <!-- Match Info -->
      <div v-if="match" class="absolute bottom-4 left-4 right-4">
        <div class="bg-black bg-opacity-75 text-white p-4 rounded-lg">
          <div class="flex items-center justify-between mb-2">
            <h3 class="text-lg font-bold">{{ match.title }}</h3>
            <span class="text-sm text-gray-300">{{ match.category }}</span>
          </div>
          
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
              <div class="flex items-center gap-2">
                <img 
                  :src="match.teams.home.logo || '/default-team.png'" 
                  :alt="match.teams.home.name"
                  class="w-6 h-6 rounded-full"
                >
                <span class="font-medium">{{ match.teams.home.name }}</span>
              </div>
              
              <span class="text-2xl font-bold">VS</span>
              
              <div class="flex items-center gap-2">
                <span class="font-medium">{{ match.teams.away.name }}</span>
                <img 
                  :src="match.teams.away.logo || '/default-team.png'" 
                  :alt="match.teams.away.name"
                  class="w-6 h-6 rounded-full"
                >
              </div>
            </div>
            
            <div v-if="match.result" class="text-right">
              <div class="text-sm text-gray-300">Kết quả</div>
              <div class="text-lg font-bold">
                {{ match.result.score.home }} - {{ match.result.score.away }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div class="text-center text-white">
        <div class="spinner mb-4"></div>
        <p>Đang tải video...</p>
      </div>
    </div>

    <!-- Error State -->
    <div v-if="error" class="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div class="text-center text-white">
        <svg class="w-16 h-16 mx-auto mb-4 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <h3 class="text-lg font-bold mb-2">Lỗi phát video</h3>
        <p class="text-gray-300 mb-4">{{ error }}</p>
        <button @click="retry" class="btn btn-primary">
          Thử lại
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import Hls from 'hls.js'
import { formatNumber } from '@/utils/helpers'

const props = defineProps({
  streamUrl: {
    type: String,
    required: true
  },
  match: {
    type: Object,
    default: null
  },
  viewerCount: {
    type: Number,
    default: 0
  },
  isLive: {
    type: Boolean,
    default: true
  }
})

const videoPlayer = ref(null)
const loading = ref(true)
const error = ref(null)
let hls = null

const initializePlayer = () => {
  if (!videoPlayer.value) return

  loading.value = true
  error.value = null

  if (Hls.isSupported()) {
    // HLS is supported
    hls = new Hls({
      enableWorker: true,
      lowLatencyMode: true,
      backBufferLength: 90
    })
    
    hls.loadSource(props.streamUrl)
    hls.attachMedia(videoPlayer.value)
    
    hls.on(Hls.Events.MANIFEST_PARSED, () => {
      loading.value = false
      videoPlayer.value.play().catch(console.error)
    })
    
    hls.on(Hls.Events.ERROR, (event, data) => {
      console.error('HLS Error:', data)
      if (data.fatal) {
        error.value = 'Không thể phát video. Vui lòng thử lại.'
        loading.value = false
      }
    })
  } else if (videoPlayer.value.canPlayType('application/vnd.apple.mpegurl')) {
    // Native HLS support (Safari)
    videoPlayer.value.src = props.streamUrl
    videoPlayer.value.addEventListener('loadeddata', () => {
      loading.value = false
    })
    videoPlayer.value.addEventListener('error', () => {
      error.value = 'Không thể phát video. Vui lòng thử lại.'
      loading.value = false
    })
  } else {
    error.value = 'Trình duyệt không hỗ trợ phát video HLS.'
    loading.value = false
  }
}

const retry = () => {
  if (hls) {
    hls.destroy()
    hls = null
  }
  initializePlayer()
}

const cleanup = () => {
  if (hls) {
    hls.destroy()
    hls = null
  }
}

// Watch for stream URL changes
watch(() => props.streamUrl, () => {
  cleanup()
  initializePlayer()
}, { immediate: true })

onMounted(() => {
  initializePlayer()
})

onUnmounted(() => {
  cleanup()
})
</script>
