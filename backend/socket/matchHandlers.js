import Match from '../models/Match.js'

export const setupMatchHandlers = (io, socket) => {
  // Join match room
  socket.on('join-match', async (matchId) => {
    try {
      const match = await Match.findById(matchId)
      if (!match) {
        socket.emit('error', { message: 'Match not found' })
        return
      }

      socket.join(`match:${matchId}`)
      socket.currentMatch = matchId

      // Notify others that user joined
      socket.to(`match:${matchId}`).emit('user-joined', {
        userId: socket.userId,
        timestamp: new Date()
      })

      // Send current match data
      socket.emit('match-data', match)

      console.log(`User ${socket.userId} joined match ${matchId}`)
    } catch (error) {
      console.error('Join match error:', error)
      socket.emit('error', { message: 'Failed to join match' })
    }
  })

  // Leave match room
  socket.on('leave-match', (matchId) => {
    socket.leave(`match:${matchId}`)
    socket.currentMatch = null

    // Notify others that user left
    socket.to(`match:${matchId}`).emit('user-left', {
      userId: socket.userId,
      timestamp: new Date()
    })

    console.log(`User ${socket.userId} left match ${matchId}`)
  })

  // Update match status
  socket.on('update-match-status', async (data) => {
    try {
      const { matchId, status } = data
      
      const match = await Match.findByIdAndUpdate(
        matchId,
        { status },
        { new: true }
      )

      if (match) {
        // Broadcast to all users in the match room
        io.to(`match:${matchId}`).emit('match-status-updated', {
          matchId,
          status,
          match
        })

        // Broadcast to all users if it's a featured match
        if (match.isFeatured) {
          io.emit('featured-match-updated', match)
        }
      }
    } catch (error) {
      console.error('Update match status error:', error)
      socket.emit('error', { message: 'Failed to update match status' })
    }
  })

  // Update match odds
  socket.on('update-match-odds', async (data) => {
    try {
      const { matchId, bettingOptions } = data
      
      const match = await Match.findByIdAndUpdate(
        matchId,
        { bettingOptions },
        { new: true }
      )

      if (match) {
        // Broadcast to all users in the match room
        io.to(`match:${matchId}`).emit('odds-updated', {
          matchId,
          bettingOptions
        })
      }
    } catch (error) {
      console.error('Update match odds error:', error)
      socket.emit('error', { message: 'Failed to update match odds' })
    }
  })

  // Update viewer count
  socket.on('update-viewer-count', async (matchId) => {
    try {
      const viewerCount = io.sockets.adapter.rooms.get(`match:${matchId}`)?.size || 0
      
      // Update match stats
      await Match.findByIdAndUpdate(matchId, {
        'stats.currentViewers': viewerCount
      })

      // Broadcast to all users in the match room
      io.to(`match:${matchId}`).emit('viewer-count-updated', {
        matchId,
        viewerCount
      })
    } catch (error) {
      console.error('Update viewer count error:', error)
    }
  })

  // Handle match events
  socket.on('match-event', async (data) => {
    try {
      const { matchId, event, data: eventData } = data
      
      // Broadcast match event to all users in the room
      io.to(`match:${matchId}`).emit('match-event', {
        matchId,
        event,
        data: eventData,
        timestamp: new Date()
      })

      // If it's a goal or important event, also broadcast to all users
      if (['goal', 'red_card', 'penalty'].includes(event)) {
        io.emit('important-match-event', {
          matchId,
          event,
          data: eventData,
          timestamp: new Date()
        })
      }
    } catch (error) {
      console.error('Match event error:', error)
      socket.emit('error', { message: 'Failed to process match event' })
    }
  })
}
