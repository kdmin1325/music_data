
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDcYxPOL5JDxuLtRyyOG2nR5HzEoEQZ6tU",
    authDomain: "stock-price-9a7b9.firebaseapp.com",
    projectId: "stock-price-9a7b9",
    storageBucket: "stock-price-9a7b9.appspot.com",
    messagingSenderId: "641285869927",
    appId: "1:641285869927:web:e6b4f715ca150726669fc2",
    measurementId: "G-V1N987XPB2"
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});