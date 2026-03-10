#!/usr/bin/env node

/**
 * Firebase Email Link Authentication Setup Script
 * This script helps enable Email Link authentication in Firebase Console
 */

const https = require('https');

const FIREBASE_CONFIG = {
  apiKey: 'AIzaSyBu3dwqiJ9Nd5A5u07iwVK_fgR9ydgkd0M',
  projectId: 'afro-ce148'
};

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
 * Check current authentication configuration
 */
async function checkAuthConfig() {
  console.log('🔍 Checking Firebase Authentication configuration...\n');
  
  const options = {
    hostname: 'identitytoolkit.googleapis.com',
    port: 443,
    path: `/v1/projects/${FIREBASE_CONFIG.projectId}/config?key=${FIREBASE_CONFIG.apiKey}`,
    method: 'GET'
  };

  try {
    const response = await makeRequest(options);
    
    if (response.statusCode === 200) {
      console.log('✅ Firebase project is accessible');
      
      const config = response.data;
      
      if (config.signIn) {
        console.log('\n📋 Current Sign-in Methods:');
        
        if (config.signIn.email) {
          console.log(`   Email/Password: ${config.signIn.email.enabled ? '✅ Enabled' : '❌ Disabled'}`);
          console.log(`   Email Link: ${config.signIn.email.passwordRequired === false ? '✅ Enabled' : '❌ Disabled'}`);
        } else {
          console.log('   Email/Password: ❌ Not configured');
        }
        
        if (config.signIn.phoneNumber) {
          console.log(`   Phone Number: ${config.signIn.phoneNumber.enabled ? '✅ Enabled' : '❌ Disabled'}`);
        }
        
        // Check authorized domains
        if (config.authorizedDomains) {
          console.log('\n🌐 Authorized Domains:');
          config.authorizedDomains.forEach(domain => {
            console.log(`   - ${domain}`);
          });
        }
      }
      
      return config;
    } else {
      console.log(`❌ Failed to get config: ${response.statusCode}`);
      console.log('Response:', response.data);
      return null;
    }
  } catch (error) {
    console.error('❌ Error checking config:', error.message);
    return null;
  }
}

/**
 * Test email link authentication
 */
async function testEmailLinkAuth(email = 'admin@afro.com') {
  console.log(`\n🧪 Testing Email Link authentication for: ${email}`);
  
  const actionCodeSettings = {
    url: 'http://localhost:3000/auth/complete',
    handleCodeInApp: true
  };

  const postData = JSON.stringify({
    email: email,
    actionCodeSettings: actionCodeSettings
  });

  const options = {
    hostname: 'identitytoolkit.googleapis.com',
    port: 443,
    path: `/v1/accounts:sendOobCode?key=${FIREBASE_CONFIG.apiKey}`,
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
      console.log('✅ Email link sent successfully!');
      console.log(`Email: ${response.data.email}`);
      return true;
    } else {
      console.log('❌ Failed to send email link');
      console.log('Response:', JSON.stringify(response.data, null, 2));
      
      if (response.data.error) {
        const errorMessage = response.data.error.message;
        console.log(`\n🔍 Error: ${errorMessage}`);
        
        switch (errorMessage) {
          case 'OPERATION_NOT_ALLOWED':
            console.log('\n📋 Solution Steps:');
            console.log('1. Go to Firebase Console: https://console.firebase.google.com/');
            console.log(`2. Select project: ${FIREBASE_CONFIG.projectId}`);
            console.log('3. Go to Authentication > Sign-in method');
            console.log('4. Enable "Email/Password" provider');
            console.log('5. In Email/Password settings, enable "Email link (passwordless sign-in)"');
            console.log('6. Add authorized domains: localhost, your-domain.com');
            break;
          case 'INVALID_EMAIL':
            console.log('📋 Use a valid email address');
            break;
          case 'EMAIL_NOT_FOUND':
            console.log('📋 Create the user first or enable sign-up');
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
 * Create admin user for testing
 */
async function createAdminUser(email = 'admin@afro.com', password = 'TempPassword123!') {
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
      console.log(`User ID: ${response.data.localId}`);
      console.log(`Email: ${response.data.email}`);
      return response.data;
    } else {
      console.log('ℹ️  User creation response:', response.statusCode);
      
      if (response.data.error && response.data.error.message === 'EMAIL_EXISTS') {
        console.log('✅ Admin user already exists');
        return { email: email, exists: true };
      } else {
        console.log('Response:', JSON.stringify(response.data, null, 2));
        return null;
      }
    }
  } catch (error) {
    console.error('Error creating user:', error.message);
    return null;
  }
}

/**
 * Display setup instructions
 */
function displaySetupInstructions() {
  console.log('\n🚀 Firebase Email Link Authentication Setup Guide\n');
  
  console.log('📋 Manual Setup Steps:');
  console.log('1. Open Firebase Console: https://console.firebase.google.com/');
  console.log(`2. Select your project: ${FIREBASE_CONFIG.projectId}`);
  console.log('3. Go to Authentication > Sign-in method');
  console.log('4. Enable "Email/Password" provider if not already enabled');
  console.log('5. Click on "Email/Password" to configure');
  console.log('6. Enable "Email link (passwordless sign-in)"');
  console.log('7. Add authorized domains:');
  console.log('   - localhost (for development)');
  console.log('   - your-production-domain.com');
  console.log('8. Save the configuration');
  
  console.log('\n🔧 Development URLs to authorize:');
  console.log('   - http://localhost:3000');
  console.log('   - http://localhost:3000/auth/complete');
  
  console.log('\n📧 Admin Email Configuration:');
  console.log('   - Update the isValidAdminEmail function in emailAuth.ts');
  console.log('   - Add your admin email domains and addresses');
  console.log('   - Test with: admin@afro.com');
  
  console.log('\n🔗 Integration Steps:');
  console.log('   - Email Link page: /auth/email-link');
  console.log('   - Completion page: /auth/complete');
  console.log('   - Regular login: /login');
}

/**
 * Main function
 */
async function main() {
  console.log('🔥 Firebase Email Link Authentication Setup\n');
  console.log(`Project ID: ${FIREBASE_CONFIG.projectId}`);
  console.log(`API Key: ${FIREBASE_CONFIG.apiKey.substring(0, 20)}...\n`);
  
  // Check current configuration
  const config = await checkAuthConfig();
  
  // Create admin user if needed
  console.log('\n' + '='.repeat(50));
  await createAdminUser();
  
  // Test email link functionality
  console.log('\n' + '='.repeat(50));
  const emailLinkWorking = await testEmailLinkAuth();
  
  // Display setup instructions
  console.log('\n' + '='.repeat(50));
  displaySetupInstructions();
  
  // Final status
  console.log('\n' + '='.repeat(50));
  console.log('📊 Setup Status:');
  console.log(`   Firebase Config: ${config ? '✅' : '❌'}`);
  console.log(`   Email Link Auth: ${emailLinkWorking ? '✅' : '❌'}`);
  
  if (!emailLinkWorking) {
    console.log('\n⚠️  Email Link authentication is not working yet.');
    console.log('   Please follow the manual setup steps above.');
  } else {
    console.log('\n🎉 Email Link authentication is ready!');
    console.log('   You can now use passwordless sign-in for admins.');
  }
}

// Run the script
if (require.main === module) {
  main().catch(error => {
    console.error('💥 Script failed:', error.message);
    process.exit(1);
  });
}

module.exports = { checkAuthConfig, testEmailLinkAuth, createAdminUser };