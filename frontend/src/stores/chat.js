import { defineStore } from 'pinia'
import socketService from '@/config/socket'

export const useChatStore = defineStore('chat', {
  state: () => ({
    messages: [],
    connected: false,
    currentMatchId: null,
  }),

  getters: {
    getMessages: (state) => state.messages,
    isConnected: (state) => state.connected,
  },

  actions: {
    // Initialize chat for match
    initChat(matchId) {
      this.currentMatchId = matchId
      this.messages = []
      this.setupChatListeners()
    },

    // Send chat message
    sendMessage(message) {
      if (!this.currentMatchId || !message.trim()) return
      
      socketService.sendChatMessage(this.currentMatchId, message)
    },

    // Setup socket listeners
    setupChatListeners() {
      socketService.on('new-chat-message', (message) => {
        this.messages.push({
          id: message.id || Date.now().toString(),
          username: message.username || 'Anonymous',
          message: message.message,
          timestamp: message.timestamp || new Date(),
          avatar: message.avatar || null
        })
        
        // Keep only last 100 messages
        if (this.messages.length > 100) {
          this.messages.shift()
        }
      })

      socketService.on('connect', () => {
        this.connected = true
      })

      socketService.on('disconnect', () => {
        this.connected = false
      })

      // User typing indicators
      socketService.on('user-typing', (data) => {
        // Handle typing indicators if needed
      })

      socketService.on('user-stopped-typing', (data) => {
        // Handle stop typing if needed
      })

      // Chat moderation
      socketService.on('message-moderated', (data) => {
        // Handle moderated messages if needed
      })

      socketService.on('chat-cleared', (data) => {
        if (data.matchId === this.currentMatchId) {
          this.messages = []
        }
      })
    },

    // Clear chat
    clearChat() {
      this.messages = []
      this.currentMatchId = null
    },
  },
})
