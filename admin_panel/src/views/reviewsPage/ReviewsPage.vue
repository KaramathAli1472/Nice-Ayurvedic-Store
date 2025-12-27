<template>
  <div class="reviews-page">
    <div class="page-header">
      <h1><i class="fas fa-star"></i> Product Reviews</h1>
      <div class="header-filters">
        <div class="filter-group">
          <select v-model="filterStatus" @change="filterReviews">
            <option value="all">All Status</option>
            <option value="pending">Pending</option>
            <option value="approved">Approved</option>
            <option value="rejected">Rejected</option>
          </select>
        </div>
        
        <div class="filter-group">
          <select v-model="filterRating" @change="filterReviews">
            <option value="all">All Ratings</option>
            <option value="5">★★★★★</option>
            <option value="4">★★★★☆</option>
            <option value="3">★★★☆☆</option>
            <option value="2">★★☆☆☆</option>
            <option value="1">★☆☆☆☆</option>
          </select>
        </div>
        
        <div class="search-box">
          <i class="fas fa-search"></i>
          <input type="text" v-model="searchQuery" placeholder="Search reviews..." 
                 @input="filterReviews" />
        </div>
      </div>
    </div>

    <!-- Reviews Stats -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon" style="background: #3b82f6">
          <i class="fas fa-star"></i>
        </div>
        <div class="stat-content">
          <h3>Average Rating</h3>
          <p class="stat-number">{{ averageRating.toFixed(1) }}</p>
          <p class="stat-text">out of 5</p>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon" style="background: #10b981">
          <i class="fas fa-check-circle"></i>
        </div>
        <div class="stat-content">
          <h3>Approved</h3>
          <p class="stat-number">{{ approvedCount }}</p>
          <p class="stat-text">reviews</p>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon" style="background: #f59e0b">
          <i class="fas fa-clock"></i>
        </div>
        <div class="stat-content">
          <h3>Pending</h3>
          <p class="stat-number">{{ pendingCount }}</p>
          <p class="stat-text">needs moderation</p>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon" style="background: #ef4444">
          <i class="fas fa-times-circle"></i>
        </div>
        <div class="stat-content">
          <h3>Rejected</h3>
          <p class="stat-number">{{ rejectedCount }}</p>
          <p class="stat-text">reviews</p>
        </div>
      </div>
    </div>

    <!-- Reviews Table -->
    <div class="reviews-table">
      <table>
        <thead>
          <tr>
            <th>Product</th>
            <th>Customer</th>
            <th>Rating</th>
            <th>Review</th>
            <th>Date</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="review in filteredReviews" :key="review.id">
            <td class="product-cell">
              <div class="product-info">
                <img :src="review.productImage" :alt="review.productName" />
                <div>
                  <div class="product-name">{{ review.productName }}</div>
                  <div class="product-price">₹{{ review.productPrice }}</div>
                </div>
              </div>
            </td>
            
            <td>
              <div class="customer-info">
                <div class="customer-name">{{ review.customerName }}</div>
                <div class="customer-email">{{ review.customerEmail }}</div>
              </div>
            </td>
            
            <td>
              <div class="rating-display">
                <div class="stars">
                  <i v-for="star in 5" :key="star" 
                     :class="star <= review.rating ? 'fas fa-star filled' : 'far fa-star'"
                     :style="{ color: star <= review.rating ? '#f59e0b' : '#d1d5db' }"></i>
                </div>
                <span class="rating-value">{{ review.rating }}/5</span>
              </div>
            </td>
            
            <td>
              <div class="review-text">{{ review.comment }}</div>
              <div v-if="review.response" class="admin-response">
                <strong>Your response:</strong> {{ review.response }}
              </div>
            </td>
            
            <td>{{ formatDate(review.date) }}</td>
            
            <td>
              <span :class="['status-badge', review.status]">
                {{ review.status }}
              </span>
            </td>
            
            <td>
              <div class="action-buttons">
                <button v-if="review.status === 'pending'" class="action-btn approve" 
                        @click="updateStatus(review.id, 'approved')">
                  <i class="fas fa-check"></i>
                </button>
                
                <button v-if="review.status === 'pending'" class="action-btn reject" 
                        @click="updateStatus(review.id, 'rejected')">
                  <i class="fas fa-times"></i>
                </button>
                
                <button class="action-btn reply" @click="openReplyModal(review)">
                  <i class="fas fa-reply"></i>
                </button>
                
                <button class="action-btn delete" @click="deleteReview(review.id)">
                  <i class="fas fa-trash"></i>
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Reply Modal -->
    <div v-if="showReplyModal" class="modal-overlay" @click.self="closeReplyModal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Reply to Review</h2>
          <button class="close-btn" @click="closeReplyModal">
            <i class="fas fa-times"></i>
          </button>
        </div>
        
        <div class="modal-body" v-if="selectedReview">
          <div class="review-preview">
            <h4>Customer Review:</h4>
            <p class="customer-review">{{ selectedReview.comment }}</p>
            <div class="review-meta">
              <span class="customer-name">{{ selectedReview.customerName }}</span>
              <span class="review-date">{{ formatDate(selectedReview.date) }}</span>
              <span class="review-rating">Rating: {{ selectedReview.rating }}/5</span>
            </div>
          </div>
          
          <div class="reply-form">
            <label>Your Response:</label>
            <textarea v-model="replyText" rows="4" placeholder="Type your response here..."></textarea>
            <div class="form-actions">
              <button class="cancel-btn" @click="closeReplyModal">Cancel</button>
              <button class="save-btn" @click="submitReply">Submit Response</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'

export default {
  name: 'ReviewsPage',
  setup() {
    const filterStatus = ref('all')
    const filterRating = ref('all')
    const searchQuery = ref('')
    const showReplyModal = ref(false)
    const selectedReview = ref(null)
    const replyText = ref('')
    
    const reviews = ref([
      {
        id: 1,
        productId: '1',
        productName: 'Ashwagandha Powder',
        productPrice: 500,
        productImage: 'https://via.placeholder.com/40',
        customerName: 'Rajesh Kumar',
        customerEmail: 'rajesh@example.com',
        rating: 5,
        comment: 'Excellent product! Really helps with stress and sleep.',
        date: '2024-01-15',
        status: 'approved',
        response: 'Thank you for your wonderful feedback!'
      },
      {
        id: 2,
        productName: 'Triphala Churna',
        productPrice: 350,
        productImage: 'https://via.placeholder.com/40',
        customerName: 'Priya Sharma',
        customerEmail: 'priya@example.com',
        rating: 4,
        comment: 'Good for digestion, but taste could be better.',
        date: '2024-01-14',
        status: 'pending',
        response: ''
      },
      {
        id: 3,
        productName: 'Moringa Capsules',
        productPrice: 250,
        productImage: 'https://via.placeholder.com/40',
        customerName: 'Amit Patel',
        customerEmail: 'amit@example.com',
        rating: 5,
        comment: 'Best immunity booster I have used!',
        date: '2024-01-13',
        status: 'approved',
        response: 'We are glad it worked well for you!'
      },
      {
        id: 4,
        productName: 'Neem Soap',
        productPrice: 120,
        productImage: 'https://via.placeholder.com/40',
        customerName: 'Sneha Gupta',
        customerEmail: 'sneha@example.com',
        rating: 3,
        comment: 'Average product, not much difference noticed.',
        date: '2024-01-12',
        status: 'rejected',
        response: ''
      },
      {
        id: 5,
        productName: 'Tulsi Drops',
        productPrice: 200,
        productImage: 'https://via.placeholder.com/40',
        customerName: 'Vikram Singh',
        customerEmail: 'vikram@example.com',
        rating: 5,
        comment: 'Great for cough and cold. Highly recommended!',
        date: '2024-01-11',
        status: 'approved',
        response: 'Thank you for recommending our product!'
      }
    ])
    
    // Computed properties
    const filteredReviews = computed(() => {
      return reviews.value.filter(review => {
        // Filter by status
        if (filterStatus.value !== 'all' && review.status !== filterStatus.value) {
          return false
        }
        
        // Filter by rating
        if (filterRating.value !== 'all' && review.rating !== parseInt(filterRating.value)) {
          return false
        }
        
        // Filter by search query
        if (searchQuery.value) {
          const query = searchQuery.value.toLowerCase()
          return (
            review.productName.toLowerCase().includes(query) ||
            review.customerName.toLowerCase().includes(query) ||
            review.comment.toLowerCase().includes(query)
          )
        }
        
        return true
      })
    })
    
    const averageRating = computed(() => {
      if (reviews.value.length === 0) return 0
      const total = reviews.value.reduce((sum, review) => sum + review.rating, 0)
      return total / reviews.value.length
    })
    
    const approvedCount = computed(() => {
      return reviews.value.filter(r => r.status === 'approved').length
    })
    
    const pendingCount = computed(() => {
      return reviews.value.filter(r => r.status === 'pending').length
    })
    
    const rejectedCount = computed(() => {
      return reviews.value.filter(r => r.status === 'rejected').length
    })
    
    // Methods
    const filterReviews = () => {
      // Filter logic handled in computed property
    }
    
    const updateStatus = (id, status) => {
      const review = reviews.value.find(r => r.id === id)
      if (review) {
        review.status = status
      }
    }
    
    const deleteReview = (id) => {
      if (confirm('Are you sure you want to delete this review?')) {
        reviews.value = reviews.value.filter(r => r.id !== id)
      }
    }
    
    const openReplyModal = (review) => {
      selectedReview.value = review
      replyText.value = review.response || ''
      showReplyModal.value = true
    }
    
    const closeReplyModal = () => {
      showReplyModal.value = false
      selectedReview.value = null
      replyText.value = ''
    }
    
    const submitReply = () => {
      if (selectedReview.value) {
        selectedReview.value.response = replyText.value
        closeReplyModal()
      }
    }
    
    const formatDate = (dateString) => {
      const date = new Date(dateString)
      return date.toLocaleDateString('en-IN', { 
        day: 'numeric', 
        month: 'short', 
        year: 'numeric' 
      })
    }
    
    onMounted(() => {
      // Fetch reviews from API/Firebase here
    })
    
    return {
      filterStatus,
      filterRating,
      searchQuery,
      showReplyModal,
      selectedReview,
      replyText,
      reviews: filteredReviews,
      averageRating,
      approvedCount,
      pendingCount,
      rejectedCount,
      filterReviews,
      updateStatus,
      deleteReview,
      openReplyModal,
      closeReplyModal,
      submitReply,
      formatDate
    }
  }
}
</script>

<style scoped>
.reviews-page {
  padding: 20px;
}

/* Page Header */
.page-header {
  margin-bottom: 30px;
  padding: 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.page-header h1 {
  margin: 0 0 20px 0;
  font-size: 24px;
  color: #1f2937;
  display: flex;
  align-items: center;
  gap: 10px;
}

.header-filters {
  display: flex;
  gap: 15px;
  flex-wrap: wrap;
}

.filter-group select {
  padding: 8px 16px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  background: white;
  font-size: 14px;
  color: #374151;
  min-width: 150px;
}

.search-box {
  flex: 1;
  display: flex;
  align-items: center;
  background: #f9fafb;
  border-radius: 6px;
  padding: 8px 12px;
  border: 1px solid #e5e7eb;
  min-width: 250px;
}

.search-box i {
  color: #9ca3af;
  margin-right: 10px;
}

.search-box input {
  border: none;
  background: transparent;
  outline: none;
  width: 100%;
  font-size: 14px;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 15px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  border: 1px solid #e5e7eb;
}

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  color: white;
}

.stat-content h3 {
  margin: 0 0 4px 0;
  color: #6b7280;
  font-size: 14px;
  font-weight: 500;
}

.stat-number {
  margin: 0 0 4px 0;
  font-size: 24px;
  font-weight: 700;
  color: #1f2937;
}

.stat-text {
  margin: 0;
  font-size: 12px;
  color: #9ca3af;
}

/* Reviews Table */
.reviews-table {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

table {
  width: 100%;
  border-collapse: collapse;
}

thead {
  background: #f9fafb;
}

th {
  padding: 16px;
  text-align: left;
  color: #374151;
  font-weight: 600;
  font-size: 14px;
  border-bottom: 1px solid #e5e7eb;
}

td {
  padding: 16px;
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
  align-items: center;
  gap: 12px;
}

.product-info img {
  width: 40px;
  height: 40px;
  border-radius: 6px;
  object-fit: cover;
}

.product-name {
  font-weight: 500;
  color: #1f2937;
}

.product-price {
  font-size: 12px;
  color: #6b7280;
}

.customer-info {
  display: flex;
  flex-direction: column;
}

.customer-name {
  font-weight: 500;
  color: #1f2937;
}

.customer-email {
  font-size: 12px;
  color: #6b7280;
}

.rating-display {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.stars {
  display: flex;
  gap: 2px;
}

.rating-value {
  font-size: 12px;
  color: #6b7280;
}

.review-text {
  max-width: 300px;
  line-height: 1.5;
}

.admin-response {
  margin-top: 8px;
  padding: 8px;
  background: #f0f9ff;
  border-radius: 4px;
  font-size: 12px;
  color: #0369a1;
}

.status-badge {
  padding: 4px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 500;
  text-transform: capitalize;
}

.status-badge.approved {
  background: #d1fae5;
  color: #065f46;
}

.status-badge.pending {
  background: #fef3c7;
  color: #92400e;
}

.status-badge.rejected {
  background: #fee2e2;
  color: #991b1b;
}

.action-buttons {
  display: flex;
  gap: 6px;
}

.action-btn {
  width: 32px;
  height: 32px;
  border-radius: 6px;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.action-btn.approve {
  background: #d1fae5;
  color: #065f46;
}

.action-btn.approve:hover {
  background: #a7f3d0;
  transform: scale(1.1);
}

.action-btn.reject {
  background: #fee2e2;
  color: #dc2626;
}

.action-btn.reject:hover {
  background: #fecaca;
  transform: scale(1.1);
}

.action-btn.reply {
  background: #dbeafe;
  color: #1e40af;
}

.action-btn.reply:hover {
  background: #bfdbfe;
  transform: scale(1.1);
}

.action-btn.delete {
  background: #f3f4f6;
  color: #6b7280;
}

.action-btn.delete:hover {
  background: #e5e7eb;
  color: #ef4444;
  transform: scale(1.1);
}

/* Modal Styles */
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
}

.modal-content {
  background: white;
  border-radius: 12px;
  width: 100%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}

.modal-header {
  padding: 20px;
  border-bottom: 1px solid #e5e7eb;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h2 {
  margin: 0;
  font-size: 20px;
  color: #1f2937;
}

.close-btn {
  width: 36px;
  height: 36px;
  border-radius: 6px;
  border: none;
  background: #f3f4f6;
  color: #6b7280;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  background: #e5e7eb;
}

.modal-body {
  padding: 20px;
}

.review-preview {
  margin-bottom: 20px;
  padding: 15px;
  background: #f9fafb;
  border-radius: 8px;
}

.review-preview h4 {
  margin: 0 0 10px 0;
  color: #374151;
}

.customer-review {
  margin: 0 0 10px 0;
  color: #4b5563;
  line-height: 1.5;
}

.review-meta {
  display: flex;
  gap: 15px;
  font-size: 12px;
  color: #6b7280;
}

.reply-form label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #374151;
}

.reply-form textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 14px;
  color: #374151;
  resize: vertical;
  margin-bottom: 20px;
}

.reply-form textarea:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.form-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

.cancel-btn, .save-btn {
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
}

.cancel-btn {
  background: white;
  color: #374151;
  border: 1px solid #d1d5db;
}

.cancel-btn:hover {
  background: #f3f4f6;
}

.save-btn {
  background: #3b82f6;
  color: white;
  border: none;
}

.save-btn:hover {
  background: #2563eb;
}

/* Responsive */
@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .page-header h1 {
    margin-bottom: 15px;
  }
  
  .header-filters {
    flex-direction: column;
  }
  
  .filter-group select,
  .search-box {
    width: 100%;
    min-width: unset;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .reviews-table {
    overflow-x: auto;
  }
  
  table {
    min-width: 1000px;
  }
}
</style>