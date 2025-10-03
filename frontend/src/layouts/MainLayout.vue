<template>
  <div class="min-h-screen bg-dark-950">
    <!-- Navigation -->
    <Navbar />
    
    <!-- Main Content -->
    <main class="pt-16">
      <router-view />
    </main>
    
    <!-- Footer -->
    <Footer />
  </div>
</template>

<script setup>
import Navbar from '@/components/Navbar.vue'
import Footer from '@/components/Footer.vue'
</script>
