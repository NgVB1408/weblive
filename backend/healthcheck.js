const mongoose = require('mongoose')

const healthCheck = async () => {
  try {
    // Check database connection
    if (mongoose.connection.readyState !== 1) {
      throw new Error('Database not connected')
    }

    // Check if we can perform a simple query
    await mongoose.connection.db.admin().ping()

    return {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      database: 'connected',
      memory: process.memoryUsage(),
      version: process.version
    }
  } catch (error) {
    return {
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      error: error.message
    }
  }
}

module.exports = healthCheck
