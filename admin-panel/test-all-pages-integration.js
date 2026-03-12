// Comprehensive Test Script for All 22 Admin Pages
// Tests backend integration for all pages with real CRUD operations

const axios = require('axios');

// Configuration
const API_BASE_URL = 'http://localhost:3000';
const TEST_RESULTS = {
  passed: [],
  failed: [],
  total: 0,
  startTime: new Date()
};

// Test utilities
const log = (message, type = 'info') => {
  const timestamp = new Date().toISOString();
  const prefix = type === 'error' ? '❌' : type === 'success' ? '✅' : 'ℹ️';
  console.log(`${prefix} [${timestamp}] ${message}`);
};

const makeRequest = async (method, endpoint, data = null, expectedStatus = 200) => {
  try {
    const config = {
      method,
      url: `${API_BASE_URL}${endpoint}`,
      headers: {
        'Content-Type': 'application/json',
      },
      ...(data && { data: JSON.stringify(data) }),
      timeout: 10000
    };

    const response = await axios(config);
    
    if (response.status === expectedStatus) {
      log(`${method} ${endpoint} - SUCCESS (${response.status})`, 'success');
      TEST_RESULTS.passed.push(`${method} ${endpoint}`);
      return { success: true, data: response.data };
    } else {
      log(`${method} ${endpoint} - FAILED (${response.status}): ${JSON.stringify(response.data)}`, 'error');
      TEST_RESULTS.failed.push(`${method} ${endpoint}`);
      return { success: false, error: response.data };
    }
  } catch (error) {
    log(`${method} ${endpoint} - ERROR: ${error.message}`, 'error');
    TEST_RESULTS.failed.push(`${method} ${endpoint}`);
    return { success: false, error: error.message };
  }
};

// Test data generators
const generateUserData = () => ({
  name: `Test User ${Date.now()}`,
  email: `testuser${Date.now()}@example.com`,
  phone: `+1${Math.floor(Math.random() * 9000000000) + 1000000000}`,
  firebase_uid: `test_${Date.now()}`
});

const generateServiceData = () => ({
  name: `Test Service ${Date.now()}`,
  description: 'Auto-generated test service',
  duration_minutes: Math.floor(Math.random() * 60) + 15,
  price: (Math.random() * 100 + 20).toFixed(2),
  category: ['haircut', 'beard', 'color', 'treatment'][Math.floor(Math.random() * 4)]
});

const generateAppointmentData = () => ({
  appointment_date: new Date(Date.now() + 86400000).toISOString().split('T')[0],
  start_time: '10:00:00',
  end_time: '10:30:00',
  status: 'scheduled'
});

// Test Suite
const tests = {
  // Health Check
  async healthCheck() {
    log('Testing Backend Health Check...');
    const result = await makeRequest('GET', '/health');
    return result.success;
  },

  // Authentication Tests
  async testAuth() {
    log('Testing Authentication Endpoints...');
    
    const tests = [
      { name: 'Login', method: 'POST', endpoint: '/auth/login', data: { email: 'test@example.com', password: 'password123' } },
      { name: 'Register', method: 'POST', endpoint: '/auth/register', data: generateUserData() },
      { name: 'Refresh Token', method: 'POST', endpoint: '/auth/refresh', data: { token: 'test_token' } },
      { name: 'Logout', method: 'POST', endpoint: '/auth/logout', data: {} }
    ];

    for (const test of tests) {
      const result = await makeRequest(test.method, test.endpoint, test.data);
      TEST_RESULTS.total++;
      if (!result.success) {
        log(`Auth test failed: ${test.name}`, 'error');
      }
    }
  },

  // Dashboard Tests
  async testDashboard() {
    log('Testing Dashboard Endpoints...');
    
    const tests = [
      { name: 'Get Dashboard Stats', method: 'GET', endpoint: '/admin/dashboard/stats' },
      { name: 'Get Recent Activities', method: 'GET', endpoint: '/admin/dashboard/activities?limit=10' },
      { name: 'Get Revenue Chart', method: 'GET', endpoint: '/admin/dashboard/revenue?period=30d' }
    ];

    for (const test of tests) {
      const result = await makeRequest(test.method, test.endpoint);
      TEST_RESULTS.total++;
      if (!result.success) {
        log(`Dashboard test failed: ${test.name}`, 'error');
      }
    }
  },

  // Users Management Tests
  async testUsers() {
    log('Testing Users Management...');
    
    // Create test user first
    const createResult = await makeRequest('POST', '/admin/users', generateUserData());
    TEST_RESULTS.total++;
    
    if (createResult.success) {
      const userId = createResult.data?.id;
      
      const tests = [
        { name: 'Get All Users', method: 'GET', endpoint: '/admin/users?page=1&limit=10' },
        { name: 'Get User by ID', method: 'GET', endpoint: `/admin/users/${userId}` },
        { name: 'Search Users', method: 'GET', endpoint: '/admin/users?search=test&page=1&limit=10' },
        { name: 'Filter Users by Status', method: 'GET', endpoint: '/admin/users?status=active&page=1&limit=10' },
        { name: 'Update User', method: 'PUT', endpoint: `/admin/users/${userId}`, data: { ...generateUserData(), name: 'Updated User' } },
        { name: 'Toggle User Status', method: 'PATCH', endpoint: `/admin/users/${userId}/status`, data: { isActive: false } },
        { name: 'Delete User', method: 'DELETE', endpoint: `/admin/users/${userId}` }
      ];

      for (const test of tests) {
        const result = await makeRequest(test.method, test.endpoint, test.data);
        TEST_RESULTS.total++;
        if (!result.success) {
          log(`Users test failed: ${test.name}`, 'error');
        }
      }
    }
  },

  // Barbers Management Tests
  async testBarbers() {
    log('Testing Barbers Management...');
    
    const createResult = await makeRequest('POST', '/admin/barbers', {
      ...generateUserData(),
      name: 'Test Barber',
      shop_name: 'Test Barbershop',
      address: '123 Test St',
      latitude: 40.7128,
      longitude: -74.0060,
      services: ['Haircut', 'Beard Trim'],
      working_hours: '{"monday": "9:00-18:00", "tuesday": "9:00-18:00"}',
      specialization: 'Traditional Cuts, Modern Fades',
      experience_years: 5
    });
    TEST_RESULTS.total++;
    
    if (createResult.success) {
      const barberId = createResult.data?.id;
      
      const tests = [
        { name: 'Get All Barbers', method: 'GET', endpoint: '/admin/barbers?page=1&limit=10' },
        { name: 'Get Barber by ID', method: 'GET', endpoint: `/admin/barbers/${barberId}` },
        { name: 'Search Barbers', method: 'GET', endpoint: '/admin/barbers?search=test&page=1&limit=10' },
        { name: 'Filter by Status', method: 'GET', endpoint: '/admin/barbers?status=active&page=1&limit=10' },
        { name: 'Update Barber', method: 'PUT', endpoint: `/admin/barbers/${barberId}`, data: { specialization: 'Updated Specialization' } },
        { name: 'Toggle Status', method: 'PATCH', endpoint: `/admin/barbers/${barberId}/status`, data: { is_active: false } },
        { name: 'Update Services', method: 'PATCH', endpoint: `/admin/barbers/${barberId}/services`, data: { services: ['New Service'] } },
        { name: 'Delete Barber', method: 'DELETE', endpoint: `/admin/barbers/${barberId}` }
      ];

      for (const test of tests) {
        const result = await makeRequest(test.method, test.endpoint, test.data);
        TEST_RESULTS.total++;
        if (!result.success) {
          log(`Barbers test failed: ${test.name}`, 'error');
        }
      }
    }
  },

  // Services Management Tests
  async testServices() {
    log('Testing Services Management...');
    
    const createResult = await makeRequest('POST', '/admin/services', generateServiceData());
    TEST_RESULTS.total++;
    
    if (createResult.success) {
      const serviceId = createResult.data?.id;
      
      const tests = [
        { name: 'Get All Services', method: 'GET', endpoint: '/admin/services?page=1&limit=10' },
        { name: 'Get Service by ID', method: 'GET', endpoint: `/admin/services/${serviceId}` },
        { name: 'Search Services', method: 'GET', endpoint: '/admin/services?search=test&page=1&limit=10' },
        { name: 'Filter by Category', method: 'GET', endpoint: '/admin/services?category=haircut&page=1&limit=10' },
        { name: 'Filter by Status', method: 'GET', endpoint: '/admin/services?is_active=true&page=1&limit=10' },
        { name: 'Update Service', method: 'PUT', endpoint: `/admin/services/${serviceId}`, data: { ...generateServiceData(), name: 'Updated Service' } },
        { name: 'Toggle Status', method: 'PATCH', endpoint: `/admin/services/${serviceId}/status`, data: { is_active: false } },
        { name: 'Delete Service', method: 'DELETE', endpoint: `/admin/services/${serviceId}` }
      ];

      for (const test of tests) {
        const result = await makeRequest(test.method, test.endpoint, test.data);
        TEST_RESULTS.total++;
        if (!result.success) {
          log(`Services test failed: ${test.name}`, 'error');
        }
      }
    }
  },

  // Appointments Management Tests
  async testAppointments() {
    log('Testing Appointments Management...');
    
    const createResult = await makeRequest('POST', '/admin/appointments', {
      ...generateAppointmentData(),
      user_id: 'test_user_id',
      barber_id: 'test_barber_id',
      service_id: 'test_service_id',
      total_amount: 50.00,
      payment_status: 'paid',
      notes: 'Test appointment'
    });
    TEST_RESULTS.total++;
    
    if (createResult.success) {
      const appointmentId = createResult.data?.id;
      
      const tests = [
        { name: 'Get All Appointments', method: 'GET', endpoint: '/admin/appointments?page=1&limit=10' },
        { name: 'Get Appointment by ID', method: 'GET', endpoint: `/admin/appointments/${appointmentId}` },
        { name: 'Search Appointments', method: 'GET', endpoint: '/admin/appointments?search=test&page=1&limit=10' },
        { name: 'Filter by Date', method: 'GET', endpoint: '/admin/appointments?date=2024-01-15&page=1&limit=10' },
        { name: 'Filter by Status', method: 'GET', endpoint: '/admin/appointments?status=completed&page=1&limit=10' },
        { name: 'Update Appointment', method: 'PUT', endpoint: `/admin/appointments/${appointmentId}`, data: { status: 'updated' } },
        { name: 'Update Status', method: 'PATCH', endpoint: `/admin/appointments/${appointmentId}/status`, data: { status: 'cancelled' } },
        { name: 'Delete Appointment', method: 'DELETE', endpoint: `/admin/appointments/${appointmentId}` }
      ];

      for (const test of tests) {
        const result = await makeRequest(test.method, test.endpoint, test.data);
        TEST_RESULTS.total++;
        if (!result.success) {
          log(`Appointments test failed: ${test.name}`, 'error');
        }
      }
    }
  },

  // Transactions Management Tests
  async testTransactions() {
    log('Testing Transactions Management...');
    
    const createResult = await makeRequest('POST', '/admin/transactions', {
      user_id: 'test_user_id',
      barber_id: 'test_barber_id',
      service_id: 'test_service_id',
      type: 'payment',
      amount: 75.00,
      currency: 'USD',
      customer_name: 'Test Customer',
      provider_name: 'Test Barber',
      service_name: 'Test Service',
      payment_method: 'credit_card',
      transaction_id: `TXN-TEST-${Date.now()}`,
      description: 'Test transaction'
    });
    TEST_RESULTS.total++;
    
    if (createResult.success) {
      const transactionId = createResult.data?.id;
      
      const tests = [
        { name: 'Get All Transactions', method: 'GET', endpoint: '/admin/transactions?page=1&limit=10' },
        { name: 'Get Transaction by ID', method: 'GET', endpoint: `/admin/transactions/${transactionId}` },
        { name: 'Search Transactions', method: 'GET', endpoint: '/admin/transactions?search=test&page=1&limit=10' },
        { name: 'Filter by Type', method: 'GET', endpoint: '/admin/transactions?type=payment&page=1&limit=10' },
        { name: 'Filter by Status', method: 'GET', endpoint: '/admin/transactions?status=completed&page=1&limit=10' },
        { name: 'Update Status', method: 'PATCH', endpoint: `/admin/transactions/${transactionId}/status`, data: { status: 'refunded' } },
        { name: 'Export Transactions', method: 'GET', endpoint: '/admin/transactions/export' },
        { name: 'Refund Transaction', method: 'PATCH', endpoint: `/admin/transactions/${transactionId}/refund`, data: { reason: 'Test refund' } }
      ];

      for (const test of tests) {
        const result = await makeRequest(test.method, test.endpoint, test.data);
        TEST_RESULTS.total++;
        if (!result.success) {
          log(`Transactions test failed: ${test.name}`, 'error');
        }
      }
    }
  },

  // Reviews Management Tests
  async testReviews() {
    log('Testing Reviews Management...');
    
    const createResult = await makeRequest('POST', '/admin/reviews', {
      user_id: 'test_user_id',
      barber_id: 'test_barber_id',
      service_id: 'test_service_id',
      rating: 5,
      comment: 'Test review - excellent service!',
      status: 'published'
    });
    TEST_RESULTS.total++;
    
    if (createResult.success) {
      const reviewId = createResult.data?.id;
      
      const tests = [
        { name: 'Get All Reviews', method: 'GET', endpoint: '/admin/reviews?page=1&limit=10' },
        { name: 'Get Review by ID', method: 'GET', endpoint: `/admin/reviews/${reviewId}` },
        { name: 'Search Reviews', method: 'GET', endpoint: '/admin/reviews?search=test&page=1&limit=10' },
        { name: 'Filter by Rating', method: 'GET', endpoint: '/admin/reviews?rating=5&page=1&limit=10' },
        { name: 'Filter by Status', method: 'GET', endpoint: '/admin/reviews?status=published&page=1&limit=10' },
        { name: 'Approve Review', method: 'PATCH', endpoint: `/admin/reviews/${reviewId}/approve` },
        { name: 'Hide Review', method: 'PATCH', endpoint: `/admin/reviews/${reviewId}/hide` },
        { name: 'Respond to Review', method: 'PATCH', endpoint: `/admin/reviews/${reviewId}/respond`, data: { response: 'Thank you for your feedback!' } },
        { name: 'Delete Review', method: 'DELETE', endpoint: `/admin/reviews/${reviewId}` },
        { name: 'Export Reviews', method: 'GET', endpoint: '/admin/reviews/export' }
      ];

      for (const test of tests) {
        const result = await makeRequest(test.method, test.endpoint, test.data);
        TEST_RESULTS.total++;
        if (!result.success) {
          log(`Reviews test failed: ${test.name}`, 'error');
        }
      }
    }
  },

  // Reports Management Tests
  async testReports() {
    log('Testing Reports Management...');
    
    const tests = [
      { name: 'Get All Reports', method: 'GET', endpoint: '/admin/reports?page=1&limit=10' },
      { name: 'Generate Revenue Report', method: 'POST', endpoint: '/admin/reports/generate', data: { type: 'revenue', period: '30d' } },
      { name: 'Generate Customer Report', method: 'POST', endpoint: '/admin/reports/generate', data: { type: 'customers', date_range: '30d' } },
      { name: 'Generate Service Report', method: 'POST', endpoint: '/admin/reports/generate', data: { type: 'services', category: 'all' } },
      { name: 'Schedule Report', method: 'POST', endpoint: '/admin/reports/schedule', data: { type: 'daily', time: '09:00' } }
    ];

    for (const test of tests) {
      const result = await makeRequest(test.method, test.endpoint, test.data);
      TEST_RESULTS.total++;
      if (!result.success) {
        log(`Reports test failed: ${test.name}`, 'error');
      }
    }
  },

  // Settings Management Tests
  async testSettings() {
    log('Testing Settings Management...');
    
    const tests = [
      { name: 'Get All Settings', method: 'GET', endpoint: '/admin/settings' },
      { name: 'Update General Settings', method: 'PUT', endpoint: '/admin/settings/general', data: { site_name: 'Test Site', contact_email: 'test@example.com' } },
      { name: 'Update Notification Settings', method: 'PUT', endpoint: '/admin/settings/notifications', data: { email_notifications: true, sms_notifications: false } },
      { name: 'Update Security Settings', method: 'PUT', endpoint: '/admin/settings/security', data: { two_factor_auth: true, password_min_length: 8 } },
      { name: 'Update Payment Settings', method: 'PUT', endpoint: '/admin/settings/payment', data: { currency: 'USD', commission_rate: 15 } }
    ];

    for (const test of tests) {
      const result = await makeRequest(test.method, test.endpoint, test.data);
      TEST_RESULTS.total++;
      if (!result.success) {
        log(`Settings test failed: ${test.name}`, 'error');
      }
    }
  }
};

// Main test runner
const runAllTests = async () => {
  log('🚀 Starting Comprehensive Backend Integration Tests');
  log('================================================');
  
  try {
    // Test health first
    const healthOk = await tests.healthCheck();
    if (!healthOk) {
      log('❌ Backend health check failed. Stopping tests.', 'error');
      return;
    }
    
    // Run all test suites
    await tests.testAuth();
    await tests.testDashboard();
    await tests.testUsers();
    await tests.testBarbers();
    await tests.testServices();
    await tests.testAppointments();
    await tests.testTransactions();
    await tests.testReviews();
    await tests.testReports();
    await tests.testSettings();
    
  } catch (error) {
    log(`Test suite error: ${error.message}`, 'error');
  }
  
  // Generate final report
  const endTime = new Date();
  const duration = Math.round((endTime - TEST_RESULTS.startTime) / 1000);
  
  log('================================================');
  log('🎯 TEST RESULTS SUMMARY');
  log('================================================');
  log(`Total Tests Run: ${TEST_RESULTS.total}`);
  log(`Tests Passed: ${TEST_RESULTS.passed.length}`);
  log(`Tests Failed: ${TEST_RESULTS.failed.length}`);
  log(`Success Rate: ${((TEST_RESULTS.passed.length / TEST_RESULTS.total) * 100).toFixed(1)}%`);
  log(`Duration: ${duration} seconds`);
  log('================================================');
  
  if (TEST_RESULTS.failed.length > 0) {
    log('❌ FAILED TESTS:', 'error');
    TEST_RESULTS.failed.forEach(test => log(`  - ${test}`, 'error'));
  }
  
  if (TEST_RESULTS.passed.length > 0) {
    log('✅ PASSED TESTS:', 'success');
    TEST_RESULTS.passed.forEach(test => log(`  - ${test}`, 'success'));
  }
  
  log('================================================');
  log('🏁 Test completed. Check individual test results above.');
  log('================================================');
};

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { runAllTests, tests };
}

// Run if called directly
if (require.main === module) {
  runAllTests().catch(console.error);
}
