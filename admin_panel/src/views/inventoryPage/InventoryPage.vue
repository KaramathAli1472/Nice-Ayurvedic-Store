<template>
  <div class="inventory-page">
    <!-- Page Header -->
    <div class="page-header">
      <h1><i class="fas fa-boxes"></i> Inventory Management</h1>
      <div class="header-actions">
        <button class="stock-btn" @click="updateStock" title="Update stock for multiple products">
          <i class="fas fa-edit"></i> Bulk Update Stock
        </button>
        <button class="export-btn" @click="exportInventory" title="Export inventory data to CSV/Excel">
          <i class="fas fa-file-export"></i> Export Inventory
        </button>
      </div>
    </div>

    <!-- Inventory Filters -->
    <div class="filters-section">
      <div class="filter-group">
        <div class="search-box">
          <i class="fas fa-search"></i>
          <input
            type="text"
            v-model="searchQuery"
            placeholder="Search by product name or SKU..."
            @input="filterProducts"
          />
        </div>
      </div>
      
      <div class="filter-group">
        <select v-model="categoryFilter" @change="filterProducts" title="Filter by category">
          <option value="">All Categories</option>
          <option v-for="category in categories" :key="category.id" :value="category.name">
            {{ category.name }}
          </option>
        </select>
        
        <select v-model="stockFilter" @change="filterProducts" title="Filter by stock status">
          <option value="">All Stock Status</option>
          <option value="in-stock">✅ In Stock (>20)</option>
          <option value="low-stock">⚠️ Low Stock (1-20)</option>
          <option value="out-stock">❌ Out of Stock (0)</option>
        </select>
        
        <button class="clear-filters" @click="clearFilters" title="Clear all filters">
          <i class="fas fa-times"></i> Clear Filters
        </button>
      </div>
    </div>

    <!-- Inventory Summary -->
    <div class="summary-cards">
      <div class="summary-card">
        <div class="summary-icon" style="background: #10b981">
          <i class="fas fa-check-circle"></i>
        </div>
        <div class="summary-content">
          <h3>In Stock</h3>
          <p class="summary-number">{{ inStockCount }}</p>
          <p class="summary-text">Products with good stock</p>
        </div>
      </div>
      
      <div class="summary-card">
        <div class="summary-icon" style="background: #f59e0b">
          <i class="fas fa-exclamation-triangle"></i>
        </div>
        <div class="summary-content">
          <h3>Low Stock</h3>
          <p class="summary-number">{{ lowStockCount }}</p>
          <p class="summary-text">Need restocking soon</p>
        </div>
      </div>
      
      <div class="summary-card">
        <div class="summary-icon" style="background: #ef4444">
          <i class="fas fa-times-circle"></i>
        </div>
        <div class="summary-content">
          <h3>Out of Stock</h3>
          <p class="summary-number">{{ outOfStockCount }}</p>
          <p class="summary-text">Urgent attention needed</p>
        </div>
      </div>
      
      <div class="summary-card">
        <div class="summary-icon" style="background: #3b82f6">
          <i class="fas fa-rupee-sign"></i>
        </div>
        <div class="summary-content">
          <h3>Total Value</h3>
          <p class="summary-number">₹{{ formatNumber(totalInventoryValue) }}</p>
          <p class="summary-text">Current inventory worth</p>
        </div>
      </div>
    </div>

    <!-- Products Table -->
    <div class="inventory-table">
      <table>
        <thead>
          <tr>
            <th>Product</th>
            <th>SKU</th>
            <th>Category</th>
            <th>Current Stock</th>
            <th>Stock Status</th>
            <th>Last Updated</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="product in filteredProducts" :key="product.id">
            <td class="product-cell">
              <div class="product-info">
                <div class="product-image">
                  <img :src="product.image || 'https://via.placeholder.com/40'" :alt="product.name" />
                </div>
                <div class="product-details">
                  <div class="product-name">{{ product.name }}</div>
                  <div class="product-price">₹{{ formatNumber(product.price) }}</div>
                </div>
              </div>
            </td>
            <td>
              <span class="sku-badge" :title="product.sku || 'No SKU'">
                {{ product.sku || 'N/A' }}
              </span>
            </td>
            <td>{{ product.category || 'Uncategorized' }}</td>
            <td>
              <div class="stock-cell">
                <span class="stock-quantity">{{ product.stock || 0 }}</span>
                <div class="stock-bar-container" :title="`${product.stock || 0} units in stock`">
                  <div class="stock-bar">
                    <div 
                      class="stock-fill" 
                      :class="getStockLevelClass(product.stock || 0)"
                      :style="{ width: getStockPercentage(product.stock || 0, product.maxStock || 100) + '%' }"
                    ></div>
                  </div>
                  <span class="stock-percentage">
                    {{ Math.round(getStockPercentage(product.stock || 0, product.maxStock || 100)) }}%
                  </span>
                </div>
              </div>
            </td>
            <td>
              <span :class="['stock-status', getStockStatusClass(product.stock || 0)]" 
                    :title="getStockStatusTooltip(product.stock || 0)">
                <i :class="getStockStatusIcon(product.stock || 0)"></i>
                {{ getStockStatus(product.stock || 0) }}
              </span>
            </td>
            <td :title="formatFullDate(product.lastUpdated)">
              {{ formatDate(product.lastUpdated) }}
            </td>
            <td>
              <div class="action-buttons">
                <button class="action-btn edit" @click="editStock(product)" 
                        :title="`Edit stock for ${product.name}`">
                  <i class="fas fa-edit"></i>
                  <span class="btn-tooltip">Edit Stock</span>
                </button>
                
                <button class="action-btn restock" @click="quickRestock(product)"
                        :title="`Quick restock ${product.name}`">
                  <i class="fas fa-plus-circle"></i>
                  <span class="btn-tooltip">Quick Restock</span>
                </button>
                
                <button class="action-btn view" @click="viewProduct(product.id)" 
                        :title="`View ${product.name} details`">
                  <i class="fas fa-eye"></i>
                  <span class="btn-tooltip">View Details</span>
                </button>
                
                <button class="action-btn delete" @click="showDeleteConfirm(product)"
                        :title="`Delete ${product.name}`">
                  <i class="fas fa-trash"></i>
                  <span class="btn-tooltip">Delete</span>
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
      
      <!-- Empty State -->
      <div v-if="filteredProducts.length === 0" class="empty-state">
        <i class="fas fa-box-open"></i>
        <h3>No products found</h3>
        <p v-if="searchQuery || categoryFilter || stockFilter">
          Try changing your filters or search terms
        </p>
        <p v-else>
          No products in inventory. Add your first product!
        </p>
        <button class="add-product-btn" @click="addNewProduct">
          <i class="fas fa-plus"></i> Add New Product
        </button>
      </div>
    </div>

    <!-- Pagination -->
    <div class="pagination" v-if="filteredProducts.length > itemsPerPage">
      <button 
        class="page-btn prev" 
        :disabled="currentPage === 1" 
        @click="currentPage--"
        title="Previous page"
      >
        <i class="fas fa-chevron-left"></i>
        Previous
      </button>
      
      <div class="page-numbers">
        <button 
          v-for="page in getVisiblePages()" 
          :key="page"
          class="page-number"
          :class="{ active: page === currentPage }"
          @click="currentPage = page"
        >
          {{ page }}
        </button>
      </div>
      
      <button 
        class="page-btn next" 
        :disabled="currentPage === totalPages" 
        @click="currentPage++"
        title="Next page"
      >
        Next
        <i class="fas fa-chevron-right"></i>
      </button>
      
      <div class="page-info">
        Showing {{ ((currentPage - 1) * itemsPerPage) + 1 }} - 
        {{ Math.min(currentPage * itemsPerPage, filteredProducts.length) }} 
        of {{ filteredProducts.length }} products
      </div>
    </div>

    <!-- Stock Update Modal -->
    <div v-if="showStockModal" class="modal-overlay" @click="closeStockModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2><i class="fas fa-edit"></i> Update Stock</h2>
          <button class="close-btn" @click="closeStockModal" title="Close">
            <i class="fas fa-times"></i>
          </button>
        </div>
        
        <div v-if="selectedProduct" class="stock-modal-body">
          <div class="product-info-modal">
            <img :src="selectedProduct.image || 'https://via.placeholder.com/60'" :alt="selectedProduct.name" />
            <div>
              <h3>{{ selectedProduct.name }}</h3>
              <p><strong>SKU:</strong> {{ selectedProduct.sku || 'N/A' }}</p>
              <p><strong>Current Stock:</strong> 
                <span :class="['current-stock', getStockStatusClass(selectedProduct.stock || 0)]">
                  {{ selectedProduct.stock || 0 }} units
                </span>
              </p>
              <p><strong>Price:</strong> ₹{{ formatNumber(selectedProduct.price) }}</p>
            </div>
          </div>
          
          <div class="stock-update-form">
            <div class="form-group">
              <label><i class="fas fa-exchange-alt"></i> Stock Update Type</label>
              <div class="radio-group">
                <label class="radio-label" title="Add or remove stock from current quantity">
                  <input type="radio" v-model="stockUpdateType" value="adjust" />
                  <span class="radio-text">
                    <i class="fas fa-plus-minus"></i>
                    Adjust Stock
                    <small>Add or remove from current stock</small>
                  </span>
                </label>
                <label class="radio-label" title="Set exact stock quantity">
                  <input type="radio" v-model="stockUpdateType" value="set" />
                  <span class="radio-text">
                    <i class="fas fa-sliders-h"></i>
                    Set Exact Quantity
                    <small>Set specific stock level</small>
                  </span>
                </label>
              </div>
            </div>
            
            <div class="form-group">
              <label for="quantity">
                <i class="fas fa-boxes"></i>
                {{ stockUpdateType === 'adjust' ? 'Adjust Quantity' : 'Set Quantity' }}
              </label>
              <div class="quantity-input">
                <button class="qty-btn minus" @click="decrementQuantity" 
                        :disabled="stockUpdateType === 'set' && stockQuantity <= 0">
                  <i class="fas fa-minus"></i>
                </button>
                <input
                  type="number"
                  id="quantity"
                  v-model="stockQuantity"
                  :placeholder="stockUpdateType === 'adjust' ? 'e.g., +10 or -5' : 'Enter exact quantity'"
                  :min="stockUpdateType === 'set' ? '0' : null"
                />
                <button class="qty-btn plus" @click="incrementQuantity">
                  <i class="fas fa-plus"></i>
                </button>
              </div>
              <p v-if="stockUpdateType === 'adjust'" class="help-text">
                <i class="fas fa-info-circle"></i>
                Enter positive number to add stock, negative to remove stock
              </p>
            </div>
            
            <div class="form-group">
              <label for="reason"><i class="fas fa-clipboard-list"></i> Reason for Update</label>
              <select id="reason" v-model="updateReason">
                <option value="restock">📦 Restock from supplier</option>
                <option value="sale">💰 Sold to customer</option>
                <option value="damage">🚫 Damaged/Expired</option>
                <option value="return">↩️ Customer return</option>
                <option value="adjustment">🔧 Manual adjustment</option>
                <option value="other">❓ Other reason</option>
              </select>
            </div>
            
            <div class="form-group">
              <label for="notes"><i class="fas fa-sticky-note"></i> Notes (Optional)</label>
              <textarea
                id="notes"
                v-model="updateNotes"
                rows="3"
                placeholder="Add any additional notes about this stock update..."
              ></textarea>
            </div>
            
            <div class="preview-result" v-if="stockQuantity !== ''">
              <div class="preview-header">
                <i class="fas fa-calculator"></i>
                <h4>Update Preview</h4>
              </div>
              <div class="preview-details">
                <div class="preview-item">
                  <span>Current Stock:</span>
                  <strong>{{ selectedProduct.stock || 0 }} units</strong>
                </div>
                <div class="preview-item">
                  <span v-if="stockUpdateType === 'adjust'">
                    {{ parseInt(stockQuantity) >= 0 ? 'Adding' : 'Removing' }}:
                  </span>
                  <span v-else>Setting to:</span>
                  <strong :class="parseInt(stockQuantity) >= 0 ? 'positive' : 'negative'">
                    {{ Math.abs(parseInt(stockQuantity) || 0) }} units
                  </strong>
                </div>
                <div class="preview-item total">
                  <span>New Stock:</span>
                  <strong class="new-stock">{{ calculateNewStock() }} units</strong>
                </div>
                <div class="stock-status-preview">
                  <span>New Status:</span>
                  <span :class="['status-badge', getStockStatusClass(calculateNewStock())]">
                    {{ getStockStatus(calculateNewStock()) }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="modal-actions">
          <button type="button" class="cancel-btn" @click="closeStockModal">
            <i class="fas fa-times"></i> Cancel
          </button>
          <button type="button" class="save-btn" @click="saveStockUpdate" :disabled="!stockQuantity || stockQuantity === '0'">
            <i class="fas fa-save"></i> 
            {{ isBulkUpdate ? 'Update All' : 'Update Stock' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { collection, getDocs, updateDoc, doc, deleteDoc } from 'firebase/firestore'
import { db } from '@/firebase'
import { useRouter } from 'vue-router'

export default {
  name: 'InventoryPage',
  setup() {
    const router = useRouter()
    const products = ref([])
    const categories = ref([])
    const searchQuery = ref('')
    const categoryFilter = ref('')
    const stockFilter = ref('')
    const showStockModal = ref(false)
    const selectedProduct = ref(null)
    const stockUpdateType = ref('adjust')
    const stockQuantity = ref('')
    const updateReason = ref('restock')
    const updateNotes = ref('')
    const currentPage = ref(1)
    const itemsPerPage = 10
    const isBulkUpdate = ref(false)
    
    // Fetch products and categories
    const fetchData = async () => {
      try {
        // Fetch products
        const productsSnapshot = await getDocs(collection(db, 'products'))
        products.value = productsSnapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
          lastUpdated: doc.data().lastUpdated || new Date().toISOString()
        }))
        
        // Fetch categories
        const categoriesSnapshot = await getDocs(collection(db, 'categories'))
        categories.value = categoriesSnapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }))
        
        // If no categories, use defaults
        if (categories.value.length === 0) {
          categories.value = [
            { id: '1', name: 'Herbs & Powders' },
            { id: '2', name: 'Oils & Massage' },
            { id: '3', name: 'Capsules & Tablets' },
            { id: '4', name: 'Personal Care' },
            { id: '5', name: 'Immunity Boosters' },
            { id: '6', name: 'Digestive Care' }
          ]
        }
        
        // If no products, use sample data
        if (products.value.length === 0) {
  products.value = [
    {
      id: '1',
      name: 'Ashwagandha Powder',
      sku: 'ASH-100',
      category: 'Herbs & Powders',
      price: 500,
      stock: 45,
      maxStock: 100,
      image: 'https://via.placeholder.com/48/3B82F6/FFFFFF?text=AP',
      lastUpdated: '2024-01-15'
    },
    {
      id: '2',
      name: 'Triphala Churna',
      sku: 'TRI-200',
      category: 'Herbs & Powders',
      price: 350,
      stock: 12,
      maxStock: 100,
      image: 'https://via.placeholder.com/48/10B981/FFFFFF?text=TC',
      lastUpdated: '2024-01-14'
    },
    {
      id: '3',
      name: 'Moringa Capsules',
      sku: 'MOR-300',
      category: 'Capsules & Tablets',
      price: 250,
      stock: 32,
      maxStock: 100,
      image: 'https://via.placeholder.com/48/F59E0B/FFFFFF?text=MC',
      lastUpdated: '2024-01-14'
    },
    {
      id: '4',
      name: 'Neem Soap',
      sku: 'NEE-400',
      category: 'Personal Care',
      price: 120,
      stock: 8,
      maxStock: 100,
      image: 'https://via.placeholder.com/48/8B5CF6/FFFFFF?text=NS',
      lastUpdated: '2024-01-13'
    },
    {
      id: '5',
      name: 'Tulsi Drops',
      sku: 'TUL-500',
      category: 'Herbs & Powders',
      price: 200,
      stock: 25,
      maxStock: 100,
      image: 'https://via.placeholder.com/48/EC4899/FFFFFF?text=TD',
      lastUpdated: '2024-01-13'
    }
  ]
}
      } catch (error) {
        console.error('Error fetching data:', error)
      }
    }
    
    // Filter products based on search and filters
    const filteredProducts = computed(() => {
      let filtered = [...products.value]
      
      // Apply search filter
      if (searchQuery.value) {
        const query = searchQuery.value.toLowerCase()
        filtered = filtered.filter(product =>
          product.name.toLowerCase().includes(query) ||
          product.sku?.toLowerCase().includes(query)
        )
      }
      
      // Apply category filter
      if (categoryFilter.value) {
        filtered = filtered.filter(product => 
          product.category === categoryFilter.value
        )
      }
      
      // Apply stock filter
      if (stockFilter.value) {
        filtered = filtered.filter(product => {
          const stock = product.stock || 0
          if (stockFilter.value === 'in-stock') return stock > 20
          if (stockFilter.value === 'low-stock') return stock > 0 && stock <= 20
          if (stockFilter.value === 'out-stock') return stock === 0
          return true
        })
      }
      
      return filtered
    })
    
    // Get paginated products
    const paginatedProducts = computed(() => {
      const start = (currentPage.value - 1) * itemsPerPage
      const end = start + itemsPerPage
      return filteredProducts.value.slice(start, end)
    })
    
    // Calculate inventory stats
    const inStockCount = computed(() => {
      return products.value.filter(p => (p.stock || 0) > 20).length
    })
    
    const lowStockCount = computed(() => {
      return products.value.filter(p => (p.stock || 0) > 0 && (p.stock || 0) <= 20).length
    })
    
    const outOfStockCount = computed(() => {
      return products.value.filter(p => (p.stock || 0) === 0).length
    })
    
    const totalInventoryValue = computed(() => {
      return products.value.reduce((total, product) => {
        return total + ((product.price || 0) * (product.stock || 0))
      }, 0)
    })
    
    const totalPages = computed(() => {
      return Math.ceil(filteredProducts.value.length / itemsPerPage)
    })
    
    // Stock helper functions
    const getStockStatus = (stock) => {
      if (stock > 20) return 'In Stock'
      if (stock > 0) return 'Low Stock'
      return 'Out of Stock'
    }
    
    const getStockStatusClass = (stock) => {
      if (stock > 20) return 'in-stock'
      if (stock > 0) return 'low-stock'
      return 'out-stock'
    }
    
    const getStockStatusIcon = (stock) => {
      if (stock > 20) return 'fas fa-check-circle'
      if (stock > 0) return 'fas fa-exclamation-triangle'
      return 'fas fa-times-circle'
    }
    
    const getStockStatusTooltip = (stock) => {
      if (stock > 20) return 'Adequate stock available'
      if (stock > 0) return 'Low stock - consider restocking'
      return 'Out of stock - urgent action needed'
    }
    
    const getStockLevelClass = (stock) => {
      if (stock > 20) return 'high'
      if (stock > 0) return 'medium'
      return 'low'
    }
    
    const getStockPercentage = (stock, maxStock) => {
      return Math.min((stock / maxStock) * 100, 100)
    }
    
    // Formatting functions
    const formatNumber = (num) => {
      return num.toLocaleString('en-IN')
    }
    
    const formatDate = (dateString) => {
      if (!dateString) return 'N/A'
      const date = new Date(dateString)
      return date.toLocaleDateString('en-IN', { day: 'numeric', month: 'short' })
    }
    
    const formatFullDate = (dateString) => {
      if (!dateString) return 'Never updated'
      const date = new Date(dateString)
      return date.toLocaleDateString('en-IN', { 
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
    
    // Pagination functions
    const getVisiblePages = () => {
      const pages = []
      const maxVisible = 5
      let start = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
      let end = Math.min(totalPages.value, start + maxVisible - 1)
      
      if (end - start + 1 < maxVisible) {
        start = Math.max(1, end - maxVisible + 1)
      }
      
      for (let i = start; i <= end; i++) {
        pages.push(i)
      }
      
      return pages
    }
    
    // Modal functions
    const editStock = (product) => {
      isBulkUpdate.value = false
      selectedProduct.value = { ...product }
      stockUpdateType.value = 'adjust'
      stockQuantity.value = ''
      updateReason.value = 'restock'
      updateNotes.value = ''
      showStockModal.value = true
    }
    
    const quickRestock = (product) => {
      selectedProduct.value = { ...product }
      stockUpdateType.value = 'adjust'
      stockQuantity.value = '20'
      updateReason.value = 'restock'
      updateNotes.value = 'Quick restock'
      showStockModal.value = true
    }
    
    const updateStock = () => {
      isBulkUpdate.value = true
      selectedProduct.value = null
      stockUpdateType.value = 'adjust'
      stockQuantity.value = ''
      updateReason.value = 'restock'
      updateNotes.value = ''
      showStockModal.value = true
      alert('Bulk stock update feature would open here')
    }
    
    const closeStockModal = () => {
      showStockModal.value = false
      selectedProduct.value = null
      stockQuantity.value = ''
      updateNotes.value = ''
      isBulkUpdate.value = false
    }
    
    const incrementQuantity = () => {
      const current = parseInt(stockQuantity.value) || 0
      stockQuantity.value = (current + 1).toString()
    }
    
    const decrementQuantity = () => {
      const current = parseInt(stockQuantity.value) || 0
      if (current > 0 || stockUpdateType.value === 'adjust') {
        stockQuantity.value = (current - 1).toString()
      }
    }
    
    const calculateNewStock = () => {
      if (!selectedProduct.value || !stockQuantity.value || stockQuantity.value === '') return 0
      
      const currentStock = selectedProduct.value.stock || 0
      const quantity = parseInt(stockQuantity.value) || 0
      
      if (stockUpdateType.value === 'adjust') {
        return Math.max(0, currentStock + quantity)
      } else {
        return Math.max(0, quantity)
      }
    }
    
    const saveStockUpdate = async () => {
      try {
        const newStock = calculateNewStock()
        
        if (isBulkUpdate.value) {
          // Bulk update logic
          alert('Bulk update would update multiple products here')
        } else {
          // Single product update
          await updateDoc(doc(db, 'products', selectedProduct.value.id), {
            stock: newStock,
            lastUpdated: new Date().toISOString()
          })
          
          // Update local data
          const index = products.value.findIndex(p => p.id === selectedProduct.value.id)
          if (index !== -1) {
            products.value[index].stock = newStock
            products.value[index].lastUpdated = new Date().toISOString()
          }
        }
        
        closeStockModal()
        alert('Stock updated successfully!')
        
      } catch (error) {
        console.error('Error updating stock:', error)
        alert('Failed to update stock: ' + error.message)
      }
    }
    
    const viewProduct = (productId) => {
      router.push(`/dashboard/products/${productId}`)
    }
    
    const showDeleteConfirm = (product) => {
      if (confirm(`Are you sure you want to delete "${product.name}"? This action cannot be undone.`)) {
        deleteProduct(product.id)
      }
    }
    
    const deleteProduct = async (productId) => {
      try {
        await deleteDoc(doc(db, 'products', productId))
        products.value = products.value.filter(p => p.id !== productId)
        alert('Product deleted successfully!')
      } catch (error) {
        console.error('Error deleting product:', error)
        alert('Failed to delete product')
      }
    }
    
    const addNewProduct = () => {
      router.push('/dashboard/products')
    }
    
    const filterProducts = () => {
      currentPage.value = 1
    }
    
    const clearFilters = () => {
      searchQuery.value = ''
      categoryFilter.value = ''
      stockFilter.value = ''
      currentPage.value = 1
    }
    
    const exportInventory = () => {
      const data = filteredProducts.value.map(p => ({
        Name: p.name,
        SKU: p.sku || 'N/A',
        Category: p.category || 'Uncategorized',
        Price: p.price,
        Stock: p.stock || 0,
        'Stock Status': getStockStatus(p.stock || 0),
        'Last Updated': formatFullDate(p.lastUpdated)
      }))
      
      // Simple CSV export
      const csvContent = [
        Object.keys(data[0]).join(','),
        ...data.map(row => Object.values(row).join(','))
      ].join('\n')
      
      const blob = new Blob([csvContent], { type: 'text/csv' })
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `inventory-export-${new Date().toISOString().split('T')[0]}.csv`
      a.click()
      
      alert('Inventory data exported as CSV!')
    }
    
    onMounted(() => {
      fetchData()
    })
    
    return {
      // Data
      products: paginatedProducts,
      categories,
      filteredProducts,
      
      // Filters
      searchQuery,
      categoryFilter,
      stockFilter,
      
      // Stats
      inStockCount,
      lowStockCount,
      outOfStockCount,
      totalInventoryValue,
      
      // Modal
      showStockModal,
      selectedProduct,
      stockUpdateType,
      stockQuantity,
      updateReason,
      updateNotes,
      isBulkUpdate,
      
      // Pagination
      currentPage,
      totalPages,
      itemsPerPage,
      
      // Methods
      editStock,
      quickRestock,
      updateStock,
      closeStockModal,
      incrementQuantity,
      decrementQuantity,
      calculateNewStock,
      saveStockUpdate,
      viewProduct,
      showDeleteConfirm,
      addNewProduct,
      filterProducts,
      clearFilters,
      exportInventory,
      formatNumber,
      formatDate,
      formatFullDate,
      getStockStatus,
      getStockStatusClass,
      getStockStatusIcon,
      getStockStatusTooltip,
      getStockLevelClass,
      getStockPercentage,
      getVisiblePages
    }
  }
}
</script>

<style scoped>
.inventory-page {
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
  border: 1px solid #e5e7eb;
}

.page-header h1 {
  margin: 0;
  font-size: 24px;
  color: #1f2937;
  display: flex;
  align-items: center;
  gap: 10px;
}

.header-actions {
  display: flex;
  gap: 15px;
}

.stock-btn, .export-btn {
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
  border: none;
  min-width: 160px;
  justify-content: center;
}

.stock-btn {
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

.stock-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(59, 130, 246, 0.4);
}

.export-btn {
  background: white;
  color: #374151;
  border: 2px solid #d1d5db;
}

.export-btn:hover {
  background: #f9fafb;
  border-color: #3b82f6;
  color: #3b82f6;
  transform: translateY(-2px);
}

/* Filters Section */
.filters-section {
  background: white;
  padding: 20px;
  border-radius: 12px;
  margin-bottom: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  border: 1px solid #e5e7eb;
}

.filter-group {
  display: flex;
  gap: 15px;
  align-items: center;
  flex-wrap: wrap;
}

.search-box {
  flex: 1;
  display: flex;
  align-items: center;
  background: #f9fafb;
  border-radius: 8px;
  padding: 10px 15px;
  border: 1px solid #e5e7eb;
  transition: all 0.3s;
  min-width: 300px;
}

.search-box:focus-within {
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.search-box i {
  color: #6b7280;
  margin-right: 10px;
}

.search-box input {
  border: none;
  background: transparent;
  outline: none;
  width: 100%;
  font-size: 14px;
}

.filter-group select {
  padding: 10px 15px;
  border: 2px solid #d1d5db;
  border-radius: 8px;
  background: white;
  font-size: 14px;
  color: #374151;
  min-width: 180px;
  cursor: pointer;
  transition: all 0.3s;
}

.filter-group select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.clear-filters {
  padding: 10px 20px;
  background: #f3f4f6;
  color: #6b7280;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
  font-weight: 500;
}

.clear-filters:hover {
  background: #e5e7eb;
  color: #374151;
  border-color: #9ca3af;
}

/* Summary Cards */
.summary-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.summary-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 20px;
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
  margin: 0 0 8px 0;
  color: #6b7280;
  font-size: 14px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.summary-number {
  margin: 0 0 8px 0;
  font-size: 28px;
  font-weight: 700;
  color: #1f2937;
}

.summary-text {
  margin: 0;
  font-size: 13px;
  color: #9ca3af;
  font-weight: 500;
}

/* Inventory Table */
.inventory-table {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  margin-bottom: 30px;
  border: 1px solid #e5e7eb;
  min-height: 400px;
}

table {
  width: 100%;
  border-collapse: collapse;
}

thead {
  background: #f9fafb;
  border-bottom: 2px solid #e5e7eb;
}

th {
  padding: 18px 16px;
  text-align: left;
  color: #374151;
  font-weight: 600;
  font-size: 14px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

td {
  padding: 16px;
  border-bottom: 1px solid #e5e7eb;
  font-size: 14px;
  color: #4b5563;
  vertical-align: middle;
}

tr:hover {
  background: #f9fafb;
}

.product-cell {
  min-width: 250px;
}

.product-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.product-image img {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  object-fit: cover;
  border: 2px solid #e5e7eb;
}

.product-details {
  display: flex;
  flex-direction: column;
}

.product-name {
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 4px;
}

.product-price {
  font-size: 13px;
  color: #6b7280;
  font-weight: 500;
}

.sku-badge {
  background: #f3f4f6;
  color: #374151;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  font-family: 'Courier New', monospace;
  display: inline-block;
}

.stock-cell {
  min-width: 140px;
}

.stock-bar-container {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 8px;
}

.stock-quantity {
  font-weight: 700;
  color: #1f2937;
  font-size: 16px;
  min-width: 30px;
}

.stock-bar {
  flex: 1;
  height: 8px;
  background: #e5e7eb;
  border-radius: 4px;
  overflow: hidden;
}

.stock-fill {
  height: 100%;
  transition: width 0.3s ease;
}

.stock-fill.high {
  background: linear-gradient(90deg, #10b981 0%, #34d399 100%);
}

.stock-fill.medium {
  background: linear-gradient(90deg, #f59e0b 0%, #fbbf24 100%);
}

.stock-fill.low {
  background: linear-gradient(90deg, #ef4444 0%, #f87171 100%);
}

.stock-percentage {
  font-size: 12px;
  color: #6b7280;
  font-weight: 600;
  min-width: 35px;
}

.stock-status {
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.stock-status.in-stock {
  background: #d1fae5;
  color: #065f46;
  border: 1px solid #a7f3d0;
}

.stock-status.low-stock {
  background: #fef3c7;
  color: #92400e;
  border: 1px solid #fde68a;
}

.stock-status.out-stock {
  background: #fee2e2;
  color: #991b1b;
  border: 1px solid #fecaca;
}

/* Action Buttons */
.action-buttons {
  display: flex;
  gap: 8px;
  position: relative;
}

.action-btn {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
  position: relative;
  font-size: 14px;
}

.action-btn .btn-tooltip {
  position: absolute;
  bottom: -40px;
  left: 50%;
  transform: translateX(-50%);
  background: #1f2937;
  color: white;
  padding: 6px 12px;
  border-radius: 4px;
  font-size: 12px;
  white-space: nowrap;
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s;
  z-index: 100;
  pointer-events: none;
}

.action-btn .btn-tooltip::after {
  content: '';
  position: absolute;
  top: -4px;
  left: 50%;
  transform: translateX(-50%);
  border-width: 0 4px 4px 4px;
  border-style: solid;
  border-color: transparent transparent #1f2937 transparent;
}

.action-btn:hover .btn-tooltip {
  opacity: 1;
  visibility: visible;
  bottom: -35px;
}

.action-btn.edit {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  color: white;
}

.action-btn.edit:hover {
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
  transform: scale(1.1) translateY(-2px);
  box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
}

.action-btn.restock {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
}

.action-btn.restock:hover {
  background: linear-gradient(135deg, #059669 0%, #047857 100%);
  transform: scale(1.1) translateY(-2px);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.action-btn.view {
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
  color: white;
}

.action-btn.view:hover {
  background: linear-gradient(135deg, #7c3aed 0%, #6d28d9 100%);
  transform: scale(1.1) translateY(-2px);
  box-shadow: 0 4px 12px rgba(139, 92, 246, 0.3);
}

.action-btn.delete {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
}

.action-btn.delete:hover {
  background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%);
  transform: scale(1.1) translateY(-2px);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
}

/* Empty State */
.empty-state {
  padding: 60px 20px;
  text-align: center;
  color: #6b7280;
}

.empty-state i {
  font-size: 64px;
  color: #d1d5db;
  margin-bottom: 20px;
}

.empty-state h3 {
  margin: 0 0 10px 0;
  color: #374151;
  font-size: 20px;
}

.empty-state p {
  margin: 0 0 30px 0;
  font-size: 15px;
  max-width: 400px;
  margin-left: auto;
  margin-right: auto;
}

.add-product-btn {
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  color: white;
  border: none;
  padding: 12px 30px;
  border-radius: 8px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s;
}

.add-product-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
}

/* Pagination */
.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 30px;
  padding: 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  border: 1px solid #e5e7eb;
  flex-wrap: wrap;
  gap: 20px;
}

.page-btn {
  padding: 10px 20px;
  border-radius: 8px;
  border: 2px solid #d1d5db;
  background: white;
  color: #374151;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
  font-weight: 500;
  min-width: 100px;
  justify-content: center;
}

.page-btn.prev {
  order: 1;
}

.page-btn.next {
  order: 3;
}

.page-btn:not(:disabled):hover {
  background: #f3f4f6;
  border-color: #3b82f6;
  color: #3b82f6;
  transform: translateY(-1px);
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-numbers {
  order: 2;
  display: flex;
  gap: 8px;
  align-items: center;
}

.page-number {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  border: 2px solid #d1d5db;
  background: white;
  color: #374151;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  transition: all 0.3s;
}

.page-number:hover {
  background: #f3f4f6;
  border-color: #9ca3af;
}

.page-number.active {
  background: #3b82f6;
  color: white;
  border-color: #3b82f6;
}

.page-info {
  order: 4;
  font-size: 14px;
  color: #6b7280;
  font-weight: 500;
  width: 100%;
  text-align: center;
  margin-top: 10px;
}

/* Stock Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
  backdrop-filter: blur(4px);
}

.modal-content {
  background: white;
  border-radius: 16px;
  width: 100%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  animation: modalSlideIn 0.3s ease;
}

@keyframes modalSlideIn {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  padding: 24px;
  border-bottom: 1px solid #e5e7eb;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #f9fafb;
  border-radius: 16px 16px 0 0;
}

.modal-header h2 {
  margin: 0;
  font-size: 20px;
  color: #1f2937;
  display: flex;
  align-items: center;
  gap: 10px;
}

.close-btn {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  border: none;
  background: white;
  color: #6b7280;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
  border: 2px solid #e5e7eb;
}

.close-btn:hover {
  background: #e5e7eb;
  color: #374151;
  border-color: #d1d5db;
}

.stock-modal-body {
  padding: 24px;
}

.product-info-modal {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 20px;
  background: #f9fafb;
  border-radius: 12px;
  margin-bottom: 24px;
  border: 1px solid #e5e7eb;
}

.product-info-modal img {
  width: 80px;
  height: 80px;
  border-radius: 12px;
  object-fit: cover;
  border: 3px solid white;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.product-info-modal h3 {
  margin: 0 0 8px 0;
  font-size: 18px;
  color: #1f2937;
}

.product-info-modal p {
  margin: 4px 0;
  font-size: 14px;
  color: #6b7280;
}

.product-info-modal p strong {
  color: #374151;
  margin-right: 8px;
}

.current-stock {
  font-weight: 700;
  padding: 4px 12px;
  border-radius: 6px;
  font-size: 14px;
}

.current-stock.in-stock {
  background: #d1fae5;
  color: #065f46;
}

.current-stock.low-stock {
  background: #fef3c7;
  color: #92400e;
}

.current-stock.out-stock {
  background: #fee2e2;
  color: #991b1b;
}

.stock-update-form .form-group {
  margin-bottom: 24px;
}

.stock-update-form label {
  display: block;
  margin-bottom: 12px;
  font-weight: 600;
  color: #374151;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.radio-group {
  display: flex;
  gap: 20px;
}

.radio-label {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  font-size: 14px;
  flex: 1;
  padding: 16px;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  transition: all 0.3s;
}

.radio-label:hover {
  border-color: #d1d5db;
  background: #f9fafb;
}

.radio-label input[type="radio"] {
  width: 20px;
  height: 20px;
  accent-color: #3b82f6;
}

.radio-text {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.radio-text i {
  font-size: 20px;
  color: #3b82f6;
  margin-bottom: 4px;
}

.radio-text small {
  font-size: 12px;
  color: #6b7280;
  font-weight: normal;
}

.quantity-input {
  display: flex;
  align-items: center;
  gap: 10px;
}

.qty-btn {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  border: 2px solid #d1d5db;
  background: white;
  color: #374151;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  transition: all 0.3s;
}

.qty-btn:hover:not(:disabled) {
  border-color: #3b82f6;
  color: #3b82f6;
  background: #f0f9ff;
}

.qty-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.stock-update-form input[type="number"] {
  flex: 1;
  padding: 12px 16px;
  border: 2px solid #d1d5db;
  border-radius: 8px;
  font-size: 16px;
  color: #374151;
  transition: all 0.3s;
  text-align: center;
  font-weight: 600;
}

.stock-update-form input[type="number"]:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.stock-update-form select,
.stock-update-form textarea {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid #d1d5db;
  border-radius: 8px;
  font-size: 14px;
  color: #374151;
  transition: all 0.3s;
  background: white;
}

.stock-update-form select:focus,
.stock-update-form textarea:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.help-text {
  margin: 8px 0 0 0;
  font-size: 12px;
  color: #6b7280;
  display: flex;
  align-items: center;
  gap: 6px;
}

.help-text i {
  color: #3b82f6;
}

.preview-result {
  padding: 20px;
  background: #f0f9ff;
  border-radius: 12px;
  margin: 24px 0;
  border: 2px solid #dbeafe;
}

.preview-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 16px;
}

.preview-header i {
  color: #3b82f6;
  font-size: 20px;
}

.preview-header h4 {
  margin: 0;
  color: #1e40af;
  font-size: 16px;
}

.preview-details {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.preview-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 8px;
  border-bottom: 1px dashed #dbeafe;
}

.preview-item.total {
  border-bottom: 2px solid #3b82f6;
  padding-top: 8px;
  margin-top: 4px;
}

.preview-item span {
  color: #4b5563;
  font-size: 14px;
}

.preview-item strong {
  color: #1f2937;
  font-size: 15px;
}

.preview-item .positive {
  color: #10b981;
}

.preview-item .negative {
  color: #ef4444;
}

.new-stock {
  color: #1e40af !important;
  font-size: 18px !important;
}

.stock-status-preview {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px dashed #dbeafe;
}

.modal-actions {
  display: flex;
  gap: 16px;
  justify-content: flex-end;
  padding: 24px;
  border-top: 1px solid #e5e7eb;
  background: #f9fafb;
  border-radius: 0 0 16px 16px;
}

.cancel-btn, .save-btn {
  padding: 12px 28px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 15px;
  font-weight: 600;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 140px;
  justify-content: center;
}

.cancel-btn {
  border: 2px solid #d1d5db;
  background: white;
  color: #374151;
}

.cancel-btn:hover {
  background: #f3f4f6;
  border-color: #9ca3af;
  transform: translateY(-2px);
}

.save-btn {
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  color: white;
  border: none;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

.save-btn:hover:not(:disabled) {
  background: linear-gradient(135deg, #1d4ed8 0%, #1e40af 100%);
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(59, 130, 246, 0.4);
}

.save-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

/* Responsive */
@media (max-width: 1200px) {
  .summary-cards {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 992px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 20px;
  }
  
  .header-actions {
    width: 100%;
    flex-direction: column;
  }
  
  .stock-btn, .export-btn {
    width: 100%;
  }
  
  .filter-group {
    flex-direction: column;
    align-items: stretch;
  }
  
  .search-box {
    min-width: unset;
  }
  
  .filter-group select {
    width: 100%;
  }
}

@media (max-width: 768px) {
  .summary-cards {
    grid-template-columns: 1fr;
  }
  
  .inventory-table {
    overflow-x: auto;
  }
  
  table {
    min-width: 1000px;
  }
  
  .pagination {
    flex-direction: column;
    gap: 15px;
  }
  
  .page-btn.prev,
  .page-btn.next {
    width: 100%;
  }
  
  .page-numbers {
    order: 3;
  }
  
  .page-info {
    order: 4;
  }
  
  .modal-content {
    max-width: 95%;
  }
  
  .radio-group {
    flex-direction: column;
  }
  
  .modal-actions {
    flex-direction: column;
  }
  
  .cancel-btn, .save-btn {
    width: 100%;
  }
}

@media (max-width: 480px) {
  .inventory-page {
    padding: 10px;
  }
  
  .page-header,
  .filters-section,
  .inventory-table,
  .pagination {
    padding: 15px;
  }
  
  .summary-card {
    padding: 20px;
  }
  
  .summary-icon {
    width: 50px;
    height: 50px;
    font-size: 20px;
  }
  
  .summary-number {
    font-size: 24px;
  }
}
</style>