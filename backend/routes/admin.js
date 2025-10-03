import express from 'express'
import { body, validationResult } from 'express-validator'
import User from '../models/User.js'
import Match from '../models/Match.js'
import Bet from '../models/Bet.js'
import { authenticate, authorize } from '../middleware/auth.js'

const router = express.Router()

// @route   GET /api/v1/admin/dashboard
// @desc    Get admin dashboard data
// @access  Private (Admin)
router.get('/dashboard', [
  authenticate,
  authorize('admin'),
], async (req, res) => {
  try {
    // Get user statistics
    const userStats = await User.aggregate([
      {
        $group: {
          _id: null,
          totalUsers: { $sum: 1 },
          activeUsers: {
            $sum: { $cond: [{ $eq: ['$isActive', true] }, 1, 0] }
          },
          newUsersToday: {
            $sum: {
              $cond: [
                { $gte: ['$createdAt', new Date(new Date().setHours(0, 0, 0, 0))] },
                1,
                0
              ]
            }
          }
        }
      }
    ])

    // Get match statistics
    const matchStats = await Match.aggregate([
      {
        $group: {
          _id: null,
          totalMatches: { $sum: 1 },
          liveMatches: {
            $sum: { $cond: [{ $eq: ['$status', 'live'] }, 1, 0] }
          },
          upcomingMatches: {
            $sum: { $cond: [{ $eq: ['$status', 'scheduled'] }, 1, 0] }
          }
        }
      }
    ])

    // Get betting statistics
    const betStats = await Bet.aggregate([
      {
        $group: {
          _id: null,
          totalBets: { $sum: 1 },
          totalAmount: { $sum: '$amount' },
          totalWin: { $sum: '$actualWin' },
          pendingBets: {
            $sum: { $cond: [{ $eq: ['$status', 'pending'] }, 1, 0] }
          },
          wonBets: {
            $sum: { $cond: [{ $eq: ['$status', 'won'] }, 1, 0] }
          }
        }
      }
    ])

    // Get today's statistics
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    
    const todayBets = await Bet.aggregate([
      {
        $match: {
          placedAt: { $gte: today }
        }
      },
      {
        $group: {
          _id: null,
          count: { $sum: 1 },
          amount: { $sum: '$amount' }
        }
      }
    ])

    res.json({
      userStats: userStats[0] || {
        totalUsers: 0,
        activeUsers: 0,
        newUsersToday: 0
      },
      matchStats: matchStats[0] || {
        totalMatches: 0,
        liveMatches: 0,
        upcomingMatches: 0
      },
      betStats: betStats[0] || {
        totalBets: 0,
        totalAmount: 0,
        totalWin: 0,
        pendingBets: 0,
        wonBets: 0
      },
      todayStats: todayBets[0] || {
        count: 0,
        amount: 0
      }
    })
  } catch (error) {
    console.error('Get dashboard data error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   GET /api/v1/admin/transactions
// @desc    Get all transactions
// @access  Private (Admin)
router.get('/transactions', [
  authenticate,
  authorize('admin'),
], async (req, res) => {
  try {
    const { page = 1, limit = 20, type, status } = req.query
    
    // In a real app, you would have a Transaction model
    // For now, we'll return mock data
    const transactions = [
      {
        _id: '1',
        user: 'User 1',
        type: 'deposit',
        amount: 500000,
        status: 'completed',
        createdAt: new Date()
      },
      {
        _id: '2',
        user: 'User 2',
        type: 'withdraw',
        amount: 100000,
        status: 'pending',
        createdAt: new Date(Date.now() - 3600000)
      }
    ]

    res.json({
      transactions,
      totalPages: 1,
      currentPage: page,
      total: transactions.length
    })
  } catch (error) {
    console.error('Get transactions error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   GET /api/v1/admin/logs
// @desc    Get system logs
// @access  Private (Admin)
router.get('/logs', [
  authenticate,
  authorize('admin'),
], async (req, res) => {
  try {
    const { page = 1, limit = 50, level, startDate, endDate } = req.query
    
    // In a real app, you would have a Log model
    // For now, we'll return mock data
    const logs = [
      {
        _id: '1',
        level: 'info',
        message: 'User login successful',
        timestamp: new Date(),
        userId: 'user123'
      },
      {
        _id: '2',
        level: 'error',
        message: 'Database connection failed',
        timestamp: new Date(Date.now() - 3600000),
        userId: null
      }
    ]

    res.json({
      logs,
      totalPages: 1,
      currentPage: page,
      total: logs.length
    })
  } catch (error) {
    console.error('Get logs error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   POST /api/v1/admin/settings
// @desc    Update system settings
// @access  Private (Admin)
router.post('/settings', [
  authenticate,
  authorize('admin'),
  body('minBetAmount').optional().isNumeric().withMessage('Min bet amount must be a number'),
  body('maxBetAmount').optional().isNumeric().withMessage('Max bet amount must be a number'),
  body('defaultCurrency').optional().isString().withMessage('Default currency must be a string'),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg })
    }

    // In a real app, you would save settings to database
    const settings = {
      minBetAmount: req.body.minBetAmount || 1000,
      maxBetAmount: req.body.maxBetAmount || 1000000,
      defaultCurrency: req.body.defaultCurrency || 'KHR',
      updatedAt: new Date(),
      updatedBy: req.user._id
    }

    res.json({
      message: 'Settings updated successfully',
      settings
    })
  } catch (error) {
    console.error('Update settings error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   GET /api/v1/admin/settings
// @desc    Get system settings
// @access  Private (Admin)
router.get('/settings', [
  authenticate,
  authorize('admin'),
], async (req, res) => {
  try {
    // In a real app, you would get settings from database
    const settings = {
      minBetAmount: 1000,
      maxBetAmount: 1000000,
      defaultCurrency: 'KHR',
      siteName: 'Livestream Betting Platform',
      maintenanceMode: false
    }

    res.json({ settings })
  } catch (error) {
    console.error('Get settings error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

export default router
