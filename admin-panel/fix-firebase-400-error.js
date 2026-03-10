#!/usr/bin/env node

/**
 * Firebase 400 Error Diagnostic and Fix Script
 * Focuses on resolving the specific 400 error in admin login
 */

const https = require('https');

const FIREBASE_CONFIG = {
  apiKey: 'AIzaSyBu3dwqiJ9Nd5A5u07iwVK_fgR9ydgkd0M',
  authDomain: 'afro-ce148.firebaseapp.com',
  projectId: 'afro-ce148'
};

/**
 * Make HTTPS request with detailed error handling
 */
function makeRequest(options, postData = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const response = data ? JSON.parse(data) : {};
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            data: response,
            rawData: data
          });
        } catch (error) {
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            data: null,
            rawData: data,
            parseError: error.message
          });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    if (postData) {
      req.write(postData);
    }
    req.end();
  });
}

/**
 * Test basic Firebase project accessibility
 */
async function testProjectAccess() {
  console.log('🔍 Testing Firebase project accessibility...\n');
  
  // Test different endpoints to find working ones
  const endpoints = [
    {
      name: 'Project Info',
      path: `/v1/projects/${FIREBASE_CONFIG.projectId}`,
      host: 'firebase.googleapis.com'
    },
    {
      name: 'Auth Config',
      path: `/v1/projects/${FIREBASE_CONFIG.projectId}/config`,
      host: 'identitytoolkit.googleapis.com'
    },
    {
      name: 'Auth Domain Check',
      path: '/__/firebase/init.json',
      host: FIREBASE_CONFIG.authDomain.replace('https://', '')
    }
  ];

  for (const endpoint of endpoints) {
    try {
      console.log(`Testing ${endpoint.name}...`);
      
      const options = {
        hostname: endpoint.host,
        port: 443,
        path: endpoint.path + (endpoint.path.includes('?') ? '&' : '?') + `key=${FIREBASE_CONFIG.apiKey}`,
        method: 'GET',
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Firebase-Admin-Node'
        }
      };

      const response = await makeRequest(options);
      
      console.log(`   Status: ${response.statusCode}`);
      
      if (response.statusCode === 200) {
        console.log('   ✅ Success!');
        if (response.data) {
          console.log('   Data keys:', Object.keys(response.data));
        }
      } else if (response.statusCode === 404) {
        console.log('   ❌ Not Found (404)');
      } else if (response.statusCode === 403) {
        console.log('   ❌ Forbidden (403) - Check API key permissions');
      } else {
        console.log('   ❌ Error:', response.statusCode);
        if (response.data && response.data.error) {
          console.log('   Error message:', response.data.error.message);
        }
      }
      
    } catch (error) {
      console.log(`   ❌ Request failed: ${error.message}`);
    }
    
    console.log('');
  }
}

/**
 * Test email/password authentication (the current failing method)
 */
async function testEmailPasswordAuth() {
  console.log('🔐 Testing Email/Password Authentication...\n');
  
  const testCredentials = [
    { email: 'admin@afro.com', password: 'admin123' },
    { email: 'test@example.com', password: 'password123' }
  ];

  for (const creds of testCredentials) {
    console.log(`Testing: ${creds.email}`);
    
    const postData = JSON.stringify({
      email: creds.email,
      password: creds.password,
      returnSecureToken: true
    });

    const options = {
      hostname: 'identitytoolkit.googleapis.com',
      port: 443,
      path: `/v1/accounts:signInWithPassword?key=${FIREBASE_CONFIG.apiKey}`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData),
        'Accept': 'application/json'
      }
    };

    try {
      const response = await makeRequest(options, postData);
      
      console.log(`   Status: ${response.statusCode}`);
      
      if (response.statusCode === 200) {
        console.log('   ✅ Authentication successful!');
        console.log(`   User ID: ${response.data.localId}`);
      } else {
        console.log('   ❌ Authentication failed');
        
        if (response.data && response.data.error) {
          const error = response.data.error;
          console.log(`   Error: ${error.message}`);
          
          // Provide specific solutions
          switch (error.message) {
            case 'OPERATION_NOT_ALLOWED':
              console.log('   🔧 Solution: Enable Email/Password authentication in Firebase Console');
              break;
            case 'EMAIL_NOT_FOUND':
              console.log('   🔧 Solution: Create the user account first');
              break;
            case 'INVALID_PASSWORD':
              console.log('   🔧 Solution: Check the password or reset it');
              break;
            case 'USER_DISABLED':
              console.log('   🔧 Solution: Enable the user account in Firebase Console');
              break;
            case 'TOO_MANY_ATTEMPTS_TRY_LATER':
              console.log('   🔧 Solution: Wait before trying again or reset the account');
              break;
            default:
              console.log(`   🔧 Unknown error: ${error.message}`);
          }
        } else if (response.parseError) {
          console.log('   ❌ Response parsing error:', response.parseError);
          console.log('   Raw response:', response.rawData.substring(0, 200) + '...');
        }
      }
      
    } catch (error) {
      console.log(`   ❌ Request error: ${error.message}`);
    }
    
    console.log('');
  }
}

/**
 * Test user creation to verify API access
 */
async function testUserCreation() {
  console.log('👤 Testing User Creation...\n');
  
  const testEmail = 'test-' + Date.now() + '@example.com';
  const testPassword = 'TestPassword123!';
  
  console.log(`Creating test user: ${testEmail}`);
  
  const postData = JSON.stringify({
    email: testEmail,
    password: testPassword,
    returnSecureToken: true
  });

  const options = {
    hostname: 'identitytoolkit.googleapis.com',
    port: 443,
    path: `/v1/accounts:signUp?key=${FIREBASE_CONFIG.apiKey}`,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData),
      'Accept': 'application/json'
    }
  };

  try {
    const response = await makeRequest(options, postData);
    
    console.log(`Status: ${response.statusCode}`);
    
    if (response.statusCode === 200) {
      console.log('✅ User creation successful!');
      console.log(`User ID: ${response.data.localId}`);
      console.log(`Email: ${response.data.email}`);
      
      // Now try to sign in with the created user
      console.log('\nTesting sign-in with created user...');
      await testSignInWithCreatedUser(testEmail, testPassword);
      
    } else {
      console.log('❌ User creation failed');
      
      if (response.data && response.data.error) {
        const error = response.data.error;
        console.log(`Error: ${error.message}`);
        
        switch (error.message) {
          case 'OPERATION_NOT_ALLOWED':
            console.log('🔧 Email/Password sign-up is disabled in Firebase Console');
            break;
          case 'EMAIL_EXISTS':
            console.log('🔧 User already exists');
            break;
          case 'WEAK_PASSWORD':
            console.log('🔧 Password is too weak');
            break;
          default:
            console.log(`🔧 Unknown error: ${error.message}`);
        }
      }
    }
    
  } catch (error) {
    console.log(`❌ Request error: ${error.message}`);
  }
}

/**
 * Test sign-in with newly created user
 */
async function testSignInWithCreatedUser(email, password) {
  const postData = JSON.stringify({
    email: email,
    password: password,
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

  try {
    const response = await makeRequest(options, postData);
    
    if (response.statusCode === 200) {
      console.log('✅ Sign-in with created user successful!');
      console.log('🎉 Firebase Authentication is working correctly!');
    } else {
      console.log('❌ Sign-in with created user failed');
      if (response.data && response.data.error) {
        console.log(`Error: ${response.data.error.message}`);
      }
    }
  } catch (error) {
    console.log(`❌ Sign-in test error: ${error.message}`);
  }
}

/**
 * Provide comprehensive solution steps
 */
function provideSolutions() {
  console.log('\n' + '='.repeat(60));
  console.log('🛠️  COMPREHENSIVE SOLUTION STEPS');
  console.log('='.repeat(60));
  
  console.log('\n1️⃣ FIREBASE CONSOLE CONFIGURATION');
  console.log('   Go to: https://console.firebase.google.com/');
  console.log(`   Project: ${FIREBASE_CONFIG.projectId}`);
  console.log('   Steps:');
  console.log('   a) Authentication > Sign-in method');
  console.log('   b) Enable "Email/Password" provider');
  console.log('   c) Save configuration');
  
  console.log('\n2️⃣ CREATE ADMIN USER');
  console.log('   In Firebase Console:');
  console.log('   a) Authentication > Users');
  console.log('   b) Add user: admin@afro.com');
  console.log('   c) Set password: admin123 (or your choice)');
  
  console.log('\n3️⃣ VERIFY API KEY');
  console.log('   Check that your API key has the correct permissions:');
  console.log(`   Current API Key: ${FIREBASE_CONFIG.apiKey}`);
  console.log('   Should have Identity Toolkit API access');
  
  console.log('\n4️⃣ TEST AUTHENTICATION');
  console.log('   After configuration, test with:');
  console.log('   - Email: admin@afro.com');
  console.log('   - Password: admin123');
  
  console.log('\n5️⃣ ENABLE EMAIL LINK (OPTIONAL)');
  console.log('   For passwordless authentication:');
  console.log('   a) In Email/Password settings');
  console.log('   b) Enable "Email link (passwordless sign-in)"');
  console.log('   c) Add authorized domains: localhost, your-domain.com');
  
  console.log('\n6️⃣ TROUBLESHOOTING');
  console.log('   If issues persist:');
  console.log('   - Check Firebase project billing (Blaze plan may be required)');
  console.log('   - Verify project ID matches your configuration');
  console.log('   - Check API key restrictions in Google Cloud Console');
  console.log('   - Ensure Identity Toolkit API is enabled');
}

/**
 * Main diagnostic function
 */
async function main() {
  console.log('🚨 Firebase 400 Error Diagnostic Tool');
  console.log('=====================================\n');
  
  console.log(`Project ID: ${FIREBASE_CONFIG.projectId}`);
  console.log(`Auth Domain: ${FIREBASE_CONFIG.authDomain}`);
  console.log(`API Key: ${FIREBASE_CONFIG.apiKey.substring(0, 20)}...\n`);
  
  // Test project accessibility
  await testProjectAccess();
  
  console.log('='.repeat(50));
  
  // Test email/password authentication
  await testEmailPasswordAuth();
  
  console.log('='.repeat(50));
  
  // Test user creation
  await testUserCreation();
  
  // Provide solutions
  provideSolutions();
  
  console.log('\n🔄 Run this script again after making changes to verify fixes.');
}

// Run the diagnostic
if (require.main === module) {
  main().catch(error => {
    console.error('💥 Diagnostic failed:', error.message);
    process.exit(1);
  });
}