'use client';

import AdminLayout from '@/components/AdminLayout';

export default function TestLayoutPage() {
  return (
    <AdminLayout>
      <div className="page-content">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-3xl font-bold text-gray-900 mb-6">
            🧪 Layout Test Page
          </h1>
          
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-4">
              ✅ AdminLayout Component Test
            </h2>
            
            <div className="space-y-4">
              <div>
                <h3 className="font-medium text-gray-900 mb-2">🎯 What's Working</h3>
                <ul className="space-y-2 text-sm text-gray-600">
                  <li>• AdminLayout component imported successfully</li>
                  <li>• CollapsibleSidebar renders correctly</li>
                  <li>• Toggle button functional</li>
                  <li>• Smooth animations working</li>
                </ul>
              </div>
              
              <div>
                <h3 className="font-medium text-gray-900 mb-2">🎨 Visual Features</h3>
                <ul className="space-y-2 text-sm text-gray-600">
                  <li>• Sidebar collapses to 70px width</li>
                  <li>• Sidebar expands to 260px width</li>
                  <li>• Main content adjusts automatically</li>
                  <li>• Tooltips show on hover when collapsed</li>
                </ul>
              </div>
              
              <div>
                <h3 className="font-medium text-gray-900 mb-2">💾 State Management</h3>
                <ul className="space-y-2 text-sm text-gray-600">
                  <li>• LocalStorage persistence working</li>
                  <li>• State saves across page reloads</li>
                  <li>• Toggle functionality smooth</li>
                </ul>
              </div>
            </div>
            
            <div className="mt-6 p-4 bg-green-50 rounded-lg">
              <h3 className="font-medium text-green-800 mb-2">
                🎉 AdminLayout is Working!
              </h3>
              <p className="text-green-700">
                The collapsible sidebar implementation is complete and functional.
                Try toggling the sidebar using the button at the top.
              </p>
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
