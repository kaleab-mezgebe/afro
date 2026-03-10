#!/usr/bin/env node

/**
 * Create Admin User Script
 * Creates or updates the admin user for the admin panel
 */

const https = require('https');
const readline = require('readline');

const FIREBASE_CONFIG = {
  apiKey: 'AIzaSyBu3dwqiJ9Nd5A5u07iwVK_fgR9ydgkd0M',
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
 * Create admin user
 */
async function createAdminUser(email, password) {
  console.log(`\n👤 Creating admin user: ${email}`);
  
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
      console.log('✅ Admin user created successfully!');
      console.log(`   User ID: ${response.data.localId}`);
      console.log(`   Email: ${response.data.email}`);
      console.log(`   Email Verified: ${response.data.emailVerified || false}`);
      return response.data;
    } else {
      console.log('❌ Failed to create admin user');
      
      if (response.data.error) {
        const errorMessage = response.data.error.message;
        console.log(`   Error: ${errorMessage}`);
        
        if (errorMessage === 'EMAIL_EXISTS') {
          console.log('   ℹ️  User already exists. Try signing in or reset password.');
          return { exists: true, email: email };
        }
      }
      
      return null;
    }
  } catch (error) {
    console.error('Request failed:', error.message);
    return null;
  }
}

/**
 * Test admin login
 */
async function testAdminLogin(email, password) {
  console.log(`\n🔐 Testing admin login: ${email}`);
  
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
      console.log('✅ Admin login successful!');
      console.log(`   User ID: ${response.data.localId}`);
      console.log(`   Email: ${response.data.email}`);
      console.log(`   Token: ${response.data.idToken ? 'Present' : 'Missing'}`);
      return true;
    } else {
      console.log('❌ Admin login failed');
      
      if (response.data.error) {
        const errorMessage = response.data.error.message;
        console.log(`   Error: ${errorMessage}`);
        
        switch (errorMessage) {
          case 'INVALID_LOGIN_CREDENTIALS':
            console.log('   🔧 Invalid email or password');
            break;
          case 'EMAIL_NOT_FOUND':
            console.log('   🔧 Admin user does not exist');
            break;
          case 'INVALID_PASSWORD':
            console.log('   🔧 Incorrect password');
            break;
          case 'USER_DISABLED':
            console.log('   🔧 Admin account is disabled');
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
 * Interactive admin setup
 */
async function interactiveSetup() {
  console.log('🚀 Admin User Setup for AFRO Admin Panel\n');
  
  // Get admin email
  const email = await new Promise(resolve => {
    rl.question('Enter admin email (default: admin@afro.com): ', (answer) => {
      resolve(answer.trim() || 'admin@afro.com');
    });
  });
  
  // Get admin password
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
  
  console.log('\n' + '='.repeat(50));
  
  // First, try to sign in with existing credentials
  console.log('🔍 Checking if admin user already exists...');
  const loginSuccess = await testAdminLogin(email, password);
  
  if (loginSuccess) {
    console.log('\n🎉 Admin user is ready! You can now sign in to the admin panel.');
    console.log(`   Email: ${email}`);
    console.log(`   Password: ${password}`);
  } else {
    console.log('\n📝 Creating new admin user...');
    const createResult = await createAdminUser(email, password);
    
    if (createResult && !createResult.exists) {
      console.log('\n🔐 Testing new admin login...');
      const newLoginSuccess = await testAdminLogin(email, password);
      
      if (newLoginSuccess) {
        console.log('\n🎉 Admin user created and tested successfully!');
        console.log(`   Email: ${email}`);
        console.log(`   Password: ${password}`);
        console.log('\n📱 You can now sign in to the admin panel at:');
        console.log('   http://localhost:3000/login');
      } else {
        console.log('\n❌ Admin user created but login test failed');
      }
    } else if (createResult && createResult.exists) {
      console.log('\n⚠️  Admin user already exists but password may be different');
      console.log('   Try using the Firebase Console to reset the password');
    } else {
      console.log('\n❌ Failed to create admin user');
    }
  }
  
  rl.close();
}

/**
 * Quick setup with default credentials
 */
async function quickSetup() {
  console.log('⚡ Quick Admin Setup with Default Credentials\n');
  
  const defaultEmail = 'admin@afro.com';
  const defaultPassword = 'admin123';
  
  console.log(`Email: ${defaultEmail}`);
  console.log(`Password: ${defaultPassword}\n`);
  
  // Test existing login
  const loginSuccess = await testAdminLogin(defaultEmail, defaultPassword);
  
  if (!loginSuccess) {
    // Create new user
    const createResult = await createAdminUser(defaultEmail, defaultPassword);
    
    if (createResult && !createResult.exists) {
      // Test new login
      await testAdminLogin(defaultEmail, defaultPassword);
    }
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
  
  console.log('🔥 AFRO Admin Panel - Admin User Setup');
  console.log('=====================================\n');
  
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