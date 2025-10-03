export const setupChatHandlers = (io, socket) => {
  // Send chat message
  socket.on('chat-message', async (data) => {
    try {
      const { matchId, message } = data
      
      if (!matchId || !message) {
        socket.emit('error', { message: 'Match ID and message are required' })
        return
      }

      // Create chat message object
      const chatMessage = {
        id: Date.now().toString(),
        userId: socket.userId,
        username: socket.username || 'Anonymous',
        message: message.trim(),
        timestamp: new Date(),
        matchId
      }

      // Broadcast to all users in the match room
      io.to(`match:${matchId}`).emit('new-chat-message', chatMessage)

      console.log(`Chat message from ${socket.userId} in match ${matchId}: ${message}`)
    } catch (error) {
      console.error('Chat message error:', error)
      socket.emit('error', { message: 'Failed to send message' })
    }
  })

  // Join chat room
  socket.on('join-chat', (matchId) => {
    socket.join(`chat:${matchId}`)
    console.log(`User ${socket.userId} joined chat for match ${matchId}`)
  })

  // Leave chat room
  socket.on('leave-chat', (matchId) => {
    socket.leave(`chat:${matchId}`)
    console.log(`User ${socket.userId} left chat for match ${matchId}`)
  })

  // Typing indicator
  socket.on('typing-start', (data) => {
    const { matchId } = data
    socket.to(`chat:${matchId}`).emit('user-typing', {
      userId: socket.userId,
      username: socket.username || 'Anonymous',
      matchId
    })
  })

  socket.on('typing-stop', (data) => {
    const { matchId } = data
    socket.to(`chat:${matchId}`).emit('user-stopped-typing', {
      userId: socket.userId,
      matchId
    })
  })

  // Moderation actions
  socket.on('moderate-message', async (data) => {
    try {
      const { messageId, action } = data
      
      // Check if user has moderation privileges
      if (!socket.isModerator) {
        socket.emit('error', { message: 'Insufficient privileges' })
        return
      }

      // Broadcast moderation action
      io.emit('message-moderated', {
        messageId,
        action,
        moderatorId: socket.userId,
        timestamp: new Date()
      })

      console.log(`Message ${messageId} moderated by ${socket.userId}: ${action}`)
    } catch (error) {
      console.error('Moderate message error:', error)
      socket.emit('error', { message: 'Failed to moderate message' })
    }
  })

  // Clear chat
  socket.on('clear-chat', (data) => {
    try {
      const { matchId } = data
      
      // Check if user has moderation privileges
      if (!socket.isModerator) {
        socket.emit('error', { message: 'Insufficient privileges' })
        return
      }

      // Broadcast clear chat action
      io.to(`chat:${matchId}`).emit('chat-cleared', {
        matchId,
        moderatorId: socket.userId,
        timestamp: new Date()
      })

      console.log(`Chat cleared for match ${matchId} by ${socket.userId}`)
    } catch (error) {
      console.error('Clear chat error:', error)
      socket.emit('error', { message: 'Failed to clear chat' })
    }
  })
}
