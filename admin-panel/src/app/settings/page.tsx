'use client';

import React, { useState, useEffect } from 'react';
import AdminLayout from '@/components/AdminLayout';
import {
  Settings,
  Save,
  Bell,
  Shield,
  Database,
  Globe,
  Users,
  CreditCard,
  Mail,
  Smartphone,
  CheckCircle,
  AlertCircle,
  TrendingUp,
  Calendar,
} from 'lucide-react';
import { SettingsService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';

interface SystemSettings {
  general: {
    siteName: string;
    siteDescription: string;
    contactEmail: string;
    supportPhone: string;
    timezone: string;
    language: string;
  };
  notifications: {
    emailNotifications: boolean;
    smsNotifications: boolean;
    pushNotifications: boolean;
    bookingReminders: boolean;
    marketingEmails: boolean;
  };
  security: {
    twoFactorAuth: boolean;
    sessionTimeout: number;
    passwordMinLength: number;
    requireStrongPassword: boolean;
    loginAttempts: number;
  };
  payment: {
    currency: string;
    paymentMethods: string[];
    refundPolicy: string;
    commissionRate: number;
  };
}

export default function SettingsPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [activeTab, setActiveTab] = useState('general');
  const [settings, setSettings] = useState<SystemSettings>({
    general: {
      siteName: 'Beauty Booking Platform',
      siteDescription: 'Professional beauty and grooming services booking platform',
      contactEmail: 'support@beautybooking.com',
      supportPhone: '+1-234-567-8900',
      timezone: 'UTC-5',
      language: 'en'
    },
    notifications: {
      emailNotifications: true,
      smsNotifications: true,
      pushNotifications: true,
      bookingReminders: true,
      marketingEmails: false
    },
    security: {
      twoFactorAuth: false,
      sessionTimeout: 30,
      passwordMinLength: 8,
      requireStrongPassword: true,
      loginAttempts: 5
    },
    payment: {
      currency: 'USD',
      paymentMethods: ['credit_card', 'paypal', 'bank_transfer'],
      refundPolicy: '7-day refund policy',
      commissionRate: 15
    }
  });

  useEffect(() => {
    if (authenticated) {
      loadSettings();
    }
  }, [authenticated]);

  const loadSettings = async () => {
    try {
      const response = await SettingsService.get();

      if (response.success && response.data) {
        // Deep merge API response with defaults to avoid undefined nested objects
        setSettings(prev => ({
          general: { ...prev.general, ...(response.data.general ?? {}) },
          notifications: { ...prev.notifications, ...(response.data.notifications ?? {}) },
          security: { ...prev.security, ...(response.data.security ?? {}) },
          payment: {
            ...prev.payment,
            ...(response.data.payment ?? {}),
            paymentMethods: response.data.payment?.paymentMethods ?? prev.payment.paymentMethods,
          },
        }));
      }
    } catch (error) {
      toast.error('Failed to load settings');
      console.error('Settings loading error:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      const response = await SettingsService.update(settings);

      if (response.success) {
        toast.success('Settings saved successfully');
      }
    } catch (error) {
      toast.error('Failed to save settings');
      console.error('Settings save error:', error);
    } finally {
      setSaving(false);
    }
  };

  const handleInputChange = (category: keyof SystemSettings, field: string, value: any) => {
    setSettings(prev => ({
      ...prev,
      [category]: {
        ...prev[category],
        [field]: value
      }
    }));
  };

  if (authLoading || loading) {
    return (
      <AdminLayout>
        <div className="page-content">
          <div className="flex items-center justify-center h-64">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-amber-500"></div>
          </div>
        </div>
      </AdminLayout>
    );
  }

  if (!authenticated) {
    return (
      <AdminLayout>
        <div className="page-content">
          <div className="flex items-center justify-center h-64">
            <div className="text-gray-500">Please login to access this page.</div>
          </div>
        </div>
      </AdminLayout>
    );
  }

  const tabs = [
    { id: 'general', label: 'General', icon: Globe },
    { id: 'notifications', label: 'Notifications', icon: Bell },
    { id: 'security', label: 'Security', icon: Shield },
    { id: 'payment', label: 'Payment', icon: CreditCard },
  ];

  return (
    <AdminLayout>
      <div className="page-content">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Settings</h1>
          <p className="text-gray-600">Manage system settings and preferences</p>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Active Settings</p>
                <p className="stat-value">12</p>
                <div className="stat-change positive">
                  <CheckCircle size={12} />
                  All configured
                </div>
              </div>
              <div className="p-3 rounded-lg bg-green-100">
                <Settings size={24} className="text-green-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Notifications</p>
                <p className="stat-value">{Object.values(settings.notifications ?? {}).filter(Boolean).length}/5</p>
                <div className="stat-change positive">
                  <Bell size={12} />
                  Active
                </div>
              </div>
              <div className="p-3 rounded-lg bg-blue-100">
                <Bell size={24} className="text-blue-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Security Level</p>
                <p className="stat-value">High</p>
                <div className="stat-change positive">
                  <Shield size={12} />
                  Protected
                </div>
              </div>
              <div className="p-3 rounded-lg bg-purple-100">
                <Shield size={24} className="text-purple-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Payment Methods</p>
                <p className="stat-value">{settings.payment?.paymentMethods?.length ?? 0}</p>
                <div className="stat-change positive">
                  <CreditCard size={12} />
                  Available
                </div>
              </div>
              <div className="p-3 rounded-lg bg-amber-100">
                <CreditCard size={24} className="text-amber-600" />
              </div>
            </div>
          </div>
        </div>

        {/* Settings Content */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div className="flex">
            {/* Sidebar */}
            <div className="w-64 border-r border-gray-200">
              <div className="p-4">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Settings</h3>
                <nav className="space-y-2">
                  {tabs.map((tab) => {
                    const Icon = tab.icon;
                    return (
                      <button
                        key={tab.id}
                        onClick={() => setActiveTab(tab.id)}
                        className={`w-full flex items-center gap-3 px-3 py-2 rounded-lg text-left transition-colors ${activeTab === tab.id
                          ? 'bg-amber-50 text-amber-700 border border-amber-200'
                          : 'text-gray-700 hover:bg-gray-50'
                          }`}
                      >
                        <Icon size={20} />
                        <span className="font-medium">{tab.label}</span>
                      </button>
                    );
                  })}
                </nav>
              </div>
            </div>

            {/* Main Content */}
            <div className="flex-1 p-6">
              {/* General Settings */}
              {activeTab === 'general' && (
                <div>
                  <h2 className="text-xl font-semibold text-gray-900 mb-6">General Settings</h2>
                  <div className="space-y-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Site Name</label>
                        <input
                          type="text"
                          value={settings.general.siteName}
                          onChange={(e) => handleInputChange('general', 'siteName', e.target.value)}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Contact Email</label>
                        <input
                          type="email"
                          value={settings.general.contactEmail}
                          onChange={(e) => handleInputChange('general', 'contactEmail', e.target.value)}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Support Phone</label>
                        <input
                          type="tel"
                          value={settings.general.supportPhone}
                          onChange={(e) => handleInputChange('general', 'supportPhone', e.target.value)}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Timezone</label>
                        <select
                          value={settings.general.timezone}
                          onChange={(e) => handleInputChange('general', 'timezone', e.target.value)}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500"
                        >
                          <option value="UTC-5">UTC-5 (Eastern Time)</option>
                          <option value="UTC-6">UTC-6 (Central Time)</option>
                          <option value="UTC-7">UTC-7 (Mountain Time)</option>
                          <option value="UTC-8">UTC-8 (Pacific Time)</option>
                        </select>
                      </div>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Site Description</label>
                      <textarea
                        value={settings.general.siteDescription}
                        onChange={(e) => handleInputChange('general', 'siteDescription', e.target.value)}
                        rows={3}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500"
                      />
                    </div>
                  </div>
                </div>
              )}

              {/* Notification Settings */}
              {activeTab === 'notifications' && (
                <div>
                  <h2 className="text-xl font-semibold text-gray-900 mb-6">Notification Settings</h2>
                  <div className="space-y-4">
                    {Object.entries(settings.notifications ?? {}).map(([key, value]) => (
                      <div key={key} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                        <div className="flex items-center gap-3">
                          {key === 'emailNotifications' && <Mail size={20} className="text-gray-600" />}
                          {key === 'smsNotifications' && <Smartphone size={20} className="text-gray-600" />}
                          {key === 'pushNotifications' && <Bell size={20} className="text-gray-600" />}
                          {key === 'bookingReminders' && <Calendar size={20} className="text-gray-600" />}
                          {key === 'marketingEmails' && <Mail size={20} className="text-gray-600" />}
                          <div>
                            <p className="font-medium text-gray-900">
                              {key.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase())}
                            </p>
                            <p className="text-sm text-gray-500">
                              {key === 'emailNotifications' && 'Send email notifications to users'}
                              {key === 'smsNotifications' && 'Send SMS notifications to users'}
                              {key === 'pushNotifications' && 'Send push notifications to users'}
                              {key === 'bookingReminders' && 'Send booking reminders to users'}
                              {key === 'marketingEmails' && 'Send marketing emails to users'}
                            </p>
                          </div>
                        </div>
                        <label className="relative inline-flex items-center cursor-pointer">
                          <input
                            type="checkbox"
                            checked={value}
                            onChange={(e) => handleInputChange('notifications', key, e.target.checked)}
                            className="sr-only peer"
                          />
                          <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-amber-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-amber-500"></div>
                        </label>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Security Settings */}
              {activeTab === 'security' && (
                <div>
                  <h2 className="text-xl font-semibold text-gray-900 mb-6">Security Settings</h2>
                  <div className="space-y-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Session Timeout (minutes)</label>
                        <input
                          type="number"
                          value={settings.security.sessionTimeout}
                          onChange={(e) => handleInputChange('security', 'sessionTimeout', parseInt(e.target.value))}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Password Min Length</label>
                        <input
                          type="number"
                          value={settings.security.passwordMinLength}
                          onChange={(e) => handleInputChange('security', 'passwordMinLength', parseInt(e.target.value))}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Max Login Attempts</label>
                        <input
                          type="number"
                          value={settings.security.loginAttempts}
                          onChange={(e) => handleInputChange('security', 'loginAttempts', parseInt(e.target.value))}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500"
                        />
                      </div>
                    </div>
                    <div className="space-y-4">
                      {Object.entries(settings.security).filter(([key]) => {
                        const value = settings.security[key as keyof typeof settings.security];
                        return typeof value === 'boolean';
                      }).map(([key, value]) => (
                        <div key={key} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                          <div className="flex items-center gap-3">
                            <Shield size={20} className="text-gray-600" />
                            <div>
                              <p className="font-medium text-gray-900">
                                {key.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase())}
                              </p>
                              <p className="text-sm text-gray-500">
                                {key === 'twoFactorAuth' && 'Enable two-factor authentication for admin users'}
                                {key === 'requireStrongPassword' && 'Require strong passwords for all users'}
                              </p>
                            </div>
                          </div>
                          <label className="relative inline-flex items-center cursor-pointer">
                            <input
                              type="checkbox"
                              checked={value as boolean}
                              onChange={(e) => handleInputChange('security', key, e.target.checked)}
                              className="sr-only peer"
                            />
                            <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-amber-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-amber-500"></div>
                          </label>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              )}

              {/* Payment Settings */}
              {activeTab === 'payment' && (
                <div>
                  <h2 className="text-xl font-semibold text-gray-900 mb-6">Payment Settings</h2>
                  <div className="space-y-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Currency</label>
                        <select
                          value={settings.payment.currency}
                          onChange={(e) => handleInputChange('payment', 'currency', e.target.value)}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500"
                        >
                          <option value="USD">USD - US Dollar</option>
                          <option value="EUR">EUR - Euro</option>
                          <option value="GBP">GBP - British Pound</option>
                          <option value="CAD">CAD - Canadian Dollar</option>
                        </select>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Commission Rate (%)</label>
                        <input
                          type="number"
                          value={settings.payment.commissionRate}
                          onChange={(e) => handleInputChange('payment', 'commissionRate', parseFloat(e.target.value))}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500"
                        />
                      </div>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Refund Policy</label>
                      <textarea
                        value={settings.payment.refundPolicy}
                        onChange={(e) => handleInputChange('payment', 'refundPolicy', e.target.value)}
                        rows={3}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Payment Methods</label>
                      <div className="space-y-2">
                        {['credit_card', 'paypal', 'bank_transfer', 'cash'].map((method) => (
                          <label key={method} className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg cursor-pointer hover:bg-gray-100">
                            <input
                              type="checkbox"
                              checked={settings.payment.paymentMethods.includes(method)}
                              onChange={(e) => {
                                const newMethods = e.target.checked
                                  ? [...settings.payment.paymentMethods, method]
                                  : settings.payment.paymentMethods.filter(m => m !== method);
                                handleInputChange('payment', 'paymentMethods', newMethods);
                              }}
                              className="w-4 h-4 text-amber-600 border-gray-300 rounded focus:ring-amber-500"
                            />
                            <span className="font-medium text-gray-900 capitalize">
                              {method.replace('_', ' ')}
                            </span>
                          </label>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Save Button */}
              <div className="mt-8 flex justify-end">
                <button
                  onClick={handleSave}
                  disabled={saving}
                  className="flex items-center gap-2 px-6 py-2 bg-amber-500 text-white rounded-lg hover:bg-amber-600 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <Save size={20} />
                  {saving ? 'Saving...' : 'Save Settings'}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
