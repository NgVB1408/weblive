import express from 'express'
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
import { body, validationResult } from 'express-validator'
import User from '../models/User.js'
import { authenticate } from '../middleware/auth.js'

const router = express.Router()

// Generate JWT tokens
const generateTokens = (userId) => {
  const accessToken = jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRE || '15m' }
  )
  
  const refreshToken = jwt.sign(
    { userId },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRE || '7d' }
  )
  
  return { accessToken, refreshToken }
}

// @route   POST /api/v1/auth/register
// @desc    Register user
// @access  Public
router.post('/register', [
  body('firstName').notEmpty().withMessage('First name is required'),
  body('lastName').notEmpty().withMessage('Last name is required'),
  body('username').isLength({ min: 3 }).withMessage('Username must be at least 3 characters'),
  body('email').isEmail().withMessage('Please include a valid email'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg })
    }

    const { firstName, lastName, username, email, password, phone } = req.body

    // Check if user exists
    const existingUser = await User.findOne({
      $or: [{ email }, { username }]
    })

    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' })
    }

    // Create user
    const user = new User({
      firstName,
      lastName,
      username,
      email,
      password,
      phone,
      wallet: {
        balance: 0,
        currency: 'KHR'
      }
    })

    await user.save()

    // Generate tokens
    const tokens = generateTokens(user._id)

    res.status(201).json({
      message: 'User registered successfully',
      user: {
        _id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        username: user.username,
        email: user.email,
        phone: user.phone,
        role: user.role,
        wallet: user.wallet,
        createdAt: user.createdAt
      },
      tokens
    })
  } catch (error) {
    console.error('Register error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   POST /api/v1/auth/login
// @desc    Login user
// @access  Public
router.post('/login', [
  body('email').isEmail().withMessage('Please include a valid email'),
  body('password').notEmpty().withMessage('Password is required'),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg })
    }

    const { email, password } = req.body

    // Find user
    const user = await User.findOne({ email }).select('+password')
    if (!user) {
      return res.status(400).json({ error: 'Invalid credentials' })
    }

    // Check if account is locked
    if (user.isLocked) {
      return res.status(423).json({ error: 'Account is temporarily locked' })
    }

    // Check password
    const isMatch = await user.comparePassword(password)
    if (!isMatch) {
      await user.incLoginAttempts()
      return res.status(400).json({ error: 'Invalid credentials' })
    }

    // Reset login attempts
    await user.resetLoginAttempts()

    // Update last login
    user.lastLogin = new Date()
    await user.save()

    // Generate tokens
    const tokens = generateTokens(user._id)

    res.json({
      message: 'Login successful',
      user: {
        _id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        username: user.username,
        email: user.email,
        phone: user.phone,
        role: user.role,
        wallet: user.wallet,
        lastLogin: user.lastLogin
      },
      tokens
    })
  } catch (error) {
    console.error('Login error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   POST /api/v1/auth/logout
// @desc    Logout user
// @access  Private
router.post('/logout', authenticate, async (req, res) => {
  try {
    // In a real app, you might want to blacklist the token
    res.json({ message: 'Logout successful' })
  } catch (error) {
    console.error('Logout error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   POST /api/v1/auth/refresh-token
// @desc    Refresh access token
// @access  Public
router.post('/refresh-token', [
  body('refreshToken').notEmpty().withMessage('Refresh token is required'),
], async (req, res) => {
  try {
    const { refreshToken } = req.body

    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET)
    
    // Find user
    const user = await User.findById(decoded.userId)
    if (!user) {
      return res.status(401).json({ error: 'Invalid refresh token' })
    }

    // Generate new access token
    const accessToken = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE || '15m' }
    )

    res.json({ accessToken })
  } catch (error) {
    console.error('Refresh token error:', error)
    res.status(401).json({ error: 'Invalid refresh token' })
  }
})

// @route   GET /api/v1/auth/profile
// @desc    Get user profile
// @access  Private
router.get('/profile', authenticate, async (req, res) => {
  try {
    const user = await User.findById(req.user._id)
    res.json({ user })
  } catch (error) {
    console.error('Get profile error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   PUT /api/v1/auth/profile
// @desc    Update user profile
// @access  Private
router.put('/profile', [
  authenticate,
  body('firstName').optional().notEmpty().withMessage('First name cannot be empty'),
  body('lastName').optional().notEmpty().withMessage('Last name cannot be empty'),
  body('phone').optional().isMobilePhone().withMessage('Please include a valid phone number'),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg })
    }

    const { firstName, lastName, phone } = req.body
    const updateData = {}

    if (firstName) updateData.firstName = firstName
    if (lastName) updateData.lastName = lastName
    if (phone) updateData.phone = phone

    const user = await User.findByIdAndUpdate(
      req.user._id,
      updateData,
      { new: true, runValidators: true }
    )

    res.json({
      message: 'Profile updated successfully',
      user
    })
  } catch (error) {
    console.error('Update profile error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   POST /api/v1/auth/change-password
// @desc    Change user password
// @access  Private
router.post('/change-password', [
  authenticate,
  body('currentPassword').notEmpty().withMessage('Current password is required'),
  body('newPassword').isLength({ min: 6 }).withMessage('New password must be at least 6 characters'),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg })
    }

    const { currentPassword, newPassword } = req.body

    // Get user with password
    const user = await User.findById(req.user._id).select('+password')
    
    // Check current password
    const isMatch = await user.comparePassword(currentPassword)
    if (!isMatch) {
      return res.status(400).json({ error: 'Current password is incorrect' })
    }

    // Update password
    user.password = newPassword
    await user.save()

    res.json({ message: 'Password changed successfully' })
  } catch (error) {
    console.error('Change password error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

export default router
