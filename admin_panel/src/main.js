import { createApp } from 'vue';
import App from './App.vue';
import router from './router';

import './assets/global-fix.css';   // << yeh line add karo

createApp(App).use(router).mount('#app');
