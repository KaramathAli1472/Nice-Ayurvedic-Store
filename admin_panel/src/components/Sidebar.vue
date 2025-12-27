<template>
  <aside class="sidebar">
    <nav>
      <router-link to="/dashboard" class="nav-item" exact-active-class="active">
        <i class="fas fa-tachometer-alt icon-blue"></i>
        <span class="nav-text">Dashboard</span>
      </router-link>
      
      <router-link to="/dashboard/products" class="nav-item" active-class="active">
        <i class="fas fa-box icon-green"></i>
        <span class="nav-text">Products</span>
      </router-link>
      
      <router-link to="/dashboard/categories" class="nav-item" active-class="active">
        <i class="fas fa-tags icon-amber"></i>
        <span class="nav-text">Categories</span>
      </router-link>
      
      <router-link to="/dashboard/orders" class="nav-item" active-class="active">
        <i class="fas fa-shopping-cart icon-red"></i>
        <span class="nav-text">Orders</span>
      </router-link>
      
      <router-link to="/dashboard/customers" class="nav-item" active-class="active">
        <i class="fas fa-users icon-purple"></i>
        <span class="nav-text">Customers</span>
      </router-link>
      
      <router-link to="/dashboard/inventory" class="nav-item" active-class="active">
        <i class="fas fa-boxes icon-orange"></i>
        <span class="nav-text">Inventory</span>
      </router-link>
      
      <router-link to="/dashboard/analytics" class="nav-item" active-class="active">
        <i class="fas fa-chart-bar icon-cyan"></i>
        <span class="nav-text">Analytics</span>
      </router-link>
      
      <router-link to="/dashboard/shipping" class="nav-item" active-class="active">
        <i class="fas fa-shipping-fast icon-indigo"></i>
        <span class="nav-text">Shipping</span>
      </router-link>
      
      <router-link to="/dashboard/reviews" class="nav-item" active-class="active">
        <i class="fas fa-star icon-yellow"></i>
        <span class="nav-text">Reviews</span>
      </router-link>
    </nav>
  </aside>
</template>

<style scoped>
.sidebar {
  width: 250px;
  background: linear-gradient(180deg, #1e293b 0%, #0f172a 100%);
  color: white;
  padding: 25px 15px;
  min-height: 100vh;
  position: fixed;
  left: 0;
  top: 0;
  box-shadow: 2px 0 10px rgba(0, 0, 0, 0.3);
  z-index: 1000;
}

nav {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 15px;
  color: #cbd5e1;
  text-decoration: none;
  border-radius: 8px;
  transition: all 0.3s;
  border-left: 3px solid transparent;
}

.nav-item:hover {
  background: rgba(255, 255, 255, 0.1);
  color: white;
  border-left: 3px solid rgba(59, 130, 246, 0.5);
  transform: translateX(5px);
}

.nav-item.active {
  background: rgba(59, 130, 246, 0.2);
  color: white;
  border-left: 3px solid #3b82f6;
  font-weight: 500;
}

.nav-item i {
  font-size: 16px;
  width: 20px;
  text-align: center;
  transition: all 0.3s;
}

.nav-text {
  font-size: 14px;
  font-weight: 500;
}

/* Colorful Icons */
.icon-blue { color: #3b82f6; }
.icon-green { color: #10b981; }
.icon-amber { color: #f59e0b; }
.icon-red { color: #ef4444; }
.icon-purple { color: #8b5cf6; }
.icon-orange { color: #f97316; }
.icon-cyan { color: #06b6d4; }
.icon-indigo { color: #6366f1; }
.icon-yellow { color: #fbbf24; }

/* Hover effects */
.nav-item:hover .icon-blue { color: #60a5fa; }
.nav-item:hover .icon-green { color: #34d399; }
.nav-item:hover .icon-amber { color: #fbbf24; }
.nav-item:hover .icon-red { color: #f87171; }
.nav-item:hover .icon-purple { color: #a78bfa; }
.nav-item:hover .icon-orange { color: #fb923c; }
.nav-item:hover .icon-cyan { color: #22d3ee; }
.nav-item:hover .icon-indigo { color: #818cf8; }
.nav-item:hover .icon-yellow { color: #fcd34d; }

/* Responsive Design */
@media (max-width: 768px) {
  .sidebar {
    width: 70px;
    padding: 20px 10px;
  }
  
  .nav-text {
    display: none;
  }
  
  .nav-item {
    justify-content: center;
    padding: 15px 5px;
    border-left: none;
    border-radius: 10px;
  }
  
  .nav-item:hover {
    transform: scale(1.1);
  }
  
  .nav-item.active {
    background: rgba(59, 130, 246, 0.3);
    border-left: none;
  }
}

@media (max-width: 480px) {
  .sidebar {
    width: 60px;
    padding: 15px 8px;
  }
  
  .nav-item i {
    font-size: 18px;
  }
}
</style>