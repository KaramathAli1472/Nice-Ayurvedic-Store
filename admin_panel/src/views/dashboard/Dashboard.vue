<!-- src/views/dashboard/Dashboard.vue -->
<template>
  <div class="desktop-dashboard">
    <!-- Dashboard Header -->
    <div class="dashboard-header">
      <div class="header-left">
        <h1>Dashboard Overview</h1>
        <p class="subtitle">Nice Ayurvedic Store Admin Panel</p>
      </div>
      <div class="header-right">
        <div class="date-box">
          <i class="fas fa-calendar-alt"></i>
          <span>{{ currentDate }}</span>
        </div>
      </div>
    </div>

    <!-- Stats Grid -->
    <div class="stats-grid">
      <div class="stat-card">
        <div
          class="stat-icon"
          style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%)"
        >
          <i class="fas fa-box"></i>
        </div>
        <div class="stat-content">
          <h3>Total Products</h3>
          <p class="stat-number">{{ totalProducts }}</p>
          <router-link to="/dashboard/products" class="view-link">
            View All →
          </router-link>
        </div>
      </div>

      <div class="stat-card">
        <div
          class="stat-icon"
          style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%)"
        >
          <i class="fas fa-shopping-cart"></i>
        </div>
        <div class="stat-content">
          <h3>Total Orders</h3>
          <p class="stat-number">{{ totalOrders }}</p>
          <router-link to="/dashboard/orders" class="view-link">
            View All →
          </router-link>
        </div>
      </div>

      <div class="stat-card">
        <div
          class="stat-icon"
          style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)"
        >
          <i class="fas fa-users"></i>
        </div>
        <div class="stat-content">
          <h3>Total Customers</h3>
          <p class="stat-number">{{ totalCustomers }}</p>
          <router-link to="/customersPage/customers" class="view-link">
            View All →
          </router-link>
        </div>
      </div>

      <div class="stat-card">
        <div
          class="stat-icon"
          style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)"
        >
          <i class="fas fa-rupee-sign"></i>
        </div>
        <div class="stat-content">
          <h3>Revenue</h3>
          <p class="stat-number">₹{{ totalRevenue }}</p>
          <span class="view-link">This Month</span>
        </div>
      </div>
    </div>

    <!-- Recent Activity -->
    <div class="recent-activity">
      <div class="section-title">
        <h2><i class="fas fa-history"></i> Recent Activity</h2>
        <router-link to="/dashboard/orders" class="see-all">
          See All →
        </router-link>
      </div>

      <div class="activity-table">
        <table>
          <thead>
            <tr>
              <th>Activity</th>
              <th>Details</th>
              <th>Time</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="activity in recentActivities" :key="activity.id">
              <td class="activity-type">
                <i :class="activity.icon"></i>
                <span>{{ activity.type }}</span>
              </td>
              <td>{{ activity.details }}</td>
              <td>{{ activity.time }}</td>
              <td>
                <span :class="['status-badge', activity.status]">
                  {{ activity.status }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="quick-actions">
      <div class="section-title">
        <h2><i class="fas fa-bolt"></i> Quick Actions</h2>
      </div>

      <div class="actions-grid">
        <!-- Products -->
        <router-link to="/dashboard/products" class="action-card">
          <div class="action-icon" style="background: #4caf50">
            <i class="fas fa-plus-circle"></i>
          </div>
          <h3>Add New Product</h3>
          <p>Add new ayurvedic product to inventory</p>
        </router-link>

        <!-- Orders -->
        <router-link to="/dashboard/orders" class="action-card">
          <div class="action-icon" style="background: #2196f3">
            <i class="fas fa-file-invoice-dollar"></i>
          </div>
          <h3>Create Order</h3>
          <p>Create new order for customer</p>
        </router-link>

        <!-- Customers -->
        <router-link to="/customersPage/customers" class="action-card">
          <div class="action-icon" style="background: #ff9800">
            <i class="fas fa-user-plus"></i>
          </div>
          <h3>Add Customer</h3>
          <p>Register new customer</p>
        </router-link>

        <!-- Logout -->
        <div class="action-card" @click="logout">
          <div class="action-icon" style="background: #f44336">
            <i class="fas fa-sign-out-alt"></i>
          </div>
          <h3>Logout</h3>
          <p>Sign out from admin panel</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from "vue";
import { collection, getDocs } from "firebase/firestore";
import { db, auth } from "@/firebase";
import { signOut } from "firebase/auth";

export default {
  name: "Dashboard",
  setup() {
    const currentDate = ref("");
    const totalProducts = ref(0);
    const totalOrders = ref(0);
    const totalCustomers = ref(0);
    const totalRevenue = ref("0");
    const recentActivities = ref([]);

    const updateDate = () => {
      const now = new Date();
      currentDate.value = now.toLocaleDateString("en-IN", {
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric",
      });
    };

    const fetchDashboardData = async () => {
      try {
        const productsSnapshot = await getDocs(collection(db, "products"));
        totalProducts.value = productsSnapshot.size;

        const ordersSnapshot = await getDocs(collection(db, "orders"));
        totalOrders.value = ordersSnapshot.size;

        let revenue = 0;
        ordersSnapshot.forEach((doc) => {
          const order = doc.data();
          revenue += order.total || 0;
        });
        totalRevenue.value = revenue.toLocaleString("en-IN");

        const customersSnapshot = await getDocs(collection(db, "customers"));
        totalCustomers.value = customersSnapshot.size;

        recentActivities.value = [
          {
            id: 1,
            icon: "fas fa-shopping-cart text-primary",
            type: "New Order",
            details: "Order #ORD-12345 from Rajesh Kumar",
            time: "10:30 AM",
            status: "completed",
          },
          {
            id: 2,
            icon: "fas fa-plus-circle text-success",
            type: "Product Added",
            details: "Ashwagandha Powder added to inventory",
            time: "9:15 AM",
            status: "success",
          },
          {
            id: 3,
            icon: "fas fa-user-plus text-info",
            type: "New Customer",
            details: "Priya Sharma registered",
            time: "Yesterday",
            status: "completed",
          },
          {
            id: 4,
            icon: "fas fa-exclamation-circle text-warning",
            type: "Low Stock",
            details: "Only 5 units of Triphala left",
            time: "2 days ago",
            status: "pending",
          },
        ];
      } catch (error) {
        console.error("Error fetching dashboard data:", error);
      }
    };

    const logout = async () => {
      try {
        await signOut(auth);
        window.location.href = "/login";
      } catch (error) {
        console.error("Logout error:", error);
      }
    };

    onMounted(() => {
      updateDate();
      fetchDashboardData();
    });

    return {
      currentDate,
      totalProducts,
      totalOrders,
      totalCustomers,
      totalRevenue,
      recentActivities,
      logout,
    };
  },
};
</script>

<style scoped>
@import url("https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap");

.desktop-dashboard {
  padding: 0 0 32px 0;
  max-width: 100%;
}

/* Header ka gap kam */
.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 0 0 18px 0;
  padding: 14px 18px;
  background: #ffffff;
  border-radius: 14px;
  box-shadow: 0 3px 14px rgba(15, 23, 42, 0.06);
}

.header-left h1 {
  margin: 0;
  color: #1f2933;
  font-size: 24px;
  font-weight: 700;
}

.subtitle {
  margin: 4px 0 0 0;
  color: #7b8794;
  font-size: 14px;
}

.date-box {
  display: flex;
  align-items: center;
  gap: 10px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #ffffff;
  padding: 8px 18px;
  border-radius: 999px;
  font-size: 13px;
  font-weight: 500;
  box-shadow: 0 6px 18px rgba(102, 126, 234, 0.35);
}

.date-box i {
  font-size: 16px;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 18px;
  margin-bottom: 22px;
}

.stat-card {
  background: #ffffff;
  border-radius: 14px;
  padding: 18px;
  box-shadow: 0 4px 14px rgba(15, 23, 42, 0.05);
  display: flex;
  align-items: center;
  gap: 14px;
  border: 1px solid #e5e9f2;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.stat-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 24px rgba(15, 23, 42, 0.12);
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: #ffffff;
}

.stat-content h3 {
  margin: 0 0 4px 0;
  color: #7b8794;
  font-size: 13px;
  font-weight: 500;
}

.stat-number {
  margin: 0 0 8px 0;
  font-size: 24px;
  font-weight: 700;
  color: #1f2933;
}

.view-link {
  color: #667eea;
  text-decoration: none;
  font-weight: 500;
  font-size: 13px;
}

.view-link:hover {
  text-decoration: underline;
}

/* Recent Activity */
.recent-activity {
  background: #ffffff;
  border-radius: 14px;
  padding: 22px;
  margin-bottom: 22px;
  box-shadow: 0 4px 16px rgba(15, 23, 42, 0.06);
}

.section-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #e5e9f2;
}

.section-title h2 {
  margin: 0;
  color: #1f2933;
  font-size: 18px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.see-all {
  color: #667eea;
  font-size: 13px;
  text-decoration: none;
  font-weight: 500;
}

.see-all:hover {
  text-decoration: underline;
}

.activity-table {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
}

thead {
  background: #f9fafb;
}

th {
  padding: 12px 10px;
  text-align: left;
  color: #1f2933;
  font-weight: 600;
  font-size: 13px;
  border-bottom: 1px solid #e5e9f2;
}

td {
  padding: 12px 10px;
  border-bottom: 1px solid #edf1f7;
  color: #4b5563;
  font-size: 13px;
}

tr:hover {
  background: #f9fafb;
}

.activity-type {
  display: flex;
  align-items: center;
  gap: 8px;
}

.activity-type i {
  font-size: 15px;
}

.text-primary {
  color: #667eea;
}
.text-success {
  color: #16a34a;
}
.text-info {
  color: #0ea5e9;
}
.text-warning {
  color: #f97316;
}

.status-badge {
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 500;
  text-transform: capitalize;
}

.status-badge.completed {
  background: #dcfce7;
  color: #166534;
}

.status-badge.success {
  background: #dbeafe;
  color: #1d4ed8;
}

.status-badge.pending {
  background: #fef9c3;
  color: #854d0e;
}

/* Quick Actions */
.quick-actions {
  background: #ffffff;
  border-radius: 14px;
  padding: 22px;
  box-shadow: 0 4px 16px rgba(15, 23, 42, 0.06);
}

.actions-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 18px;
}

.action-card {
  background: #f9fafb;
  border-radius: 14px;
  padding: 18px;
  text-decoration: none;
  color: inherit;
  transition: all 0.2s ease;
  border: 1px solid #e5e9f2;
  cursor: pointer;
}

.action-card:hover {
  background: #ffffff;
  border-color: #667eea;
  transform: translateY(-3px);
  box-shadow: 0 10px 22px rgba(102, 126, 234, 0.18);
}

.action-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 14px;
  font-size: 22px;
  color: #ffffff;
}

.action-card h3 {
  margin: 0 0 6px 0;
  color: #1f2933;
  font-size: 15px;
  font-weight: 600;
}

.action-card p {
  margin: 0;
  color: #7b8794;
  font-size: 13px;
  line-height: 1.5;
}

/* Responsive */
@media (max-width: 1200px) {
  .stats-grid,
  .actions-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 768px) {
  .desktop-dashboard {
    padding: 10px;
  }

  .stats-grid,
  .actions-grid {
    grid-template-columns: 1fr;
  }

  .dashboard-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
}
</style>
