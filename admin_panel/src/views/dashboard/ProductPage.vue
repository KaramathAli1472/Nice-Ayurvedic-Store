<template>
  <div class="product-page">
    <div class="header">
      <h1>Product Management</h1>
    </div>

    <div class="layout">
      <!-- Left: Add/Edit Product Form -->
      <div class="form-section">
        <div class="card">
          <h2>{{ editingProduct ? "Edit Product" : "Add New Product" }}</h2>
          <form @submit.prevent="editingProduct ? updateProduct() : addProduct()">
            <div class="form-group">
              <label>Product Name</label>
              <input type="text" v-model="name" placeholder="Enter product name" required />
            </div>

            <div class="form-group">
              <label>Category</label>
              <select v-model="category" required>
                <option value="">Select Category</option>
                <option value="Ayurvedic Medicine">Ayurvedic Medicine</option>
                <option value="Personal Care">Personal Care</option>
                <option value="Dietary Supplement">Dietary Supplement</option>
                <option value="Sugar Management">Sugar Management</option>
                <option value="Women's Health">Women's Health</option>
                <option value="Men's Health">Men's Health</option>
              </select>
            </div>

            <div class="row">
              <div class="form-group half">
                <label>Price (₹)</label>
                <input type="number" v-model.number="price" placeholder="0" required />
              </div>
              <div class="form-group half">
                <label>Stock</label>
                <input type="number" v-model.number="stock" placeholder="0" required />
              </div>
            </div>

            <div class="form-group">
              <label>Description</label>
              <textarea v-model="description" placeholder="Product description"></textarea>
            </div>

            <div class="form-group">
              <label>Product Image</label>
              <div class="file-upload" @click="triggerFileInput">
                <input type="file" ref="fileInput" @change="handleImageUpload" accept="image/*" />
                <span>{{ imageFile ? imageFile.name : "Choose image" }}</span>
              </div>
              <div v-if="imagePreview" class="image-preview">
                <img :src="imagePreview" alt="Preview" />
              </div>
            </div>

            <button type="submit" class="submit-btn">{{ editingProduct ? "Update Product" : "Add Product" }}</button>
            <button v-if="editingProduct" type="button" class="submit-btn cancel-btn" @click="cancelEdit">Cancel</button>
          </form>
        </div>
      </div>

      <!-- Right: Product List -->
      <div class="list-section">
        <div class="card">
          <div class="list-header">
            <h2>All Products</h2>
            <span class="count">{{ products.length }} products</span>
          </div>

          <div class="table-container">
            <table>
              <thead>
                <tr>
                  <th>Image</th>
                  <th>Name</th>
                  <th>Category</th>
                  <th>Price</th>
                  <th>Stock</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="prod in products" :key="prod.id">
                  <td>
                    <img 
                      :src="prod.imageUrl || 'https://via.placeholder.com/60'" 
                      :alt="prod.name"
                      class="product-img"
                      @click="viewImage(prod.imageUrl)"
                    />
                  </td>
                  <td>{{ prod.name }}</td>
                  <td><span class="category-tag">{{ prod.category }}</span></td>
                  <td>₹{{ prod.price }}</td>
                  <td>
                    <span :class="['stock', { 'low': prod.stock < 10 }]">
                      {{ prod.stock }}
                    </span>
                  </td>
                  <td>
                    <button class="edit-btn" @click="editProduct(prod)">Edit</button>
                    <button class="delete-btn" @click="deleteProduct(prod.id)">Delete</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Image Modal -->
    <div v-if="showModal" class="modal" @click="showModal = false">
      <img :src="selectedImage" class="modal-img" />
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from "vue";
import { collection, addDoc, getDocs, doc, updateDoc, deleteDoc } from "firebase/firestore";
import { db } from "../../firebase";

export default {
  name: "ProductPage",
  setup() {
    const name = ref("");
    const category = ref("");
    const price = ref(0);
    const stock = ref(0);
    const description = ref("");
    const imageFile = ref(null);
    const imagePreview = ref(null);
    const products = ref([]);

    const selectedImage = ref(null);
    const showModal = ref(false);
    const fileInput = ref(null);
    const editingProduct = ref(null);

    const triggerFileInput = () => {
      fileInput.value.click();
    };

    const handleImageUpload = (e) => {
      const file = e.target.files[0];
      if (file) {
        imageFile.value = file;
        // Create preview
        const reader = new FileReader();
        reader.onload = (e) => {
          imagePreview.value = e.target.result;
        };
        reader.readAsDataURL(file);
      }
    };

    const viewImage = (url) => {
      if (!url) return;
      selectedImage.value = url;
      showModal.value = true;
    };

    const fetchProducts = async () => {
      try {
        const querySnapshot = await getDocs(collection(db, "products"));
        products.value = querySnapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }));
      } catch (error) {
        console.error("Error fetching products:", error);
      }
    };

    const uploadToCloudinary = async (file) => {
      if (!file) return "";
      
      const formData = new FormData();
      formData.append("file", file);
      formData.append("upload_preset", "niceayurvedic");
      formData.append("cloud_name", "dn8fjqa0w");

      try {
        const res = await fetch(
          "https://api.cloudinary.com/v1_1/dn8fjqa0w/image/upload",
          { 
            method: "POST", 
            body: formData 
          }
        );
        
        if (!res.ok) {
          throw new Error(`Upload failed: ${res.status}`);
        }
        
        const data = await res.json();
        return data.secure_url || "";
      } catch (error) {
        console.error("Cloudinary upload error:", error);
        return "";
      }
    };

    const addProduct = async () => {
      try {
        // Upload image if exists
        let imageUrl = "";
        if (imageFile.value) {
          imageUrl = await uploadToCloudinary(imageFile.value);
        }

        const newProduct = {
          name: name.value,
          category: category.value,
          price: Number(price.value),
          stock: Number(stock.value),
          description: description.value,
          imageUrl,
          createdAt: new Date(),
        };

        // Add to Firestore
        const docRef = await addDoc(collection(db, "products"), newProduct);
        
        // INSTANT UPDATE: Add to local state immediately
        products.value.unshift({ ...newProduct, id: docRef.id });
        
        // Reset form
        resetForm();
        
        alert("Product added successfully!");
        
      } catch (error) {
        console.error("Error adding product:", error);
        alert("Error adding product. Please try again.");
      }
    };

    const editProduct = (prod) => {
      editingProduct.value = prod;
      name.value = prod.name;
      category.value = prod.category;
      price.value = prod.price;
      stock.value = prod.stock;
      description.value = prod.description || "";
      imageFile.value = null;
      imagePreview.value = prod.imageUrl || null;
    };

    const cancelEdit = () => {
      resetForm();
      editingProduct.value = null;
    };

    const updateProduct = async () => {
      if (!editingProduct.value) return;

      try {
        let imageUrl = editingProduct.value.imageUrl;

        // Upload new image if selected
        if (imageFile.value) {
          imageUrl = await uploadToCloudinary(imageFile.value);
        }

        const updatedProduct = {
          name: name.value,
          category: category.value,
          price: Number(price.value),
          stock: Number(stock.value),
          description: description.value,
          imageUrl,
          updatedAt: new Date(),
        };

        // Update in Firestore
        const docRef = doc(db, "products", editingProduct.value.id);
        await updateDoc(docRef, updatedProduct);

        // INSTANT UPDATE: Update local state immediately
        const index = products.value.findIndex(p => p.id === editingProduct.value.id);
        if (index !== -1) {
          products.value[index] = { ...updatedProduct, id: editingProduct.value.id };
        }

        cancelEdit();
        alert("Product updated successfully!");
        
      } catch (error) {
        console.error("Error updating product:", error);
        alert("Error updating product. Please try again.");
      }
    };

    const deleteProduct = async (id) => {
      if (!confirm("Are you sure you want to delete this product?")) return;

      try {
        await deleteDoc(doc(db, "products", id));
        
        // INSTANT UPDATE: Remove from local state immediately
        products.value = products.value.filter(p => p.id !== id);
        
        alert("Product deleted successfully!");
        
      } catch (error) {
        console.error("Error deleting product:", error);
        alert("Error deleting product. Please try again.");
      }
    };

    const resetForm = () => {
      name.value = "";
      category.value = "";
      price.value = 0;
      stock.value = 0;
      description.value = "";
      imageFile.value = null;
      imagePreview.value = null;
      editingProduct.value = null;
      
      // Clear file input
      if (fileInput.value) {
        fileInput.value.value = "";
      }
    };

    onMounted(fetchProducts);

    return {
      name,
      category,
      price,
      stock,
      description,
      imageFile,
      imagePreview,
      products,
      selectedImage,
      showModal,
      fileInput,
      editingProduct,
      handleImageUpload,
      triggerFileInput,
      viewImage,
      addProduct,
      editProduct,
      cancelEdit,
      updateProduct,
      deleteProduct,
    };
  },
};
</script>

<style scoped>
.product-page {
  padding: 20px;
  background: #f8f9fa;
  min-height: 100vh;
}

.header h1 {
  margin: 0 0 25px 0;
  color: #2c5530;
  font-size: 28px;
  font-weight: 600;
}

.layout {
  display: flex;
  gap: 25px;
}

.form-section {
  flex: 1;
  min-width: 400px;
}

.list-section {
  flex: 2;
  min-width: 600px;
}

.card {
  background: white;
  padding: 25px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  margin-bottom: 20px;
  border: 1px solid #e9ecef;
}

h2 {
  margin-top: 0;
  margin-bottom: 25px;
  color: #2c5530;
  font-size: 22px;
  font-weight: 600;
  border-bottom: 2px solid #e9f7ef;
  padding-bottom: 10px;
}

.form-group {
  margin-bottom: 22px;
}

label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #2c5530;
  font-size: 15px;
}

input, select, textarea {
  width: 100%;
  padding: 12px 15px;
  border: 2px solid #dee2e6;
  border-radius: 8px;
  font-size: 15px;
  color: #495057;
  transition: all 0.3s;
  background: #f8f9fa;
}

input:focus, select:focus, textarea:focus {
  outline: none;
  border-color: #2c5530;
  background: white;
  box-shadow: 0 0 0 3px rgba(44, 85, 48, 0.1);
}

input::placeholder, textarea::placeholder {
  color: #adb5bd;
}

.row {
  display: flex;
  gap: 15px;
}

.half {
  flex: 1;
}

.file-upload {
  border: 2px dashed #2c5530;
  color: #2c5530;
  padding: 20px;
  text-align: center;
  border-radius: 8px;
  cursor: pointer;
  position: relative;
  background: rgba(44, 85, 48, 0.05);
  transition: all 0.3s;
}

.file-upload:hover {
  background: rgba(44, 85, 48, 0.1);
}

.file-upload input {
  display: none;
}

.file-upload span {
  font-weight: 500;
  font-size: 15px;
}

.image-preview {
  margin-top: 15px;
  text-align: center;
}

.image-preview img {
  max-width: 200px;
  max-height: 150px;
  border-radius: 8px;
  border: 2px solid #dee2e6;
  object-fit: cover;
}

.submit-btn {
  width: 100%;
  padding: 14px;
  background: #2c5530;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  margin-top: 10px;
  transition: all 0.3s;
}

.submit-btn:hover {
  background: #1e3d23;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(44, 85, 48, 0.2);
}

.cancel-btn {
  background: #dc3545;
  margin-top: 10px;
}

.cancel-btn:hover {
  background: #c82333;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
  padding-bottom: 15px;
  border-bottom: 2px solid #e9f7ef;
}

.count {
  background: #e9f7ef;
  color: #2c5530;
  padding: 6px 15px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
}

.table-container {
  overflow-x: auto;
  border-radius: 8px;
  border: 1px solid #dee2e6;
}

table {
  width: 100%;
  border-collapse: collapse;
  background: white;
}

th {
  background: #2c5530;
  padding: 15px;
  text-align: left;
  font-weight: 600;
  color: white;
  font-size: 15px;
  border-bottom: 3px solid #1e3d23;
}

td {
  padding: 15px;
  border-bottom: 1px solid #e9ecef;
  color: #495057;
  font-size: 15px;
}

tr:hover {
  background: #f8f9fa;
}

.product-img {
  width: 60px;
  height: 60px;
  object-fit: cover;
  border-radius: 6px;
  border: 2px solid #e9ecef;
  cursor: pointer;
  transition: transform 0.3s;
}

.product-img:hover {
  transform: scale(1.05);
}

.category-tag {
  background: #e9f7ef;
  color: #2c5530;
  padding: 5px 12px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 500;
  display: inline-block;
}

.stock {
  font-weight: bold;
  padding: 5px 12px;
  border-radius: 20px;
  font-size: 14px;
  background: #d4edda;
  color: #155724;
}

.stock.low {
  background: #f8d7da;
  color: #721c24;
}

.edit-btn, .delete-btn {
  padding: 7px 15px;
  margin-right: 8px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.3s;
}

.edit-btn {
  background: #2c5530;
  color: white;
}

.edit-btn:hover {
  background: #1e3d23;
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

.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.85);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  padding: 20px;
}

.modal-img {
  max-width: 90%;
  max-height: 90%;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.5);
  cursor: pointer;
  animation: zoomIn 0.3s;
}

@keyframes zoomIn {
  from {
    transform: scale(0.8);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}

/* Responsive adjustments */
@media (max-width: 1200px) {
  .layout {
    flex-direction: column;
  }
  
  .form-section,
  .list-section {
    min-width: 100%;
  }
}
</style>