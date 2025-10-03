import axios from 'axios'
import { useAuthStore } from '@/stores/auth'
import router from '@/router'
import { useToast } from 'vue-toastification'

const toast = useToast()

// Create axios instance
const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor
api.interceptors.request.use(
  (config) => {
    const authStore = useAuthStore()
    
    // Add auth token if available
    if (authStore.token) {
      config.headers.Authorization = `Bearer ${authStore.token}`
    }
    
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor
api.interceptors.response.use(
  (response) => {
    return response
  },
  async (error) => {
    const authStore = useAuthStore()
    
    if (error.response) {
      const { status, data } = error.response
      
      switch (status) {
        case 401:
          // Unauthorized - try to refresh token
          if (!error.config._retry && authStore.refreshToken) {
            error.config._retry = true
            
            try {
              const newToken = await authStore.refreshAccessToken()
              error.config.headers.Authorization = `Bearer ${newToken}`
              return api.request(error.config)
            } catch (refreshError) {
              // Refresh failed - logout
              authStore.logout()
              router.push('/login')
              toast.error('Session expired. Please login again.')
            }
          } else {
            authStore.logout()
            router.push('/login')
            toast.error('Unauthorized access')
          }
          break
          
        case 403:
          toast.error('Access forbidden')
          break
          
        case 404:
          toast.error('Resource not found')
          break
          
        case 429:
          toast.error('Too many requests. Please slow down.')
          break
          
        case 500:
          toast.error('Server error. Please try again later.')
          break
          
        default:
          toast.error(data.error || 'An error occurred')
      }
    } else if (error.request) {
      toast.error('Network error. Please check your connection.')
    } else {
      toast.error('An unexpected error occurred')
    }
    
    return Promise.reject(error)
  }
)

export default api
