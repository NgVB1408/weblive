import Bet from '../models/Bet.js'
import Match from '../models/Match.js'
import User from '../models/User.js'

export const setupBetHandlers = (io, socket) => {
  // Place bet
  socket.on('place-bet', async (data) => {
    try {
      const { matchId, bettingOption, amount } = data
      
      // Validate bet data
      if (!matchId || !bettingOption || !amount) {
        socket.emit('bet-error', { message: 'Invalid bet data' })
        return
      }

      // Find match
      const match = await Match.findById(matchId)
      if (!match) {
        socket.emit('bet-error', { message: 'Match not found' })
        return
      }

      // Check if betting is allowed
      if (match.status !== 'live' && match.status !== 'scheduled') {
        socket.emit('bet-error', { message: 'Betting is not allowed for this match' })
        return
      }

      // Check user balance
      const user = await User.findById(socket.userId)
      if (user.wallet.balance < amount) {
        socket.emit('bet-error', { message: 'Insufficient balance' })
        return
      }

      // Create bet
      const bet = new Bet({
        user: socket.userId,
        match: matchId,
        bettingOption,
        amount,
        potentialWin: Math.floor(amount * bettingOption.odds)
      })

      await bet.save()

      // Update user balance
      user.wallet.balance -= amount
      await user.save()

      // Update match stats
      match.stats.totalBets += 1
      match.stats.totalAmount += amount
      await match.save()

      // Emit bet placed event
      socket.emit('bet-placed', {
        bet,
        newBalance: user.wallet.balance
      })

      // Broadcast to match room
      io.to(`match:${matchId}`).emit('bet-activity', {
        type: 'bet-placed',
        userId: socket.userId,
        amount,
        bettingOption: bettingOption.name,
        timestamp: new Date()
      })

      console.log(`Bet placed by ${socket.userId} for match ${matchId}: ${amount}`)
    } catch (error) {
      console.error('Place bet error:', error)
      socket.emit('bet-error', { message: 'Failed to place bet' })
    }
  })

  // Cancel bet
  socket.on('cancel-bet', async (data) => {
    try {
      const { betId } = data
      
      const bet = await Bet.findOne({
        _id: betId,
        user: socket.userId,
        status: 'pending'
      })

      if (!bet) {
        socket.emit('bet-error', { message: 'Bet not found or cannot be cancelled' })
        return
      }

      // Check if match is still bettable
      const match = await Match.findById(bet.match)
      if (match.status === 'live') {
        socket.emit('bet-error', { message: 'Cannot cancel bet on live match' })
        return
      }

      // Cancel bet
      bet.status = 'cancelled'
      bet.settledAt = new Date()
      await bet.save()

      // Refund user
      const user = await User.findById(socket.userId)
      user.wallet.balance += bet.amount
      await user.save()

      // Update match stats
      match.stats.totalBets -= 1
      match.stats.totalAmount -= bet.amount
      await match.save()

      // Emit bet cancelled event
      socket.emit('bet-cancelled', {
        betId,
        newBalance: user.wallet.balance
      })

      console.log(`Bet ${betId} cancelled by ${socket.userId}`)
    } catch (error) {
      console.error('Cancel bet error:', error)
      socket.emit('bet-error', { message: 'Failed to cancel bet' })
    }
  })

  // Get user's active bets
  socket.on('get-active-bets', async () => {
    try {
      const bets = await Bet.find({
        user: socket.userId,
        status: 'pending'
      }).populate('match', 'title teams status')

      socket.emit('active-bets', bets)
    } catch (error) {
      console.error('Get active bets error:', error)
      socket.emit('bet-error', { message: 'Failed to get active bets' })
    }
  })

  // Settle bet (admin only)
  socket.on('settle-bet', async (data) => {
    try {
      const { betId, result } = data
      
      // Check if user has admin privileges
      if (!socket.isAdmin) {
        socket.emit('bet-error', { message: 'Insufficient privileges' })
        return
      }

      const bet = await Bet.findById(betId)
      if (!bet) {
        socket.emit('bet-error', { message: 'Bet not found' })
        return
      }

      // Determine if bet won
      let won = false
      if (bet.bettingOption.type === 'win') {
        won = result.winner === 'home'
      } else if (bet.bettingOption.type === 'lose') {
        won = result.winner === 'away'
      } else if (bet.bettingOption.type === 'draw') {
        won = result.winner === 'draw'
      }

      // Update bet status
      bet.status = won ? 'won' : 'lost'
      bet.actualWin = won ? bet.potentialWin : 0
      bet.settledAt = new Date()
      await bet.save()

      // Update user balance if won
      if (won) {
        const user = await User.findById(bet.user)
        user.wallet.balance += bet.actualWin
        await user.save()

        // Notify user
        io.to(`user:${bet.user}`).emit('bet-result', {
          betId,
          status: 'won',
          winAmount: bet.actualWin,
          newBalance: user.wallet.balance
        })
      } else {
        // Notify user
        io.to(`user:${bet.user}`).emit('bet-result', {
          betId,
          status: 'lost',
          winAmount: 0
        })
      }

      // Broadcast to match room
      io.to(`match:${bet.match}`).emit('bet-settled', {
        betId,
        status: bet.status,
        winAmount: bet.actualWin
      })

      console.log(`Bet ${betId} settled: ${bet.status}`)
    } catch (error) {
      console.error('Settle bet error:', error)
      socket.emit('bet-error', { message: 'Failed to settle bet' })
    }
  })
}
