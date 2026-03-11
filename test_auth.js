const http = require('http');

function makeRequest(path, method = 'GET', data = null, token = null) {
  return new Promise((resolve, reject) => {
    const headers = {
      'Content-Type': 'application/json'
    };

    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const options = {
      hostname: 'localhost',
      port: 3001,
      path: `/api/v1/admin${path}`,
      method: method,
      headers: headers
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => {
        body += chunk;
      });
      res.on('end', () => {
        try {
          const data = body ? JSON.parse(body) : null;
          resolve({
            status: res.statusCode,
            data: data
          });
        } catch (error) {
          resolve({
            status: res.statusCode,
            data: body
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

async function testAuth() {
  try {
    console.log('🔍 Testing authentication status...');

    // Test without token (should get 401)
    const noTokenResponse = await makeRequest('/users');
    console.log('Without token:', noTokenResponse.status);

    // Test with fake token (should get 401)
    const fakeTokenResponse = await makeRequest('/users', 'GET', null, 'fake-token');
    console.log('With fake token:', fakeTokenResponse.status);

    console.log('\n📝 Results:');
    console.log('- 401 = Authentication required (expected)');
    console.log('- 404 = Route not found (problem)');
    console.log('- 200 = Success (authenticated)');

  } catch (error) {
    console.error('💥 Request failed:', error.message);
  }
}

testAuth();
