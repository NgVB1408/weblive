import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'
import App from './App.vue'
import Toast from 'vue-toastification'

// Styles
import './assets/styles/main.css'
import 'vue-toastification/dist/index.css'

// Create app instance
const app = createApp(App)

// Pinia store
const pinia = createPinia()
app.use(pinia)

// Router
app.use(router)

// Toast notifications
app.use(Toast, {
  position: 'top-right',
  timeout: 3000,
  closeOnClick: true,
  pauseOnFocusLoss: true,
  pauseOnHover: true,
  draggable: true,
  draggablePercent: 0.6,
  showCloseButtonOnHover: false,
  hideProgressBar: false,
  closeButton: 'button',
  icon: true,
  rtl: false,
  transition: 'Vue-Toastification__bounce',
  maxToasts: 3,
  newestOnTop: true
})

// Global error handler
app.config.errorHandler = (err, instance, info) => {
  console.error('Global error:', err)
  console.log('Error info:', info)
}

// Mount app
app.mount('#app')
