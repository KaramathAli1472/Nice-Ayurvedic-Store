<template>
  <div class="desktop-login">
    <div class="login-container">
      <!-- Left panel with logo -->
      <div class="left-panel">
        <div class="logo-container">
          <img src="@/assets/logo.png" alt="Nice Ayurvedic Store" class="logo" />
          <h1>Nice Ayurvedic Store</h1>
        </div>
        <h2>Admin Dashboard</h2>
        <p>Authentic Ayurvedic products & traditional remedies</p>
        <div class="sanskrit-text">
          <p>शरीरमाद्यं खलु धर्मसाधनम्</p>
          <p class="english">
            "The body is the primary instrument for fulfilling one's purpose"
          </p>
        </div>
      </div>

      <!-- Right panel with login form -->
      <div class="right-panel">
        <div class="form-container">
          <h3>Admin Login</h3>
          <p class="subtitle">Access your admin dashboard</p>

          <form @submit.prevent="login">
            <div class="input-group">
              <label for="email">
                <i class="fas fa-envelope"></i> Email Address
              </label>
              <input
                id="email"
                v-model="email"
                type="email"
                placeholder="admin@ayurvedicstore.com"
                required
              />
            </div>

            <div class="input-group">
              <label for="password">
                <i class="fas fa-lock"></i> Password
              </label>
              <input
                id="password"
                v-model="password"
                :type="showPassword ? 'text' : 'password'"
                placeholder="Enter your password"
                required
              />
              <span class="eye-icon" @click="showPassword = !showPassword">
                <i :class="showPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
              </span>
            </div>

            <div class="options">
              <label class="remember-me">
                <input type="checkbox" v-model="rememberMe" />
                <span>Remember me</span>
              </label>
              <a href="#" class="forgot-password">Forgot Password?</a>
            </div>

            <button
              type="submit"
              class="login-btn"
              :disabled="loading"
            >
              <i class="fas fa-sign-in-alt"></i>
              {{ loading ? 'Logging in...' : 'Login to Dashboard' }}
            </button>

            <p v-if="error" class="error-message">
              <i class="fas fa-exclamation-circle"></i> {{ error }}
            </p>

            <div class="security-note">
              <i class="fas fa-shield-alt"></i>
              <span>Secure login powered by Firebase</span>
            </div>
          </form>

          <div class="footer">
            <p>© 2024 Nice Ayurvedic Store. All rights reserved.</p>
            <p class="support">
              <i class="fas fa-headset"></i> Support: +91 98854 22430
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { signInWithEmailAndPassword } from "firebase/auth";
import { auth } from "../../firebase";

export default {
  name: "Login",
  data() {
    return {
      email: "",
      password: "",
      rememberMe: false,
      showPassword: false,
      error: "",
      loading: false,
    };
  },
  mounted() {
    const rememberedEmail = localStorage.getItem("rememberedEmail");
    if (rememberedEmail) {
      this.email = rememberedEmail;
      this.rememberMe = true;
    }
  },
  methods: {
    async login() {
      this.error = "";
      this.loading = true;

      if (this.rememberMe) {
        localStorage.setItem("rememberedEmail", this.email);
      } else {
        localStorage.removeItem("rememberedEmail");
      }

      try {
        await signInWithEmailAndPassword(auth, this.email, this.password);
        this.$router.push("/dashboard");
      } catch (err) {
        console.error(err);
        this.error = "Email or Password is incorrect. Please try again.";
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

<style scoped>
/* Pure full‑screen login */
.desktop-login {
  position: fixed;          /* viewport pe chipka do */
  inset: 0;                 /* top/right/bottom/left: 0 */
  display: flex;
  background: #000;         /* backup color (dikhne nahi wala) */
}

/* Card ki jagah full screen 2 columns */
.login-container {
  display: flex;
  flex: 1;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

/* Dono panels half‑half */
.left-panel,
.right-panel {
  flex: 1;
}

/* LEFT PANEL */
.left-panel {
  background: linear-gradient(135deg, #0f5132 0%, #198754 100%);
  padding: 60px;
  color: white;
  display: flex;
  flex-direction: column;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

.left-panel::before {
  content: "";
  position: absolute;
  inset: 0;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100' preserveAspectRatio='none'%3E%3Cpath d='M0,0 L100,0 L100,100 Z' fill='white' opacity='0.05'/%3E%3C/svg%3E");
  background-size: cover;
}

.logo-container {
  margin-bottom: 30px;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.logo {
  width: 120px;
  height: 120px;
  margin-bottom: 20px;
  border-radius: 50%;
  border: 3px solid rgba(255, 255, 255, 0.3);
  padding: 10px;
  background: rgba(255, 255, 255, 0.1);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.logo-container h1 {
  font-size: 36px;
  font-weight: 700;
  margin: 0 0 10px 0;
  color: #fff;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.left-panel h2 {
  font-size: 28px;
  font-weight: 400;
  margin: 0 0 15px 0;
  color: #d4edda;
}

.left-panel p {
  font-size: 18px;
  line-height: 1.6;
  margin: 0 0 30px 0;
  color: #c3e6cb;
  max-width: 400px;
}

.sanskrit-text {
  margin-top: auto;
  padding-top: 30px;
  border-top: 1px solid rgba(255, 255, 255, 0.2);
}

.sanskrit-text p {
  font-size: 20px;
  font-style: italic;
  color: #fff;
  margin: 0 0 10px 0;
}

.sanskrit-text .english {
  font-size: 16px;
  font-style: normal;
  opacity: 0.9;
  color: #d4edda;
  margin: 0;
}

/* RIGHT PANEL */
.right-panel {
  padding: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8f9fa;
}

.form-container {
  width: 100%;
  max-width: 400px;
}

.form-container h3 {
  font-size: 32px;
  color: #333;
  margin: 0 0 10px 0;
  font-weight: 700;
}

.subtitle {
  color: #666;
  margin: 0 0 40px 0;
  font-size: 16px;
}

/* FORM */
.input-group {
  position: relative;
  margin-bottom: 25px;
}

.input-group label {
  display: block;
  margin-bottom: 8px;
  color: #555;
  font-weight: 600;
  font-size: 14px;
}

.input-group label i {
  margin-right: 8px;
  color: #198754;
}

.input-group input {
  width: 100%;
  padding: 15px;
  border: 2px solid #e0e0e0;
  border-radius: 10px;
  font-size: 16px;
  transition: all 0.3s;
  background: white;
  box-sizing: border-box;
}

.input-group input:focus {
  outline: none;
  border-color: #198754;
  box-shadow: 0 0 0 3px rgba(25, 135, 84, 0.1);
}

.eye-icon {
  position: absolute;
  right: 15px;
  top: 50%;
  transform: translateY(-50%);
  cursor: pointer;
  color: #666;
  font-size: 18px;
  background: white;
  padding: 0 5px;
  border-radius: 3px;
}

.options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.remember-me {
  display: flex;
  align-items: center;
  cursor: pointer;
  color: #555;
  font-size: 14px;
}

.remember-me input {
  margin-right: 8px;
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.forgot-password {
  color: #198754;
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
}

.forgot-password:hover {
  text-decoration: underline;
}

.login-btn {
  width: 100%;
  padding: 18px;
  background: linear-gradient(to right, #198754, #0f5132);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 18px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  margin-bottom: 20px;
}

.login-btn:hover:not(:disabled) {
  background: linear-gradient(to right, #157347, #0b4226);
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(25, 135, 84, 0.3);
}

.login-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.login-btn i {
  margin-right: 10px;
}

.error-message {
  background: #fee;
  color: #c00;
  padding: 12px;
  border-radius: 8px;
  font-size: 14px;
  margin-bottom: 20px;
  border-left: 4px solid #c00;
}

.error-message i {
  margin-right: 8px;
}

.security-note {
  display: flex;
  align-items: center;
  justify-content: center;
  background: #e9f7ef;
  padding: 12px;
  border-radius: 8px;
  margin-top: 25px;
  color: #198754;
  font-size: 14px;
}

.security-note i {
  margin-right: 8px;
}

.footer {
  margin-top: 40px;
  padding-top: 20px;
  border-top: 1px solid #e0e0e0;
  text-align: center;
  color: #777;
  font-size: 13px;
}

.footer p {
  margin: 0 0 8px 0;
}

.support {
  color: #198754;
}

.support i {
  margin-right: 5px;
}
</style>
