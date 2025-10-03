import { defineStore } from 'pinia'
import api from '@/config/api'
import { useAuthStore } from './auth'
import { useToast } from 'vue-toastification'

const toast = useToast()

export const useBetStore = defineStore('bet', {
  state: () => ({
    activeBets: [],
    betHistory: [],
    betStats: null,
    loading: false,
    placingBet: false,
  }),

  getters: {
    pendingBets: (state) => state.activeBets.filter(b => b.status === 'pending'),
    totalPendingAmount: (state) => {
      return state.activeBets
        .filter(b => b.status === 'pending')
        .reduce((sum, b) => sum + b.amount, 0)
    },
    totalPotentialWin: (state) => {
      return state.activeBets
        .filter(b => b.status === 'pending')
        .reduce((sum, b) => sum + b.potentialWin, 0)
    },
    winRate: (state) => {
      if (!state.betStats) return 0
      return state.betStats.winRate || 0
    },
  },

  actions: {
    // Place a bet
    async placeBet(betData) {
      try {
        this.placingBet = true
        const authStore = useAuthStore()

        const { data } = await api.post('/bets/place', betData)
        
        // Update local state
        this.activeBets.unshift(data.bet)
        
        // Update user balance
        authStore.updateBalance(data.wallet.balance)
        
        toast.success('Bet placed successfully!')
        return { success: true, bet: data.bet }
      } catch (error) {
        console.error('Place bet error:', error)
        const errorMsg = error.response?.data?.error || 'Failed to place bet'
        toast.error(errorMsg)
        return { success: false, error: errorMsg }
      } finally {
        this.placingBet = false
      }
    },

    // Fetch active bets
    async fetchActiveBets() {
      try {
        const { data } = await api.get('/bets/active')
        this.activeBets = data.bets
        return data.bets
      } catch (error) {
        console.error('Fetch active bets error:', error)
        return []
      }
    },

    // Fetch bet history
    async fetchBetHistory(params = {}) {
      try {
        this.loading = true
        const { data } = await api.get('/bets/history', { params })
        this.betHistory = data.bets
        return data
      } catch (error) {
        console.error('Fetch bet history error:', error)
        return null
      } finally {
        this.loading = false
      }
    },

    // Fetch bet statistics
    async fetchBetStats() {
      try {
        const { data } = await api.get('/bets/stats')
        this.betStats = data.stats
        return data.stats
      } catch (error) {
        console.error('Fetch bet stats error:', error)
        return null
      }
    },

    // Cancel a bet
    async cancelBet(betId) {
      try {
        const { data } = await api.delete(`/bets/${betId}/cancel`)
        
        // Update local state
        const betIndex = this.activeBets.findIndex(b => b._id === betId)
        if (betIndex !== -1) {
          this.activeBets[betIndex].status = 'cancelled'
        }
        
        // Update user balance
        const authStore = useAuthStore()
        authStore.updateBalance(data.newBalance)
        
        toast.success('Bet cancelled successfully!')
        return { success: true }
      } catch (error) {
        console.error('Cancel bet error:', error)
        const errorMsg = error.response?.data?.error || 'Failed to cancel bet'
        toast.error(errorMsg)
        return { success: false, error: errorMsg }
      }
    },

    // Listen for bet result (socket)
    setupBetListeners(socketService) {
      socketService.on('bet-result', (data) => {
        const betIndex = this.activeBets.findIndex(b => b._id === data.betId)
        if (betIndex !== -1) {
          this.activeBets[betIndex].status = data.status
          this.activeBets[betIndex].actualWin = data.winAmount
          
          if (data.status === 'won') {
            toast.success(`You won ${data.winAmount}!`)
          } else if (data.status === 'lost') {
            toast.error('Bet lost')
          }
        }
        
        // Refresh stats
        this.fetchBetStats()
      })
    },

    // Clear bet data
    clearBets() {
      this.activeBets = []
      this.betHistory = []
      this.betStats = null
    },
  },
})
