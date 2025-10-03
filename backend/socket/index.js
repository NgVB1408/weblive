import { setupMatchHandlers } from './matchHandlers.js'
import { setupChatHandlers } from './chatHandlers.js'
import { setupBetHandlers } from './betHandlers.js'

export const setupSocketHandlers = (io) => {
  console.log('🔌 Setting up Socket.io handlers...')

  // Authentication middleware
  io.use((socket, next) => {
    const token = socket.handshake.auth.token
    
    if (!token) {
      return next(new Error('Authentication error'))
    }

    // Verify JWT token
    try {
      const jwt = require('jsonwebtoken')
      const decoded = jwt.verify(token, process.env.JWT_SECRET)
      socket.userId = decoded.userId
      next()
    } catch (error) {
      next(new Error('Authentication error'))
    }
  })

  io.on('connection', (socket) => {
    console.log(`✅ User connected: ${socket.id}`)

    // Join user to their personal room
    socket.join(`user:${socket.userId}`)

    // Setup handlers
    setupMatchHandlers(io, socket)
    setupChatHandlers(io, socket)
    setupBetHandlers(io, socket)

    socket.on('disconnect', (reason) => {
      console.log(`❌ User disconnected: ${socket.id}, reason: ${reason}`)
    })

    socket.on('error', (error) => {
      console.error(`Socket error for ${socket.id}:`, error)
    })
  })

  // Broadcast system-wide events
  setInterval(() => {
    io.emit('system-heartbeat', {
      timestamp: new Date().toISOString(),
      connectedUsers: io.engine.clientsCount
    })
  }, 30000) // Every 30 seconds
}
