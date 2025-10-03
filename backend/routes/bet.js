import express from 'express'
import { body, validationResult } from 'express-validator'
import Bet from '../models/Bet.js'
import Match from '../models/Match.js'
import User from '../models/User.js'
import { authenticate } from '../middleware/auth.js'

const router = express.Router()

// @route   POST /api/v1/bets/place
// @desc    Place a bet
// @access  Private
router.post('/place', [
  authenticate,
  body('matchId').notEmpty().withMessage('Match ID is required'),
  body('bettingOption.type').notEmpty().withMessage('Betting option type is required'),
  body('bettingOption.name').notEmpty().withMessage('Betting option name is required'),
  body('bettingOption.odds').isNumeric().withMessage('Odds must be a number'),
  body('amount').isNumeric().withMessage('Amount must be a number'),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg })
    }

    const { matchId, bettingOption, amount } = req.body

    // Find match
    const match = await Match.findById(matchId)
    if (!match) {
      return res.status(404).json({ error: 'Match not found' })
    }

    // Check if betting is allowed
    if (match.status !== 'live' && match.status !== 'scheduled') {
      return res.status(400).json({ error: 'Betting is not allowed for this match' })
    }

    // Check if betting option is active
    const option = match.bettingOptions.find(opt => 
      opt.type === bettingOption.type && 
      opt.name === bettingOption.name && 
      opt.isActive
    )

    if (!option) {
      return res.status(400).json({ error: 'Betting option not available' })
    }

    // Validate amount
    if (amount < option.minBet || amount > option.maxBet) {
      return res.status(400).json({ 
        error: `Amount must be between ${option.minBet} and ${option.maxBet}` 
      })
    }

    // Check user balance
    const user = await User.findById(req.user._id)
    if (user.wallet.balance < amount) {
      return res.status(400).json({ error: 'Insufficient balance' })
    }

    // Create bet
    const bet = new Bet({
      user: req.user._id,
      match: matchId,
      bettingOption: {
        type: bettingOption.type,
        name: bettingOption.name,
        odds: bettingOption.odds
      },
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
    
    if (bettingOption.type === 'win') {
      match.stats.homeBets += 1
    } else if (bettingOption.type === 'lose') {
      match.stats.awayBets += 1
    }
    
    await match.save()

    // Populate bet with match and user data
    await bet.populate('match', 'title teams status')
    await bet.populate('user', 'username')

    res.status(201).json({
      message: 'Bet placed successfully',
      bet,
      wallet: {
        balance: user.wallet.balance,
        currency: user.wallet.currency
      }
    })
  } catch (error) {
    console.error('Place bet error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   GET /api/v1/bets/active
// @desc    Get user's active bets
// @access  Private
router.get('/active', authenticate, async (req, res) => {
  try {
    const bets = await Bet.find({ 
      user: req.user._id, 
      status: 'pending' 
    })
    .populate('match', 'title teams status startTime')
    .sort({ placedAt: -1 })

    res.json({ bets })
  } catch (error) {
    console.error('Get active bets error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   GET /api/v1/bets/history
// @desc    Get user's bet history
// @access  Private
router.get('/history', authenticate, async (req, res) => {
  try {
    const { page = 1, limit = 20, status } = req.query
    const query = { user: req.user._id }
    
    if (status) {
      query.status = status
    }

    const bets = await Bet.find(query)
      .populate('match', 'title teams status')
      .sort({ placedAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)

    const total = await Bet.countDocuments(query)

    res.json({
      bets,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    })
  } catch (error) {
    console.error('Get bet history error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   GET /api/v1/bets/stats
// @desc    Get user's betting statistics
// @access  Private
router.get('/stats', authenticate, async (req, res) => {
  try {
    const stats = await Bet.aggregate([
      { $match: { user: req.user._id } },
      {
        $group: {
          _id: null,
          totalBets: { $sum: 1 },
          totalAmount: { $sum: '$amount' },
          totalWin: { $sum: '$actualWin' },
          wonBets: {
            $sum: { $cond: [{ $eq: ['$status', 'won'] }, 1, 0] }
          },
          lostBets: {
            $sum: { $cond: [{ $eq: ['$status', 'lost'] }, 1, 0] }
          },
          pendingBets: {
            $sum: { $cond: [{ $eq: ['$status', 'pending'] }, 1, 0] }
          }
        }
      }
    ])

    const result = stats[0] || {
      totalBets: 0,
      totalAmount: 0,
      totalWin: 0,
      wonBets: 0,
      lostBets: 0,
      pendingBets: 0
    }

    result.winRate = result.totalBets > 0 ? 
      ((result.wonBets / result.totalBets) * 100).toFixed(1) : 0

    result.profit = result.totalWin - result.totalAmount

    res.json({ stats: result })
  } catch (error) {
    console.error('Get bet stats error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   DELETE /api/v1/bets/:id/cancel
// @desc    Cancel a bet
// @access  Private
router.delete('/:id/cancel', authenticate, async (req, res) => {
  try {
    const bet = await Bet.findOne({ 
      _id: req.params.id, 
      user: req.user._id, 
      status: 'pending' 
    })

    if (!bet) {
      return res.status(404).json({ error: 'Bet not found or cannot be cancelled' })
    }

    // Check if match is still bettable
    const match = await Match.findById(bet.match)
    if (match.status === 'live') {
      return res.status(400).json({ error: 'Cannot cancel bet on live match' })
    }

    // Cancel bet
    bet.status = 'cancelled'
    bet.settledAt = new Date()
    await bet.save()

    // Refund user
    const user = await User.findById(req.user._id)
    user.wallet.balance += bet.amount
    await user.save()

    // Update match stats
    match.stats.totalBets -= 1
    match.stats.totalAmount -= bet.amount
    
    if (bet.bettingOption.type === 'win') {
      match.stats.homeBets -= 1
    } else if (bet.bettingOption.type === 'lose') {
      match.stats.awayBets -= 1
    }
    
    await match.save()

    res.json({
      message: 'Bet cancelled successfully',
      newBalance: user.wallet.balance
    })
  } catch (error) {
    console.error('Cancel bet error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   GET /api/v1/bets/:id
// @desc    Get single bet
// @access  Private
router.get('/:id', authenticate, async (req, res) => {
  try {
    const bet = await Bet.findOne({ 
      _id: req.params.id, 
      user: req.user._id 
    })
    .populate('match', 'title teams status startTime')
    .populate('user', 'username')

    if (!bet) {
      return res.status(404).json({ error: 'Bet not found' })
    }

    res.json({ bet })
  } catch (error) {
    console.error('Get bet error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

export default router
