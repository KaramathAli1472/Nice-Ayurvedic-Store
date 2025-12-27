<template>
  <div class="analytics-page">
    <!-- Page Header -->
    <div class="page-header">
      <h1><i class="fas fa-chart-bar"></i> Reports & Analytics</h1>
      <div class="header-actions">
        <div class="date-filter">
          <select v-model="selectedPeriod" @change="updateCharts">
            <option value="today">Today</option>
            <option value="week">This Week</option>
            <option value="month">This Month</option>
            <option value="quarter">This Quarter</option>
            <option value="year">This Year</option>
          </select>
        </div>
        <button class="export-btn" @click="exportReport">
          <i class="fas fa-download"></i> Export Report
        </button>
      </div>
    </div>

    <!-- Summary Cards -->
    <div class="summary-grid">
      <div class="summary-card">
        <div class="summary-icon" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%)">
          <i class="fas fa-rupee-sign"></i>
        </div>
        <div class="summary-content">
          <h3>Total Revenue</h3>
          <p class="summary-number">₹{{ formatNumber(totalRevenue) }}</p>
          <span class="summary-change" :class="revenueChange >= 0 ? 'positive' : 'negative'">
            <i :class="revenueChange >= 0 ? 'fas fa-arrow-up' : 'fas fa-arrow-down'"></i>
            {{ Math.abs(revenueChange) }}% from last period
          </span>
        </div>
      </div>

      <div class="summary-card">
        <div class="summary-icon" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%)">
          <i class="fas fa-shopping-cart"></i>
        </div>
        <div class="summary-content">
          <h3>Total Orders</h3>
          <p class="summary-number">{{ totalOrders }}</p>
          <span class="summary-change" :class="ordersChange >= 0 ? 'positive' : 'negative'">
            <i :class="ordersChange >= 0 ? 'fas fa-arrow-up' : 'fas fa-arrow-down'"></i>
            {{ Math.abs(ordersChange) }}% from last period
          </span>
        </div>
      </div>

      <div class="summary-card">
        <div class="summary-icon" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)">
          <i class="fas fa-box"></i>
        </div>
        <div class="summary-content">
          <h3>Products Sold</h3>
          <p class="summary-number">{{ productsSold }}</p>
          <span class="summary-change" :class="productsChange >= 0 ? 'positive' : 'negative'">
            <i :class="productsChange >= 0 ? 'fas fa-arrow-up' : 'fas fa-arrow-down'"></i>
            {{ Math.abs(productsChange) }}% from last period
          </span>
        </div>
      </div>

      <div class="summary-card">
        <div class="summary-icon" style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)">
          <i class="fas fa-user-plus"></i>
        </div>
        <div class="summary-content">
          <h3>New Customers</h3>
          <p class="summary-number">{{ newCustomers }}</p>
          <span class="summary-change" :class="customersChange >= 0 ? 'positive' : 'negative'">
            <i :class="customersChange >= 0 ? 'fas fa-arrow-up' : 'fas fa-arrow-down'"></i>
            {{ Math.abs(customersChange) }}% from last period
          </span>
        </div>
      </div>
    </div>

    <!-- Charts Section with Actual Charts -->
    <div class="charts-section">
      <div class="chart-container">
        <div class="chart-header">
          <h3><i class="fas fa-chart-line"></i> Revenue Trend</h3>
          <div class="chart-legend">
            <span class="legend-item"><span class="legend-color current"></span> Current Period</span>
            <span class="legend-item"><span class="legend-color previous"></span> Previous Period</span>
          </div>
        </div>
        <!-- Line Chart for Revenue -->
        <div class="chart-wrapper">
          <canvas ref="revenueChart"></canvas>
        </div>
      </div>

      <div class="chart-container">
        <div class="chart-header">
          <h3><i class="fas fa-chart-pie"></i> Sales by Category</h3>
        </div>
        <!-- Pie/Doughnut Chart for Categories -->
        <div class="chart-wrapper">
          <canvas ref="categoryChart"></canvas>
        </div>
      </div>
    </div>

    <!-- Top Products Table -->
    <div class="data-section">
      <div class="section-header">
        <h3><i class="fas fa-trophy"></i> Top Selling Products</h3>
        <router-link to="/dashboard/products" class="view-all">
          View All Products →
        </router-link>
      </div>
      
      <div class="data-table">
        <table>
          <thead>
            <tr>
              <th>Product</th>
              <th>Category</th>
              <th>Units Sold</th>
              <th>Revenue</th>
              <th>Stock Status</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="product in topProducts" :key="product.id">
              <td class="product-cell">
                <div class="product-info">
                  <div class="product-name">{{ product.name }}</div>
                  <div class="product-sku">SKU: {{ product.sku }}</div>
                </div>
              </td>
              <td>{{ product.category }}</td>
              <td>{{ product.unitsSold }}</td>
              <td>₹{{ formatNumber(product.revenue) }}</td>
              <td>
                <span :class="['stock-badge', product.stock > 20 ? 'in-stock' : product.stock > 0 ? 'low-stock' : 'out-stock']">
                  {{ product.stock > 20 ? 'In Stock' : product.stock > 0 ? 'Low Stock' : 'Out of Stock' }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Recent Orders -->
    <div class="data-section">
      <div class="section-header">
        <h3><i class="fas fa-history"></i> Recent Orders</h3>
        <router-link to="/dashboard/orders" class="view-all">
          View All Orders →
        </router-link>
      </div>
      
      <div class="data-table">
        <table>
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
            <tr v-for="order in recentOrders" :key="order.id">
              <td>
                <router-link :to="`/dashboard/orders/${order.id}`" class="order-link">
                  {{ order.orderId }}
                </router-link>
              </td>
              <td>{{ order.customerName }}</td>
              <td>{{ formatDate(order.date) }}</td>
              <td>₹{{ formatNumber(order.amount) }}</td>
              <td>
                <span :class="['status-badge', order.status]">
                  {{ order.status }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { collection, getDocs, query, orderBy } from 'firebase/firestore'
import { db } from '@/firebase'

// Chart.js import
import { Chart, registerables } from 'chart.js'

// Register all Chart.js components
Chart.register(...registerables)

export default {
  name: 'AnalyticsPage',
  setup() {
    const selectedPeriod = ref('month')
    const revenueChart = ref(null)
    const categoryChart = ref(null)
    
    let revenueChartInstance = null
    let categoryChartInstance = null
    
    // Analytics data
    const totalRevenue = ref(0)
    const totalOrders = ref(0)
    const productsSold = ref(0)
    const newCustomers = ref(0)
    
    // Change percentages
    const revenueChange = ref(12.5)
    const ordersChange = ref(8.2)
    const productsChange = ref(5.7)
    const customersChange = ref(15.3)
    
    // Sample data
    const topProducts = ref([
      { id: 1, name: 'Ashwagandha Powder', sku: 'ASH-100', category: 'Herbs', unitsSold: 245, revenue: 122500, stock: 45 },
      { id: 2, name: 'Triphala Churna', sku: 'TRI-200', category: 'Digestive', unitsSold: 189, revenue: 94500, stock: 12 },
      { id: 3, name: 'Moringa Capsules', sku: 'MOR-300', category: 'Immunity', unitsSold: 167, revenue: 83500, stock: 32 },
      { id: 4, name: 'Neem Soap', sku: 'NEE-400', category: 'Skin Care', unitsSold: 134, revenue: 40200, stock: 8 },
      { id: 5, name: 'Tulsi Drops', sku: 'TUL-500', category: 'Immunity', unitsSold: 98, revenue: 49000, stock: 25 },
    ])
    
    const recentOrders = ref([
      { id: 1, orderId: 'ORD-1001', customerName: 'Rajesh Kumar', date: '2024-01-15', amount: 2450, status: 'completed' },
      { id: 2, orderId: 'ORD-1002', customerName: 'Priya Sharma', date: '2024-01-14', amount: 1890, status: 'processing' },
      { id: 3, orderId: 'ORD-1003', customerName: 'Amit Patel', date: '2024-01-14', amount: 3250, status: 'completed' },
      { id: 4, orderId: 'ORD-1004', customerName: 'Sneha Gupta', date: '2024-01-13', amount: 1250, status: 'pending' },
      { id: 5, orderId: 'ORD-1005', customerName: 'Vikram Singh', date: '2024-01-13', amount: 2890, status: 'completed' },
    ])

    const fetchAnalytics = async () => {
      try {
        // Fetch actual data from Firebase
        const ordersQuery = query(collection(db, 'orders'), orderBy('createdAt', 'desc'))
        const ordersSnapshot = await getDocs(ordersQuery)
        
        let revenue = 0
        let ordersCount = 0
        
        ordersSnapshot.forEach(doc => {
          const order = doc.data()
          revenue += order.total || 0
          ordersCount++
        })
        
        totalRevenue.value = revenue
        totalOrders.value = ordersCount
        
        // Fetch products count
        const productsSnapshot = await getDocs(collection(db, 'products'))
        productsSold.value = productsSnapshot.size
        
        // Fetch new customers
        const customersSnapshot = await getDocs(collection(db, 'customers'))
        newCustomers.value = customersSnapshot.size
        
      } catch (error) {
        console.error('Error fetching analytics:', error)
      }
    }

    const formatNumber = (num) => {
      return num.toLocaleString('en-IN')
    }

    const formatDate = (dateString) => {
      const date = new Date(dateString)
      return date.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })
    }

    const exportReport = () => {
      // Implement report export functionality
      alert('Export functionality would be implemented here')
    }

    // Initialize Charts
    const initCharts = () => {
      // Destroy existing charts if they exist
      if (revenueChartInstance) {
        revenueChartInstance.destroy()
      }
      if (categoryChartInstance) {
        categoryChartInstance.destroy()
      }

      // Revenue Line Chart
      const revenueCtx = revenueChart.value.getContext('2d')
      revenueChartInstance = new Chart(revenueCtx, {
        type: 'line',
        data: {
          labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
          datasets: [
            {
              label: 'Current Period',
              data: [12000, 19000, 15000, 25000, 22000, 30000, 28000],
              borderColor: '#3b82f6',
              backgroundColor: 'rgba(59, 130, 246, 0.1)',
              borderWidth: 3,
              tension: 0.4,
              fill: true,
              pointBackgroundColor: '#3b82f6',
              pointRadius: 4,
              pointHoverRadius: 6
            },
            {
              label: 'Previous Period',
              data: [10000, 15000, 12000, 20000, 18000, 25000, 23000],
              borderColor: '#d1d5db',
              backgroundColor: 'rgba(209, 213, 219, 0.1)',
              borderWidth: 2,
              tension: 0.4,
              fill: true,
              borderDash: [5, 5],
              pointBackgroundColor: '#d1d5db',
              pointRadius: 3
            }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              position: 'top',
              labels: {
                usePointStyle: true,
                padding: 20
              }
            },
            tooltip: {
              mode: 'index',
              intersect: false,
              backgroundColor: 'rgba(0, 0, 0, 0.7)',
              titleColor: '#fff',
              bodyColor: '#fff',
              callbacks: {
                label: function(context) {
                  return `${context.dataset.label}: ₹${context.parsed.y.toLocaleString('en-IN')}`
                }
              }
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              grid: {
                color: 'rgba(0, 0, 0, 0.05)'
              },
              ticks: {
                callback: function(value) {
                  return '₹' + value.toLocaleString('en-IN')
                },
                font: {
                  size: 11
                }
              }
            },
            x: {
              grid: {
                color: 'rgba(0, 0, 0, 0.05)'
              },
              ticks: {
                font: {
                  size: 11
                }
              }
            }
          }
        }
      })

      // Category Doughnut Chart
      const categoryCtx = categoryChart.value.getContext('2d')
      categoryChartInstance = new Chart(categoryCtx, {
        type: 'doughnut',
        data: {
          labels: ['Herbs & Powders', 'Oils & Massage', 'Capsules & Tablets', 'Personal Care', 'Immunity Boosters'],
          datasets: [{
            data: [35, 25, 20, 12, 8],
            backgroundColor: [
              '#3b82f6',
              '#10b981',
              '#f59e0b',
              '#8b5cf6',
              '#ec4899'
            ],
            borderWidth: 2,
            borderColor: '#ffffff',
            hoverOffset: 15
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          cutout: '60%',
          plugins: {
            legend: {
              position: 'right',
              labels: {
                usePointStyle: true,
                padding: 20,
                font: {
                  size: 12
                }
              }
            },
            tooltip: {
              backgroundColor: 'rgba(0, 0, 0, 0.7)',
              titleColor: '#fff',
              bodyColor: '#fff',
              callbacks: {
                label: function(context) {
                  const label = context.label || ''
                  const value = context.parsed || 0
                  const total = context.dataset.data.reduce((a, b) => a + b, 0)
                  const percentage = Math.round((value / total) * 100)
                  return `${label}: ${percentage}% (₹${(value * 1000).toLocaleString('en-IN')})`
                }
              }
            }
          }
        }
      })
    }

    const updateCharts = () => {
      // Update chart data based on selected period
      if (revenueChartInstance && categoryChartInstance) {
        // You can update chart data here based on selectedPeriod
        console.log('Updating charts for period:', selectedPeriod.value)
        
        // Example: Update revenue chart data based on period
        const periodData = {
          'today': [500, 800, 600, 900, 700, 1000, 850],
          'week': [7000, 8500, 9200, 7800, 9500, 11000, 10200],
          'month': [12000, 19000, 15000, 25000, 22000, 30000, 28000],
          'quarter': [35000, 42000, 38000, 45000, 50000, 55000, 52000],
          'year': [120000, 135000, 125000, 145000, 160000, 180000, 175000]
        }
        
        if (revenueChartInstance.data.datasets[0]) {
          revenueChartInstance.data.datasets[0].data = periodData[selectedPeriod.value] || periodData.month
          revenueChartInstance.update()
        }
      }
    }

    onMounted(async () => {
      await fetchAnalytics()
      
      // Wait for next tick to ensure canvas elements are rendered
      await nextTick()
      
      if (revenueChart.value && categoryChart.value) {
        initCharts()
      }
    })

    onUnmounted(() => {
      // Clean up charts when component is destroyed
      if (revenueChartInstance) {
        revenueChartInstance.destroy()
      }
      if (categoryChartInstance) {
        categoryChartInstance.destroy()
      }
    })

    return {
      selectedPeriod,
      totalRevenue,
      totalOrders,
      productsSold,
      newCustomers,
      revenueChange,
      ordersChange,
      productsChange,
      customersChange,
      topProducts,
      recentOrders,
      revenueChart,
      categoryChart,
      fetchAnalytics,
      formatNumber,
      formatDate,
      exportReport,
      updateCharts
    }
  }
}
</script>

<style scoped>
.analytics-page {
  padding: 20px;
}

/* Page Header */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding: 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.page-header h1 {
  margin: 0;
  font-size: 24px;
  color: #1f2937;
  display: flex;
  align-items: center;
  gap: 10px;
}

.page-header h1 i {
  color: #3b82f6;
}

.header-actions {
  display: flex;
  gap: 15px;
  align-items: center;
}

.date-filter select {
  padding: 8px 16px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  background: white;
  font-size: 14px;
  color: #374151;
  cursor: pointer;
  transition: all 0.3s;
}

.date-filter select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.export-btn {
  background: #10b981;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.export-btn:hover {
  background: #059669;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

/* Summary Grid */
.summary-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.summary-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 15px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  border: 1px solid #e5e7eb;
  transition: transform 0.3s, box-shadow 0.3s;
}

.summary-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 16px rgba(0,0,0,0.1);
}

.summary-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: white;
  flex-shrink: 0;
}

.summary-content {
  flex: 1;
}

.summary-content h3 {
  margin: 0 0 5px 0;
  color: #6b7280;
  font-size: 14px;
  font-weight: 500;
}

.summary-number {
  margin: 0 0 5px 0;
  font-size: 24px;
  font-weight: 700;
  color: #1f2937;
}

.summary-change {
  font-size: 12px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.summary-change.positive {
  color: #10b981;
}

.summary-change.negative {
  color: #ef4444;
}

/* Charts Section */
.charts-section {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.chart-container {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  display: flex;
  flex-direction: column;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  flex-shrink: 0;
}

.chart-header h3 {
  margin: 0;
  font-size: 18px;
  color: #1f2937;
  display: flex;
  align-items: center;
  gap: 8px;
}

.chart-legend {
  display: flex;
  gap: 15px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #6b7280;
}

.legend-color {
  width: 12px;
  height: 12px;
  border-radius: 2px;
}

.legend-color.current {
  background: #3b82f6;
}

.legend-color.previous {
  background: #d1d5db;
}

/* Chart Wrapper */
.chart-wrapper {
  flex: 1;
  min-height: 300px;
  position: relative;
}

/* Remove old placeholder styles */
.chart-placeholder {
  display: none;
}

/* Data Sections */
.data-section {
  background: white;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-header h3 {
  margin: 0;
  font-size: 18px;
  color: #1f2937;
  display: flex;
  align-items: center;
  gap: 8px;
}

.view-all {
  color: #3b82f6;
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
  transition: color 0.3s;
}

.view-all:hover {
  color: #2563eb;
  text-decoration: underline;
}

/* Data Tables */
.data-table {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
  min-width: 600px;
}

thead {
  background: #f9fafb;
}

th {
  padding: 12px 16px;
  text-align: left;
  color: #374151;
  font-weight: 600;
  font-size: 14px;
  border-bottom: 1px solid #e5e7eb;
  white-space: nowrap;
}

td {
  padding: 12px 16px;
  border-bottom: 1px solid #e5e7eb;
  font-size: 14px;
  color: #4b5563;
}

tr:hover {
  background: #f9fafb;
}

.product-cell {
  min-width: 200px;
}

.product-info {
  display: flex;
  flex-direction: column;
}

.product-name {
  font-weight: 500;
  color: #1f2937;
}

.product-sku {
  font-size: 12px;
  color: #6b7280;
}

.order-link {
  color: #3b82f6;
  text-decoration: none;
  font-weight: 500;
  transition: color 0.3s;
}

.order-link:hover {
  color: #2563eb;
  text-decoration: underline;
}

/* Status Badges */
.stock-badge, .status-badge {
  padding: 4px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 500;
  text-transform: capitalize;
  display: inline-block;
}

.stock-badge.in-stock {
  background: #d1fae5;
  color: #065f46;
}

.stock-badge.low-stock {
  background: #fef3c7;
  color: #92400e;
}

.stock-badge.out-stock {
  background: #fee2e2;
  color: #991b1b;
}

.status-badge.completed {
  background: #d1fae5;
  color: #065f46;
}

.status-badge.processing {
  background: #dbeafe;
  color: #1e40af;
}

.status-badge.pending {
  background: #fef3c7;
  color: #92400e;
}

/* Responsive */
@media (max-width: 1200px) {
  .summary-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .charts-section {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 15px;
  }
  
  .header-actions {
    width: 100%;
    flex-direction: column;
    gap: 10px;
  }
  
  .date-filter select {
    width: 100%;
  }
  
  .export-btn {
    width: 100%;
    justify-content: center;
  }
  
  .summary-grid {
    grid-template-columns: 1fr;
  }
  
  .chart-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .chart-legend {
    align-self: flex-start;
  }
}
</style>