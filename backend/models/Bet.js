import mongoose from 'mongoose'

const betSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  match: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Match',
    required: true
  },
  bettingOption: {
    type: {
      type: String,
      required: true
    },
    name: {
      type: String,
      required: true
    },
    odds: {
      type: Number,
      required: true
    }
  },
  amount: {
    type: Number,
    required: true,
    min: 1000 // Minimum bet amount
  },
  potentialWin: {
    type: Number,
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'won', 'lost', 'cancelled', 'refunded'],
    default: 'pending'
  },
  actualWin: {
    type: Number,
    default: 0
  },
  placedAt: {
    type: Date,
    default: Date.now
  },
  settledAt: {
    type: Date,
    default: null
  },
  notes: {
    type: String,
    default: null
  }
}, {
  timestamps: true
})

// Indexes
betSchema.index({ user: 1, status: 1 })
betSchema.index({ match: 1, status: 1 })
betSchema.index({ status: 1, placedAt: -1 })
betSchema.index({ user: 1, placedAt: -1 })

// Virtual for profit/loss
betSchema.virtual('profit').get(function() {
  if (this.status === 'won') {
    return this.actualWin - this.amount
  } else if (this.status === 'lost') {
    return -this.amount
  }
  return 0
})

// Virtual for is active
betSchema.virtual('isActive').get(function() {
  return this.status === 'pending'
})

// Pre-save middleware
betSchema.pre('save', function(next) {
  // Calculate potential win
  if (this.isModified('amount') || this.isModified('bettingOption.odds')) {
    this.potentialWin = Math.floor(this.amount * this.bettingOption.odds)
  }
  
  // Set settledAt when status changes to final state
  if (this.isModified('status') && ['won', 'lost', 'cancelled', 'refunded'].includes(this.status)) {
    this.settledAt = new Date()
  }
  
  next()
})

// Static methods
betSchema.statics.getUserBets = function(userId, status = null) {
  const query = { user: userId }
  if (status) {
    query.status = status
  }
  return this.find(query).populate('match', 'title teams status').sort({ placedAt: -1 })
}

betSchema.statics.getMatchBets = function(matchId) {
  return this.find({ match: matchId }).populate('user', 'username').sort({ placedAt: -1 })
}

betSchema.statics.getActiveBets = function() {
  return this.find({ status: 'pending' }).populate('user match')
}

betSchema.statics.getBetStats = function(userId) {
  return this.aggregate([
    { $match: { user: mongoose.Types.ObjectId(userId) } },
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
}

// Instance methods
betSchema.methods.cancel = function() {
  if (this.status === 'pending') {
    this.status = 'cancelled'
    this.settledAt = new Date()
    return this.save()
  }
  throw new Error('Cannot cancel bet that is not pending')
}

betSchema.methods.settle = function(result) {
  if (this.status !== 'pending') {
    throw new Error('Bet is already settled')
  }
  
  // Determine if bet won based on result
  let won = false
  
  if (this.bettingOption.type === 'win') {
    won = result.winner === 'home'
  } else if (this.bettingOption.type === 'lose') {
    won = result.winner === 'away'
  } else if (this.bettingOption.type === 'draw') {
    won = result.winner === 'draw'
  }
  // Add more betting types as needed
  
  this.status = won ? 'won' : 'lost'
  this.actualWin = won ? this.potentialWin : 0
  this.settledAt = new Date()
  
  return this.save()
}

export default mongoose.model('Bet', betSchema)
