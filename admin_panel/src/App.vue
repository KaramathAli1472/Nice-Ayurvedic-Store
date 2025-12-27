<!-- src/App.vue -->
<template>
  <router-view />
</template>

<script>
export default {
  name: "App",
};
</script>

<style>
html,
body,
#app {
  margin: 0;
  padding: 0;
  width: 100%;
  min-height: 100vh;
}

body {
  font-family: Arial, sans-serif;
  background: #f3f4f6;
  color: #111827;
  box-sizing: border-box;
}

*,
*::before,
*::after {
  box-sizing: inherit;
}
</style>
