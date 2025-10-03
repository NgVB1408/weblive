<template>
  <div class="min-h-screen bg-dark-950 flex items-center justify-center">
    <div class="w-full max-w-md">
      <!-- Logo -->
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold gradient-text">
          {{ $route.meta.title }}
        </h1>
        <p class="text-gray-400 mt-2">
          {{ $route.name === 'Login' ? 'Đăng nhập vào tài khoản' : 'Tạo tài khoản mới' }}
        </p>
      </div>
      
      <!-- Auth Form -->
      <div class="card">
        <router-view />
      </div>
      
      <!-- Footer -->
      <div class="text-center mt-6">
        <p class="text-gray-500 text-sm">
          © 2024 Livestream Betting Platform. All rights reserved.
        </p>
      </div>
    </div>
  </div>
</template>
