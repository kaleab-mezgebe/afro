#!/usr/bin/env node

/**
 * Firebase Authentication Test Script
 * This script tests Firebase authentication and helps diagnose 400 errors
 */

const https = require('https');

// Firebase configuration from .env.local
const FIREBASE_CONFIG = {
  apiKey: 'AIzaSyBu3dwqiJ9Nd5A5u07iwVK_fgR9ydgkd0M',
  authDomain: 'afro-ce148.firebaseapp.com',
  projectId: 'afro-ce148'
};

// Test credentials (replace with actual admin credentials)
const TEST_CREDENTIALS = {
  email: 'admin@afro.com',
  password: 'admin123'
};

/**
 * Test Firebase REST API authentication
 */
async function testFirebaseAuth() {
  console.log('🔥 Testing Firebase Authentication...\n');
  
  // Test 1: Check if Email/Password sign-in is enabled
  console.log('1️⃣ Checking Firebase Auth configuration...');
  
  const authUrl = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_CONFIG.apiKey}`;
  
  const postData = JSON.stringify({
    email: TEST_CREDENTIALS.email,
    password: TEST_CREDENTIALS.password,
    returnSecureToken: true
  });

  const options = {
    hostname: 'identitytoolkit.googleapis.com',
    port: 443,
    path: `/v1/accounts:signInWithPassword?key=${FIREBASE_CONFIG.apiKey}`,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData)
    }
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        console.log(`Status Code: ${res.statusCode}`);
        console.log(`Response Headers:`, res.headers);
        
        try {
          const response = JSON.parse(data);
          console.log(`Response Body:`, JSON.stringify(response, null, 2));
          
          if (res.statusCode === 200) {
            console.log('✅ Authentication successful!');
            resolve(response);
          } else {
            console.log('❌ Authentication failed!');
            
            // Analyze common error codes
            if (response.error) {
              const errorCode = response.error.message;
              console.log(`\n🔍 Error Analysis:`);
              
              switch (errorCode) {
                case 'EMAIL_NOT_FOUND':
                  console.log('   - The email address is not registered');
                  break;
                case 'INVALID_PASSWORD':
                  console.log('   - The password is incorrect');
                  break;
                case 'USER_DISABLED':
                  console.log('   - The user account has been disabled');
                  break;
                case 'OPERATION_NOT_ALLOWED':
                  console.log('   - Email/Password sign-in is NOT ENABLED in Firebase Console');
                  console.log('   - Go to Firebase Console > Authentication > Sign-in method');
                  console.log('   - Enable "Email/Password" provider');
                  break;
                case 'TOO_MANY_ATTEMPTS_TRY_LATER':
                  console.log('   - Too many failed attempts, account temporarily locked');
                  break;
                default:
                  console.log(`   - Unknown error: ${errorCode}`);
              }
            }
            
            reject(new Error(`Authentication failed: ${res.statusCode}`));
          }
        } catch (parseError) {
          console.log('Raw response:', data);
          reject(parseError);
        }
      });
    });

    req.on('error', (error) => {
      console.error('Request error:', error);
      reject(error);
    });

    req.write(postData);
    req.end();
  });
}

/**
 * Test Firebase project configuration
 */
async function testFirebaseConfig() {
  console.log('\n2️⃣ Testing Firebase project configuration...');
  
  const configUrl = `https://${FIREBASE_CONFIG.authDomain}/__/firebase/init.json`;
  
  return new Promise((resolve, reject) => {
    https.get(configUrl, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        console.log(`Config Status: ${res.statusCode}`);
        
        if (res.statusCode === 200) {
          try {
            const config = JSON.parse(data);
            console.log('✅ Firebase project is accessible');
            console.log(`Project ID: ${config.projectId || 'Not found'}`);
            resolve(config);
          } catch (error) {
            console.log('❌ Invalid config response');
            reject(error);
          }
        } else {
          console.log('❌ Firebase project not accessible');
          reject(new Error(`Config check failed: ${res.statusCode}`));
        }
      });
    }).on('error', (error) => {
      console.error('Config request error:', error);
      reject(error);
    });
  });
}

/**
 * Main test function
 */
async function main() {
  console.log('🚀 Firebase Authentication Diagnostic Tool\n');
  console.log(`Project ID: ${FIREBASE_CONFIG.projectId}`);
  console.log(`Auth Domain: ${FIREBASE_CONFIG.authDomain}`);
  console.log(`Test Email: ${TEST_CREDENTIALS.email}\n`);
  
  try {
    // Test Firebase configuration
    await testFirebaseConfig();
    
    // Test authentication
    await testFirebaseAuth();
    
  } catch (error) {
    console.error('\n💥 Test failed:', error.message);
    
    console.log('\n🛠️  Troubleshooting Steps:');
    console.log('1. Check Firebase Console: https://console.firebase.google.com/');
    console.log(`2. Go to project: ${FIREBASE_CONFIG.projectId}`);
    console.log('3. Navigate to Authentication > Sign-in method');
    console.log('4. Enable "Email/Password" provider');
    console.log('5. Create an admin user in Authentication > Users');
    console.log('6. Verify the API key is correct');
    
    process.exit(1);
  }
}

// Run the test
if (require.main === module) {
  main();
}

module.exports = { testFirebaseAuth, testFirebaseConfig };