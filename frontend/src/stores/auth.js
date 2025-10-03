import { defineStore } from 'pinia'
import api from '@/config/api'
import { storage } from '@/utils/helpers'
import socketService from '@/config/socket'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: storage.get('user') || null,
    token: storage.get('token') || null,
    refreshToken: storage.get('refreshToken') || null,
    isAuthenticated: !!storage.get('token'),
    loading: false,
  }),

  getters: {
    isAdmin: (state) => state.user?.role === 'admin',
    isModerator: (state) => ['admin', 'moderator'].includes(state.user?.role),
    username: (state) => state.user?.username || 'Guest',
    userAvatar: (state) => state.user?.avatar || 'https://ui-avatars.com/api/?name=User',
    balance: (state) => state.user?.wallet?.balance || 0,
    currency: (state) => state.user?.wallet?.currency || 'KHR',
  },

  actions: {
    // Register new user
    async register(userData) {
      try {
        this.loading = true
        const { data } = await api.post('/auth/register', userData)
        
        this.setAuthData(data)
        socketService.connect()
        
        return { success: true, user: data.user }
      } catch (error) {
        console.error('Register error:', error)
        return { 
          success: false, 
          error: error.response?.data?.error || 'Registration failed' 
        }
      } finally {
        this.loading = false
      }
    },

    // Login user
    async login(credentials) {
      try {
        this.loading = true
        const { data } = await api.post('/auth/login', credentials)
        
        this.setAuthData(data)
        socketService.connect()
        
        return { success: true, user: data.user }
      } catch (error) {
        console.error('Login error:', error)
        return { 
          success: false, 
          error: error.response?.data?.error || 'Login failed' 
        }
      } finally {
        this.loading = false
      }
    },

    // Logout user
    async logout() {
      try {
        if (this.token) {
          await api.post('/auth/logout', {
            refreshToken: this.refreshToken
          })
        }
      } catch (error) {
        console.error('Logout error:', error)
      } finally {
        this.clearAuthData()
        socketService.disconnect()
      }
    },

    // Refresh access token
    async refreshAccessToken() {
      try {
        const { data } = await api.post('/auth/refresh-token', {
          refreshToken: this.refreshToken
        })
        
        this.token = data.accessToken
        storage.set('token', data.accessToken)
        
        return data.accessToken
      } catch (error) {
        console.error('Refresh token error:', error)
        this.clearAuthData()
        throw error
      }
    },

    // Get user profile
    async fetchProfile() {
      try {
        const { data } = await api.get('/auth/profile')
        this.user = data.user
        storage.set('user', data.user)
        return data.user
      } catch (error) {
        console.error('Fetch profile error:', error)
        return null
      }
    },

    // Update user profile
    async updateProfile(profileData) {
      try {
        const { data } = await api.put('/auth/profile', profileData)
        this.user = data.user
        storage.set('user', data.user)
        return { success: true, user: data.user }
      } catch (error) {
        console.error('Update profile error:', error)
        return { 
          success: false, 
          error: error.response?.data?.error || 'Update failed' 
        }
      }
    },

    // Change password
    async changePassword(passwordData) {
      try {
        await api.post('/auth/change-password', passwordData)
        return { success: true }
      } catch (error) {
        console.error('Change password error:', error)
        return { 
          success: false, 
          error: error.response?.data?.error || 'Password change failed' 
        }
      }
    },

    // Set authentication data
    setAuthData(data) {
      this.user = data.user
      this.token = data.tokens.accessToken
      this.refreshToken = data.tokens.refreshToken
      this.isAuthenticated = true

      storage.set('user', data.user)
      storage.set('token', data.tokens.accessToken)
      storage.set('refreshToken', data.tokens.refreshToken)
    },

    // Clear authentication data
    clearAuthData() {
      this.user = null
      this.token = null
      this.refreshToken = null
      this.isAuthenticated = false

      storage.remove('user')
      storage.remove('token')
      storage.remove('refreshToken')
    },

    // Update wallet balance
    updateBalance(newBalance) {
      if (this.user) {
        this.user.wallet.balance = newBalance
        storage.set('user', this.user)
      }
    },
  },
})
