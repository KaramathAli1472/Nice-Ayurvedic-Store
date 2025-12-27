<!-- src/views/dashboard/DashboardLayout.vue -->
<template>
  <div class="dashboard-layout">
    <!-- Sidebar -->
    <Sidebar />
    
    <!-- Main Content -->
    <main class="main-content">
      <!-- Top Bar -->
      <div class="top-bar">
        <div class="search-container">
          <i class="fas fa-search"></i>
          <input type="text" placeholder="Search..." />
        </div>
        <div class="user-profile">
          <div class="user-info">
            <span class="user-name">Admin</span>
            <span class="user-role">Super Admin</span>
          </div>
          <div class="avatar">
            <i class="fas fa-user-circle"></i>
          </div>
          <!-- Simple Logout Button -->
          <button class="logout-btn" @click="logout">
            <i class="fas fa-sign-out-alt"></i>
            Logout
          </button>
        </div>
      </div>
      
      <!-- Page Content -->
      <div class="content-area">
        <router-view></router-view>
      </div>
    </main>
  </div>
</template>

<script>
import { useRouter } from 'vue-router'
import { auth } from '@/firebase'
import { signOut } from 'firebase/auth'
import Sidebar from '@/components/Sidebar.vue'

export default {
  name: 'DashboardLayout',
  components: {
    Sidebar
  },
  setup() {
    const router = useRouter()

    const logout = async () => {
      try {
        await signOut(auth)
        // Login page pe redirect karo
        router.push('/login')
      } catch (error) {
        console.error('Logout error:', error)
        alert('Logout failed. Please try again.')
      }
    }

    return {
      logout
    }
  }
}
</script>

<style scoped>
.dashboard-layout {
  display: flex;
  min-height: 100vh;
  background-color: #f3f4f6;
}

.main-content {
  flex: 1;
  margin-left: 250px;
  display: flex;
  flex-direction: column;
}

.top-bar {
  background: white;
  padding: 15px 30px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  border-bottom: 1px solid #e5e7eb;
}

.search-container {
  display: flex;
  align-items: center;
  background: #f9fafb;
  border-radius: 8px;
  padding: 8px 15px;
  width: 300px;
}

.search-container i {
  color: #6b7280;
  margin-right: 10px;
}

.search-container input {
  border: none;
  background: transparent;
  outline: none;
  width: 100%;
  font-size: 14px;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-info {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.user-name {
  font-weight: 600;
  color: #111827;
  font-size: 14px;
}

.user-role {
  color: #6b7280;
  font-size: 12px;
}

.avatar i {
  font-size: 36px;
  color: #3b82f6;
}

/* Logout Button Styles */
.logout-btn {
  background: #ef4444;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
  margin-left: 10px;
}

.logout-btn:hover {
  background: #dc2626;
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(239, 68, 68, 0.3);
}

.logout-btn i {
  font-size: 14px;
}

.content-area {
  flex: 1;
  padding: 10px;
  overflow-y: auto;
}

/* Responsive */
@media (max-width: 768px) {
  .main-content {
    margin-left: 0;
  }
  
  .top-bar {
    padding: 5px 10px;
    flex-wrap: wrap;
  }
  
  .search-container {
    width: 100%;
    margin-bottom: 5px;
  }
  
  .user-profile {
    width: 100%;
    justify-content: flex-end;
  }
}
</style>