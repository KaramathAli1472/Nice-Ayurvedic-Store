<template>
  <div class="categories-page">
    <!-- Page Header -->
    <div class="page-header">
      <h1><i class="fas fa-tags"></i> Product Categories</h1>
      <button class="add-btn" @click="openAddModal">
        <i class="fas fa-plus"></i> Add Category
      </button>
    </div>

    <!-- Categories Grid -->
    <div class="categories-grid">
      <div v-for="category in categories" :key="category.id" class="category-card">
        <div class="category-header">
          <div class="category-icon" :style="{ background: category.color }">
            <i :class="category.icon"></i>
          </div>
          <div class="category-actions">
            <button class="action-btn edit" @click="editCategory(category)">
              <i class="fas fa-edit"></i>
            </button>
            <button class="action-btn delete" @click="deleteCategory(category.id)">
              <i class="fas fa-trash"></i>
            </button>
          </div>
        </div>
        
        <div class="category-content">
          <h3>{{ category.name }}</h3>
          <p class="category-desc">{{ category.description }}</p>
          
          <div class="category-stats">
            <div class="stat">
              <span class="stat-label">Products</span>
              <span class="stat-value">{{ category.productCount }}</span>
            </div>
            <div class="stat">
              <span class="stat-label">Status</span>
              <span :class="['status-badge', category.active ? 'active' : 'inactive']">
                {{ category.active ? 'Active' : 'Inactive' }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Add/Edit Category Modal -->
    <div v-if="showModal" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>{{ isEditing ? 'Edit Category' : 'Add New Category' }}</h2>
          <button class="close-btn" @click="closeModal">
            <i class="fas fa-times"></i>
          </button>
        </div>
        
        <form @submit.prevent="saveCategory">
          <div class="form-group">
            <label for="categoryName">Category Name *</label>
            <input
              type="text"
              id="categoryName"
              v-model="categoryForm.name"
              placeholder="e.g., Herbs, Oils, Supplements"
              required
            />
          </div>
          
          <div class="form-group">
            <label for="categoryDesc">Description</label>
            <textarea
              id="categoryDesc"
              v-model="categoryForm.description"
              rows="3"
              placeholder="Describe this category..."
            ></textarea>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label for="categoryIcon">Icon</label>
              <div class="icon-selector">
                <div
                  v-for="icon in availableIcons"
                  :key="icon"
                  class="icon-option"
                  :class="{ selected: categoryForm.icon === icon }"
                  @click="categoryForm.icon = icon"
                >
                  <i :class="icon"></i>
                </div>
              </div>
            </div>
            
            <div class="form-group">
              <label for="categoryColor">Color</label>
              <div class="color-selector">
                <div
                  v-for="color in availableColors"
                  :key="color"
                  class="color-option"
                  :class="{ selected: categoryForm.color === color }"
                  :style="{ background: color }"
                  @click="categoryForm.color = color"
                ></div>
              </div>
            </div>
          </div>
          
          <div class="form-group">
            <label class="checkbox-label">
              <input type="checkbox" v-model="categoryForm.active" />
              <span>Active Category</span>
            </label>
          </div>
          
          <div class="modal-actions">
            <button type="button" class="cancel-btn" @click="closeModal">
              Cancel
            </button>
            <button type="submit" class="save-btn">
              {{ isEditing ? 'Update Category' : 'Add Category' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc } from 'firebase/firestore'
import { db } from '@/firebase'

export default {
  name: 'CategoriesPage',
  setup() {
    const categories = ref([])
    const showModal = ref(false)
    const isEditing = ref(false)
    const editingId = ref(null)
    
    const categoryForm = ref({
      name: '',
      description: '',
      icon: 'fas fa-leaf',
      color: '#10b981',
      active: true,
      productCount: 0
    })
    
    const availableIcons = [
      'fas fa-leaf',
      'fas fa-seedling',
      'fas fa-flask',
      'fas fa-pills',
      'fas fa-oil-can',
      'fas fa-spa',
      'fas fa-mortar-pestle',
      'fas fa-heart',
      'fas fa-brain',
      'fas fa-lungs'
    ]
    
    const availableColors = [
      '#10b981',
      '#3b82f6',
      '#8b5cf6',
      '#f59e0b',
      '#ef4444',
      '#ec4899',
      '#06b6d4',
      '#84cc16',
      '#f97316',
      '#6366f1'
    ]
    
    const fetchCategories = async () => {
      try {
        const querySnapshot = await getDocs(collection(db, 'categories'))
        categories.value = []
        
        querySnapshot.forEach(doc => {
          categories.value.push({
            id: doc.id,
            ...doc.data()
          })
        })
        
        // If no categories in database, show sample data
        if (categories.value.length === 0) {
          categories.value = [
            {
              id: '1',
              name: 'Herbs & Powders',
              description: 'Traditional Ayurvedic herbs and powders',
              icon: 'fas fa-leaf',
              color: '#10b981',
              active: true,
              productCount: 24
            },
            {
              id: '2',
              name: 'Oils & Massage',
              description: 'Ayurvedic oils for massage and therapy',
              icon: 'fas fa-oil-can',
              color: '#f59e0b',
              active: true,
              productCount: 18
            },
            {
              id: '3',
              name: 'Capsules & Tablets',
              description: 'Easy-to-consume supplements',
              icon: 'fas fa-pills',
              color: '#3b82f6',
              active: true,
              productCount: 32
            },
            {
              id: '4',
              name: 'Personal Care',
              description: 'Soaps, shampoos, and skincare',
              icon: 'fas fa-spa',
              color: '#ec4899',
              active: true,
              productCount: 15
            },
            {
              id: '5',
              name: 'Immunity Boosters',
              description: 'Products to strengthen immunity',
              icon: 'fas fa-heart',
              color: '#ef4444',
              active: true,
              productCount: 12
            },
            {
              id: '6',
              name: 'Digestive Care',
              description: 'Aids for digestive health',
              icon: 'fas fa-mortar-pestle',
              color: '#8b5cf6',
              active: true,
              productCount: 8
            }
          ]
        }
      } catch (error) {
        console.error('Error fetching categories:', error)
      }
    }
    
    const openAddModal = () => {
      isEditing.value = false
      editingId.value = null
      categoryForm.value = {
        name: '',
        description: '',
        icon: 'fas fa-leaf',
        color: '#10b981',
        active: true,
        productCount: 0
      }
      showModal.value = true
    }
    
    const editCategory = (category) => {
      isEditing.value = true
      editingId.value = category.id
      categoryForm.value = { ...category }
      showModal.value = true
    }
    
    const deleteCategory = async (id) => {
      if (confirm('Are you sure you want to delete this category?')) {
        try {
          await deleteDoc(doc(db, 'categories', id))
          fetchCategories()
        } catch (error) {
          console.error('Error deleting category:', error)
          alert('Failed to delete category')
        }
      }
    }
    
    const saveCategory = async () => {
      try {
        if (isEditing.value && editingId.value) {
          // Update existing category
          await updateDoc(doc(db, 'categories', editingId.value), categoryForm.value)
        } else {
          // Add new category
          await addDoc(collection(db, 'categories'), categoryForm.value)
        }
        
        closeModal()
        fetchCategories()
      } catch (error) {
        console.error('Error saving category:', error)
        alert('Failed to save category')
      }
    }
    
    const closeModal = () => {
      showModal.value = false
    }
    
    onMounted(() => {
      fetchCategories()
    })
    
    return {
      categories,
      showModal,
      isEditing,
      categoryForm,
      availableIcons,
      availableColors,
      openAddModal,
      editCategory,
      deleteCategory,
      saveCategory,
      closeModal
    }
  }
}
</script>

<style scoped>
.categories-page {
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

.add-btn {
  background: #3b82f6;
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

.add-btn:hover {
  background: #2563eb;
  transform: translateY(-1px);
}

/* Categories Grid */
.categories-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
}

.category-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  border: 1px solid #e5e7eb;
  transition: transform 0.3s, box-shadow 0.3s;
}

.category-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 16px rgba(0,0,0,0.1);
}

.category-header {
  height: 80px;
  background: linear-gradient(135deg, var(--category-color, #10b981) 0%, rgba(16, 185, 129, 0.8) 100%);
  padding: 15px;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.category-icon {
  width: 50px;
  height: 50px;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  color: white;
}

.category-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  width: 32px;
  height: 32px;
  border-radius: 6px;
  border: none;
  background: rgba(255, 255, 255, 0.2);
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.action-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: scale(1.1);
}

.action-btn.delete:hover {
  background: rgba(239, 68, 68, 0.8);
}

.category-content {
  padding: 20px;
}

.category-content h3 {
  margin: 0 0 8px 0;
  font-size: 18px;
  color: #1f2937;
}

.category-desc {
  margin: 0 0 15px 0;
  color: #6b7280;
  font-size: 14px;
  line-height: 1.5;
}

.category-stats {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 15px;
  border-top: 1px solid #e5e7eb;
}

.stat {
  display: flex;
  flex-direction: column;
}

.stat-label {
  font-size: 12px;
  color: #9ca3af;
  margin-bottom: 4px;
}

.stat-value {
  font-size: 18px;
  font-weight: 700;
  color: #1f2937;
}

.status-badge {
  padding: 4px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 500;
}

.status-badge.active {
  background: #d1fae5;
  color: #065f46;
}

.status-badge.inactive {
  background: #f3f4f6;
  color: #6b7280;
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
  max-width: 500px;
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
  transition: all 0.2s;
}

.close-btn:hover {
  background: #e5e7eb;
  color: #374151;
}

form {
  padding: 20px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #374151;
  font-size: 14px;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 14px;
  color: #374151;
  transition: border-color 0.2s;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.icon-selector,
.color-selector {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 8px;
}

.icon-option {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  background: #f3f4f6;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 18px;
  color: #6b7280;
}

.icon-option:hover {
  background: #e5e7eb;
  transform: scale(1.1);
}

.icon-option.selected {
  background: #3b82f6;
  color: white;
  transform: scale(1.1);
}

.color-option {
  width: 32px;
  height: 32px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  border: 2px solid transparent;
}

.color-option:hover {
  transform: scale(1.2);
}

.color-option.selected {
  border-color: #1f2937;
  transform: scale(1.2);
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  user-select: none;
}

.checkbox-label input[type="checkbox"] {
  width: 18px;
  height: 18px;
}

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid #e5e7eb;
}

.cancel-btn {
  padding: 10px 20px;
  border: 1px solid #d1d5db;
  background: white;
  color: #374151;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
}

.cancel-btn:hover {
  background: #f3f4f6;
}

.save-btn {
  padding: 10px 20px;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
}

.save-btn:hover {
  background: #2563eb;
  transform: translateY(-1px);
}

/* Responsive */
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 15px;
  }
  
  .add-btn {
    width: 100%;
    justify-content: center;
  }
  
  .form-row {
    grid-template-columns: 1fr;
  }
  
  .categories-grid {
    grid-template-columns: 1fr;
  }
}
</style>