import dayjs from 'dayjs'
import relativeTimePlugin from 'dayjs/plugin/relativeTime'
import duration from 'dayjs/plugin/duration'

dayjs.extend(relativeTimePlugin)
dayjs.extend(duration)

// Format currency
export const formatCurrency = (amount, currency = 'KHR') => {
  if (currency === 'KHR') {
    return new Intl.NumberFormat('km-KH', {
      style: 'decimal',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(amount) + ' ៛'
  }
  
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency
  }).format(amount)
}

// Format number with K, M, B suffix
export const formatNumber = (num) => {
  if (num >= 1000000000) {
    return (num / 1000000000).toFixed(1) + 'B'
  }
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + 'M'
  }
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'K'
  }
  return num.toString()
}

// Format date
export const formatDate = (date, format = 'MMM DD, YYYY HH:mm') => {
  return dayjs(date).format(format)
}

// Relative time (e.g., "2 hours ago")
export const relativeTime = (date) => {
  return dayjs(date).fromNow()
}

// Time until (e.g., "in 2 hours")
export const timeUntil = (date) => {
  return dayjs(date).toNow()
}

// Calculate duration
export const calculateDuration = (start, end) => {
  const diff = dayjs(end).diff(dayjs(start))
  const duration = dayjs.duration(diff)
  
  const hours = Math.floor(duration.asHours())
  const minutes = duration.minutes()
  
  if (hours > 0) {
    return `${hours}h ${minutes}m`
  }
  return `${minutes}m`
}

// Truncate text
export const truncate = (text, length = 50) => {
  if (!text) return ''
  if (text.length <= length) return text
  return text.substring(0, length) + '...'
}

// Debounce function
export const debounce = (func, wait = 300) => {
  let timeout
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout)
      func(...args)
    }
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
  }
}

// Throttle function
export const throttle = (func, limit = 1000) => {
  let inThrottle
  return function(...args) {
    if (!inThrottle) {
      func.apply(this, args)
      inThrottle = true
      setTimeout(() => inThrottle = false, limit)
    }
  }
}

// Copy to clipboard
export const copyToClipboard = async (text) => {
  try {
    await navigator.clipboard.writeText(text)
    return true
  } catch (error) {
    console.error('Copy failed:', error)
    return false
  }
}

// Generate random ID
export const generateId = () => {
  return Math.random().toString(36).substring(2, 15)
}

// Validate email
export const isValidEmail = (email) => {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return re.test(email)
}

// Validate phone number (Cambodian format)
export const isValidPhone = (phone) => {
  const re = /^(0|\+855)[1-9]\d{7,8}$/
  return re.test(phone)
}

// Get bet status color
export const getBetStatusColor = (status) => {
  const colors = {
    pending: 'text-yellow-400',
    won: 'text-green-400',
    lost: 'text-red-400',
    cancelled: 'text-gray-400',
    refunded: 'text-blue-400'
  }
  return colors[status] || 'text-gray-400'
}

// Get bet status badge class
export const getBetStatusBadge = (status) => {
  const badges = {
    pending: 'badge-warning',
    won: 'badge-success',
    lost: 'badge-danger',
    cancelled: 'badge-info',
    refunded: 'badge-info'
  }
  return badges[status] || 'badge-info'
}

// Get match status color
export const getMatchStatusColor = (status) => {
  const colors = {
    scheduled: 'text-blue-400',
    live: 'text-red-400',
    paused: 'text-yellow-400',
    finished: 'text-gray-400',
    cancelled: 'text-gray-500'
  }
  return colors[status] || 'text-gray-400'
}

// Get match status text
export const getMatchStatusText = (status) => {
  const statuses = {
    scheduled: 'Sắp diễn ra',
    live: 'Đang live',
    paused: 'Tạm dừng',
    finished: 'Kết thúc',
    cancelled: 'Hủy'
  }
  return statuses[status] || 'Không xác định'
}

// Local storage helpers
export const storage = {
  get(key) {
    try {
      const item = localStorage.getItem(key)
      return item ? JSON.parse(item) : null
    } catch (error) {
      console.error('Storage get error:', error)
      return null
    }
  },
  
  set(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value))
      return true
    } catch (error) {
      console.error('Storage set error:', error)
      return false
    }
  },
  
  remove(key) {
    try {
      localStorage.removeItem(key)
      return true
    } catch (error) {
      console.error('Storage remove error:', error)
      return false
    }
  },
  
  clear() {
    try {
      localStorage.clear()
      return true
    } catch (error) {
      console.error('Storage clear error:', error)
      return false
    }
  }
}

// Calculate potential win
export const calculatePotentialWin = (amount, odds) => {
  return Math.floor(amount * odds)
}

// Format odds
export const formatOdds = (odds) => {
  return odds.toFixed(2) + 'x'
}

// Check if match is live
export const isMatchLive = (match) => {
  return match.status === 'live'
}

// Check if betting is allowed
export const isBettingAllowed = (match) => {
  return match.status === 'live' || match.status === 'scheduled'
}

// Get category icon
export const getCategoryIcon = (category) => {
  const icons = {
    sports: '⚽',
    esports: '🎮',
    casino: '🎰',
    lottery: '🎫',
    other: '🎯'
  }
  return icons[category] || '🎯'
}

// Calculate win rate percentage
export const calculateWinRate = (won, total) => {
  if (total === 0) return 0
  return ((won / total) * 100).toFixed(1)
}

// Group items by date
export const groupByDate = (items, dateKey = 'createdAt') => {
  const groups = {}
  
  items.forEach(item => {
    const date = dayjs(item[dateKey]).format('YYYY-MM-DD')
    if (!groups[date]) {
      groups[date] = []
    }
    groups[date].push(item)
  })
  
  return groups
}

export default {
  formatCurrency,
  formatNumber,
  formatDate,
  relativeTime,
  timeUntil,
  calculateDuration,
  truncate,
  debounce,
  throttle,
  copyToClipboard,
  generateId,
  isValidEmail,
  isValidPhone,
  getBetStatusColor,
  getBetStatusBadge,
  getMatchStatusColor,
  storage,
  calculatePotentialWin,
  formatOdds,
  isMatchLive,
  isBettingAllowed,
  getCategoryIcon,
  calculateWinRate,
  groupByDate
}
