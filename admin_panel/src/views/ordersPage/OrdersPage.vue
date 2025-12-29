<template>
  <div class="orders-dashboard">
    <!-- Dashboard Header -->
    <div class="dashboard-header">
      <div class="header-content">
        <h1 class="dashboard-title">
          <i class="fas fa-shopping-bag"></i> Orders Management
        </h1>
        <p class="dashboard-subtitle">
          Track and manage all customer orders in one place
        </p>
      </div>
      <div class="header-stats">
        <div class="stat-card" v-for="stat in orderStats" :key="stat.label">
          <div class="stat-icon" :class="stat.class">
            <i :class="stat.icon"></i>
          </div>
          <div class="stat-info">
            <h3>{{ stat.value }}</h3>
            <p>{{ stat.label }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Filters and Controls -->
    <div class="filters-panel">
      <div class="filter-group">
        <div class="search-box">
          <i class="fas fa-search search-icon"></i>
          <input 
            type="text" 
            v-model="searchQuery" 
            placeholder="Search by customer, product or phone..."
            class="search-input"
          />
        </div>
        
        <div class="filter-options">
          <select v-model="statusFilter" class="filter-select">
            <option value="">All Status</option>
            <option value="pending">Pending</option>
            <option value="confirmed">Confirmed</option>
            <option value="processing">Processing</option>
            <option value="shipped">Shipped</option>
            <option value="delivered">Delivered</option>
            <option value="cancelled">Cancelled</option>
          </select>
          
          <select v-model="sortBy" class="filter-select">
            <option value="dateDesc">Newest First</option>
            <option value="dateAsc">Oldest First</option>
            <option value="priceHigh">Price: High to Low</option>
            <option value="priceLow">Price: Low to High</option>
            <option value="name">Customer Name A-Z</option>
          </select>
          
          <button class="export-btn" @click="exportOrders">
            <i class="fas fa-file-export"></i> Export CSV
          </button>
          
          <button class="refresh-btn" @click="refreshOrders">
            <i class="fas fa-sync-alt"></i> Refresh
          </button>
        </div>
      </div>
    </div>

    <!-- Orders Table -->
    <div class="orders-table-container">
      <div class="table-wrapper">
        <table class="orders-table">
          <thead>
            <tr>
              <th>Order ID</th>
              <th>Customer Details</th>
              <th>Order Items</th>
              <th>Quantity</th>
              <th>Amount</th>
              <th>Order Date</th>
              <th>Status</th>
              <th class="text-center">Actions</th>
            </tr>
          </thead>
          
          <tbody>
            <tr 
              v-for="order in filteredOrders" 
              :key="order.id"
              :class="getOrderRowClass(order.status)"
            >
              <!-- Order ID -->
              <td class="order-id">
                <span class="order-id-text">#{{ order.id.substring(0, 8) }}</span>
                <small class="order-time">{{ formatTime(order.createdAt) }}</small>
              </td>
              
              <!-- Customer Details -->
              <td class="customer-cell">
                <div class="customer-info">
                  <div class="customer-avatar">
                    <i class="fas fa-user"></i>
                  </div>
                  <div class="customer-details">
                    <h4 class="customer-name">{{ order.customerName }}</h4>
                    <p class="customer-contact">
                      <i class="fas fa-phone"></i> {{ order.phone }}
                    </p>
                    <p v-if="order.email" class="customer-email">
                      <i class="fas fa-envelope"></i> {{ order.email }}
                    </p>
                    <p v-if="order.address" class="customer-address">
                      <i class="fas fa-map-marker-alt"></i> {{ truncateText(order.address, 30) }}
                    </p>
                  </div>
                </div>
              </td>
              
              <!-- Order Items -->
              <td class="product-cell">
                <div class="product-info">
                  <div class="product-image" v-if="order.productImage">
                    <img :src="order.productImage" :alt="order.productName" />
                  </div>
                  <div class="product-details">
                    <h4 class="product-name">{{ order.productName }}</h4>
                    <p v-if="order.productCategory" class="product-category">
                      {{ order.productCategory }}
                    </p>
                  </div>
                </div>
              </td>
              
              <!-- Quantity -->
              <td class="quantity-cell">
                <span class="quantity-badge">{{ order.quantity }}</span>
                <small class="quantity-label">units</small>
              </td>
              
              <!-- Amount -->
              <td class="amount-cell">
                <div class="amount-details">
                  <p class="item-price">₹{{ order.price.toLocaleString() }}</p>
                  <p class="total-amount">
                    <strong>Total: ₹{{ (order.price * order.quantity).toLocaleString() }}</strong>
                  </p>
                  <p v-if="order.shippingCharge" class="shipping-charge">
                    + ₹{{ order.shippingCharge }} shipping
                  </p>
                </div>
              </td>
              
              <!-- Order Date -->
              <td class="date-cell">
                <div class="date-details">
                  <p class="order-date">{{ formatDate(order.createdAt) }}</p>
                  <p class="order-day">{{ formatDay(order.createdAt) }}</p>
                  <small class="date-label">Order Placed</small>
                </div>
              </td>
              
              <!-- Status -->
              <td class="status-cell">
                <div class="status-selector">
                  <select 
                    v-model="order.status" 
                    @change="updateOrderStatus(order)"
                    class="status-dropdown"
                    :class="getStatusClass(order.status)"
                  >
                    <option value="pending">Pending</option>
                    <option value="confirmed">Confirmed</option>
                    <option value="processing">Processing</option>
                    <option value="shipped">Shipped</option>
                    <option value="delivered">Delivered</option>
                    <option value="cancelled">Cancelled</option>
                  </select>
                  <span class="status-indicator" :class="getStatusClass(order.status)"></span>
                </div>
                <div class="status-actions">
                  <button 
                    v-if="order.status === 'pending'" 
                    class="quick-action-btn confirm-btn"
                    @click="quickUpdateStatus(order, 'confirmed')"
                  >
                    <i class="fas fa-check"></i> Confirm
                  </button>
                  <button 
                    v-if="order.status === 'confirmed'" 
                    class="quick-action-btn process-btn"
                    @click="quickUpdateStatus(order, 'processing')"
                  >
                    <i class="fas fa-cogs"></i> Process
                  </button>
                  <button 
                    v-if="order.status === 'processing'" 
                    class="quick-action-btn ship-btn"
                    @click="quickUpdateStatus(order, 'shipped')"
                  >
                    <i class="fas fa-shipping-fast"></i> Ship
                  </button>
                </div>
              </td>
              
              <!-- Actions -->
              <td class="actions-cell text-center">
                <div class="action-buttons">
                  <button 
                    class="icon-btn view-btn"
                    @click="viewOrderDetails(order)"
                    title="View Details"
                  >
                    <i class="fas fa-eye"></i>
                  </button>
                  <button 
                    class="icon-btn edit-btn"
                    @click="editOrder(order)"
                    title="Edit Order"
                  >
                    <i class="fas fa-edit"></i>
                  </button>
                  <button 
                    class="icon-btn delete-btn"
                    @click="confirmDeleteOrder(order)"
                    title="Delete Order"
                  >
                    <i class="fas fa-trash"></i>
                  </button>
                  <button 
                    class="icon-btn invoice-btn"
                    @click="generateInvoice(order)"
                    title="Generate Invoice"
                  >
                    <i class="fas fa-file-invoice"></i>
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
        
        <!-- Empty State -->
        <div v-if="filteredOrders.length === 0" class="empty-state">
          <i class="fas fa-shopping-bag empty-icon"></i>
          <h3>No Orders Found</h3>
          <p v-if="searchQuery || statusFilter">
            No orders match your current filters.
          </p>
          <p v-else>
            All orders are processed! New orders will appear here.
          </p>
          <button class="empty-btn" @click="clearFilters">
            <i class="fas fa-times"></i> Clear Filters
          </button>
        </div>
      </div>
      
      <!-- Table Footer -->
      <div v-if="filteredOrders.length > 0" class="table-footer">
        <div class="footer-info">
          <p>
            Showing <strong>{{ filteredOrders.length }}</strong> of 
            <strong>{{ orders.length }}</strong> orders
            <span v-if="searchQuery" class="search-info">
              • Filtered by: "{{ searchQuery }}"
            </span>
            <span v-if="statusFilter" class="status-info">
              • Status: {{ getStatusLabel(statusFilter) }}
            </span>
          </p>
        </div>
        <div class="footer-actions">
          <div class="pagination">
            <button class="page-btn" :disabled="currentPage === 1" @click="prevPage">
              <i class="fas fa-chevron-left"></i>
            </button>
            <span class="page-info">
              Page {{ currentPage }} of {{ totalPages }}
            </span>
            <button class="page-btn" :disabled="currentPage === totalPages" @click="nextPage">
              <i class="fas fa-chevron-right"></i>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Order Details Modal -->
    <div v-if="selectedOrder" class="order-modal" @click="closeModal">
      <div class="modal-content" @click.stop>
        <button class="modal-close" @click="closeModal">
          <i class="fas fa-times"></i>
        </button>
        
        <div class="modal-header">
          <h2>Order Details</h2>
          <span class="order-status-badge" :class="getStatusClass(selectedOrder.status)">
            {{ getStatusLabel(selectedOrder.status) }}
          </span>
        </div>
        
        <div class="modal-body">
          <!-- Order Summary -->
          <div class="order-summary">
            <div class="summary-row">
              <div class="summary-col">
                <h4>Order Information</h4>
                <p><strong>Order ID:</strong> #{{ selectedOrder.id }}</p>
                <p><strong>Date:</strong> {{ formatFullDate(selectedOrder.createdAt) }}</p>
                <p><strong>Time:</strong> {{ formatTime(selectedOrder.createdAt) }}</p>
              </div>
              <div class="summary-col">
                <h4>Customer Information</h4>
                <p><strong>Name:</strong> {{ selectedOrder.customerName }}</p>
                <p><strong>Phone:</strong> {{ selectedOrder.phone }}</p>
                <p v-if="selectedOrder.email"><strong>Email:</strong> {{ selectedOrder.email }}</p>
                <p v-if="selectedOrder.address"><strong>Address:</strong> {{ selectedOrder.address }}</p>
              </div>
            </div>
            
            <!-- Order Items -->
            <div class="order-items">
              <h4>Order Items</h4>
              <div class="item-card">
                <div class="item-image" v-if="selectedOrder.productImage">
                  <img :src="selectedOrder.productImage" :alt="selectedOrder.productName" />
                </div>
                <div class="item-details">
                  <h5>{{ selectedOrder.productName }}</h5>
                  <p v-if="selectedOrder.productCategory">Category: {{ selectedOrder.productCategory }}</p>
                  <div class="item-meta">
                    <span class="item-quantity">Quantity: {{ selectedOrder.quantity }}</span>
                    <span class="item-price">Price: ₹{{ selectedOrder.price.toLocaleString() }}</span>
                  </div>
                </div>
                <div class="item-total">
                  <h5>₹{{ (selectedOrder.price * selectedOrder.quantity).toLocaleString() }}</h5>
                  <small>Total</small>
                </div>
              </div>
            </div>
            
            <!-- Order Totals -->
            <div class="order-totals">
              <div class="totals-row">
                <span>Subtotal</span>
                <span>₹{{ (selectedOrder.price * selectedOrder.quantity).toLocaleString() }}</span>
              </div>
              <div v-if="selectedOrder.shippingCharge" class="totals-row">
                <span>Shipping</span>
                <span>₹{{ selectedOrder.shippingCharge.toLocaleString() }}</span>
              </div>
              <div class="totals-row total">
                <strong>Grand Total</strong>
                <strong>
                  ₹{{ 
                    ((selectedOrder.price * selectedOrder.quantity) + 
                     (selectedOrder.shippingCharge || 0)).toLocaleString() 
                  }}
                </strong>
              </div>
            </div>
            
            <!-- Status Timeline -->
            <div class="status-timeline">
              <h4>Order Status Timeline</h4>
              <div class="timeline">
                <div 
                  v-for="status in statusOptions" 
                  :key="status.value"
                  class="timeline-step"
                  :class="{ 
                    'active': getStatusIndex(selectedOrder.status) >= getStatusIndex(status.value),
                    'current': selectedOrder.status === status.value 
                  }"
                >
                  <div class="timeline-icon">
                    <i :class="getStatusIcon(status.value)"></i>
                  </div>
                  <div class="timeline-label">
                    <p>{{ status.label }}</p>
                    <small v-if="selectedOrder.status === status.value">Current Status</small>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="modal-footer">
          <button class="modal-btn secondary-btn" @click="closeModal">
            Close
          </button>
          <button class="modal-btn primary-btn" @click="generateInvoice(selectedOrder)">
            <i class="fas fa-file-invoice"></i> Generate Invoice
          </button>
          <button 
            v-if="selectedOrder.status !== 'delivered' && selectedOrder.status !== 'cancelled'"
            class="modal-btn action-btn"
            @click="nextStatus(selectedOrder)"
          >
            <i class="fas fa-arrow-right"></i> Move to Next Status
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { 
  collection, 
  onSnapshot, 
  doc, 
  updateDoc, 
  deleteDoc,
  query,
  orderBy,
  where,
  getDocs 
} from "firebase/firestore";
import { db } from "../../firebase";

export default {
  name: "OrdersDashboard",
  
  data() {
    return {
      orders: [],
      selectedOrder: null,
      searchQuery: "",
      statusFilter: "",
      sortBy: "dateDesc",
      currentPage: 1,
      itemsPerPage: 10,
      isLoading: false,
      statusOptions: [
        { value: "pending", label: "Pending", icon: "fas fa-clock" },
        { value: "confirmed", label: "Confirmed", icon: "fas fa-check-circle" },
        { value: "processing", label: "Processing", icon: "fas fa-cogs" },
        { value: "shipped", label: "Shipped", icon: "fas fa-shipping-fast" },
        { value: "delivered", label: "Delivered", icon: "fas fa-box-open" },
        { value: "cancelled", label: "Cancelled", icon: "fas fa-times-circle" }
      ]
    };
  },
  
  computed: {
    // Order statistics
    orderStats() {
      const total = this.orders.length;
      const pending = this.orders.filter(o => o.status === "pending").length;
      const processing = this.orders.filter(o => o.status === "processing" || o.status === "confirmed").length;
      const delivered = this.orders.filter(o => o.status === "delivered").length;
      const revenue = this.orders
        .filter(o => o.status === "delivered")
        .reduce((sum, order) => sum + (order.price * order.quantity), 0);

      return [
        {
          label: "Total Orders",
          value: total,
          icon: "fas fa-shopping-bag",
          class: "total-orders"
        },
        {
          label: "Pending",
          value: pending,
          icon: "fas fa-clock",
          class: "pending-orders"
        },
        {
          label: "In Process",
          value: processing,
          icon: "fas fa-cogs",
          class: "processing-orders"
        },
        {
          label: "Delivered",
          value: delivered,
          icon: "fas fa-check-circle",
          class: "delivered-orders"
        },
        {
          label: "Revenue",
          value: `₹${revenue.toLocaleString()}`,
          icon: "fas fa-rupee-sign",
          class: "revenue-orders"
        }
      ];
    },
    
    // Filtered and sorted orders
    filteredOrders() {
      let filtered = this.orders;
      
      // Apply search filter
      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase();
        filtered = filtered.filter(order => 
          order.customerName?.toLowerCase().includes(query) ||
          order.phone?.includes(query) ||
          order.productName?.toLowerCase().includes(query) ||
          order.email?.toLowerCase().includes(query)
        );
      }
      
      // Apply status filter
      if (this.statusFilter) {
        filtered = filtered.filter(order => order.status === this.statusFilter);
      }
      
      // Apply sorting
      filtered = this.sortOrders(filtered);
      
      return filtered;
    },
    
    // Pagination
    paginatedOrders() {
      const start = (this.currentPage - 1) * this.itemsPerPage;
      const end = start + this.itemsPerPage;
      return this.filteredOrders.slice(start, end);
    },
    
    totalPages() {
      return Math.ceil(this.filteredOrders.length / this.itemsPerPage);
    }
  },
  
  mounted() {
    this.loadOrders();
  },
  
  methods: {
  // Load orders from Firestore
  async loadOrders() {
    this.isLoading = true;
    try {
      const ordersRef = collection(db, "orders");

      // Query orders sorted by createdAt descending
      const q = query(ordersRef, orderBy("createdAt", "desc"));

      // Real-time listener
      onSnapshot(q, (snapshot) => {
        this.orders = snapshot.docs.map(doc => {
          const data = doc.data();
          return {
            id: doc.id,
            customerName: data.customerName || '',
            phone: data.phone || '',
            email: data.email || '',
            address: data.address || '',
            productName: data.productName || '',
            productCategory: data.productCategory || '',
            productImage: data.productImage || '',
            quantity: data.quantity || 1,
            price: data.price || 0,
            shippingCharge: data.shippingCharge || 0,
            status: data.status || 'pending',
            createdAt: data.createdAt?.toDate ? data.createdAt.toDate() : new Date()
          };
        });
        this.isLoading = false;
      }, (error) => {
        console.error("Error fetching orders:", error);
        this.isLoading = false;
      });

    } catch (error) {
      console.error("Error loading orders:", error);
      this.isLoading = false;
    }
  },
    
    // Refresh orders
    refreshOrders() {
      this.loadOrders();
    },
    
    // Sort orders based on selected criteria
    sortOrders(orders) {
      switch (this.sortBy) {
        case "dateAsc":
          return [...orders].sort((a, b) => a.createdAt - b.createdAt);
        case "priceHigh":
          return [...orders].sort((a, b) => (b.price * b.quantity) - (a.price * a.quantity));
        case "priceLow":
          return [...orders].sort((a, b) => (a.price * a.quantity) - (b.price * b.quantity));
        case "name":
          return [...orders].sort((a, b) => 
            (a.customerName || "").localeCompare(b.customerName || "")
          );
        default: // dateDesc
          return [...orders].sort((a, b) => b.createdAt - a.createdAt);
      }
    },
    
    // Update order status
    async updateOrderStatus(order) {
      try {
        await updateDoc(doc(db, "orders", order.id), {
          status: order.status,
          updatedAt: new Date()
        });
        this.showToast(`Order status updated to ${this.getStatusLabel(order.status)}`, "success");
      } catch (error) {
        console.error("Error updating order status:", error);
        this.showToast("Failed to update order status", "error");
      }
    },
    
    // Quick status update
    async quickUpdateStatus(order, newStatus) {
      order.status = newStatus;
      await this.updateOrderStatus(order);
    },
    
    // Move to next status
    nextStatus(order) {
      const statusIndex = this.getStatusIndex(order.status);
      const nextStatus = this.statusOptions[statusIndex + 1];
      if (nextStatus && order.status !== "delivered" && order.status !== "cancelled") {
        this.quickUpdateStatus(order, nextStatus.value);
      }
    },
    
    // Delete order
    async deleteOrder(order) {
      try {
        await deleteDoc(doc(db, "orders", order.id));
        this.showToast("Order deleted successfully", "success");
      } catch (error) {
        console.error("Error deleting order:", error);
        this.showToast("Failed to delete order", "error");
      }
    },
    
    // Confirm delete with modal
    confirmDeleteOrder(order) {
      if (confirm(`Are you sure you want to delete order #${order.id.substring(0, 8)}?`)) {
        this.deleteOrder(order);
      }
    },
    
    // View order details
    viewOrderDetails(order) {
      this.selectedOrder = order;
    },
    
    // Edit order
    editOrder(order) {
      // You can implement edit functionality here
      alert(`Edit order #${order.id.substring(0, 8)} - To be implemented`);
    },
    
    // Generate invoice
    generateInvoice(order) {
      // You can implement invoice generation here
      alert(`Generating invoice for order #${order.id.substring(0, 8)} - To be implemented`);
    },
    
    // Export orders to CSV
    exportOrders() {
      const csvContent = [
        ['Order ID', 'Customer', 'Product', 'Quantity', 'Price', 'Total', 'Status', 'Date'].join(','),
        ...this.filteredOrders.map(order => [
          `"${order.id}"`,
          `"${order.customerName}"`,
          `"${order.productName}"`,
          order.quantity,
          order.price,
          (order.price * order.quantity),
          `"${this.getStatusLabel(order.status)}"`,
          `"${this.formatDate(order.createdAt)}"`
        ].join(','))
      ].join('\n');
      
      const blob = new Blob([csvContent], { type: 'text/csv' });
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `orders_${new Date().toISOString().split('T')[0]}.csv`;
      a.click();
      window.URL.revokeObjectURL(url);
      
      this.showToast('Orders exported successfully', 'success');
    },
    
    // Clear filters
    clearFilters() {
      this.searchQuery = "";
      this.statusFilter = "";
      this.sortBy = "dateDesc";
      this.currentPage = 1;
    },
    
    // Close modal
    closeModal() {
      this.selectedOrder = null;
    },
    
    // Pagination
    prevPage() {
      if (this.currentPage > 1) {
        this.currentPage--;
      }
    },
    
    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++;
      }
    },
    
    // Helper methods
    getStatusClass(status) {
      switch(status) {
        case 'pending': return 'status-pending';
        case 'confirmed': return 'status-confirmed';
        case 'processing': return 'status-processing';
        case 'shipped': return 'status-shipped';
        case 'delivered': return 'status-delivered';
        case 'cancelled': return 'status-cancelled';
        default: return 'status-pending';
      }
    },
    
    getStatusLabel(status) {
      const option = this.statusOptions.find(s => s.value === status);
      return option ? option.label : status;
    },
    
    getStatusIcon(status) {
      const option = this.statusOptions.find(s => s.value === status);
      return option ? option.icon : 'fas fa-question-circle';
    },
    
    getStatusIndex(status) {
      return this.statusOptions.findIndex(s => s.value === status);
    },
    
    getOrderRowClass(status) {
      return `status-row-${status}`;
    },
    
    formatDate(date) {
      if (!date) return 'N/A';
      return new Date(date).toLocaleDateString('en-IN');
    },
    
    formatFullDate(date) {
      if (!date) return 'N/A';
      return new Date(date).toLocaleDateString('en-IN', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      });
    },
    
    formatDay(date) {
      if (!date) return 'N/A';
      return new Date(date).toLocaleDateString('en-IN', { weekday: 'short' });
    },
    
    formatTime(date) {
      if (!date) return 'N/A';
      return new Date(date).toLocaleTimeString('en-IN', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
      });
    },
    
    truncateText(text, maxLength) {
      if (!text) return '';
      return text.length > maxLength ? text.substring(0, maxLength) + '...' : text;
    },
    
    showToast(message, type = 'info') {
      // You can implement a toast notification system here
      alert(message);
    }
  }
};
</script>

<style scoped>
/* Professional Orders Dashboard Styles */
.orders-dashboard {
  padding: 10px;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4e8f0 100%);
  min-height: 100vh;
}

/* Dashboard Header */
.dashboard-header {
  background: white;
  border-radius: 16px;
  padding: 10px;
  margin-bottom: 10px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #e1e5eb;
}

.header-content {
  margin-bottom: 25px;
}

.dashboard-title {
  color: #2c5530;
  font-size: 32px;
  font-weight: 700;
  margin: 0 0 10px 0;
  display: flex;
  align-items: center;
  gap: 15px;
}

.dashboard-title i {
  color: #4a7c4a;
}

.dashboard-subtitle {
  color: #6c757d;
  font-size: 16px;
  margin: 0;
  font-weight: 400;
}

.header-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
}

.stat-card {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 20px;
  border: 2px solid #e9ecef;
  transition: all 0.3s;
}

.stat-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 15px rgba(0, 0, 0, 0.1);
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 24px;
}

.stat-icon.total-orders {
  background: linear-gradient(135deg, #667eea, #764ba2);
}

.stat-icon.pending-orders {
  background: linear-gradient(135deg, #f093fb, #f5576c);
}

.stat-icon.processing-orders {
  background: linear-gradient(135deg, #4facfe, #00f2fe);
}

.stat-icon.delivered-orders {
  background: linear-gradient(135deg, #43e97b, #38f9d7);
}

.stat-icon.revenue-orders {
  background: linear-gradient(135deg, #fa709a, #fee140);
}

.stat-info h3 {
  color: #2c5530;
  font-size: 28px;
  font-weight: 700;
  margin: 0 0 5px 0;
}

.stat-info p {
  color: #6c757d;
  margin: 0;
  font-size: 14px;
  font-weight: 500;
}

/* Filters Panel */
.filters-panel {
  background: white;
  border-radius: 16px;
  padding: 20px 30px;
  margin-bottom: 30px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #e1e5eb;
}

.filter-group {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}

.search-box {
  position: relative;
  flex: 1;
  min-width: 300px;
}

.search-icon {
  position: absolute;
  left: 15px;
  top: 50%;
  transform: translateY(-50%);
  color: #6c757d;
}

.search-input {
  width: 100%;
  padding: 12px 20px 12px 45px;
  border: 2px solid #e1e5eb;
  border-radius: 10px;
  font-size: 14px;
  color: #495057;
  background: #f8fafc;
  transition: all 0.3s;
}

.search-input:focus {
  outline: none;
  border-color: #2c5530;
  background: white;
  box-shadow: 0 0 0 4px rgba(44, 85, 48, 0.1);
}

.filter-options {
  display: flex;
  gap: 15px;
  align-items: center;
  flex-wrap: wrap;
}

.filter-select {
  padding: 10px 15px;
  border: 2px solid #e1e5eb;
  border-radius: 8px;
  font-size: 14px;
  color: #495057;
  background: white;
  cursor: pointer;
  min-width: 150px;
}

.filter-select:focus {
  outline: none;
  border-color: #2c5530;
}

.export-btn, .refresh-btn {
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.export-btn {
  background: #198754;
  color: white;
}

.export-btn:hover {
  background: #157347;
  transform: translateY(-2px);
}

.refresh-btn {
  background: #0dcaf0;
  color: white;
}

.refresh-btn:hover {
  background: #0ba5c7;
  transform: translateY(-2px);
}

/* Orders Table Container */
.orders-table-container {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #e1e5eb;
}

.table-wrapper {
  overflow-x: auto;
  padding: 20px;
}

.orders-table {
  width: 100%;
  border-collapse: collapse;
  min-width: 1200px;
}

.orders-table th {
  background: #f8fafc;
  padding: 18px 20px;
  text-align: left;
  font-weight: 600;
  color: #2c5530;
  border-bottom: 2px solid #e1e5eb;
  font-size: 14px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.orders-table td {
  padding: 20px;
  border-bottom: 1px solid #f1f5f9;
  vertical-align: top;
}

.orders-table tr:last-child td {
  border-bottom: none;
}

.orders-table tr:hover {
  background: #f8fafc;
}

.text-center {
  text-align: center;
}

/* Order ID Column */
.order-id {
  min-width: 120px;
}

.order-id-text {
  display: block;
  font-family: 'Courier New', monospace;
  font-weight: 600;
  color: #2c5530;
  font-size: 14px;
}

.order-time {
  display: block;
  color: #94a3b8;
  font-size: 12px;
  margin-top: 5px;
}

/* Customer Cell */
.customer-cell {
  min-width: 250px;
}

.customer-info {
  display: flex;
  gap: 15px;
  align-items: flex-start;
}

.customer-avatar {
  width: 50px;
  height: 50px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 20px;
  flex-shrink: 0;
}

.customer-details {
  flex: 1;
}

.customer-name {
  color: #2c5530;
  font-weight: 600;
  margin: 0 0 8px 0;
  font-size: 15px;
}

.customer-contact,
.customer-email,
.customer-address {
  color: #6c757d;
  font-size: 13px;
  margin: 4px 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.customer-contact i,
.customer-email i,
.customer-address i {
  width: 16px;
  color: #4a7c4a;
}

/* Product Cell */
.product-cell {
  min-width: 200px;
}

.product-info {
  display: flex;
  gap: 15px;
  align-items: center;
}

.product-image {
  width: 50px;
  height: 50px;
  border-radius: 8px;
  overflow: hidden;
  flex-shrink: 0;
}

.product-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.product-details {
  flex: 1;
}

.product-name {
  color: #2c5530;
  font-weight: 600;
  margin: 0 0 5px 0;
  font-size: 15px;
}

.product-category {
  color: #6c757d;
  font-size: 12px;
  margin: 0;
  background: #f1f5f9;
  padding: 4px 8px;
  border-radius: 4px;
  display: inline-block;
}

/* Quantity Cell */
.quantity-cell {
  min-width: 80px;
}

.quantity-badge {
  display: inline-block;
  background: #2c5530;
  color: white;
  padding: 6px 12px;
  border-radius: 20px;
  font-weight: 600;
  font-size: 14px;
}

.quantity-label {
  display: block;
  color: #94a3b8;
  font-size: 12px;
  margin-top: 5px;
}

/* Amount Cell */
.amount-cell {
  min-width: 120px;
}

.item-price {
  color: #2c5530;
  font-weight: 600;
  margin: 0 0 5px 0;
  font-size: 16px;
}

.total-amount {
  color: #198754;
  font-weight: 700;
  margin: 0 0 5px 0;
  font-size: 14px;
}

.shipping-charge {
  color: #6c757d;
  font-size: 12px;
  margin: 0;
}

/* Date Cell */
.date-cell {
  min-width: 120px;
}

.order-date {
  color: #2c5530;
  font-weight: 600;
  margin: 0 0 5px 0;
  font-size: 14px;
}

.order-day {
  color: #4a7c4a;
  font-weight: 500;
  margin: 0 0 5px 0;
  font-size: 13px;
}

.date-label {
  color: #94a3b8;
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

/* Status Cell */
.status-cell {
  min-width: 180px;
}

.status-selector {
  position: relative;
  margin-bottom: 10px;
}

.status-dropdown {
  width: 100%;
  padding: 8px 12px;
  border: 2px solid #e1e5eb;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  appearance: none;
  padding-right: 35px;
  transition: all 0.3s;
}

.status-dropdown:focus {
  outline: none;
  border-color: #2c5530;
}

.status-pending {
  background: #fff3cd;
  color: #856404;
  border-color: #ffeaa7;
}

.status-confirmed {
  background: #d1ecf1;
  color: #0c5460;
  border-color: #bee5eb;
}

.status-processing {
  background: #cce5ff;
  color: #004085;
  border-color: #b8daff;
}

.status-shipped {
  background: #d4edda;
  color: #155724;
  border-color: #c3e6cb;
}

.status-delivered {
  background: #d1e7dd;
  color: #0f5132;
  border-color: #badbcc;
}

.status-cancelled {
  background: #f8d7da;
  color: #721c24;
  border-color: #f5c6cb;
}

.status-indicator {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.status-indicator.status-pending {
  background: #ffc107;
}

.status-indicator.status-confirmed {
  background: #17a2b8;
}

.status-indicator.status-processing {
  background: #007bff;
}

.status-indicator.status-shipped {
  background: #28a745;
}

.status-indicator.status-delivered {
  background: #20c997;
}

.status-indicator.status-cancelled {
  background: #dc3545;
}

.status-actions {
  display: flex;
  gap: 5px;
  flex-wrap: wrap;
}

.quick-action-btn {
  padding: 4px 8px;
  border: none;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 4px;
  transition: all 0.3s;
}

.confirm-btn {
  background: #17a2b8;
  color: white;
}

.confirm-btn:hover {
  background: #138496;
}

.process-btn {
  background: #007bff;
  color: white;
}

.process-btn:hover {
  background: #0056b3;
}

.ship-btn {
  background: #28a745;
  color: white;
}

.ship-btn:hover {
  background: #1e7e34;
}

/* Actions Cell */
.actions-cell {
  min-width: 150px;
}

.action-buttons {
  display: flex;
  gap: 8px;
  justify-content: center;
}

.icon-btn {
  width: 36px;
  height: 36px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.view-btn {
  background: #0dcaf0;
  color: white;
}

.view-btn:hover {
  background: #0ba5c7;
  transform: translateY(-2px);
}

.edit-btn {
  background: #ffc107;
  color: white;
}

.edit-btn:hover {
  background: #e0a800;
  transform: translateY(-2px);
}

.delete-btn {
  background: #dc3545;
  color: white;
}

.delete-btn:hover {
  background: #c82333;
  transform: translateY(-2px);
}

.invoice-btn {
  background: #6f42c1;
  color: white;
}

.invoice-btn:hover {
  background: #5a32a3;
  transform: translateY(-2px);
}

/* Status Row Classes */
.status-row-pending {
  background: linear-gradient(90deg, rgba(255, 243, 205, 0.1), transparent);
}

.status-row-confirmed {
  background: linear-gradient(90deg, rgba(209, 236, 241, 0.1), transparent);
}

.status-row-processing {
  background: linear-gradient(90deg, rgba(204, 229, 255, 0.1), transparent);
}

.status-row-shipped {
  background: linear-gradient(90deg, rgba(212, 237, 218, 0.1), transparent);
}

.status-row-delivered {
  background: linear-gradient(90deg, rgba(209, 231, 221, 0.1), transparent);
}

.status-row-cancelled {
  background: linear-gradient(90deg, rgba(248, 215, 218, 0.1), transparent);
}

/* Empty State */
.empty-state {
  padding: 60px 20px;
  text-align: center;
  color: #6c757d;
}

.empty-icon {
  font-size: 64px;
  color: #cbd5e1;
  margin-bottom: 20px;
}

.empty-state h3 {
  color: #2c5530;
  margin: 0 0 10px 0;
  font-size: 20px;
}

.empty-state p {
  margin: 0 0 25px 0;
  color: #94a3b8;
}

.empty-btn {
  padding: 12px 30px;
  background: #2c5530;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s;
}

.empty-btn:hover {
  background: #1e3d23;
  transform: translateY(-2px);
}

/* Table Footer */
.table-footer {
  padding: 20px 30px;
  border-top: 2px solid #f1f5f9;
  background: #f8fafc;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}

.footer-info {
  color: #6c757d;
  font-size: 14px;
}

.search-info,
.status-info {
  color: #2c5530;
  font-weight: 500;
  margin-left: 10px;
}

.pagination {
  display: flex;
  align-items: center;
  gap: 15px;
}

.page-btn {
  width: 40px;
  height: 40px;
  border: 2px solid #e1e5eb;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.page-btn:hover:not(:disabled) {
  border-color: #2c5530;
  color: #2c5530;
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-info {
  color: #2c5530;
  font-weight: 500;
  font-size: 14px;
}

/* Order Modal */
.order-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 10000;
  padding: 20px;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal-content {
  position: relative;
  background: white;
  border-radius: 16px;
  max-width: 800px;
  max-height: 90vh;
  overflow: hidden;
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-close {
  position: absolute;
  top: 15px;
  right: 15px;
  width: 40px;
  height: 40px;
  background: #dc3545;
  color: white;
  border: none;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  z-index: 10001;
  transition: all 0.3s;
}

.modal-close:hover {
  background: #c82333;
  transform: rotate(90deg);
}

.modal-header {
  padding: 25px 30px;
  border-bottom: 1px solid #e1e5eb;
  background: #f8fafc;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h2 {
  margin: 0;
  color: #2c5530;
  font-size: 24px;
  font-weight: 700;
}

.order-status-badge {
  padding: 8px 20px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
}

.modal-body {
  padding: 30px;
  overflow-y: auto;
  max-height: calc(90vh - 200px);
}

.order-summary {
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.summary-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 30px;
}

.summary-col h4 {
  color: #2c5530;
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 15px 0;
}

.summary-col p {
  color: #6c757d;
  margin: 8px 0;
  font-size: 14px;
}

.summary-col p strong {
  color: #2c5530;
  min-width: 100px;
  display: inline-block;
}

.order-items {
  margin-top: 20px;
}

.order-items h4 {
  color: #2c5530;
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 15px 0;
}

.item-card {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 20px;
  background: #f8fafc;
  border-radius: 12px;
  border: 1px solid #e1e5eb;
}

.item-image {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  overflow: hidden;
  flex-shrink: 0;
}

.item-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.item-details {
  flex: 1;
}

.item-details h5 {
  color: #2c5530;
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 8px 0;
}

.item-details p {
  color: #6c757d;
  font-size: 14px;
  margin: 0 0 8px 0;
}

.item-meta {
  display: flex;
  gap: 20px;
  font-size: 14px;
  color: #2c5530;
  font-weight: 500;
}

.item-total {
  text-align: right;
}

.item-total h5 {
  color: #198754;
  font-size: 20px;
  font-weight: 700;
  margin: 0;
}

.item-total small {
  color: #94a3b8;
  font-size: 12px;
}

.order-totals {
  background: #f8fafc;
  padding: 20px;
  border-radius: 12px;
  border: 1px solid #e1e5eb;
}

.totals-row {
  display: flex;
  justify-content: space-between;
  padding: 10px 0;
  border-bottom: 1px dashed #e1e5eb;
}

.totals-row:last-child {
  border-bottom: none;
}

.totals-row.total {
  padding-top: 15px;
  border-top: 2px solid #2c5530;
}

.status-timeline {
  margin-top: 30px;
}

.status-timeline h4 {
  color: #2c5530;
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 20px 0;
}

.timeline {
  display: flex;
  justify-content: space-between;
  position: relative;
}

.timeline::before {
  content: '';
  position: absolute;
  top: 25px;
  left: 0;
  right: 0;
  height: 2px;
  background: #e1e5eb;
  z-index: 1;
}

.timeline-step {
  position: relative;
  z-index: 2;
  text-align: center;
  flex: 1;
}

.timeline-icon {
  width: 50px;
  height: 50px;
  background: white;
  border: 2px solid #e1e5eb;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 10px;
  font-size: 20px;
  color: #94a3b8;
  transition: all 0.3s;
}

.timeline-step.active .timeline-icon {
  background: #2c5530;
  border-color: #2c5530;
  color: white;
}

.timeline-step.current .timeline-icon {
  transform: scale(1.1);
  box-shadow: 0 0 0 4px rgba(44, 85, 48, 0.2);
}

.timeline-label p {
  color: #6c757d;
  font-size: 12px;
  margin: 0;
}

.timeline-label small {
  color: #2c5530;
  font-weight: 600;
  font-size: 11px;
}

.modal-footer {
  padding: 20px 30px;
  border-top: 1px solid #e1e5eb;
  background: #f8fafc;
  display: flex;
  gap: 15px;
  justify-content: flex-end;
}

.modal-btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s;
}

.primary-btn {
  background: #2c5530;
  color: white;
}

.primary-btn:hover {
  background: #1e3d23;
  transform: translateY(-2px);
}

.secondary-btn {
  background: #6c757d;
  color: white;
}

.secondary-btn:hover {
  background: #545b62;
  transform: translateY(-2px);
}

.action-btn {
  background: #0dcaf0;
  color: white;
}

.action-btn:hover {
  background: #0ba5c7;
  transform: translateY(-2px);
}

/* Responsive Design */
@media (max-width: 1200px) {
  .header-stats {
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  }
}

@media (max-width: 992px) {
  .dashboard-layout {
    padding: 15px;
  }
  
  .filter-group {
    flex-direction: column;
    align-items: stretch;
  }
  
  .search-box {
    min-width: 100%;
  }
  
  .filter-options {
    flex-wrap: wrap;
  }
}

@media (max-width: 768px) {
  .dashboard-header {
    padding: 20px;
  }
  
  .dashboard-title {
    font-size: 24px;
  }
  
  .stat-card {
    padding: 15px;
  }
  
  .modal-content {
    max-width: 95%;
  }
  
  .summary-row {
    grid-template-columns: 1fr;
  }
  
  .timeline {
    flex-wrap: wrap;
    gap: 20px;
  }
  
  .timeline-step {
    flex: 0 0 calc(33.333% - 20px);
  }
  
  .modal-footer {
    flex-wrap: wrap;
  }
  
  .modal-btn {
    flex: 1;
    min-width: 150px;
  }
}

@media (max-width: 576px) {
  .timeline-step {
    flex: 0 0 calc(50% - 20px);
  }
  
  .item-card {
    flex-direction: column;
    text-align: center;
  }
  
  .item-meta {
    justify-content: center;
  }
}
</style>
