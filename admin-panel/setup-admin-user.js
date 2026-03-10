#!/usr/bin/env node

/**
 * Admin User Setup Script
 * Creates Firebase user and registers them in the backend with ADMIN role
 */

const https = require('https');
const readline = require('readline');

const FIREBASE_CONFIG = {
  apiKey: 'AIzaSyBu3dwqiJ9Nd5A5u07iwVK_fgR9ydgkd0M',
  projectId: 'afro-ce148'
};

const BACKEND_URL = 'http://localhost:3001/api/v1';

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
            data: response
          });
        } catch (error) {
          resolve({
            statusCode: res.statusCode,
            data: data,
            parseError: true
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
 * Make HTTP request to backend
 */
function makeBackendRequest(path, method = 'GET', data = null, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(BACKEND_URL + path);
    const options = {
      hostname: url.hostname,
      port: url.port || (url.protocol === 'https:' ? 443 : 80),
      path: url.pathname,
      method: method,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    if (token) {
      options.headers.Authorization = `Bearer ${token}`;
    }

    const req = (url.protocol === 'https:' ? https : require('http')).request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        try {
          const response = responseData ? JSON.parse(responseData) : {};
          resolve({
            statusCode: res.statusCode,
            data: response
          });
        } catch (error) {
          resolve({
            statusCode: res.statusCode,
            data: responseData,
            parseError: true
          });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

/**
 * Create Firebase user
 */
async function createFirebaseUser(email, password) {
  console.log(`\n👤 Creating Firebase user: ${email}`);
  
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
    
    if (response.statusCode === 200) {
      console.log('✅ Firebase user created successfully!');
      return {
        uid: response.data.localId,
        email: response.data.email,
        idToken: response.data.idToken
      };
    } else {
      if (response.data.error && response.data.error.message === 'EMAIL_EXISTS') {
        console.log('ℹ️  Firebase user already exists, trying to sign in...');
        return await signInFirebaseUser(email, password);
      } else {
        console.log('❌ Failed to create Firebase user');
        console.log('Response:', response.data);
        return null;
      }
    }
  } catch (error) {
    console.error('Request failed:', error.message);
    return null;
  }
}

/**
 * Sign in Firebase user
 */
async function signInFirebaseUser(email, password) {
  console.log(`\n🔐 Signing in Firebase user: ${email}`);
  
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
      console.log('✅ Firebase sign-in successful!');
      return {
        uid: response.data.localId,
        email: response.data.email,
        idToken: response.data.idToken
      };
    } else {
      console.log('❌ Firebase sign-in failed');
      console.log('Response:', response.data);
      return null;
    }
  } catch (error) {
    console.error('Request failed:', error.message);
    return null;
  }
}

/**
 * Register user in backend
 */
async function registerUserInBackend(firebaseUser) {
  console.log(`\n📝 Registering user in backend: ${firebaseUser.email}`);
  
  try {
    // First, verify the token with backend
    const verifyResponse = await makeBackendRequest('/auth/verify-token', 'POST', {
      token: firebaseUser.idToken
    });

    if (verifyResponse.statusCode === 200 || verifyResponse.statusCode === 201) {
      console.log('✅ User registered in backend successfully!');
      return verifyResponse.data;
    } else {
      console.log('❌ Failed to register user in backend');
      console.log('Response:', verifyResponse.data);
      return null;
    }
  } catch (error) {
    console.error('Backend request failed:', error.message);
    return null;
  }
}

/**
 * Assign admin role
 */
async function assignAdminRole(firebaseUser) {
  console.log(`\n👑 Assigning ADMIN role to: ${firebaseUser.email}`);
  
  try {
    const response = await makeBackendRequest('/auth/assign-role', 'POST', {
      userId: firebaseUser.uid,
      role: 'ADMIN'
    }, firebaseUser.idToken);

    if (response.statusCode === 200 || response.statusCode === 201) {
      console.log('✅ ADMIN role assigned successfully!');
      return true;
    } else {
      console.log('❌ Failed to assign ADMIN role');
      console.log('Response:', response.data);
      return false;
    }
  } catch (error) {
    console.error('Role assignment failed:', error.message);
    return false;
  }
}

/**
 * Test admin access
 */
async function testAdminAccess(firebaseUser) {
  console.log(`\n🧪 Testing admin access for: ${firebaseUser.email}`);
  
  try {
    const response = await makeBackendRequest('/admin/analytics', 'GET', null, firebaseUser.idToken);

    if (response.statusCode === 200) {
      console.log('✅ Admin access confirmed!');
      console.log('Analytics data:', response.data);
      return true;
    } else {
      console.log('❌ Admin access denied');
      console.log('Response:', response.data);
      return false;
    }
  } catch (error) {
    console.error('Admin access test failed:', error.message);
    return false;
  }
}

/**
 * Interactive setup
 */
async function interactiveSetup() {
  console.log('🚀 AFRO Admin Panel - Complete Admin Setup\n');
  
  // Get admin credentials
  const email = await new Promise(resolve => {
    rl.question('Enter admin email (default: admin@afro.com): ', (answer) => {
      resolve(answer.trim() || 'admin@afro.com');
    });
  });
  
  const password = await new Promise(resolve => {
    rl.question('Enter admin password (min 6 chars): ', (answer) => {
      resolve(answer.trim());
    });
  });
  
  if (!password || password.length < 6) {
    console.log('❌ Password must be at least 6 characters long');
    rl.close();
    return;
  }
  
  console.log('\n' + '='.repeat(60));
  
  // Step 1: Create/Sign in Firebase user
  const firebaseUser = await createFirebaseUser(email, password);
  if (!firebaseUser) {
    console.log('\n❌ Failed to create/sign in Firebase user');
    rl.close();
    return;
  }
  
  console.log('\n' + '='.repeat(60));
  
  // Step 2: Register in backend
  const backendUser = await registerUserInBackend(firebaseUser);
  if (!backendUser) {
    console.log('\n❌ Failed to register user in backend');
    rl.close();
    return;
  }
  
  console.log('\n' + '='.repeat(60));
  
  // Step 3: Assign admin role
  const roleAssigned = await assignAdminRole(firebaseUser);
  if (!roleAssigned) {
    console.log('\n❌ Failed to assign admin role');
    rl.close();
    return;
  }
  
  console.log('\n' + '='.repeat(60));
  
  // Step 4: Test admin access
  const adminAccess = await testAdminAccess(firebaseUser);
  
  console.log('\n' + '='.repeat(60));
  console.log('📊 Setup Summary:');
  console.log(`   Firebase User: ✅ ${firebaseUser.email}`);
  console.log(`   Backend Registration: ✅ ${backendUser ? 'Success' : 'Failed'}`);
  console.log(`   Admin Role: ✅ ${roleAssigned ? 'Assigned' : 'Failed'}`);
  console.log(`   Admin Access: ${adminAccess ? '✅ Working' : '❌ Failed'}`);
  
  if (adminAccess) {
    console.log('\n🎉 Admin setup complete!');
    console.log(`   Email: ${email}`);
    console.log(`   Password: ${password}`);
    console.log('\n📱 You can now sign in to the admin panel at:');
    console.log('   http://localhost:3000/login');
    console.log('   http://localhost:3000/auth/email-link');
  } else {
    console.log('\n❌ Admin setup incomplete. Check the errors above.');
  }
  
  rl.close();
}

/**
 * Quick setup with default credentials
 */
async function quickSetup() {
  console.log('⚡ Quick Admin Setup\n');
  
  const email = 'admin@afro.com';
  const password = 'admin123';
  
  console.log(`Email: ${email}`);
  console.log(`Password: ${password}\n`);
  
  // Run all setup steps
  const firebaseUser = await createFirebaseUser(email, password);
  if (firebaseUser) {
    await registerUserInBackend(firebaseUser);
    await assignAdminRole(firebaseUser);
    await testAdminAccess(firebaseUser);
  }
  
  console.log('\n📱 Admin Panel URLs:');
  console.log('   Regular Login: http://localhost:3000/login');
  console.log('   Email Link: http://localhost:3000/auth/email-link');
}

/**
 * Main function
 */
async function main() {
  const args = process.argv.slice(2);
  
  console.log('🔥 AFRO Admin Panel - Complete Admin Setup');
  console.log('==========================================\n');
  
  if (args.includes('--quick') || args.includes('-q')) {
    await quickSetup();
  } else {
    await interactiveSetup();
  }
}

// Handle process termination
process.on('SIGINT', () => {
  console.log('\n\n👋 Setup cancelled');
  rl.close();
  process.exit(0);
});

// Run the script
if (require.main === module) {
  main().catch(error => {
    console.error('💥 Setup failed:', error.message);
    rl.close();
    process.exit(1);
  });
}