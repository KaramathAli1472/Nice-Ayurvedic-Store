<template>
  <div class="customers-dashboard">
    <!-- Dashboard Header -->
    <div class="dashboard-header">
      <div class="header-content">
        <h1 class="dashboard-title">
          <i class="fas fa-users"></i> Customers Management
        </h1>
        <p class="dashboard-subtitle">
          Manage and monitor all your Ayurvedic store customers
        </p>
      </div>
      <div class="header-stats">
        <div class="stat-card" v-for="stat in customerStats" :key="stat.label">
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
            placeholder="Search customers by name, phone or email..."
            class="search-input"
          />
        </div>
        
        <div class="filter-options">
          <select v-model="sortBy" class="filter-select">
            <option value="newest">Newest First</option>
            <option value="oldest">Oldest First</option>
            <option value="nameAsc">Name A-Z</option>
            <option value="nameDesc">Name Z-A</option>
          </select>
          
          <button class="refresh-btn" @click="fetchCustomers">
            <i class="fas fa-sync-alt"></i> Refresh
          </button>
          
          <button class="add-btn" @click="openAddModal">
            <i class="fas fa-user-plus"></i> Add Customer
          </button>
        </div>
      </div>
    </div>

    <!-- Customers Table -->
    <div class="customers-table-container">
      <div class="table-wrapper">
        <table class="customers-table">
          <thead>
            <tr>
              <th class="text-center">#</th>
              <th>Customer Details</th>
              <th>Contact Information</th>
              <th>Location</th>
              <th>Orders</th>
              <th>Joined Date</th>
              <th class="text-center">Actions</th>
            </tr>
          </thead>
          
          <tbody>
            <tr v-for="(customer, index) in filteredCustomers" :key="customer.id">
              <!-- Serial Number -->
              <td class="serial-number text-center">{{ index + 1 }}</td>
              
              <!-- Customer Details -->
              <td class="customer-details">
                <div class="customer-info">
                  <div class="customer-avatar" :class="getAvatarClass(customer)">
                    <span v-if="!customer.profileImage">
                      {{ getInitials(customer.name) }}
                    </span>
                    <img v-else :src="customer.profileImage" :alt="customer.name" />
                  </div>
                  <div class="customer-meta">
                    <h4 class="customer-name">{{ customer.name || "N/A" }}</h4>
                    <p class="customer-id">ID: {{ customer.id.substring(0, 8) }}</p>
                    <div class="customer-tags">
                      <span class="customer-tag" v-if="customer.isPremium">
                        <i class="fas fa-crown"></i> Premium
                      </span>
                      <span class="customer-tag" v-if="customer.totalOrders > 10">
                        <i class="fas fa-star"></i> Loyal
                      </span>
                    </div>
                  </div>
                </div>
              </td>
              
              <!-- Contact Information -->
              <td class="contact-info">
                <div class="contact-details">
                  <p class="contact-item">
                    <i class="fas fa-phone"></i>
                    <span>{{ customer.phone || "No phone" }}</span>
                  </p>
                  <p class="contact-item">
                    <i class="fas fa-envelope"></i>
                    <span>{{ customer.email || "No email" }}</span>
                  </p>
                  <div class="contact-actions">
                    <button 
                      v-if="customer.phone" 
                      class="contact-action call-btn"
                      @click="callCustomer(customer)"
                      title="Call Customer"
                    >
                      <i class="fas fa-phone-alt"></i>
                    </button>
                    <button 
                      v-if="customer.email" 
                      class="contact-action email-btn"
                      @click="emailCustomer(customer)"
                      title="Email Customer"
                    >
                      <i class="fas fa-envelope"></i>
                    </button>
                    <button 
                      v-if="customer.phone" 
                      class="contact-action whatsapp-btn"
                      @click="whatsappCustomer(customer)"
                      title="WhatsApp Customer"
                    >
                      <i class="fab fa-whatsapp"></i>
                    </button>
                  </div>
                </div>
              </td>
              
              <!-- Location -->
              <td class="location-info">
                <div class="location-details">
                  <p v-if="customer.address" class="address">
                    <i class="fas fa-map-marker-alt"></i>
                    {{ truncateText(customer.address, 30) }}
                  </p>
                  <p v-else class="address">
                    <i class="fas fa-map-marker-alt"></i>
                    Location not specified
                  </p>
                  <p v-if="customer.city" class="city-state">
                    {{ customer.city }}{{ customer.state ? ', ' + customer.state : '' }}
                  </p>
                </div>
              </td>
              
              <!-- Orders -->
              <td class="orders-info">
                <div class="orders-details">
                  <div class="orders-count">
                    <span class="count-number">{{ customer.totalOrders || 0 }}</span>
                    <small class="count-label">orders</small>
                  </div>
                  <div class="orders-amount">
                    <span class="amount">₹{{ formatNumber(customer.totalSpent || 0) }}</span>
                    <small class="amount-label">total spent</small>
                  </div>
                </div>
              </td>
              
              <!-- Joined Date -->
              <td class="date-info">
                <div class="date-details">
                  <p class="join-date">{{ formatDate(customer.createdAt) }}</p>
                  <p class="join-time">{{ formatTime(customer.createdAt) }}</p>
                  <small class="date-ago">{{ timeAgo(customer.createdAt) }}</small>
                </div>
              </td>
              
              <!-- Actions -->
              <td class="actions-cell text-center">
                <div class="action-buttons">
                  <button 
                    class="icon-btn view-btn"
                    @click="viewCustomer(customer)"
                    title="View Details"
                  >
                    <i class="fas fa-eye"></i>
                  </button>
                  <button 
                    class="icon-btn edit-btn"
                    @click="editCustomer(customer)"
                    title="Edit Customer"
                  >
                    <i class="fas fa-edit"></i>
                  </button>
                  <button 
                    class="icon-btn orders-btn"
                    @click="viewCustomerOrders(customer)"
                    title="View Orders"
                  >
                    <i class="fas fa-shopping-bag"></i>
                  </button>
                  <button 
                    class="icon-btn delete-btn"
                    @click="confirmDelete(customer)"
                    title="Delete Customer"
                  >
                    <i class="fas fa-trash"></i>
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
        
        <!-- Empty State -->
        <div v-if="filteredCustomers.length === 0" class="empty-state">
          <i class="fas fa-users empty-icon"></i>
          <h3>No Customers Found</h3>
          <p v-if="searchQuery">
            No customers match your search "{{ searchQuery }}"
          </p>
          <p v-else>
            Start by adding your first customer to the database
          </p>
          <button class="empty-btn" @click="openAddModal">
            <i class="fas fa-user-plus"></i> Add First Customer
          </button>
        </div>
      </div>
      
      <!-- Table Footer -->
      <div v-if="filteredCustomers.length > 0" class="table-footer">
        <div class="footer-info">
          <p>
            Showing <strong>{{ filteredCustomers.length }}</strong> of 
            <strong>{{ customers.length }}</strong> customers
            <span v-if="searchQuery" class="search-info">
              • Search: "{{ searchQuery }}"
            </span>
          </p>
        </div>
        <div class="footer-actions">
          <button class="export-btn" @click="exportCustomers">
            <i class="fas fa-file-export"></i> Export CSV
          </button>
        </div>
      </div>
    </div>

    <!-- Customer Details Modal -->
    <div v-if="selectedCustomer" class="customer-modal" @click="closeModal">
      <div class="modal-content" @click.stop>
        <button class="modal-close" @click="closeModal">
          <i class="fas fa-times"></i>
        </button>
        
        <div class="modal-header">
          <div class="customer-header">
            <div class="customer-avatar-large" :class="getAvatarClass(selectedCustomer)">
              <span v-if="!selectedCustomer.profileImage">
                {{ getInitials(selectedCustomer.name) }}
              </span>
              <img v-else :src="selectedCustomer.profileImage" :alt="selectedCustomer.name" />
            </div>
            <div class="customer-header-info">
              <h2>{{ selectedCustomer.name || "N/A" }}</h2>
              <p class="customer-id">Customer ID: {{ selectedCustomer.id.substring(0, 8) }}</p>
              <div class="customer-status">
                <span class="status-badge" :class="getStatusClass(selectedCustomer)">
                  {{ getStatusText(selectedCustomer) }}
                </span>
              </div>
            </div>
          </div>
        </div>
        
        <div class="modal-body">
          <div class="customer-details-grid">
            <!-- Personal Information -->
            <div class="detail-section">
              <h4><i class="fas fa-user-circle"></i> Personal Information</h4>
              <div class="detail-items">
                <div class="detail-item">
                  <label>Full Name</label>
                  <p>{{ selectedCustomer.name || "Not specified" }}</p>
                </div>
                <div class="detail-item">
                  <label>Email Address</label>
                  <p>{{ selectedCustomer.email || "Not provided" }}</p>
                </div>
                <div class="detail-item">
                  <label>Phone Number</label>
                  <p>{{ selectedCustomer.phone || "Not provided" }}</p>
                </div>
                <div class="detail-item">
                  <label>Customer Since</label>
                  <p>{{ formatFullDate(selectedCustomer.createdAt) }}</p>
                </div>
              </div>
            </div>
            
            <!-- Address Information -->
            <div class="detail-section">
              <h4><i class="fas fa-map-marked-alt"></i> Address Information</h4>
              <div class="detail-items">
                <div class="detail-item full-width">
                  <label>Address</label>
                  <p>{{ selectedCustomer.address || "Not provided" }}</p>
                </div>
                <div class="detail-item">
                  <label>City</label>
                  <p>{{ selectedCustomer.city || "Not specified" }}</p>
                </div>
                <div class="detail-item">
                  <label>State</label>
                  <p>{{ selectedCustomer.state || "Not specified" }}</p>
                </div>
                <div class="detail-item">
                  <label>PIN Code</label>
                  <p>{{ selectedCustomer.pincode || "Not specified" }}</p>
                </div>
              </div>
            </div>
            
            <!-- Order Statistics -->
            <div class="detail-section stats-section">
              <h4><i class="fas fa-chart-line"></i> Order Statistics</h4>
              <div class="stats-grid">
                <div class="stat-box">
                  <div class="stat-value">{{ selectedCustomer.totalOrders || 0 }}</div>
                  <div class="stat-label">Total Orders</div>
                </div>
                <div class="stat-box">
                  <div class="stat-value">₹{{ formatNumber(selectedCustomer.totalSpent || 0) }}</div>
                  <div class="stat-label">Total Spent</div>
                </div>
                <div class="stat-box">
                  <div class="stat-value">
                    ₹{{ selectedCustomer.totalOrders ? formatNumber((selectedCustomer.totalSpent || 0) / selectedCustomer.totalOrders) : 0 }}
                  </div>
                  <div class="stat-label">Avg. Order Value</div>
                </div>
                <div class="stat-box">
                  <div class="stat-value">
                    {{ selectedCustomer.lastOrderDate ? timeAgo(selectedCustomer.lastOrderDate) : "Never" }}
                  </div>
                  <div class="stat-label">Last Order</div>
                </div>
              </div>
            </div>
            
            <!-- Recent Orders -->
            <div class="detail-section orders-section" v-if="customerOrders.length > 0">
              <h4><i class="fas fa-shopping-bag"></i> Recent Orders</h4>
              <div class="orders-list">
                <div v-for="order in customerOrders" :key="order.id" class="order-item">
                  <div class="order-header">
                    <span class="order-id">Order #{{ order.id.substring(0, 8) }}</span>
                    <span class="order-date">{{ formatDate(order.createdAt) }}</span>
                  </div>
                  <div class="order-details">
                    <p class="order-product">{{ order.productName }}</p>
                    <div class="order-meta">
                      <span class="order-quantity">Qty: {{ order.quantity }}</span>
                      <span class="order-price">₹{{ formatNumber(order.price) }}</span>
                      <span class="order-status" :class="getOrderStatusClass(order.status)">
                        {{ order.status }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="modal-footer">
          <button class="modal-btn secondary-btn" @click="closeModal">
            <i class="fas fa-times"></i> Close
          </button>
          <button class="modal-btn edit-btn" @click="editCustomer(selectedCustomer)">
            <i class="fas fa-edit"></i> Edit Customer
          </button>
          <button class="modal-btn primary-btn" @click="emailCustomer(selectedCustomer)" v-if="selectedCustomer.email">
            <i class="fas fa-envelope"></i> Send Email
          </button>
        </div>
      </div>
    </div>

    <!-- Add Customer Modal -->
    <div v-if="showAddModal" class="add-modal" @click="closeAddModal">
      <div class="modal-content" @click.stop>
        <button class="modal-close" @click="closeAddModal">
          <i class="fas fa-times"></i>
        </button>
        
        <div class="modal-header">
          <h2><i class="fas fa-user-plus"></i> Add New Customer</h2>
        </div>
        
        <div class="modal-body">
          <form @submit.prevent="addCustomer" class="add-form">
            <div class="form-group">
              <label><i class="fas fa-user"></i> Full Name *</label>
              <input 
                type="text" 
                v-model="newCustomer.name" 
                required 
                placeholder="Enter customer full name"
                class="form-input"
              />
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label><i class="fas fa-phone"></i> Phone Number *</label>
                <input 
                  type="tel" 
                  v-model="newCustomer.phone" 
                  required 
                  placeholder="+91 9876543210"
                  class="form-input"
                />
              </div>
              <div class="form-group">
                <label><i class="fas fa-envelope"></i> Email Address</label>
                <input 
                  type="email" 
                  v-model="newCustomer.email" 
                  placeholder="customer@example.com"
                  class="form-input"
                />
              </div>
            </div>
            
            <div class="form-group">
              <label><i class="fas fa-map-marker-alt"></i> Address</label>
              <textarea 
                v-model="newCustomer.address" 
                placeholder="Enter full address"
                rows="3"
                class="form-textarea"
              ></textarea>
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label>City</label>
                <input 
                  type="text" 
                  v-model="newCustomer.city" 
                  placeholder="City"
                  class="form-input"
                />
              </div>
              <div class="form-group">
                <label>State</label>
                <input 
                  type="text" 
                  v-model="newCustomer.state" 
                  placeholder="State"
                  class="form-input"
                />
              </div>
              <div class="form-group">
                <label>PIN Code</label>
                <input 
                  type="text" 
                  v-model="newCustomer.pincode" 
                  placeholder="PIN Code"
                  class="form-input"
                />
              </div>
            </div>
            
            <div class="form-actions">
              <button type="button" class="cancel-btn" @click="closeAddModal">
                Cancel
              </button>
              <button type="submit" class="submit-btn">
                <i class="fas fa-save"></i> Save Customer
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed } from "vue";
import { 
  collection, 
  getDocs, 
  deleteDoc, 
  doc, 
  addDoc,
  query,
  orderBy,
  where 
} from "firebase/firestore";
import { db } from "../../firebase";

export default {
  name: "CustomersDashboard",
  
  setup() {
    const customers = ref([]);
    const selectedCustomer = ref(null);
    const showAddModal = ref(false);
    const searchQuery = ref("");
    const sortBy = ref("newest");
    const customerOrders = ref([]);
    
    // New customer form data
    const newCustomer = ref({
      name: "",
      phone: "",
      email: "",
      address: "",
      city: "",
      state: "",
      pincode: ""
    });

    // Computed properties
    const customerStats = computed(() => {
      const total = customers.value.length;
      const totalOrders = customers.value.reduce((sum, cust) => sum + (cust.totalOrders || 0), 0);
      const totalSpent = customers.value.reduce((sum, cust) => sum + (cust.totalSpent || 0), 0);
      const newCustomers = customers.value.filter(cust => {
        const createdDate = cust.createdAt?.toDate ? cust.createdAt.toDate() : new Date(cust.createdAt);
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
        return createdDate > sevenDaysAgo;
      }).length;

      return [
        {
          label: "Total Customers",
          value: total,
          icon: "fas fa-users",
          class: "total-customers"
        },
        {
          label: "Total Orders",
          value: totalOrders,
          icon: "fas fa-shopping-bag",
          class: "total-orders"
        },
        {
          label: "Total Revenue",
          value: `₹${formatNumber(totalSpent)}`,
          icon: "fas fa-rupee-sign",
          class: "total-revenue"
        },
        {
          label: "New (7 days)",
          value: newCustomers,
          icon: "fas fa-user-plus",
          class: "new-customers"
        }
      ];
    });

    const filteredCustomers = computed(() => {
      let filtered = [...customers.value];
      
      // Apply search filter
      if (searchQuery.value.trim()) {
        const query = searchQuery.value.toLowerCase();
        filtered = filtered.filter(customer => 
          customer.name?.toLowerCase().includes(query) ||
          customer.phone?.includes(query) ||
          customer.email?.toLowerCase().includes(query) ||
          customer.address?.toLowerCase().includes(query)
        );
      }
      
      // Apply sorting
      filtered.sort((a, b) => {
        switch (sortBy.value) {
          case "oldest":
            const dateA = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt);
            const dateB = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt);
            return dateA - dateB;
          case "nameAsc":
            return (a.name || "").localeCompare(b.name || "");
          case "nameDesc":
            return (b.name || "").localeCompare(a.name || "");
          case "newest":
          default:
            const dateA2 = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt);
            const dateB2 = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt);
            return dateB2 - dateA2;
        }
      });
      
      return filtered;
    });

    // Methods
    const fetchCustomers = async () => {
      try {
        const customersRef = collection(db, "customers");
        const q = query(customersRef, orderBy("createdAt", "desc"));
        const snapshot = await getDocs(q);
        
        customers.value = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));
      } catch (error) {
        console.error("Error fetching customers:", error);
        showToast("Error loading customers", "error");
      }
    };

    const deleteCustomer = async (id) => {
      try {
        await deleteDoc(doc(db, "customers", id));
        customers.value = customers.value.filter(c => c.id !== id);
        showToast("Customer deleted successfully", "success");
      } catch (error) {
        console.error("Error deleting customer:", error);
        showToast("Error deleting customer", "error");
      }
    };

    const confirmDelete = (customer) => {
      if (confirm(`Are you sure you want to delete customer "${customer.name}"?`)) {
        deleteCustomer(customer.id);
      }
    };

    const addCustomer = async () => {
      try {
        const customerData = {
          ...newCustomer.value,
          createdAt: new Date(),
          totalOrders: 0,
          totalSpent: 0,
          lastOrderDate: null
        };
        
        const docRef = await addDoc(collection(db, "customers"), customerData);
        
        // Add to local state
        customers.value.unshift({
          id: docRef.id,
          ...customerData
        });
        
        showToast("Customer added successfully", "success");
        closeAddModal();
        resetNewCustomer();
      } catch (error) {
        console.error("Error adding customer:", error);
        showToast("Error adding customer", "error");
      }
    };

    const viewCustomer = async (customer) => {
      selectedCustomer.value = customer;
      
      // Fetch customer orders
      try {
        const ordersRef = collection(db, "orders");
        const q = query(ordersRef, where("customerId", "==", customer.id), orderBy("createdAt", "desc"));
        const snapshot = await getDocs(q);
        customerOrders.value = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));
      } catch (error) {
        console.error("Error fetching customer orders:", error);
        customerOrders.value = [];
      }
    };

    const editCustomer = (customer) => {
      alert(`Edit customer "${customer.name}" - Feature to be implemented`);
    };

    const viewCustomerOrders = (customer) => {
      alert(`View orders for "${customer.name}" - Feature to be implemented`);
    };

    const callCustomer = (customer) => {
      if (customer.phone) {
        window.location.href = `tel:${customer.phone}`;
      }
    };

    const emailCustomer = (customer) => {
      if (customer.email) {
        window.location.href = `mailto:${customer.email}`;
      }
    };

    const whatsappCustomer = (customer) => {
      if (customer.phone) {
        const message = encodeURIComponent(`Hello ${customer.name},`);
        window.open(`https://wa.me/${customer.phone}?text=${message}`, '_blank');
      }
    };

    const exportCustomers = () => {
      const csvContent = [
        ['Name', 'Phone', 'Email', 'Address', 'City', 'State', 'PIN Code', 'Total Orders', 'Total Spent', 'Created Date'].join(','),
        ...filteredCustomers.value.map(customer => [
          `"${customer.name || ''}"`,
          `"${customer.phone || ''}"`,
          `"${customer.email || ''}"`,
          `"${customer.address || ''}"`,
          `"${customer.city || ''}"`,
          `"${customer.state || ''}"`,
          `"${customer.pincode || ''}"`,
          customer.totalOrders || 0,
          customer.totalSpent || 0,
          `"${formatDate(customer.createdAt)}"`
        ].join(','))
      ].join('\n');
      
      const blob = new Blob([csvContent], { type: 'text/csv' });
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `customers_${new Date().toISOString().split('T')[0]}.csv`;
      a.click();
      window.URL.revokeObjectURL(url);
      
      showToast('Customers exported successfully', 'success');
    };

    const openAddModal = () => {
      showAddModal.value = true;
    };

    const closeAddModal = () => {
      showAddModal.value = false;
      resetNewCustomer();
    };

    const closeModal = () => {
      selectedCustomer.value = null;
      customerOrders.value = [];
    };

    const resetNewCustomer = () => {
      newCustomer.value = {
        name: "",
        phone: "",
        email: "",
        address: "",
        city: "",
        state: "",
        pincode: ""
      };
    };

    // Helper methods
    const getAvatarClass = (customer) => {
      const colors = ['avatar-blue', 'avatar-green', 'avatar-purple', 'avatar-orange'];
      const index = customer.name ? customer.name.charCodeAt(0) % colors.length : 0;
      return colors[index];
    };

    const getInitials = (name) => {
      if (!name) return '?';
      return name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2);
    };

    const getStatusClass = (customer) => {
      if (customer.totalOrders > 10) return 'status-premium';
      if (customer.totalOrders > 0) return 'status-active';
      return 'status-inactive';
    };

    const getStatusText = (customer) => {
      if (customer.totalOrders > 10) return 'Premium';
      if (customer.totalOrders > 0) return 'Active';
      return 'New';
    };

    const getOrderStatusClass = (status) => {
      switch (status?.toLowerCase()) {
        case 'delivered': return 'status-delivered';
        case 'shipped': return 'status-shipped';
        case 'processing': return 'status-processing';
        case 'pending': return 'status-pending';
        default: return 'status-pending';
      }
    };

    const formatDate = (date) => {
      if (!date) return "—";
      const dateObj = date.toDate ? date.toDate() : new Date(date);
      return dateObj.toLocaleDateString('en-IN');
    };

    const formatFullDate = (date) => {
      if (!date) return "—";
      const dateObj = date.toDate ? date.toDate() : new Date(date);
      return dateObj.toLocaleDateString('en-IN', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      });
    };

    const formatTime = (date) => {
      if (!date) return "";
      const dateObj = date.toDate ? date.toDate() : new Date(date);
      return dateObj.toLocaleTimeString('en-IN', { 
        hour: '2-digit', 
        minute: '2-digit' 
      });
    };

    const timeAgo = (date) => {
      if (!date) return "Never";
      const dateObj = date.toDate ? date.toDate() : new Date(date);
      const now = new Date();
      const seconds = Math.floor((now - dateObj) / 1000);
      
      if (seconds < 60) return "Just now";
      
      const minutes = Math.floor(seconds / 60);
      if (minutes < 60) return `${minutes}m ago`;
      
      const hours = Math.floor(minutes / 60);
      if (hours < 24) return `${hours}h ago`;
      
      const days = Math.floor(hours / 24);
      if (days < 30) return `${days}d ago`;
      
      const months = Math.floor(days / 30);
      if (months < 12) return `${months}mo ago`;
      
      const years = Math.floor(months / 12);
      return `${years}y ago`;
    };

    const formatNumber = (num) => {
      return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    };

    const truncateText = (text, length) => {
      if (!text) return "";
      if (text.length <= length) return text;
      return text.substring(0, length) + "...";
    };

    const showToast = (message, type) => {
      alert(message); // Replace with actual toast implementation
    };

    onMounted(() => {
      fetchCustomers();
    });

    return {
      customers,
      selectedCustomer,
      showAddModal,
      searchQuery,
      sortBy,
      newCustomer,
      customerOrders,
      customerStats,
      filteredCustomers,
      fetchCustomers,
      deleteCustomer,
      confirmDelete,
      addCustomer,
      viewCustomer,
      editCustomer,
      viewCustomerOrders,
      callCustomer,
      emailCustomer,
      whatsappCustomer,
      exportCustomers,
      openAddModal,
      closeAddModal,
      closeModal,
      getAvatarClass,
      getInitials,
      getStatusClass,
      getStatusText,
      getOrderStatusClass,
      formatDate,
      formatFullDate,
      formatTime,
      timeAgo,
      formatNumber,
      truncateText
    };
  }
};
</script>

<style scoped>
/* Dashboard Container */
.customers-dashboard {
  padding: 30px;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4e8f0 100%);
  min-height: 100vh;
}

/* Dashboard Header */
.dashboard-header {
  background: white;
  border-radius: 16px;
  padding: 30px;
  margin-bottom: 30px;
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
  border-color: #2c5530;
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

.stat-icon.total-customers {
  background: linear-gradient(135deg, #667eea, #764ba2);
}

.stat-icon.total-orders {
  background: linear-gradient(135deg, #4facfe, #00f2fe);
}

.stat-icon.total-revenue {
  background: linear-gradient(135deg, #fa709a, #fee140);
}

.stat-icon.new-customers {
  background: linear-gradient(135deg, #43e97b, #38f9d7);
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

.refresh-btn, .add-btn {
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

.refresh-btn {
  background: #0dcaf0;
  color: white;
}

.refresh-btn:hover {
  background: #0ba5c7;
  transform: translateY(-2px);
}

.add-btn {
  background: #2c5530;
  color: white;
}

.add-btn:hover {
  background: #1e3d23;
  transform: translateY(-2px);
}

/* Customers Table Container */
.customers-table-container {
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

.customers-table {
  width: 100%;
  border-collapse: collapse;
  min-width: 1000px;
}

.customers-table th {
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

.customers-table td {
  padding: 20px;
  border-bottom: 1px solid #f1f5f9;
  vertical-align: top;
}

.customers-table tr:last-child td {
  border-bottom: none;
}

.customers-table tr:hover {
  background: #f8fafc;
}

.text-center {
  text-align: center;
}

/* Serial Number */
.serial-number {
  font-weight: 600;
  color: #6c757d;
  font-size: 16px;
}

/* Customer Details Column */
.customer-details {
  min-width: 200px;
}

.customer-info {
  display: flex;
  gap: 15px;
  align-items: center;
}

.customer-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  color: white;
  font-size: 18px;
  flex-shrink: 0;
}

.customer-avatar img {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  object-fit: cover;
}

.avatar-blue {
  background: linear-gradient(135deg, #667eea, #764ba2);
}

.avatar-green {
  background: linear-gradient(135deg, #43e97b, #38f9d7);
}

.avatar-purple {
  background: linear-gradient(135deg, #fa709a, #fee140);
}

.avatar-orange {
  background: linear-gradient(135deg, #f093fb, #f5576c);
}

.customer-meta {
  flex: 1;
}

.customer-name {
  color: #2c5530;
  font-weight: 600;
  margin: 0 0 5px 0;
  font-size: 15px;
}

.customer-id {
  color: #94a3b8;
  font-size: 12px;
  margin: 0 0 8px 0;
}

.customer-tags {
  display: flex;
  gap: 5px;
  flex-wrap: wrap;
}

.customer-tag {
  background: #e9f7ef;
  color: #2c5530;
  padding: 2px 8px;
  border-radius: 10px;
  font-size: 11px;
  font-weight: 500;
  display: inline-flex;
  align-items: center;
  gap: 3px;
}

/* Contact Information Column */
.contact-info {
  min-width: 180px;
}

.contact-details {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.contact-item {
  color: #6c757d;
  font-size: 14px;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.contact-item i {
  color: #4a7c4a;
  width: 16px;
}

.contact-actions {
  display: flex;
  gap: 8px;
  margin-top: 10px;
}

.contact-action {
  width: 30px;
  height: 30px;
  border: none;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 12px;
  transition: all 0.3s;
}

.call-btn {
  background: #28a745;
}

.call-btn:hover {
  background: #1e7e34;
  transform: translateY(-2px);
}

.email-btn {
  background: #17a2b8;
}

.email-btn:hover {
  background: #138496;
  transform: translateY(-2px);
}

.whatsapp-btn {
  background: #25d366;
}

.whatsapp-btn:hover {
  background: #1da851;
  transform: translateY(-2px);
}

/* Location Column */
.location-info {
  min-width: 150px;
}

.location-details {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.address {
  color: #6c757d;
  font-size: 14px;
  margin: 0;
  display: flex;
  align-items: flex-start;
  gap: 8px;
}

.address i {
  color: #4a7c4a;
  margin-top: 3px;
  flex-shrink: 0;
}

.city-state {
  color: #2c5530;
  font-size: 13px;
  font-weight: 500;
  margin: 0;
}

/* Orders Column */
.orders-info {
  min-width: 120px;
}

.orders-details {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.orders-count, .orders-amount {
  display: flex;
  align-items: baseline;
  gap: 5px;
}

.count-number, .amount {
  color: #2c5530;
  font-weight: 700;
  font-size: 16px;
}

.count-label, .amount-label {
  color: #94a3b8;
  font-size: 12px;
}

/* Date Column */
.date-info {
  min-width: 120px;
}

.date-details {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.join-date {
  color: #2c5530;
  font-weight: 600;
  font-size: 14px;
  margin: 0;
}

.join-time {
  color: #6c757d;
  font-size: 13px;
  margin: 0;
}

.date-ago {
  color: #94a3b8;
  font-size: 11px;
}

/* Actions Column */
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

.orders-btn {
  background: #6f42c1;
  color: white;
}

.orders-btn:hover {
  background: #5a32a3;
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

.search-info {
  color: #2c5530;
  font-weight: 500;
  margin-left: 10px;
}

.export-btn {
  padding: 10px 20px;
  background: #198754;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.export-btn:hover {
  background: #157347;
  transform: translateY(-2px);
}

/* Customer Details Modal */
.customer-modal, .add-modal {
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
}

.customer-header {
  display: flex;
  align-items: center;
  gap: 20px;
}

.customer-avatar-large {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  color: white;
  font-size: 36px;
  flex-shrink: 0;
}

.customer-avatar-large img {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  object-fit: cover;
}

.customer-header-info {
  flex: 1;
}

.customer-header-info h2 {
  color: #2c5530;
  font-size: 28px;
  font-weight: 700;
  margin: 0 0 5px 0;
}

.customer-id {
  color: #6c757d;
  font-size: 14px;
  margin: 0 0 10px 0;
}

.customer-status {
  display: flex;
  gap: 10px;
}

.status-badge {
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  display: inline-block;
}

.status-premium {
  background: linear-gradient(135deg, #fa709a, #fee140);
  color: #000;
}

.status-active {
  background: #d4edda;
  color: #155724;
}

.status-inactive {
  background: #f8d7da;
  color: #721c24;
}

.modal-body {
  padding: 30px;
  overflow-y: auto;
  max-height: calc(90vh - 200px);
}

.customer-details-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 30px;
}

.detail-section {
  padding: 20px;
  background: #f8fafc;
  border-radius: 12px;
  border: 1px solid #e1e5eb;
}

.detail-section h4 {
  color: #2c5530;
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 20px 0;
  display: flex;
  align-items: center;
  gap: 10px;
}

.detail-items {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
}

.detail-item.full-width {
  grid-column: 1 / -1;
}

.detail-item label {
  display: block;
  color: #6c757d;
  font-size: 12px;
  font-weight: 500;
  margin-bottom: 4px;
}

.detail-item p {
  color: #2c5530;
  font-weight: 500;
  margin: 0;
  font-size: 14px;
}

.stats-section .stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 15px;
}

.stat-box {
  padding: 15px;
  background: white;
  border-radius: 8px;
  border: 1px solid #e1e5eb;
  text-align: center;
}

.stat-value {
  color: #2c5530;
  font-size: 20px;
  font-weight: 700;
  margin-bottom: 5px;
}

.stat-label {
  color: #6c757d;
  font-size: 12px;
}

.orders-section .orders-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.order-item {
  padding: 15px;
  background: white;
  border-radius: 8px;
  border: 1px solid #e1e5eb;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.order-id {
  color: #2c5530;
  font-weight: 600;
  font-size: 14px;
}

.order-date {
  color: #6c757d;
  font-size: 12px;
}

.order-details .order-product {
  color: #495057;
  font-weight: 500;
  margin: 0 0 8px 0;
  font-size: 14px;
}

.order-meta {
  display: flex;
  gap: 15px;
  font-size: 13px;
}

.order-quantity, .order-price {
  color: #6c757d;
}

.order-status {
  padding: 2px 8px;
  border-radius: 10px;
  font-size: 11px;
  font-weight: 500;
}

.status-delivered {
  background: #d4edda;
  color: #155724;
}

.status-shipped {
  background: #cce5ff;
  color: #004085;
}

.status-processing {
  background: #fff3cd;
  color: #856404;
}

.status-pending {
  background: #f8d7da;
  color: #721c24;
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

/* Add Customer Form */
.add-form {
  padding: 20px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #2c5530;
  font-weight: 600;
  margin-bottom: 8px;
  font-size: 14px;
}

.form-input, .form-textarea {
  width: 100%;
  padding: 12px 15px;
  border: 2px solid #e1e5eb;
  border-radius: 8px;
  font-size: 14px;
  color: #495057;
  background: #f8fafc;
  transition: all 0.3s;
}

.form-input:focus, .form-textarea:focus {
  outline: none;
  border-color: #2c5530;
  background: white;
  box-shadow: 0 0 0 4px rgba(44, 85, 48, 0.1);
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
}

.form-actions {
  display: flex;
  gap: 15px;
  justify-content: flex-end;
  margin-top: 30px;
}

.cancel-btn, .submit-btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.cancel-btn {
  background: #6c757d;
  color: white;
}

.cancel-btn:hover {
  background: #545b62;
  transform: translateY(-2px);
}

.submit-btn {
  background: #2c5530;
  color: white;
  display: flex;
  align-items: center;
  gap: 10px;
}

.submit-btn:hover {
  background: #1e3d23;
  transform: translateY(-2px);
}

/* Responsive Design */
@media (max-width: 1200px) {
  .header-stats {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .customers-dashboard {
    padding: 15px;
  }
  
  .dashboard-header {
    padding: 20px;
  }
  
  .dashboard-title {
    font-size: 24px;
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
  
  .modal-content {
    max-width: 95%;
  }
  
  .customer-header {
    flex-direction: column;
    text-align: center;
  }
  
  .detail-items,
  .stats-grid {
    grid-template-columns: 1fr;
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
  .stat-card {
    flex-direction: column;
    text-align: center;
    gap: 15px;
  }
  
  .action-buttons {
    flex-wrap: wrap;
    justify-content: center;
  }
  
  .form-row {
    grid-template-columns: 1fr;
  }
}
</style>