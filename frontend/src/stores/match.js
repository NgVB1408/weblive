import { defineStore } from 'pinia'
import api from '@/config/api'
import socketService from '@/config/socket'

export const useMatchStore = defineStore('match', {
  state: () => ({
    matches: [],
    liveMatches: [],
    upcomingMatches: [],
    featuredMatches: [],
    currentMatch: null,
    loading: false,
    error: null,
    viewerCounts: {},
  }),

  getters: {
    getLiveMatches: (state) => state.liveMatches,
    getUpcomingMatches: (state) => state.upcomingMatches,
    getFeaturedMatches: (state) => state.featuredMatches,
    getMatchById: (state) => (id) => state.matches.find(m => m._id === id),
    
    getCurrentMatchViewers: (state) => {
      if (!state.currentMatch) return 0
      return state.viewerCounts[state.currentMatch._id] || state.currentMatch.stats?.currentViewers || 0
    },
  },

  actions: {
    // Fetch all matches with filters
    async fetchMatches(filters = {}) {
      try {
        this.loading = true
        const { data } = await api.get('/matches', { params: filters })
        this.matches = data.matches
        return data
      } catch (error) {
        console.error('Fetch matches error:', error)
        this.error = error.message
        return null
      } finally {
        this.loading = false
      }
    },

    // Fetch live matches
    async fetchLiveMatches() {
      try {
        const { data } = await api.get('/matches/live')
        this.liveMatches = data.matches
        return data.matches
      } catch (error) {
        console.error('Fetch live matches error:', error)
        return []
      }
    },

    // Fetch upcoming matches
    async fetchUpcomingMatches() {
      try {
        const { data } = await api.get('/matches/upcoming')
        this.upcomingMatches = data.matches
        return data.matches
      } catch (error) {
        console.error('Fetch upcoming matches error:', error)
        return []
      }
    },

    // Fetch featured matches
    async fetchFeaturedMatches() {
      try {
        const { data } = await api.get('/matches/featured')
        this.featuredMatches = data.matches
        return data.matches
      } catch (error) {
        console.error('Fetch featured matches error:', error)
        return []
      }
    },

    // Fetch single match
    async fetchMatch(id) {
      try {
        this.loading = true
        const { data } = await api.get(`/matches/${id}`)
        this.currentMatch = data.match
        return data.match
      } catch (error) {
        console.error('Fetch match error:', error)
        this.error = error.message
        return null
      } finally {
        this.loading = false
      }
    },

    // Join match room (socket)
    joinMatchRoom(matchId) {
      socketService.joinMatch(matchId)
      this.setupMatchListeners(matchId)
    },

    // Leave match room (socket)
    leaveMatchRoom(matchId) {
      socketService.leaveMatch(matchId)
      this.removeMatchListeners()
    },

    // Setup socket listeners for match
    setupMatchListeners(matchId) {
      // Viewer count updated
      socketService.on('viewer-count-updated', (data) => {
        if (data.matchId === matchId) {
          this.viewerCounts[matchId] = data.viewerCount
          
          if (this.currentMatch?._id === matchId) {
            this.currentMatch.stats.currentViewers = data.viewerCount
          }
        }
      })

      // Odds updated
      socketService.on('odds-updated', (data) => {
        if (data.matchId === matchId && this.currentMatch?._id === matchId) {
          this.currentMatch.bettingOptions = data.bettingOptions
        }
      })

      // Match updated
      socketService.on('match-updated', (match) => {
        if (match._id === matchId) {
          this.currentMatch = match
        }
      })

      // Match started
      socketService.on('match-started', (data) => {
        if (data.matchId === matchId) {
          this.currentMatch = data.match
        }
      })

      // Match ended
      socketService.on('match-ended', (data) => {
        if (data.matchId === matchId && this.currentMatch) {
          this.currentMatch.status = 'finished'
          this.currentMatch.result = data.result
        }
      })

      // Match stats updated
      socketService.on('match-stats-updated', (data) => {
        if (data.matchId === matchId && this.currentMatch) {
          this.currentMatch.stats = data.stats
        }
      })
    },

    // Remove socket listeners
    removeMatchListeners() {
      socketService.off('viewer-count-updated')
      socketService.off('odds-updated')
      socketService.off('match-updated')
      socketService.off('match-started')
      socketService.off('match-ended')
      socketService.off('match-stats-updated')
    },

    // Update match odds locally (real-time)
    updateMatchOdds(matchId, bettingOptions) {
      if (this.currentMatch?._id === matchId) {
        this.currentMatch.bettingOptions = bettingOptions
      }
      
      const matchIndex = this.matches.findIndex(m => m._id === matchId)
      if (matchIndex !== -1) {
        this.matches[matchIndex].bettingOptions = bettingOptions
      }
    },

    // Clear current match
    clearCurrentMatch() {
      if (this.currentMatch) {
        this.leaveMatchRoom(this.currentMatch._id)
      }
      this.currentMatch = null
    },
  },
})
