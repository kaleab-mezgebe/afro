'use client';

import { useEffect, useState } from 'react';
import Sidebar from '@/components/layout/Sidebar';
import { api } from '@/lib/api';
import toast from 'react-hot-toast';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

export default function AnalyticsPage() {
  const [period, setPeriod] = useState('month');
  const [loading, setLoading] = useState(true);
  const [revenueData, setRevenueData] = useState([]);
  const [userGrowthData, setUserGrowthData] = useState([]);
  const [summary, setSummary] = useState({
    totalRevenue: 0,
    newUsers: 0,
    totalAppointments: 0,
    revenueGrowth: 0,
    userGrowth: 0,
    appointmentGrowth: 0,
  });

  useEffect(() => {
    loadAnalytics();
  }, [period]);

  const loadAnalytics = async () => {
    try {
      const [revenueRes, userRes, systemRes] = await Promise.all([
        api.getRevenueAnalytics(period),
        api.getUserAnalytics(period),
        api.getSystemAnalytics(period),
      ]);
      
      setRevenueData(revenueRes.data.chartData || []);
      setUserGrowthData(userRes.data.chartData || []);
      setSummary({
        totalRevenue: systemRes.data.totalRevenue || 0,
        newUsers: systemRes.data.totalUsers || 0,
        totalAppointments: systemRes.data.totalAppointments || 0,
        revenueGrowth: systemRes.data.revenueGrowth || 0,
        userGrowth: systemRes.data.userGrowth || 0,
        appointmentGrowth: systemRes.data.appointmentGrowth || 0,
      });
    } catch (error) {
      console.error('Analytics error:', error);
      toast.error('Failed to load analytics');
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
        <div className="mb-8 flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Analytics & Reports</h1>
            <p className="text-gray-600 mt-2">System-wide statistics and insights</p>
          </div>
          <select
            aria-label="Select time period"
            className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            value={period}
            onChange={(e) => setPeriod(e.target.value)}
          >
            <option value="week">Last Week</option>
            <option value="month">Last Month</option>
            <option value="quarter">Last Quarter</option>
            <option value="year">Last Year</option>
          </select>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Revenue Trends</h2>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={revenueData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Line type="monotone" dataKey="revenue" stroke="#8884d8" strokeWidth={2} />
              </LineChart>
            </ResponsiveContainer>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">User Growth</h2>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={userGrowthData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Bar dataKey="users" fill="#82ca9d" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Total Revenue</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">
              ${summary.totalRevenue.toLocaleString()}
            </p>
            <p className={`text-sm mt-2 ${summary.revenueGrowth >= 0 ? 'text-green-600' : 'text-red-600'}`}>
              {summary.revenueGrowth >= 0 ? '↑' : '↓'} {Math.abs(summary.revenueGrowth)}% from last period
            </p>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">New Users</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">
              {summary.newUsers.toLocaleString()}
            </p>
            <p className={`text-sm mt-2 ${summary.userGrowth >= 0 ? 'text-green-600' : 'text-red-600'}`}>
              {summary.userGrowth >= 0 ? '↑' : '↓'} {Math.abs(summary.userGrowth)}% from last period
            </p>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Appointments</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">
              {summary.totalAppointments.toLocaleString()}
            </p>
            <p className={`text-sm mt-2 ${summary.appointmentGrowth >= 0 ? 'text-green-600' : 'text-red-600'}`}>
              {summary.appointmentGrowth >= 0 ? '↑' : '↓'} {Math.abs(summary.appointmentGrowth)}% from last period
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
