#!/usr/bin/env node

/**
 * Firebase Authentication Setup Script
 * This script helps enable Email/Password authentication and create admin users
 */

const https = require('https');
const readline = require('readline');

// Firebase configuration
const FIREBASE_CONFIG = {
  apiKey: 'AIzaSyBu3dwqiJ9Nd5A5u07iwVK_fgR9ydgkd0M',
  authDomain: 'afro-ce148.firebaseapp.com',
  projectId: 'afro-ce148'
};

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

/**
 * Make HTTPS request helper
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
            data: response
          });
        } catch (error) {
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            data: data
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
 * Test direct authentication
 */
async function testDirectAuth(email, password) {
  console.log(`\n🔐 Testing authentication for: ${email}`);
  
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
    
    console.log(`Status: ${response.statusCode}`);
    
    if (response.statusCode === 200) {
      console.log('✅ Authentication successful!');
      console.log(`User ID: ${response.data.localId}`);
      console.log(`ID Token: ${response.data.idToken ? 'Present' : 'Missing'}`);
      return true;
    } else {
      console.log('❌ Authentication failed!');
      console.log('Response:', JSON.stringify(response.data, null, 2));
      
      if (response.data.error) {
        const errorMessage = response.data.error.message;
        console.log(`\n🔍 Error: ${errorMessage}`);
        
        switch (errorMessage) {
          case 'OPERATION_NOT_ALLOWED':
            console.log('📋 Solution: Email/Password authentication is disabled');
            console.log('   1. Go to Firebase Console: https://console.firebase.google.com/');
            console.log(`   2. Select project: ${FIREBASE_CONFIG.projectId}`);
            console.log('   3. Go to Authentication > Sign-in method');
            console.log('   4. Enable "Email/Password" provider');
            break;
          case 'EMAIL_NOT_FOUND':
            console.log('📋 Solution: User does not exist');
            console.log('   1. Create user in Firebase Console > Authentication > Users');
            console.log('   2. Or use the signup endpoint to create the user');
            break;
          case 'INVALID_PASSWORD':
            console.log('📋 Solution: Incorrect password');
            break;
          case 'USER_DISABLED':
            console.log('📋 Solution: User account is disabled');
            break;
        }
      }
      return false;
    }
  } catch (error) {
    console.error('Request failed:', error.message);
    return false;
  }
}

/**
 * Create a new user
 */
async function createUser(email, password) {
  console.log(`\n👤 Creating user: ${email}`);
  
  const postData = JSON.stringify({
    email: email,
    password: password,
    returnSecureToken: true
  });

  const options = {
    hostname: 'identitytoolkit.googleapis.com',
    port: 443,
    path: `/v1/accounts:signUp?key=${FIREBASE_CONFIG.apiKey}`,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData)
    }
  };

  try {
    const response = await makeRequest(options, postData);
    
    console.log(`Status: ${response.statusCode}`);
    
    if (response.statusCode === 200) {
      console.log('✅ User created successfully!');
      console.log(`User ID: ${response.data.localId}`);
      console.log(`Email: ${response.data.email}`);
      return true;
    } else {
      console.log('❌ User creation failed!');
      console.log('Response:', JSON.stringify(response.data, null, 2));
      
      if (response.data.error) {
        const errorMessage = response.data.error.message;
        console.log(`\n🔍 Error: ${errorMessage}`);
        
        switch (errorMessage) {
          case 'OPERATION_NOT_ALLOWED':
            console.log('📋 Email/Password authentication is not enabled');
            break;
          case 'EMAIL_EXISTS':
            console.log('📋 User already exists, try signing in instead');
            break;
          case 'WEAK_PASSWORD':
            console.log('📋 Password is too weak, use at least 6 characters');
            break;
        }
      }
      return false;
    }
  } catch (error) {
    console.error('Request failed:', error.message);
    return false;
  }
}

/**
 * Get project configuration
 */
async function getProjectConfig() {
  console.log('\n🔧 Checking Firebase project configuration...');
  
  // Try multiple endpoints to verify project
  const endpoints = [
    `https://firebase.googleapis.com/v1beta1/projects/${FIREBASE_CONFIG.projectId}?key=${FIREBASE_CONFIG.apiKey}`,
    `https://identitytoolkit.googleapis.com/v1/projects/${FIREBASE_CONFIG.projectId}/config?key=${FIREBASE_CONFIG.apiKey}`
  ];

  for (const endpoint of endpoints) {
    try {
      const url = new URL(endpoint);
      const options = {
        hostname: url.hostname,
        port: 443,
        path: url.pathname + url.search,
        method: 'GET'
      };

      const response = await makeRequest(options);
      console.log(`Testing ${url.hostname}: ${response.statusCode}`);
      
      if (response.statusCode === 200) {
        console.log('✅ Project is accessible');
        return response.data;
      }
    } catch (error) {
      console.log(`❌ Failed to check ${endpoint}: ${error.message}`);
    }
  }
  
  console.log('⚠️  Project configuration check inconclusive');
  return null;
}

/**
 * Interactive setup
 */
async function interactiveSetup() {
  console.log('\n🚀 Firebase Authentication Interactive Setup\n');
  
  // Check project first
  await getProjectConfig();
  
  console.log('\nWhat would you like to do?');
  console.log('1. Test existing admin login');
  console.log('2. Create new admin user');
  console.log('3. Both (create then test)');
  
  const choice = await new Promise(resolve => {
    rl.question('Enter choice (1-3): ', resolve);
  });

  let email, password;
  
  if (choice === '1' || choice === '3') {
    email = await new Promise(resolve => {
      rl.question('Enter admin email: ', resolve);
    });
    
    password = await new Promise(resolve => {
      rl.question('Enter admin password: ', resolve);
    });
  }

  if (choice === '2' || choice === '3') {
    if (!email) {
      email = await new Promise(resolve => {
        rl.question('Enter new admin email: ', resolve);
      });
    }
    
    if (!password) {
      password = await new Promise(resolve => {
        rl.question('Enter new admin password (min 6 chars): ', resolve);
      });
    }
    
    console.log('\n📝 Creating admin user...');
    const created = await createUser(email, password);
    
    if (!created) {
      console.log('\n❌ Failed to create user. Check the error above.');
      rl.close();
      return;
    }
  }

  if (choice === '1' || choice === '3') {
    console.log('\n🔐 Testing login...');
    const loginSuccess = await testDirectAuth(email, password);
    
    if (loginSuccess) {
      console.log('\n🎉 Setup complete! You can now use these credentials in the admin panel.');
    } else {
      console.log('\n❌ Login test failed. Check the Firebase Console configuration.');
    }
  }
  
  rl.close();
}

/**
 * Quick test mode
 */
async function quickTest() {
  console.log('🚀 Quick Firebase Authentication Test\n');
  
  const testCredentials = [
    { email: 'admin@afro.com', password: 'admin123' },
    { email: 'admin@example.com', password: 'password123' }
  ];

  await getProjectConfig();
  
  for (const creds of testCredentials) {
    await testDirectAuth(creds.email, creds.password);
  }
}

/**
 * Main function
 */
async function main() {
  const args = process.argv.slice(2);
  
  console.log('🔥 Firebase Authentication Setup & Diagnostic Tool');
  console.log(`Project: ${FIREBASE_CONFIG.projectId}`);
  console.log(`Auth Domain: ${FIREBASE_CONFIG.authDomain}\n`);
  
  if (args.includes('--quick') || args.includes('-q')) {
    await quickTest();
  } else {
    await interactiveSetup();
  }
}

// Handle process termination
process.on('SIGINT', () => {
  console.log('\n\n👋 Goodbye!');
  rl.close();
  process.exit(0);
});

// Run the script
if (require.main === module) {
  main().catch(error => {
    console.error('💥 Script failed:', error.message);
    process.exit(1);
  });
}

module.exports = { testDirectAuth, createUser, getProjectConfig };