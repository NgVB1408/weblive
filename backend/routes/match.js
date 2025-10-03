import express from 'express'
import { body, validationResult } from 'express-validator'
import Match from '../models/Match.js'
import { authenticate, authorize } from '../middleware/auth.js'

const router = express.Router()

// @route   GET /api/v1/matches
// @desc    Get all matches with filters
// @access  Public
router.get('/', async (req, res) => {
  try {
    const { 
      status, 
      category, 
      isFeatured, 
      page = 1, 
      limit = 20,
      sort = 'startTime'
    } = req.query

    const query = { isActive: true }
    
    if (status) query.status = status
    if (category) query.category = category
    if (isFeatured !== undefined) query.isFeatured = isFeatured === 'true'

    const matches = await Match.find(query)
      .populate('createdBy', 'username')
      .sort({ [sort]: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)

    const total = await Match.countDocuments(query)

    res.json({
      matches,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    })
  } catch (error) {
    console.error('Get matches error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   GET /api/v1/matches/live
// @desc    Get live matches
// @access  Public
router.get('/live', async (req, res) => {
  try {
    const matches = await Match.getLiveMatches()
      .populate('createdBy', 'username')

    res.json({ matches })
  } catch (error) {
    console.error('Get live matches error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   GET /api/v1/matches/upcoming
// @desc    Get upcoming matches
// @access  Public
router.get('/upcoming', async (req, res) => {
  try {
    const matches = await Match.getUpcomingMatches()
      .populate('createdBy', 'username')

    res.json({ matches })
  } catch (error) {
    console.error('Get upcoming matches error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   GET /api/v1/matches/featured
// @desc    Get featured matches
// @access  Public
router.get('/featured', async (req, res) => {
  try {
    const matches = await Match.getFeaturedMatches()
      .populate('createdBy', 'username')

    res.json({ matches })
  } catch (error) {
    console.error('Get featured matches error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   GET /api/v1/matches/:id
// @desc    Get single match
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const match = await Match.findById(req.params.id)
      .populate('createdBy', 'username')

    if (!match) {
      return res.status(404).json({ error: 'Match not found' })
    }

    res.json({ match })
  } catch (error) {
    console.error('Get match error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   POST /api/v1/matches
// @desc    Create new match
// @access  Private (Admin/Moderator)
router.post('/', [
  authenticate,
  authorize('admin', 'moderator'),
  body('title').notEmpty().withMessage('Title is required'),
  body('category').isIn(['sports', 'esports', 'casino', 'lottery', 'other']).withMessage('Invalid category'),
  body('teams.home.name').notEmpty().withMessage('Home team name is required'),
  body('teams.away.name').notEmpty().withMessage('Away team name is required'),
  body('startTime').isISO8601().withMessage('Valid start time is required'),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg })
    }

    const matchData = {
      ...req.body,
      createdBy: req.user._id
    }

    const match = new Match(matchData)
    await match.save()

    await match.populate('createdBy', 'username')

    res.status(201).json({
      message: 'Match created successfully',
      match
    })
  } catch (error) {
    console.error('Create match error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   PUT /api/v1/matches/:id
// @desc    Update match
// @access  Private (Admin/Moderator)
router.put('/:id', [
  authenticate,
  authorize('admin', 'moderator'),
], async (req, res) => {
  try {
    const match = await Match.findById(req.params.id)
    if (!match) {
      return res.status(404).json({ error: 'Match not found' })
    }

    const updatedMatch = await Match.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate('createdBy', 'username')

    res.json({
      message: 'Match updated successfully',
      match: updatedMatch
    })
  } catch (error) {
    console.error('Update match error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   DELETE /api/v1/matches/:id
// @desc    Delete match
// @access  Private (Admin)
router.delete('/:id', [
  authenticate,
  authorize('admin'),
], async (req, res) => {
  try {
    const match = await Match.findById(req.params.id)
    if (!match) {
      return res.status(404).json({ error: 'Match not found' })
    }

    // Soft delete
    match.isActive = false
    await match.save()

    res.json({ message: 'Match deleted successfully' })
  } catch (error) {
    console.error('Delete match error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   PUT /api/v1/matches/:id/status
// @desc    Update match status
// @access  Private (Admin/Moderator)
router.put('/:id/status', [
  authenticate,
  authorize('admin', 'moderator'),
  body('status').isIn(['scheduled', 'live', 'paused', 'finished', 'cancelled']).withMessage('Invalid status'),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg })
    }

    const { status } = req.body
    const match = await Match.findById(req.params.id)
    
    if (!match) {
      return res.status(404).json({ error: 'Match not found' })
    }

    match.status = status
    
    // Set end time if match is finished
    if (status === 'finished' && !match.endTime) {
      match.endTime = new Date()
    }

    await match.save()
    await match.populate('createdBy', 'username')

    res.json({
      message: 'Match status updated successfully',
      match
    })
  } catch (error) {
    console.error('Update match status error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

// @route   PUT /api/v1/matches/:id/odds
// @desc    Update match odds
// @access  Private (Admin/Moderator)
router.put('/:id/odds', [
  authenticate,
  authorize('admin', 'moderator'),
  body('bettingOptions').isArray().withMessage('Betting options must be an array'),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg })
    }

    const { bettingOptions } = req.body
    const match = await Match.findById(req.params.id)
    
    if (!match) {
      return res.status(404).json({ error: 'Match not found' })
    }

    match.bettingOptions = bettingOptions
    await match.save()
    await match.populate('createdBy', 'username')

    res.json({
      message: 'Match odds updated successfully',
      match
    })
  } catch (error) {
    console.error('Update match odds error:', error)
    res.status(500).json({ error: 'Server error' })
  }
})

export default router
