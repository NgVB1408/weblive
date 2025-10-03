import express from 'express'
import { body, validationResult } from 'express-validator'
import User from '../models/User.js'
import { authenticate } from '../middleware/auth.js'

const router = express.Router()

// @route   GET /api/v1/wallet/balance
// @desc    Get user wallet balance
// @access  Private
router.get('/balance', authenticate, async (req, res) => {
  try {
    const user = await User.findById(req.user._id)
    res.json({
      balance: user.wallet.balance,
      currency: user.wallet.currency
    })
  } catch (error) {
    console.error('Get balance error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   POST /api/v1/wallet/deposit
// @desc    Deposit money to wallet
// @access  Private
router.post('/deposit', [
  authenticate,
  body('amount').isNumeric().withMessage('Amount must be a number'),
  body('method').notEmpty().withMessage('Payment method is required'),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg })
    }

    const { amount, method } = req.body

    if (amount < 1000) {
      return res.status(400).json({ error: 'Minimum deposit amount is 1,000 KHR' })
    }

    const user = await User.findById(req.user._id)
    
    // In a real app, you would integrate with payment gateway
    // For now, we'll simulate a successful deposit
    user.wallet.balance += amount
    await user.save()

    // Create transaction record (you might want to create a Transaction model)
    const transaction = {
      type: 'deposit',
      amount,
      method,
      status: 'completed',
      createdAt: new Date()
    }

    res.json({
      message: 'Deposit successful',
      newBalance: user.wallet.balance,
      transaction
    })
  } catch (error) {
    console.error('Deposit error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   POST /api/v1/wallet/withdraw
// @desc    Withdraw money from wallet
// @access  Private
router.post('/withdraw', [
  authenticate,
  body('amount').isNumeric().withMessage('Amount must be a number'),
  body('accountNumber').notEmpty().withMessage('Account number is required'),
  body('bank').notEmpty().withMessage('Bank is required'),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg })
    }

    const { amount, accountNumber, bank } = req.body

    if (amount < 1000) {
      return res.status(400).json({ error: 'Minimum withdrawal amount is 1,000 KHR' })
    }

    const user = await User.findById(req.user._id)
    
    if (user.wallet.balance < amount) {
      return res.status(400).json({ error: 'Insufficient balance' })
    }

    // Deduct amount from wallet
    user.wallet.balance -= amount
    await user.save()

    // Create transaction record
    const transaction = {
      type: 'withdraw',
      amount,
      accountNumber,
      bank,
      status: 'pending', // Withdrawals need approval
      createdAt: new Date()
    }

    res.json({
      message: 'Withdrawal request submitted',
      newBalance: user.wallet.balance,
      transaction
    })
  } catch (error) {
    console.error('Withdraw error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   GET /api/v1/wallet/transactions
// @desc    Get user transaction history
// @access  Private
router.get('/transactions', authenticate, async (req, res) => {
  try {
    const { page = 1, limit = 20, type } = req.query
    
    // In a real app, you would query a Transaction model
    // For now, we'll return mock data
    const transactions = [
      {
        _id: '1',
        type: 'deposit',
        amount: 500000,
        status: 'completed',
        createdAt: new Date()
      },
      {
        _id: '2',
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

// @route   POST /api/v1/wallet/transfer
// @desc    Transfer money to another user
// @access  Private
router.post('/transfer', [
  authenticate,
  body('amount').isNumeric().withMessage('Amount must be a number'),
  body('recipientUsername').notEmpty().withMessage('Recipient username is required'),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg })
    }

    const { amount, recipientUsername } = req.body

    if (amount < 1000) {
      return res.status(400).json({ error: 'Minimum transfer amount is 1,000 KHR' })
    }

    // Find recipient
    const recipient = await User.findOne({ username: recipientUsername })
    if (!recipient) {
      return res.status(404).json({ error: 'Recipient not found' })
    }

    if (recipient._id.toString() === req.user._id.toString()) {
      return res.status(400).json({ error: 'Cannot transfer to yourself' })
    }

    const sender = await User.findById(req.user._id)
    
    if (sender.wallet.balance < amount) {
      return res.status(400).json({ error: 'Insufficient balance' })
    }

    // Transfer money
    sender.wallet.balance -= amount
    recipient.wallet.balance += amount

    await sender.save()
    await recipient.save()

    res.json({
      message: 'Transfer successful',
      newBalance: sender.wallet.balance
    })
  } catch (error) {
    console.error('Transfer error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

export default router
