<template>
  <!-- RouterView will render Login, Dashboard, etc -->
  <router-view></router-view>
</template>

<script>
export default {
  name: "App",
};
</script>

<style>
/* Global reset + layout */
html, body, #app {
  margin: 0;
  padding: 0;
  width: 100%;
  min-height: 100vh;
}

/* Optional global styles */
body {
  font-family: Arial, sans-serif;
  background: #f3f4f6; /* light grey so black side area nahi aayega */
  color: #111827;
  box-sizing: border-box;
}

/* Ensure all elements use border-box */
*, *::before, *::after {
  box-sizing: inherit;
}
</style>
