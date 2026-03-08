'use client';

import { useEffect, useState } from 'react';
import Sidebar from '@/components/layout/Sidebar';
import StatCard from '@/components/ui/StatCard';
import { FiUsers, FiUserCheck, FiCalendar, FiDollarSign } from 'react-icons/fi';
import { api } from '@/lib/api';
import toast from 'react-hot-toast';

export default function DashboardPage() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalProviders: 0,
    totalAppointments: 0,
    totalRevenue: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      const response = await api.getSystemAnalytics('month');
      setStats({
        totalUsers: response.data.totalUsers || 0,
        totalProviders: response.data.totalProviders || 0,
        totalAppointments: response.data.totalAppointments || 0,
        totalRevenue: response.data.totalRevenue || 0,
      });
    } catch (error) {
      console.error('Dashboard data error:', error);
      toast.error('Failed to load dashboard data');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex">
        <Sidebar />
        <div className="flex-1 flex items-center justify-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex">
      <Sidebar />
      <div className="flex-1 p-8 bg-gray-50">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Dashboard</h1>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <StatCard
            title="Total Users"
            value={stats.totalUsers}
            icon={FiUsers}
            color="blue"
            trend={{ value: 12, isPositive: true }}
          />
          <StatCard
            title="Total Providers"
            value={stats.totalProviders}
            icon={FiUserCheck}
            color="green"
            trend={{ value: 8, isPositive: true }}
          />
          <StatCard
            title="Appointments"
            value={stats.totalAppointments}
            icon={FiCalendar}
            color="purple"
            trend={{ value: 15, isPositive: true }}
          />
          <StatCard
            title="Revenue"
            value={`$${stats.totalRevenue.toLocaleString()}`}
            icon={FiDollarSign}
            color="yellow"
            trend={{ value: 20, isPositive: true }}
          />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Recent Activity</h2>
            <div className="space-y-4">
              <p className="text-sm text-gray-500 text-center py-8">
                Activity feed coming soon. Connect to backend activity logs for real-time updates.
              </p>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h2>
            <div className="space-y-3">
              <button type="button" className="w-full text-left px-4 py-3 bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors">
                <p className="text-sm font-medium text-blue-900">Approve Pending Providers</p>
              </button>
              <button type="button" className="w-full text-left px-4 py-3 bg-green-50 hover:bg-green-100 rounded-lg transition-colors">
                <p className="text-sm font-medium text-green-900">View Flagged Reviews</p>
              </button>
              <button type="button" className="w-full text-left px-4 py-3 bg-purple-50 hover:bg-purple-100 rounded-lg transition-colors">
                <p className="text-sm font-medium text-purple-900">Generate Monthly Report</p>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
