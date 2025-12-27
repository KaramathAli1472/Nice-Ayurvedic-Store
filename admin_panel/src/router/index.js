import { createRouter, createWebHistory } from "vue-router";

import Login from "../views/login/Login.vue";
import DashboardLayout from "../views/dashboard/DashboardLayout.vue";
import Dashboard from "../views/dashboard/Dashboard.vue";
import Products from "../views/dashboard/ProductPage.vue";
import Orders from "../views/ordersPage/OrdersPage.vue";
import Customers from "../views/customersPage/CustomersPage.vue";
import Analytics from "../views/reportsPage/AnalyticsPage.vue";
import Categories from "../views/categoriesPage/CategoriesPage.vue";
import Inventory from "../views/inventoryPage/InventoryPage.vue";
import Shipping from "../views/shippingPage/ShippingPage.vue";
import Reviews from "../views/reviewsPage/ReviewsPage.vue";

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
      {
        path: "analytics", // /dashboard/analytics
        name: "Analytics",
        component: Analytics,
      },
      {
        path: "categories", // /dashboard/categories
        name: "Categories",
        component: Categories,
      },
      {
        path: "inventory", // /dashboard/inventory
        name: "Inventory",
        component: Inventory,
      },
      {
        path: "shipping", // /dashboard/shipping
        name: "Shipping",
        component: Shipping,
      },
      {
        path: "reviews", // /dashboard/reviews
        name: "Reviews",
        component: Reviews,
      },
    ],
  },
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