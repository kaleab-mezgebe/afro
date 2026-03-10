'use client';

import { useEffect, useState } from 'react';
import Sidebar from '@/components/Sidebar';
import {
  Users,
  Scissors,
  Calendar,
  DollarSign,
  TrendingUp,
  TrendingDown,
  CheckCircle,
  AlertCircle,
  Activity,
  BarChart3,
  PieChart,
  UserPlus,
  Star,
  MessageSquare
} from 'lucide-react';
import { api } from '@/lib/api';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';

interface ActivityItem {
  id: number;
  type: string;
  message: string;
  time: string;
  icon: any;
  color: string;
}

interface StatCardProps {
  title: string;
  value: string | number;
  icon: any;
  trend?: { value: number; isPositive: boolean };
  color?: string;
}

export default function DashboardPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalProviders: 0,
    totalCustomers: 0,
    todayAppointments: 0,
    totalRevenue: 0,
    pendingApprovals: 0,
  });
  const [loading, setLoading] = useState(true);
  const [recentActivity, setRecentActivity] = useState<ActivityItem[]>([]);

  useEffect(() => {
    if (authenticated) {
      loadDashboardData();
    }
  }, [authenticated]);

  const loadDashboardData = async () => {
    try {
      const response = await api.getSystemAnalytics('month');
      setStats({
        totalUsers: response.data.totalUsers || 0,
        totalProviders: response.data.totalProviders || 0,
        totalCustomers: response.data.totalCustomers || 0,
        todayAppointments: response.data.totalAppointments || 0,
        totalRevenue: response.data.totalRevenue || 0,
        pendingApprovals: 3, // Mock data
      });

      // Mock recent activity data
      setRecentActivity([
        { id: 1, type: 'user', message: 'New user registered: James Smith', time: '2 minutes ago', icon: UserPlus, color: 'text-green-500' },
        { id: 2, type: 'booking', message: 'New booking at Elite Cuts Salon', time: '15 minutes ago', icon: Calendar, color: 'text-blue-500' },
        { id: 3, type: 'review', message: 'New 5-star review for Style Studio', time: '1 hour ago', icon: Star, color: 'text-yellow-500' },
        { id: 4, type: 'message', message: 'Support ticket from customer', time: '2 hours ago', icon: MessageSquare, color: 'text-purple-500' },
        { id: 5, type: 'payment', message: 'Payment received: $45.00', time: '3 hours ago', icon: DollarSign, color: 'text-green-500' },
      ]);
    } catch (error) {
      console.error('Dashboard data error:', error);
      toast.error('Failed to load dashboard data');
    } finally {
      setLoading(false);
    }
  };

  const StatCard: React.FC<StatCardProps> = ({ title, value, icon: Icon, trend, color = 'primary' }) => (
    <div className="stat-card">
      <div className="flex items-center justify-between">
        <div>
          <p className="stat-label">{title}</p>
          <p className="stat-value">{value}</p>
          {trend && (
            <div className={`stat-change ${trend.isPositive ? 'positive' : 'negative'}`}>
              {trend.isPositive ? <TrendingUp size={12} /> : <TrendingDown size={12} />}
              {trend.value}% from last month
            </div>
          )}
        </div>
        <div className={`p-3 rounded-lg bg-${color}-100`}>
          <Icon size={24} className={`text-${color}-600`} />
        </div>
      </div>
    </div>
  );

  const handleQuickAction = (action: string) => {
    toast(`${action} clicked - functionality to be implemented`);
  };

  const exportReport = () => {
    toast('Exporting report...');
    // Add export functionality
  };

  if (authLoading || loading) {
    return (
      <div className="flex">
        <Sidebar />
        <div className="main-content flex items-center justify-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex">
      <Sidebar />
      <div className="main-content">
        {/* Header */}
        <div className="header">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
            <p className="text-gray-600">Welcome back! Here's what's happening with your salon business today.</p>
          </div>
          <div className="flex gap-3">
            <button onClick={exportReport} className="btn btn-secondary">
              <Activity size={16} />
              Export Report
            </button>
            <button onClick={() => handleQuickAction('View Analytics')} className="btn btn-primary">
              <BarChart3 size={16} />
              View Analytics
            </button>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="stats-grid">
          <StatCard
            title="Total Users"
            value={stats.totalUsers.toLocaleString()}
            icon={Users}
            trend={{ value: 12, isPositive: true }}
            color="blue"
          />
          <StatCard
            title="Total Providers"
            value={stats.totalProviders.toLocaleString()}
            icon={Scissors}
            trend={{ value: 8, isPositive: true }}
            color="green"
          />
          <StatCard
            title="Total Customers"
            value={stats.totalCustomers.toLocaleString()}
            icon={Users}
            trend={{ value: 15, isPositive: true }}
            color="purple"
          />
          <StatCard
            title="Today's Appointments"
            value={stats.todayAppointments}
            icon={Calendar}
            trend={{ value: 5, isPositive: false }}
            color="orange"
          />
          <StatCard
            title="Total Revenue"
            value={`$${stats.totalRevenue.toLocaleString()}`}
            icon={DollarSign}
            trend={{ value: 20, isPositive: true }}
            color="green"
          />
          <StatCard
            title="Pending Approvals"
            value={stats.pendingApprovals}
            icon={AlertCircle}
            color="red"
          />
        </div>

        {/* Charts and Activity */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Appointments Chart */}
          <div className="card lg:col-span-2">
            <h2 className="text-lg font-semibold mb-4">Appointments Overview</h2>
            <div className="h-64 bg-gray-50 rounded-lg flex items-center justify-center">
              <div className="text-center">
                <BarChart3 size={48} className="text-gray-400 mx-auto mb-2" />
                <p className="text-gray-500">Appointments chart coming soon</p>
                <p className="text-sm text-gray-400">Daily appointment trends</p>
              </div>
            </div>
          </div>

          {/* Revenue Chart */}
          <div className="card">
            <h2 className="text-lg font-semibold mb-4">Revenue Breakdown</h2>
            <div className="h-64 bg-gray-50 rounded-lg flex items-center justify-center">
              <div className="text-center">
                <PieChart size={48} className="text-gray-400 mx-auto mb-2" />
                <p className="text-gray-500">Revenue chart coming soon</p>
                <p className="text-sm text-gray-400">Monthly revenue distribution</p>
              </div>
            </div>
          </div>
        </div>

        {/* Recent Activity and Quick Actions */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Recent Activity */}
          <div className="card">
            <h2 className="text-lg font-semibold mb-4">Recent Activity</h2>
            <div className="space-y-3">
              {recentActivity.map((activity) => {
                const Icon = activity.icon;
                return (
                  <div key={activity.id} className="flex items-center gap-3 p-3 hover:bg-gray-50 rounded-lg transition-colors cursor-pointer">
                    <div className={`p-2 rounded-lg bg-gray-100`}>
                      <Icon size={16} className={activity.color} />
                    </div>
                    <div className="flex-1">
                      <p className="text-sm font-medium text-gray-900">{activity.message}</p>
                      <p className="text-xs text-gray-500">{activity.time}</p>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Quick Actions */}
          <div className="card">
            <h2 className="text-lg font-semibold mb-4">Quick Actions</h2>
            <div className="space-y-3">
              <button
                onClick={() => handleQuickAction('Approve Providers')}
                className="w-full text-left p-4 bg-primary bg-opacity-10 hover:bg-opacity-20 rounded-lg transition-colors border border-primary"
              >
                <div className="flex items-center gap-3">
                  <CheckCircle className="text-primary" size={20} />
                  <div>
                    <p className="font-medium text-gray-900">Approve Pending Providers</p>
                    <p className="text-sm text-gray-600">{stats.pendingApprovals} providers waiting</p>
                  </div>
                </div>
              </button>

              <button
                onClick={() => handleQuickAction('View Reviews')}
                className="w-full text-left p-4 bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors border border-blue-200"
              >
                <div className="flex items-center gap-3">
                  <Star className="text-blue-600" size={20} />
                  <div>
                    <p className="font-medium text-gray-900">View Flagged Reviews</p>
                    <p className="text-sm text-gray-600">Review moderation needed</p>
                  </div>
                </div>
              </button>

              <button
                onClick={() => handleQuickAction('Generate Report')}
                className="w-full text-left p-4 bg-green-50 hover:bg-green-100 rounded-lg transition-colors border border-green-200"
              >
                <div className="flex items-center gap-3">
                  <BarChart3 className="text-green-600" size={20} />
                  <div>
                    <p className="font-medium text-gray-900">Generate Monthly Report</p>
                    <p className="text-sm text-gray-600">Download detailed analytics</p>
                  </div>
                </div>
              </button>

              <button
                onClick={() => handleQuickAction('Send Notifications')}
                className="w-full text-left p-4 bg-purple-50 hover:bg-purple-100 rounded-lg transition-colors border border-purple-200"
              >
                <div className="flex items-center gap-3">
                  <MessageSquare className="text-purple-600" size={20} />
                  <div>
                    <p className="font-medium text-gray-900">Send Notifications</p>
                    <p className="text-sm text-gray-600">Broadcast to users</p>
                  </div>
                </div>
              </button>
            </div>
          </div>
        </div>

        {/* Top Performing Salons */}
        <div className="card">
          <h2 className="text-lg font-semibold mb-4">Top Performing Salons</h2>
          <div className="overflow-x-auto">
            <table className="table">
              <thead>
                <tr>
                  <th>Salon Name</th>
                  <th>Owner</th>
                  <th>Rating</th>
                  <th>Total Bookings</th>
                  <th>Revenue</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr className="cursor-pointer hover:bg-gray-50">
                  <td className="font-medium">Elite Cuts Salon</td>
                  <td>James Elite</td>
                  <td>
                    <div className="flex items-center gap-1">
                      <Star size={16} className="text-yellow-500 fill-current" />
                      4.7
                    </div>
                  </td>
                  <td>320</td>
                  <td>$8,500</td>
                  <td><span className="badge badge-success">Active</span></td>
                </tr>
                <tr className="cursor-pointer hover:bg-gray-50">
                  <td className="font-medium">Style Studio</td>
                  <td>Mary Style</td>
                  <td>
                    <div className="flex items-center gap-1">
                      <Star size={16} className="text-yellow-500 fill-current" />
                      4.9
                    </div>
                  </td>
                  <td>450</td>
                  <td>$12,600</td>
                  <td><span className="badge badge-success">Active</span></td>
                </tr>
                <tr className="cursor-pointer hover:bg-gray-50">
                  <td className="font-medium">Glamour Lounge</td>
                  <td>John Classic</td>
                  <td>
                    <div className="flex items-center gap-1">
                      <Star size={16} className="text-yellow-500 fill-current" />
                      4.5
                    </div>
                  </td>
                  <td>280</td>
                  <td>$6,300</td>
                  <td><span className="badge badge-warning">Pending</span></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
