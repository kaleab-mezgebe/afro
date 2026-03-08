'use client';

import { useState } from 'react';
import Sidebar from '@/components/layout/Sidebar';
import toast from 'react-hot-toast';

export default function SettingsPage() {
  const [settings, setSettings] = useState({
    siteName: 'AFRO',
    supportEmail: 'support@afro.com',
    commissionRate: 15,
    minBookingHours: 2,
    maxCancellationHours: 24,
  });

  const handleSave = () => {
    toast.success('Settings saved successfully');
  };

  return (
    <div className="flex">
      <Sidebar />
      <div className="flex-1 p-8 bg-gray-50">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Settings</h1>
          <p className="text-gray-600 mt-2">Configure system settings and preferences</p>
        </div>

        <div className="max-w-3xl">
          <div className="bg-white rounded-lg shadow mb-6">
            <div className="p-6 border-b">
              <h2 className="text-lg font-semibold text-gray-900">General Settings</h2>
            </div>
            <div className="p-6 space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Site Name
                </label>
                <input
                  type="text"
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={settings.siteName}
                  onChange={(e) => setSettings({ ...settings, siteName: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Support Email
                </label>
                <input
                  type="email"
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={settings.supportEmail}
                  onChange={(e) => setSettings({ ...settings, supportEmail: e.target.value })}
                />
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow mb-6">
            <div className="p-6 border-b">
              <h2 className="text-lg font-semibold text-gray-900">Business Settings</h2>
            </div>
            <div className="p-6 space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Commission Rate (%)
                </label>
                <input
                  type="number"
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={settings.commissionRate}
                  onChange={(e) => setSettings({ ...settings, commissionRate: parseInt(e.target.value) })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Minimum Booking Hours
                </label>
                <input
                  type="number"
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={settings.minBookingHours}
                  onChange={(e) => setSettings({ ...settings, minBookingHours: parseInt(e.target.value) })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Maximum Cancellation Hours
                </label>
                <input
                  type="number"
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={settings.maxCancellationHours}
                  onChange={(e) => setSettings({ ...settings, maxCancellationHours: parseInt(e.target.value) })}
                />
              </div>
            </div>
          </div>

          <div className="flex justify-end">
            <button
              onClick={handleSave}
              className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              Save Changes
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
