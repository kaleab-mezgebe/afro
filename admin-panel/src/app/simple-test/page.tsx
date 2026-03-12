'use client';

import AdminLayout from '@/components/AdminLayout';

export default function SimpleTestPage() {
  return (
    <AdminLayout>
      <div className="page-content">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-3xl font-bold text-gray-900 mb-6">
            ✅ Simple Test Page
          </h1>
          
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-4">
              🎛️ Collapsible Sidebar Test
            </h2>
            
            <div className="space-y-4">
              <div>
                <h3 className="font-medium text-gray-900 mb-2">✅ What to Test</h3>
                <ul className="space-y-2 text-sm text-gray-600">
                  <li>• Click toggle button at top of sidebar</li>
                  <li>• Sidebar should collapse to 70px width</li>
                  <li>• Content should expand to fill space</li>
                  <li>• Hover over icons to see tooltips</li>
                  <li>• Click toggle again to expand</li>
                </ul>
              </div>
              
              <div>
                <h3 className="font-medium text-gray-900 mb-2">🎯 Expected Behavior</h3>
                <ul className="space-y-2 text-sm text-gray-600">
                  <li>• Smooth 0.3s animations</li>
                  <li>• Chevron icons change direction</li>
                  <li>• State persists in localStorage</li>
                  <li>• Main content auto-adjusts</li>
                </ul>
              </div>
            </div>
            
            <div className="mt-6 p-4 bg-green-50 rounded-lg">
              <h3 className="font-medium text-green-800 mb-2">
                🎉 AdminLayout Working!
              </h3>
              <p className="text-green-700">
                If you can see this page with the collapsible sidebar, 
                then the implementation is successful!
              </p>
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
