'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';

export default function TemplatePage() {
  const [loading, setLoading] = useState(false);

  if (loading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
        </div>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout>
      <div className="page-content">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Page Title</h1>
          <p className="text-gray-600">Page description goes here</p>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Content</h2>
          <p className="text-gray-600">Your page content here</p>
        </div>
      </div>
    </AdminLayout>
  );
}
