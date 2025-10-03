const mongoose = require('mongoose')

// Database connection
const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/livestream_betting', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    })
    console.log(`MongoDB Connected: ${conn.connection.host}`)
  } catch (error) {
    console.error('Database connection error:', error)
    process.exit(1)
  }
}

// Initialize default admin user
const createDefaultAdmin = async () => {
  const User = require('../backend/models/User')
  const bcrypt = require('bcryptjs')
  
  try {
    // Check if admin already exists
    const existingAdmin = await User.findOne({ email: 'admin@livestream.com' })
    
    if (!existingAdmin) {
      const adminUser = new User({
        username: 'admin',
        email: 'admin@livestream.com',
        password: 'admin123', // Will be hashed by pre-save middleware
        firstName: 'Admin',
        lastName: 'User',
        role: 'admin',
        isActive: true,
        isVerified: true,
        wallet: {
          balance: 1000000, // 1M KHR for testing
          currency: 'KHR'
        }
      })
      
      await adminUser.save()
      console.log('✅ Default admin user created:')
      console.log('   Email: admin@livestream.com')
      console.log('   Password: admin123')
    } else {
      console.log('ℹ️  Admin user already exists')
    }
  } catch (error) {
    console.error('Error creating admin user:', error)
  }
}

// Initialize sample data
const createSampleData = async () => {
  const Match = require('../backend/models/Match')
  const User = require('../backend/models/User')
  
  try {
    // Check if sample data already exists
    const existingMatches = await Match.countDocuments()
    
    if (existingMatches === 0) {
      // Create sample matches
      const sampleMatches = [
        {
          title: 'Manchester United vs Liverpool',
          description: 'Premier League - Round 15',
          category: 'sports',
          subcategory: 'football',
          teams: {
            home: {
              name: 'Manchester United',
              logo: 'https://logos-world.net/wp-content/uploads/2020/06/Manchester-United-Logo.png'
            },
            away: {
              name: 'Liverpool',
              logo: 'https://logos-world.net/wp-content/uploads/2020/06/Liverpool-Logo.png'
            }
          },
          status: 'live',
          startTime: new Date(),
          isFeatured: true,
          bettingOptions: [
            {
              type: 'win',
              name: 'Manchester United thắng',
              odds: 2.5,
              isActive: true,
              maxBet: 100000,
              minBet: 1000
            },
            {
              type: 'lose',
              name: 'Liverpool thắng',
              odds: 2.8,
              isActive: true,
              maxBet: 100000,
              minBet: 1000
            },
            {
              type: 'draw',
              name: 'Hòa',
              odds: 3.2,
              isActive: true,
              maxBet: 100000,
              minBet: 1000
            }
          ],
          stats: {
            currentViewers: 1250,
            totalBets: 45,
            totalAmount: 2500000,
            homeBets: 20,
            awayBets: 15
          },
          createdBy: await User.findOne({ role: 'admin' }).select('_id')
        },
        {
          title: 'Real Madrid vs Barcelona',
          description: 'La Liga - El Clasico',
          category: 'sports',
          subcategory: 'football',
          teams: {
            home: {
              name: 'Real Madrid',
              logo: 'https://logos-world.net/wp-content/uploads/2020/06/Real-Madrid-Logo.png'
            },
            away: {
              name: 'Barcelona',
              logo: 'https://logos-world.net/wp-content/uploads/2020/06/Barcelona-Logo.png'
            }
          },
          status: 'scheduled',
          startTime: new Date(Date.now() + 2 * 60 * 60 * 1000), // 2 hours from now
          isFeatured: true,
          bettingOptions: [
            {
              type: 'win',
              name: 'Real Madrid thắng',
              odds: 2.1,
              isActive: true,
              maxBet: 200000,
              minBet: 1000
            },
            {
              type: 'lose',
              name: 'Barcelona thắng',
              odds: 2.9,
              isActive: true,
              maxBet: 200000,
              minBet: 1000
            },
            {
              type: 'draw',
              name: 'Hòa',
              odds: 3.5,
              isActive: true,
              maxBet: 200000,
              minBet: 1000
            }
          ],
          stats: {
            currentViewers: 0,
            totalBets: 0,
            totalAmount: 0,
            homeBets: 0,
            awayBets: 0
          },
          createdBy: await User.findOne({ role: 'admin' }).select('_id')
        }
      ]
      
      await Match.insertMany(sampleMatches)
      console.log('✅ Sample matches created')
    } else {
      console.log('ℹ️  Sample data already exists')
    }
  } catch (error) {
    console.error('Error creating sample data:', error)
  }
}

// Main initialization function
const initializeDatabase = async () => {
  await connectDB()
  await createDefaultAdmin()
  await createSampleData()
  console.log('🎉 Database initialization completed!')
  process.exit(0)
}

// Run initialization if this file is executed directly
if (require.main === module) {
  initializeDatabase()
}

module.exports = {
  connectDB,
  createDefaultAdmin,
  createSampleData,
  initializeDatabase
}
