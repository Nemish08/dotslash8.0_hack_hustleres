import { initializeApp } from "firebase/app"
import { GoogleAuthProvider } from "firebase/auth"
import { getDatabase } from "firebase/database"

const firebaseConfig = {
    apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
    authDomain: "socialai-84ffe.firebaseapp.com",
    projectId: "socialai-84ffe",
    databaseURL: "https://socialai-84ffe-default-rtdb.asia-southeast1.firebasedatabase.app",
    storageBucket: "socialai-84ffe.firebasestorage.app",
    messagingSenderId: "302294878610",
    appId: "1:302294878610:web:3a6057490e3adcbc6dd94b",
    measurementId: "G-ZS4VPGV6MS"
}

export const app = initializeApp(firebaseConfig)
export const provider = new GoogleAuthProvider()
export const db = getDatabase(app)