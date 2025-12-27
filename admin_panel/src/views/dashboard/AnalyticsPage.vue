<template>
  <div class="analytics-page">
    <!-- Page Header -->
    <div class="page-header">
      <h1 class="page-title">Analytics Dashboard</h1>
      <div class="date-range">
        <button class="date-btn">Today</button>
        <button class="date-btn">Last 7 Days</button>
        <button class="date-btn active">Last 30 Days</button>
        <button class="date-btn">Custom Range</button>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon revenue">
          <i class="fas fa-rupee-sign"></i>
        </div>
        <div class="stat-info">
          <h3>Total Revenue</h3>
          <p class="stat-amount">₹ 1,24,850</p>
          <p class="stat-change positive">+12.5%</p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon orders">
          <i class="fas fa-shopping-bag"></i>
        </div>
        <div class="stat-info">
          <h3>Total Orders</h3>
          <p class="stat-amount">248</p>
          <p class="stat-change positive">+8.2%</p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon customers">
          <i class="fas fa-users"></i>
        </div>
        <div class="stat-info">
          <h3>New Customers</h3>
          <p class="stat-amount">45</p>
          <p class="stat-change positive">+5.3%</p>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-icon products">
          <i class="fas fa-box"></i>
        </div>
        <div class="stat-info">
          <h3>Products Sold</h3>
          <p class="stat-amount">524</p>
          <p class="stat-change negative">-2.1%</p>
        </div>
      </div>
    </div>

    <!-- Charts Section -->
    <div class="charts-section">
      <div class="chart-container">
        <h3>Revenue Overview</h3>
        <div class="chart-placeholder">
          <!-- Yahan aap chart library use kar sakte hain (Chart.js, ApexCharts, etc.) -->
          <p>Revenue chart yahan aayega</p>
          <div class="fake-chart">
            <div class="chart-bar" style="height: 60%"></div>
            <div class="chart-bar" style="height: 80%"></div>
            <div class="chart-bar" style="height: 45%"></div>
            <div class="chart-bar" style="height: 90%"></div>
            <div class="chart-bar" style="height: 70%"></div>
            <div class="chart-bar" style="height: 85%"></div>
            <div class="chart-bar" style="height: 50%"></div>
          </div>
        </div>
      </div>

      <div class="chart-container">
        <h3>Top Selling Products</h3>
        <div class="top-products">
          <div class="product-item">
            <span class="product-name">Ashwagandha Powder</span>
            <span class="product-sales">85 units</span>
          </div>
          <div class="product-item">
            <span class="product-name">Triphala Churna</span>
            <span class="product-sales">72 units</span>
          </div>
          <div class="product-item">
            <span class="product-name">Brahmi Capsules</span>
            <span class="product-sales">68 units</span>
          </div>
          <div class="product-item">
            <span class="product-name">Neem Soap</span>
            <span class="product-sales">54 units</span>
          </div>
          <div class="product-item">
            <span class="product-name">Amla Juice</span>
            <span class="product-sales">42 units</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Recent Orders Table -->
    <div class="recent-orders">
      <h3>Recent Orders</h3>
      <table class="orders-table">
        <thead>
          <tr>
            <th>Order ID</th>
            <th>Customer</th>
            <th>Date</th>
            <th>Amount</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>#ORD-00124</td>
            <td>Rajesh Kumar</td>
            <td>2024-01-15</td>
            <td>₹ 2,450</td>
            <td><span class="status delivered">Delivered</span></td>
          </tr>
          <tr>
            <td>#ORD-00123</td>
            <td>Priya Sharma</td>
            <td>2024-01-14</td>
            <td>₹ 1,850</td>
            <td><span class="status pending">Pending</span></td>
          </tr>
          <tr>
            <td>#ORD-00122</td>
            <td>Amit Patel</td>
            <td>2024-01-14</td>
            <td>₹ 3,200</td>
            <td><span class="status shipped">Shipped</span></td>
          </tr>
          <tr>
            <td>#ORD-00121</td>
            <td>Neha Gupta</td>
            <td>2024-01-13</td>
            <td>₹ 1,250</td>
            <td><span class="status delivered">Delivered</span></td>
          </tr>
          <tr>
            <td>#ORD-00120</td>
            <td>Sanjay Singh</td>
            <td>2024-01-12</td>
            <td>₹ 4,500</td>
            <td><span class="status cancelled">Cancelled</span></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AnalyticsPage',
  data() {
    return {
      // Yahan aap apna data define kar sakte hain
    }
  },
  mounted() {
    // Yahan aap API calls kar sakte hain
  },
  methods: {
    // Yahan aap apne methods define kar sakte hain
  }
}
</script>

<style scoped>
.analytics-page {
  padding: 20px;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.page-title {
  color: #333;
  font-size: 24px;
}

.date-range {
  display: flex;
  gap: 10px;
}

.date-btn {
  padding: 8px 16px;
  border: 1px solid #ddd;
  background: white;
  border-radius: 4px;
  cursor: pointer;
}

.date-btn.active {
  background-color: #4CAF50;
  color: white;
  border-color: #4CAF50;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
  font-size: 24px;
  color: white;
}

.stat-icon.revenue {
  background-color: #4CAF50;
}

.stat-icon.orders {
  background-color: #2196F3;
}

.stat-icon.customers {
  background-color: #FF9800;
}

.stat-icon.products {
  background-color: #9C27B0;
}

.stat-info h3 {
  margin: 0 0 5px 0;
  color: #666;
  font-size: 14px;
}

.stat-amount {
  margin: 0 0 5px 0;
  font-size: 24px;
  font-weight: bold;
  color: #333;
}

.stat-change {
  margin: 0;
  font-size: 14px;
}

.stat-change.positive {
  color: #4CAF50;
}

.stat-change.negative {
  color: #F44336;
}

.charts-section {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 20px;
  margin-bottom: 30px;
}

.chart-container {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.chart-container h3 {
  margin-top: 0;
  color: #333;
}

.chart-placeholder {
  height: 300px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  color: #999;
}

.fake-chart {
  display: flex;
  align-items: flex-end;
  height: 200px;
  width: 100%;
  gap: 10px;
  margin-top: 20px;
}

.chart-bar {
  flex: 1;
  background-color: #4CAF50;
  border-radius: 4px 4px 0 0;
}

.top-products {
  margin-top: 20px;
}

.product-item {
  display: flex;
  justify-content: space-between;
  padding: 12px 0;
  border-bottom: 1px solid #eee;
}

.product-item:last-child {
  border-bottom: none;
}

.product-name {
  color: #333;
}

.product-sales {
  color: #666;
  font-weight: bold;
}

.recent-orders {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.recent-orders h3 {
  margin-top: 0;
  color: #333;
}

.orders-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 15px;
}

.orders-table th,
.orders-table td {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.orders-table th {
  background-color: #f8f9fa;
  color: #666;
  font-weight: 600;
}

.orders-table tr:hover {
  background-color: #f9f9f9;
}

.status {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: bold;
}

.status.delivered {
  background-color: #d4edda;
  color: #155724;
}

.status.pending {
  background-color: #fff3cd;
  color: #856404;
}

.status.shipped {
  background-color: #d1ecf1;
  color: #0c5460;
}

.status.cancelled {
  background-color: #f8d7da;
  color: #721c24;
}

/* Responsive design */
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 15px;
  }
  
  .date-range {
    flex-wrap: wrap;
  }
  
  .charts-section {
    grid-template-columns: 1fr;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .orders-table {
    display: block;
    overflow-x: auto;
  }
}
</style>