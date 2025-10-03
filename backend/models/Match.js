import mongoose from 'mongoose'

const matchSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    trim: true
  },
  category: {
    type: String,
    enum: ['sports', 'esports', 'casino', 'lottery', 'other'],
    required: true
  },
  subcategory: {
    type: String,
    trim: true
  },
  teams: {
    home: {
      name: {
        type: String,
        required: true
      },
      logo: {
        type: String,
        default: null
      }
    },
    away: {
      name: {
        type: String,
        required: true
      },
      logo: {
        type: String,
        default: null
      }
    }
  },
  status: {
    type: String,
    enum: ['scheduled', 'live', 'paused', 'finished', 'cancelled'],
    default: 'scheduled'
  },
  startTime: {
    type: Date,
    required: true
  },
  endTime: {
    type: Date,
    default: null
  },
  streamUrl: {
    type: String,
    default: null
  },
  isFeatured: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  },
  bettingOptions: [{
    type: {
      type: String,
      enum: ['win', 'draw', 'lose', 'over', 'under', 'handicap', 'custom'],
      required: true
    },
    name: {
      type: String,
      required: true
    },
    odds: {
      type: Number,
      required: true,
      min: 1.01
    },
    isActive: {
      type: Boolean,
      default: true
    },
    maxBet: {
      type: Number,
      default: 100000
    },
    minBet: {
      type: Number,
      default: 1000
    }
  }],
  result: {
    winner: {
      type: String,
      enum: ['home', 'away', 'draw'],
      default: null
    },
    score: {
      home: {
        type: Number,
        default: 0
      },
      away: {
        type: Number,
        default: 0
      }
    },
    details: {
      type: String,
      default: null
    }
  },
  stats: {
    currentViewers: {
      type: Number,
      default: 0
    },
    totalBets: {
      type: Number,
      default: 0
    },
    totalAmount: {
      type: Number,
      default: 0
    },
    homeBets: {
      type: Number,
      default: 0
    },
    awayBets: {
      type: Number,
      default: 0
    }
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  timestamps: true
})

// Indexes
matchSchema.index({ status: 1, startTime: 1 })
matchSchema.index({ category: 1 })
matchSchema.index({ isFeatured: 1 })
matchSchema.index({ 'teams.home.name': 1, 'teams.away.name': 1 })

// Virtual for match duration
matchSchema.virtual('duration').get(function() {
  if (this.startTime && this.endTime) {
    return this.endTime - this.startTime
  }
  return null
})

// Virtual for is live
matchSchema.virtual('isLive').get(function() {
  return this.status === 'live'
})

// Virtual for can bet
matchSchema.virtual('canBet').get(function() {
  return this.status === 'live' || this.status === 'scheduled'
})

// Pre-save middleware
matchSchema.pre('save', function(next) {
  // Auto-set endTime if match is finished
  if (this.status === 'finished' && !this.endTime) {
    this.endTime = new Date()
  }
  next()
})

// Static methods
matchSchema.statics.getLiveMatches = function() {
  return this.find({ 
    status: 'live',
    isActive: true 
  }).sort({ startTime: -1 })
}

matchSchema.statics.getUpcomingMatches = function() {
  return this.find({ 
    status: 'scheduled',
    isActive: true,
    startTime: { $gt: new Date() }
  }).sort({ startTime: 1 })
}

matchSchema.statics.getFeaturedMatches = function() {
  return this.find({ 
    isFeatured: true,
    isActive: true,
    status: { $in: ['scheduled', 'live'] }
  }).sort({ startTime: 1 })
}

export default mongoose.model('Match', matchSchema)
