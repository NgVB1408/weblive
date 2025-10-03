import express from 'express'
import { body, validationResult } from 'express-validator'
import User from '../models/User.js'
import { authenticate, authorize } from '../middleware/auth.js'

const router = express.Router()

// @route   GET /api/v1/users
// @desc    Get all users (Admin only)
// @access  Private (Admin)
router.get('/', [
  authenticate,
  authorize('admin'),
], async (req, res) => {
  try {
    const { page = 1, limit = 20, role, search } = req.query
    
    const query = {}
    if (role) query.role = role
    if (search) {
      query.$or = [
        { username: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { firstName: { $regex: search, $options: 'i' } },
        { lastName: { $regex: search, $options: 'i' } }
      ]
    }

    const users = await User.find(query)
      .select('-password')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)

    const total = await User.countDocuments(query)

    res.json({
      users,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    })
  } catch (error) {
    console.error('Get users error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   GET /api/v1/users/:id
// @desc    Get single user
// @access  Private (Admin/Moderator)
router.get('/:id', [
  authenticate,
  authorize('admin', 'moderator'),
], async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password')
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' })
    }

    res.json({ user })
  } catch (error) {
    console.error('Get user error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   PUT /api/v1/users/:id
// @desc    Update user
// @access  Private (Admin)
router.put('/:id', [
  authenticate,
  authorize('admin'),
  body('role').optional().isIn(['user', 'moderator', 'admin']).withMessage('Invalid role'),
  body('isActive').optional().isBoolean().withMessage('isActive must be boolean'),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg })
    }

    const user = await User.findById(req.params.id)
    if (!user) {
      return res.status(404).json({ error: 'User not found' })
    }

    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).select('-password')

    res.json({
      message: 'User updated successfully',
      user: updatedUser
    })
  } catch (error) {
    console.error('Update user error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   DELETE /api/v1/users/:id
// @desc    Delete user
// @access  Private (Admin)
router.delete('/:id', [
  authenticate,
  authorize('admin'),
], async (req, res) => {
  try {
    const user = await User.findById(req.params.id)
    if (!user) {
      return res.status(404).json({ error: 'User not found' })
    }

    // Soft delete
    user.isActive = false
    await user.save()

    res.json({ message: 'User deactivated successfully' })
  } catch (error) {
    console.error('Delete user error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   PUT /api/v1/users/:id/balance
// @desc    Update user balance
// @access  Private (Admin)
router.put('/:id/balance', [
  authenticate,
  authorize('admin'),
  body('amount').isNumeric().withMessage('Amount must be a number'),
  body('type').isIn(['add', 'subtract', 'set']).withMessage('Type must be add, subtract, or set'),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg })
    }

    const { amount, type } = req.body
    const user = await User.findById(req.params.id)
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' })
    }

    let newBalance = user.wallet.balance
    
    switch (type) {
      case 'add':
        newBalance += amount
        break
      case 'subtract':
        newBalance -= amount
        if (newBalance < 0) {
          return res.status(400).json({ error: 'Insufficient balance' })
        }
        break
      case 'set':
        newBalance = amount
        break
    }

    user.wallet.balance = newBalance
    await user.save()

    res.json({
      message: 'Balance updated successfully',
      newBalance: user.wallet.balance
    })
  } catch (error) {
    console.error('Update balance error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   GET /api/v1/users/:id/bets
// @desc    Get user's betting history
// @access  Private (Admin/Moderator)
router.get('/:id/bets', [
  authenticate,
  authorize('admin', 'moderator'),
], async (req, res) => {
  try {
    const { page = 1, limit = 20, status } = req.query
    
    const Bet = require('../models/Bet.js')
    const query = { user: req.params.id }
    if (status) query.status = status

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
    console.error('Get user bets error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   GET /api/v1/users/stats
// @desc    Get user statistics
// @access  Private (Admin)
router.get('/stats', [
  authenticate,
  authorize('admin'),
], async (req, res) => {
  try {
    const stats = await User.aggregate([
      {
        $group: {
          _id: null,
          totalUsers: { $sum: 1 },
          activeUsers: {
            $sum: { $cond: [{ $eq: ['$isActive', true] }, 1, 0] }
          },
          verifiedUsers: {
            $sum: { $cond: [{ $eq: ['$isVerified', true] }, 1, 0] }
          },
          totalBalance: { $sum: '$wallet.balance' },
          avgBalance: { $avg: '$wallet.balance' }
        }
      }
    ])

    const roleStats = await User.aggregate([
      {
        $group: {
          _id: '$role',
          count: { $sum: 1 }
        }
      }
    ])

    res.json({
      stats: stats[0] || {
        totalUsers: 0,
        activeUsers: 0,
        verifiedUsers: 0,
        totalBalance: 0,
        avgBalance: 0
      },
      roleStats
    })
  } catch (error) {
    console.error('Get user stats error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

export default router
