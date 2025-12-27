// src/router/index.js
import { createRouter, createWebHistory } from "vue-router";

import Login from "../views/login/Login.vue";
import Dashboard from "../views/dashboard/Dashboard.vue";
import Products from "../views/dashboard/ProductPage.vue";
import Orders from "../views/ordersPage/OrdersPage.vue";
import Customers from "../views/customersPage/CustomersPage.vue";

const routes = [
  {
    path: "/",
    redirect: "/login",
  },
  {
    path: "/login",
    name: "Login",
    component: Login,
  },
  {
    path: "/dashboard",
    name: "Dashboard",
    component: Dashboard,
  },
  {
    path: "/products",
    name: "Products",
    component: Products,
  },
  {
    path: "/orders",
    name: "Orders",
    component: Orders,
  },
  {
    path: "/customers",
    name: "Customers",
    component: Customers,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;

