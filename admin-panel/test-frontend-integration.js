// Frontend Integration Test Script
// Tests all 22 admin pages for proper API integration setup

const fs = require('fs');
const path = require('path');

// Test configuration
const ADMIN_PANEL_PATH = path.join(__dirname, 'src/app');
const TEST_RESULTS = {
  pages: [],
  total: 0,
  passed: 0,
  failed: 0,
  issues: []
};

// Utility functions
const log = (message, type = 'info') => {
  const timestamp = new Date().toISOString();
  const prefix = type === 'error' ? '❌' : type === 'success' ? '✅' : 'ℹ️';
  console.log(`${prefix} [${timestamp}] ${message}`);
};

const checkFileExists = (filePath) => {
  try {
    return fs.existsSync(filePath);
  } catch (error) {
    return false;
  }
};

const readFileContent = (filePath) => {
  try {
    return fs.readFileSync(filePath, 'utf8');
  } catch (error) {
    return '';
  }
};

// Test functions
const testPageIntegration = (pageName, pagePath) => {
  const pageFile = path.join(pagePath, 'page.tsx');
  const results = {
    page: pageName,
    path: pageFile,
    hasAdminLayout: false,
    hasApiImport: false,
    hasRealApiCalls: false,
    hasErrorHandling: false,
    hasLoadingStates: false,
    hasAuthCheck: false,
    issues: []
  };

  if (!checkFileExists(pageFile)) {
    results.issues.push('Page file not found');
    return results;
  }

  const content = readFileContent(pageFile);
  
  // Check for AdminLayout
  results.hasAdminLayout = content.includes('AdminLayout') && content.includes('<AdminLayout>');
  if (!results.hasAdminLayout) {
    results.issues.push('Missing AdminLayout import or usage');
  }

  // Check for API imports
  results.hasApiImport = content.includes('from \'@/lib/api-backend\'') || content.includes('from \'@/lib/api\'');
  if (!results.hasApiImport) {
    results.issues.push('Missing API service import');
  }

  // Check for real API calls (not mock data)
  results.hasRealApiCalls = content.includes('Service.') && 
    (content.includes('.getAll(') || content.includes('.create(') || 
     content.includes('.update(') || content.includes('.delete('));
  if (!results.hasRealApiCalls) {
    results.issues.push('Using mock data instead of real API calls');
  }

  // Check for error handling
  results.hasErrorHandling = content.includes('try') && content.includes('catch') && 
    (content.includes('toast.error') || content.includes('console.error'));
  if (!results.hasErrorHandling) {
    results.issues.push('Missing proper error handling');
  }

  // Check for loading states
  results.hasLoadingStates = content.includes('useState') && 
    (content.includes('loading') || content.includes('setLoading'));
  if (!results.hasLoadingStates) {
    results.issues.push('Missing loading state management');
  }

  // Check for authentication
  results.hasAuthCheck = content.includes('useAuth') && 
    (content.includes('authenticated') || content.includes('authLoading'));
  if (!results.hasAuthCheck) {
    results.issues.push('Missing authentication check');
  }

  return results;
};

// List of all 22 pages to test
const pages = [
  { name: 'Dashboard', path: 'dashboard' },
  { name: 'Appointments', path: 'appointments' },
  { name: 'Barbers', path: 'barbers' },
  { name: 'Beauty Professionals', path: 'beauty-professionals' },
  { name: 'Reviews-New', path: 'reviews-new' },
  { name: 'Theme-Updated', path: 'theme-updated' },
  { name: 'Users', path: 'users' },
  { name: 'Services', path: 'services' },
  { name: 'Salons', path: 'salons' },
  { name: 'Providers', path: 'providers' },
  { name: 'Bookings', path: 'bookings' },
  { name: 'Employees', path: 'employees' },
  { name: 'Admins', path: 'admins' },
  { name: 'Beauty-Salons', path: 'beauty-salons' },
  { name: 'Barbershops', path: 'barbershops' },
  { name: 'Location-Analytics', path: 'location-analytics' },
  { name: 'Location-Map', path: 'location-map' },
  { name: 'Customers', path: 'customers' },
  { name: 'Finance', path: 'finance' },
  { name: 'Payouts', path: 'payouts' },
  { name: 'Reports', path: 'reports' },
  { name: 'Reviews', path: 'reviews' },
  { name: 'Settings', path: 'settings' },
  { name: 'Transactions', path: 'transactions' }
];

// Main test runner
const runFrontendTests = () => {
  log('🚀 Starting Frontend Integration Tests');
  log('========================================');
  
  TEST_RESULTS.total = pages.length;
  
  pages.forEach(page => {
    log(`Testing ${page.name} page...`);
    const pagePath = path.join(ADMIN_PANEL_PATH, page.path);
    const results = testPageIntegration(page.name, pagePath);
    
    TEST_RESULTS.pages.push(results);
    
    // Calculate if page passed
    const allChecksPassed = results.hasAdminLayout && 
                          results.hasApiImport && 
                          results.hasRealApiCalls && 
                          results.hasErrorHandling && 
                          results.hasLoadingStates && 
                          results.hasAuthCheck;
    
    if (allChecksPassed && results.issues.length === 0) {
      TEST_RESULTS.passed++;
      log(`${page.name} - PASSED ✅`, 'success');
    } else {
      TEST_RESULTS.failed++;
      log(`${page.name} - FAILED ❌`, 'error');
      results.issues.forEach(issue => log(`  - ${issue}`, 'error'));
    }
  });
  
  // Generate summary
  log('========================================');
  log('📊 FRONTEND INTEGRATION TEST RESULTS');
  log('========================================');
  log(`Total Pages Tested: ${TEST_RESULTS.total}`);
  log(`Pages Passed: ${TEST_RESULTS.passed}`);
  log(`Pages Failed: ${TEST_RESULTS.failed}`);
  log(`Success Rate: ${((TEST_RESULTS.passed / TEST_RESULTS.total) * 100).toFixed(1)}%`);
  log('========================================');
  
  // Detailed results
  TEST_RESULTS.pages.forEach(page => {
    const status = page.issues.length === 0 ? '✅' : '❌';
    log(`${status} ${page.page}: ${page.issues.length} issues`);
    page.issues.forEach(issue => log(`    - ${issue}`, 'error'));
  });
  
  // Recommendations
  log('========================================');
  log('🎯 RECOMMENDATIONS');
  log('========================================');
  
  const pagesNeedingWork = TEST_RESULTS.pages.filter(p => p.issues.length > 0);
  
  if (pagesNeedingWork.length > 0) {
    log('Pages that need integration work:');
    pagesNeedingWork.forEach(page => {
      log(`- ${page.page}: ${page.issues.length} issues to fix`);
    });
    
    log('\nCommon issues to fix:');
    log('1. Import AdminLayout and wrap page content');
    log('2. Import API services from @/lib/api-backend');
    log('3. Replace mock data with real API calls');
    log('4. Add proper error handling with try/catch');
    log('5. Add loading state management');
    log('6. Add authentication checks with useAuth');
  } else {
    log('🎉 All pages are properly integrated!');
  }
  
  log('========================================');
  log('🏁 Frontend integration test completed.');
  log('========================================');
  
  return TEST_RESULTS;
};

// Run tests if called directly
if (require.main === module) {
  runFrontendTests();
}

module.exports = { runFrontendTests, testPageIntegration };
