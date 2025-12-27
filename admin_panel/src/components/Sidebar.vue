<template>
  <aside class="sidebar">
    <div class="logo-container">
      <img src="@/assets/logo.png" alt="Nice Ayurvedic Store" class="logo" />
    </div>
    <nav>
      <router-link to="/" class="nav-item">
        📊 Dashboard
      </router-link>
      <router-link to="/products" class="nav-item">
        📦 Products
      </router-link>
      <router-link to="/orders" class="nav-item">
        🛒 Orders
      </router-link>
      <router-link to="/customers" class="nav-item">
        👥 Customers
      </router-link>
    </nav>
  </aside>
</template>

<script>
export default {
  name: 'Sidebar'
}
</script>

<style scoped>
.sidebar {
  width: 250px;
  background: #1e293b;
  color: white;
  padding: 20px;
}

.logo-container {
  display: flex;
  justify-content: center;
  margin-bottom: 30px;
}

.logo {
  max-width: 180px;
  height: auto;
  object-fit: contain;
}

.nav-item {
  display: block;
  padding: 12px 15px;
  color: #cbd5e1;
  text-decoration: none;
  border-radius: 5px;
  margin-bottom: 5px;
  transition: all 0.3s;
}

.nav-item:hover {
  background: #334155;
  color: white;
}

.router-link-active {
  background: #3b82f6;
  color: white;
}
</style>