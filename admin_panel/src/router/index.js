import { createRouter, createWebHistory } from "vue-router";

import Login from "../views/login/Login.vue";
import DashboardLayout from "../views/dashboard/DashboardLayout.vue";
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
    component: DashboardLayout,
    children: [
      {
        path: "", // Default dashboard
        name: "Dashboard",
        component: Dashboard,
      },
      {
        path: "products", // /dashboard/products
        name: "Products",
        component: Products,
      },
      {
        path: "orders", // /dashboard/orders
        name: "Orders",
        component: Orders,
      },
      {
        path: "customers", // /dashboard/customers
        name: "Customers",
        component: Customers,
      },
    ],
  },
  // Agar koi route nahi mila toh dashboard pe redirect karo
  {
    path: "/:pathMatch(.*)*",
    redirect: "/dashboard",
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;