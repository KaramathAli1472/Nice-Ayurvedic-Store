<template>
  <div class="shipping-page">
    <div class="page-header">
      <h1><i class="fas fa-shipping-fast"></i> Shipping Management</h1>
      <button class="add-btn" @click="addShippingMethod">
        <i class="fas fa-plus"></i> Add Shipping Method
      </button>
    </div>

    <!-- Shipping Methods -->
    <div class="shipping-methods">
      <div class="method-card" v-for="method in shippingMethods" :key="method.id">
        <div class="method-header">
          <h3>{{ method.name }}</h3>
          <div class="method-status" :class="{ active: method.active }">
            {{ method.active ? 'Active' : 'Inactive' }}
          </div>
        </div>
        
        <div class="method-details">
          <p><i class="fas fa-money-bill-wave"></i> Cost: ₹{{ method.cost }}</p>
          <p><i class="fas fa-clock"></i> Delivery: {{ method.deliveryTime }}</p>
          <p><i class="fas fa-map-marker-alt"></i> Zones: {{ method.zones }}</p>
        </div>
        
        <div class="method-actions">
          <button class="edit-btn" @click="editMethod(method)">
            <i class="fas fa-edit"></i> Edit
          </button>
          <button class="toggle-btn" @click="toggleMethod(method.id)" 
                  :class="{ active: method.active }">
            {{ method.active ? 'Deactivate' : 'Activate' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Shipping Zones -->
    <div class="shipping-zones">
      <h2><i class="fas fa-globe"></i> Shipping Zones</h2>
      <div class="zones-grid">
        <div class="zone-card" v-for="zone in shippingZones" :key="zone.id">
          <h3>{{ zone.name }}</h3>
          <p>{{ zone.description }}</p>
          <div class="zone-countries">
            <span v-for="country in zone.countries" :key="country" class="country-tag">
              {{ country }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Add/Edit Modal -->
    <div v-if="showModal" class="modal-overlay" @click.self="closeModal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>{{ isEditing ? 'Edit Shipping Method' : 'Add Shipping Method' }}</h2>
          <button class="close-btn" @click="closeModal">
            <i class="fas fa-times"></i>
          </button>
        </div>
        
        <div class="modal-body">
          <div class="form-group">
            <label>Method Name *</label>
            <input type="text" v-model="methodForm.name" placeholder="e.g., Standard Delivery" />
          </div>
          
          <div class="form-group">
            <label>Shipping Cost (₹) *</label>
            <input type="number" v-model="methodForm.cost" placeholder="0" />
          </div>
          
          <div class="form-group">
            <label>Delivery Time *</label>
            <input type="text" v-model="methodForm.deliveryTime" placeholder="e.g., 3-5 business days" />
          </div>
          
          <div class="form-group">
            <label>Description</label>
            <textarea v-model="methodForm.description" rows="3"></textarea>
          </div>
          
          <div class="form-group">
            <label>
              <input type="checkbox" v-model="methodForm.active" />
              Active Method
            </label>
          </div>
        </div>
        
        <div class="modal-actions">
          <button class="cancel-btn" @click="closeModal">Cancel</button>
          <button class="save-btn" @click="saveMethod">{{ isEditing ? 'Update' : 'Add' }} Method</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'

export default {
  name: 'ShippingPage',
  setup() {
    const showModal = ref(false)
    const isEditing = ref(false)
    const editingId = ref(null)
    
    const methodForm = ref({
      name: '',
      cost: '',
      deliveryTime: '',
      description: '',
      active: true
    })
    
    const shippingMethods = ref([
      {
        id: 1,
        name: 'Standard Delivery',
        cost: 50,
        deliveryTime: '3-5 business days',
        description: 'Regular shipping via local courier',
        active: true,
        zones: 'All India'
      },
      {
        id: 2,
        name: 'Express Delivery',
        cost: 150,
        deliveryTime: '1-2 business days',
        description: 'Priority shipping for urgent orders',
        active: true,
        zones: 'Metro cities'
      },
      {
        id: 3,
        name: 'Free Shipping',
        cost: 0,
        deliveryTime: '5-7 business days',
        description: 'Free shipping on orders above ₹2000',
        active: true,
        zones: 'All India'
      }
    ])
    
    const shippingZones = ref([
      {
        id: 1,
        name: 'North India',
        description: 'Delhi, Punjab, Haryana, Uttar Pradesh',
        countries: ['India']
      },
      {
        id: 2,
        name: 'South India',
        description: 'Karnataka, Tamil Nadu, Kerala, Andhra Pradesh',
        countries: ['India']
      },
      {
        id: 3,
        name: 'Metro Cities',
        description: 'Major metropolitan areas',
        countries: ['India']
      }
    ])
    
    const addShippingMethod = () => {
      isEditing.value = false
      editingId.value = null
      methodForm.value = {
        name: '',
        cost: '',
        deliveryTime: '',
        description: '',
        active: true
      }
      showModal.value = true
    }
    
    const editMethod = (method) => {
      isEditing.value = true
      editingId.value = method.id
      methodForm.value = { ...method }
      showModal.value = true
    }
    
    const saveMethod = () => {
      if (isEditing.value) {
        const index = shippingMethods.value.findIndex(m => m.id === editingId.value)
        if (index !== -1) {
          shippingMethods.value[index] = { ...shippingMethods.value[index], ...methodForm.value }
        }
      } else {
        const newMethod = {
          id: shippingMethods.value.length + 1,
          zones: 'All India',
          ...methodForm.value
        }
        shippingMethods.value.push(newMethod)
      }
      closeModal()
    }
    
    const toggleMethod = (id) => {
      const method = shippingMethods.value.find(m => m.id === id)
      if (method) {
        method.active = !method.active
      }
    }
    
    const closeModal = () => {
      showModal.value = false
    }
    
    return {
      showModal,
      isEditing,
      methodForm,
      shippingMethods,
      shippingZones,
      addShippingMethod,
      editMethod,
      saveMethod,
      toggleMethod,
      closeModal
    }
  }
}
</script>

<style scoped>
.shipping-page {
  padding: 20px;
}

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

.shipping-methods {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.method-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  border: 1px solid #e5e7eb;
}

.method-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  padding-bottom: 15px;
  border-bottom: 1px solid #e5e7eb;
}

.method-header h3 {
  margin: 0;
  font-size: 18px;
  color: #1f2937;
}

.method-status {
  padding: 4px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 500;
}

.method-status.active {
  background: #d1fae5;
  color: #065f46;
}

.method-status:not(.active) {
  background: #f3f4f6;
  color: #6b7280;
}

.method-details {
  margin-bottom: 20px;
}

.method-details p {
  margin: 8px 0;
  color: #4b5563;
  display: flex;
  align-items: center;
  gap: 8px;
}

.method-actions {
  display: flex;
  gap: 10px;
}

.edit-btn, .toggle-btn {
  padding: 8px 16px;
  border-radius: 6px;
  border: none;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  flex: 1;
  transition: all 0.2s;
}

.edit-btn {
  background: #dbeafe;
  color: #1e40af;
}

.edit-btn:hover {
  background: #bfdbfe;
}

.toggle-btn {
  background: #f3f4f6;
  color: #374151;
}

.toggle-btn.active {
  background: #fee2e2;
  color: #991b1b;
}

.toggle-btn:hover {
  opacity: 0.9;
}

.shipping-zones {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.shipping-zones h2 {
  margin: 0 0 20px 0;
  font-size: 20px;
  color: #1f2937;
  display: flex;
  align-items: center;
  gap: 10px;
}

.zones-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
}

.zone-card {
  background: #f9fafb;
  border-radius: 8px;
  padding: 15px;
  border: 1px solid #e5e7eb;
}

.zone-card h3 {
  margin: 0 0 8px 0;
  font-size: 16px;
  color: #1f2937;
}

.zone-card p {
  margin: 0 0 12px 0;
  color: #6b7280;
  font-size: 14px;
}

.zone-countries {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.country-tag {
  padding: 4px 10px;
  background: #e0e7ff;
  color: #4f46e5;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 500;
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
}

.close-btn:hover {
  background: #e5e7eb;
}

.modal-body {
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
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 14px;
  color: #374151;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.form-group label input[type="checkbox"] {
  margin-right: 8px;
}

.modal-actions {
  padding: 20px;
  border-top: 1px solid #e5e7eb;
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
  
  .shipping-methods {
    grid-template-columns: 1fr;
  }
  
  .zones-grid {
    grid-template-columns: 1fr;
  }
}
</style>