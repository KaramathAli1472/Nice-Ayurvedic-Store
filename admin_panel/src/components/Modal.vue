<template>
  <div v-if="show" class="modal" @click.self="close">
    <div class="modal-content">
      <slot></slot>
      <button class="close-btn" @click="close">×</button>
    </div>
  </div>
</template>

<script>
export default {
  name: "Modal",
  props: {
    show: { type: Boolean, default: false }
  },
  emits: ["update:show"],
  methods: {
    close() {
      this.$emit("update:show", false);
    }
  }
};
</script>

<style scoped>
.modal {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: #fff;
  padding: 20px;
  border-radius: 10px;
  position: relative;
  max-width: 90%;
  max-height: 90%;
  overflow: auto;
}

.close-btn {
  position: absolute;
  top: 8px;
  right: 12px;
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
}
</style>
