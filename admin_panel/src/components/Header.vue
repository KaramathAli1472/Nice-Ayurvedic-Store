<template>
  <header class="header">
    <div class="header-left">
      <button class="menu-btn" @click="$emit('toggle-sidebar')">
        ☰
      </button>
      <h2>{{ pageTitle }}</h2>
    </div>
    <div class="header-right">
      <div class="user-info">
        <span>Admin</span>
        <button @click="logout">Logout</button>
      </div>
    </div>
  </header>
</template>

<script>
export default {
  name: 'Header',
  computed: {
    pageTitle() {
      return this.$route.name || 'Dashboard'
    }
  },
  methods: {
    logout() {
      // Firebase logout logic here
      this.$router.push('/login')
    }
  }
}
</script>

<style scoped>
.header {
  background: white;
  padding: 15px 30px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 15px;
}

.menu-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 15px;
}
</style>