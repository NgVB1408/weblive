import { io } from 'socket.io-client'
import { useAuthStore } from '@/stores/auth'

class SocketService {
  constructor() {
    this.socket = null
    this.connected = false
  }
  
  connect() {
    const authStore = useAuthStore()
    
    if (this.socket?.connected) {
      return this.socket
    }
    
    this.socket = io(import.meta.env.VITE_SOCKET_URL, {
      auth: {
        token: authStore.token || null
      },
      transports: ['websocket', 'polling'],
      reconnection: true,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 5000,
      reconnectionAttempts: 5,
    })
    
    this.socket.on('connect', () => {
      console.log('✅ Socket connected:', this.socket.id)
      this.connected = true
    })
    
    this.socket.on('disconnect', (reason) => {
      console.log('❌ Socket disconnected:', reason)
      this.connected = false
    })
    
    this.socket.on('connect_error', (error) => {
      console.error('Socket connection error:', error)
    })
    
    this.socket.on('error', (error) => {
      console.error('Socket error:', error)
    })
    
    return this.socket
  }
  
  disconnect() {
    if (this.socket) {
      this.socket.disconnect()
      this.socket = null
      this.connected = false
    }
  }
  
  emit(event, data) {
    if (this.socket?.connected) {
      this.socket.emit(event, data)
    }
  }
  
  on(event, callback) {
    if (this.socket) {
      this.socket.on(event, callback)
    }
  }
  
  off(event, callback) {
    if (this.socket) {
      this.socket.off(event, callback)
    }
  }
  
  joinMatch(matchId) {
    this.emit('join-match', matchId)
  }
  
  leaveMatch(matchId) {
    this.emit('leave-match', matchId)
  }
  
  sendChatMessage(matchId, message) {
    this.emit('chat-message', { matchId, message })
  }
}

export default new SocketService()
