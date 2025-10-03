import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

// Layouts
import MainLayout from '@/layouts/MainLayout.vue'
import AuthLayout from '@/layouts/AuthLayout.vue'

// Pages
import Home from '@/pages/Home.vue'
import Login from '@/pages/Login.vue'
import Register from '@/pages/Register.vue'
import LivestreamPage from '@/pages/LivestreamPage.vue'
import Matches from '@/pages/Matches.vue'
import Profile from '@/pages/Profile.vue'
import Wallet from '@/pages/Wallet.vue'
import BetHistory from '@/pages/BetHistory.vue'
import NotFound from '@/pages/NotFound.vue'

const routes = [
  {
    path: '/',
    component: MainLayout,
    children: [
      {
        path: '',
        name: 'Home',
        component: Home,
        meta: { title: 'Home' }
      },
      {
        path: 'matches',
        name: 'Matches',
        component: Matches,
        meta: { title: 'All Matches' }
      },
      {
        path: 'live/:id',
        name: 'Livestream',
        component: LivestreamPage,
        meta: { title: 'Live Match', requiresAuth: false }
      },
      {
        path: 'profile',
        name: 'Profile',
        component: Profile,
        meta: { title: 'Profile', requiresAuth: true }
      },
      {
        path: 'wallet',
        name: 'Wallet',
        component: Wallet,
        meta: { title: 'Wallet', requiresAuth: true }
      },
      {
        path: 'bets',
        name: 'BetHistory',
        component: BetHistory,
        meta: { title: 'Bet History', requiresAuth: true }
      },
    ]
  },
  {
    path: '/auth',
    component: AuthLayout,
    children: [
      {
        path: 'login',
        name: 'Login',
        component: Login,
        meta: { title: 'Login', guest: true }
      },
      {
        path: 'register',
        name: 'Register',
        component: Register,
        meta: { title: 'Register', guest: true }
      },
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: NotFound,
    meta: { title: '404 Not Found' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    } else {
      return { top: 0 }
    }
  }
})

// Navigation guards
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  
  // Set page title
  document.title = to.meta.title 
    ? `${to.meta.title} - ${import.meta.env.VITE_APP_NAME}`
    : import.meta.env.VITE_APP_NAME

  // Check authentication
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next({ name: 'Login', query: { redirect: to.fullPath } })
  } else if (to.meta.guest && authStore.isAuthenticated) {
    next({ name: 'Home' })
  } else {
    next()
  }
})

export default router
