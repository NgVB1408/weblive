<template>
  <div class="space-y-6">
    <!-- Page Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p class="text-gray-600">Tổng quan hệ thống livestream betting</p>
      </div>
      <div class="flex items-center space-x-3">
        <button class="btn btn-primary">
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
          </svg>
          Thêm trận đấu
        </button>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <div class="flex-shrink-0">
            <div class="w-8 h-8 bg-blue-500 rounded-md flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
              </svg>
            </div>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-500">Tổng người dùng</p>
            <p class="text-2xl font-semibold text-gray-900">{{ stats.totalUsers }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <div class="flex-shrink-0">
            <div class="w-8 h-8 bg-green-500 rounded-md flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
              </svg>
            </div>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-500">Trận đấu đang live</p>
            <p class="text-2xl font-semibold text-gray-900">{{ stats.liveMatches }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <div class="flex-shrink-0">
            <div class="w-8 h-8 bg-yellow-500 rounded-md flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"></path>
              </svg>
            </div>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-500">Tổng cược hôm nay</p>
            <p class="text-2xl font-semibold text-gray-900">{{ formatCurrency(stats.todayBets) }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
          <div class="flex-shrink-0">
            <div class="w-8 h-8 bg-purple-500 rounded-md flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"></path>
              </svg>
            </div>
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-500">Doanh thu hôm nay</p>
            <p class="text-2xl font-semibold text-gray-900">{{ formatCurrency(stats.todayRevenue) }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Charts Row -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Revenue Chart -->
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Doanh thu 7 ngày qua</h3>
        <div class="h-64">
          <canvas ref="revenueChart"></canvas>
        </div>
      </div>

      <!-- User Activity Chart -->
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Hoạt động người dùng</h3>
        <div class="h-64">
          <canvas ref="activityChart"></canvas>
        </div>
      </div>
    </div>

    <!-- Recent Activity -->
    <div class="bg-white rounded-lg shadow">
      <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-medium text-gray-900">Hoạt động gần đây</h3>
      </div>
      <div class="divide-y divide-gray-200">
        <div v-for="activity in recentActivities" :key="activity.id" class="px-6 py-4">
          <div class="flex items-center justify-between">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center">
                  <span class="text-sm font-medium text-gray-600">{{ activity.user.charAt(0) }}</span>
                </div>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-900">{{ activity.description }}</p>
                <p class="text-sm text-gray-500">{{ activity.time }}</p>
              </div>
            </div>
            <div class="flex items-center">
              <span class="text-sm font-medium" :class="activity.type === 'bet' ? 'text-green-600' : 'text-blue-600'">
                {{ activity.amount }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Chart, registerables } from 'chart.js'
import { formatCurrency } from '@/utils/helpers'

Chart.register(...registerables)

const revenueChart = ref(null)
const activityChart = ref(null)

const stats = ref({
  totalUsers: 1250,
  liveMatches: 8,
  todayBets: 2500000,
  todayRevenue: 125000
})

const recentActivities = ref([
  {
    id: 1,
    user: 'John Doe',
    description: 'Đặt cược 100,000 ៛ cho trận đấu A vs B',
    time: '2 phút trước',
    type: 'bet',
    amount: '+100,000 ៛'
  },
  {
    id: 2,
    user: 'Jane Smith',
    description: 'Nạp tiền vào ví',
    time: '5 phút trước',
    type: 'deposit',
    amount: '+500,000 ៛'
  },
  {
    id: 3,
    user: 'Mike Johnson',
    description: 'Đặt cược 50,000 ៛ cho trận đấu C vs D',
    time: '10 phút trước',
    type: 'bet',
    amount: '+50,000 ៛'
  }
])

onMounted(() => {
  // Initialize charts here
  // This would be implemented with Chart.js
})
</script>
