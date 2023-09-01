import { createRouter, createWebHistory } from 'vue-router'
import JxMap from '@/views/JxMap.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: JxMap
    },
  ]
})

export default router
