<template>
  <div class="min-h-screen bg-dark-950 flex items-center justify-center">
    <div class="text-center">
      <div class="mb-8">
        <h1 class="text-9xl font-bold text-yellow-500 mb-4">404</h1>
        <h2 class="text-3xl font-bold text-white mb-4">Trang không tìm thấy</h2>
        <p class="text-gray-400 mb-8">Xin lỗi, trang bạn đang tìm kiếm không tồn tại.</p>
      </div>
      
      <div class="space-y-4">
        <router-link to="/" class="btn btn-primary">
          Về trang chủ
        </router-link>
        <div class="text-sm text-gray-500">
          Hoặc thử tìm kiếm trận đấu khác
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// 404 Not Found page
</script>
