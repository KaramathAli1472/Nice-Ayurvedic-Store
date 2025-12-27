import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyBfHRQ4ODYk1gTk07-9P3nqVdRtmt7PH9c",
  authDomain: "nice-ayurvedic-store.firebaseapp.com",
  projectId: "nice-ayurvedic-store",
  storageBucket: "nice-ayurvedic-store.firebasestorage.app",
  messagingSenderId: "209482983272",
  appId: "1:209482983272:web:b64742281f4296b181d8dd",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Export services
export const db = getFirestore(app);
export const auth = getAuth(app);

