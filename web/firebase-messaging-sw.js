importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCxV0AuKBwRcarvO3l1rYFUoZzu5dqf85U',
  appId: '1:1020371140475:web:3802674651d406c63487de',
  messagingSenderId: '1020371140475',
  projectId: 'medical-baf76',
  authDomain: 'medical-baf76.firebaseapp.com',
  storageBucket: 'medical-baf76.firebasestorage.app',
});

const messaging = firebase.messaging();
