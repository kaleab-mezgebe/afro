'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
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
  MessageSquare,
  Store,
  Crown,
  Briefcase,
  Shield,
  Building,
  Sparkles
} from 'lucide-react';
import { DashboardService } from '@/lib/api-backend';
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
    // People Management Stats
    totalCustomers: 0,
    totalBarbers: 0,
    totalBeautyProfessionals: 0,
    totalSalonOwners: 0,
    totalEmployees: 0,
    totalAdmins: 0,

    // Business Management Stats
    totalBarbershops: 0,
    totalBeautySalons: 0,

    // Operations Stats
    todayAppointments: 0,
    pendingApprovals: 0,
    totalRevenue: 0,

    // Performance Stats
    avgRating: 0,
    newThisMonth: 0,
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
      // Load real data from backend API
      const [statsData, activitiesData] = await Promise.all([
        DashboardService.getStats(),
        DashboardService.getRecentActivities(10)
      ]);

      if (statsData.success && statsData.data) {
        setStats(statsData.data);
      }

      if (activitiesData.success && activitiesData.data) {
        setRecentActivity(activitiesData.data);
      }
    } catch (error) {
      toast.error('Failed to load dashboard data');
      console.error('Dashboard data loading error:', error);
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
        {/* Creative Analytics Header */}
        <div className="bg-gradient-to-r from-indigo-600 via-purple-600 to-pink-600 rounded-3xl p-8 mb-8 text-white shadow-2xl">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="text-4xl font-bold mb-2 flex items-center gap-3">
                <BarChart3 className="fill-white" size={36} />
                Analytics Command Center
              </h1>
              <p className="text-indigo-100 text-lg">Real-time insights and business intelligence</p>
            </div>
            <div className="text-right">
              <div className="text-3xl font-bold text-yellow-300">Live</div>
              <div className="text-indigo-100">Real-time Data</div>
            </div>
          </div>
        </div>

        {/* Enhanced Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <StatCard
            title="Total Customers"
            value={(stats.totalCustomers || 0).toLocaleString()}
            icon={Users}
            trend={{ value: 15, isPositive: true }}
            color="blue"
          />
          <StatCard
            title="Total Barbers"
            value={(stats.totalBarbers || 0).toLocaleString()}
            icon={Scissors}
            trend={{ value: 8, isPositive: true }}
            color="amber"
          />
          <StatCard
            title="Beauty Professionals"
            value={(stats.totalBeautyProfessionals || 0).toLocaleString()}
            icon={Sparkles}
            trend={{ value: 12, isPositive: true }}
            color="pink"
          />
          <StatCard
            title="Total Revenue"
            value={`$${(stats.totalRevenue || 0).toLocaleString()}`}
            icon={DollarSign}
            trend={{ value: 22, isPositive: true }}
            color="green"
          />
        </div>

        {/* Real-time Metrics Bar */}
        <div className="bg-gradient-to-r from-green-500 via-emerald-500 to-teal-500 rounded-2xl p-4 mb-8 text-white shadow-lg">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 bg-white rounded-full animate-pulse"></div>
              <span className="font-medium">Live Metrics</span>
            </div>
            <div className="flex gap-6 text-sm">
              <span>📈 +15% Revenue</span>
              <span>👥 +8% New Customers</span>
              <span>⭐ 4.8 Avg Rating</span>
              <span>💰 $12.5K Today</span>
            </div>
          </div>
        </div>

        {/* Charts Section */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          {/* Revenue Chart */}
          <div className="bg-white rounded-2xl shadow-lg border border-gray-200 p-6 hover:shadow-xl transition-all duration-300">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-900">Revenue Overview</h3>
              <div className="flex items-center gap-2 text-green-600 text-sm">
                <TrendingUp size={16} />
                <span>+12%</span>
              </div>
            </div>
            <div className="h-64 bg-gradient-to-br from-green-50 to-emerald-100 rounded-xl flex items-center justify-center relative overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-t from-green-100 to-transparent"></div>
              <div className="relative text-center">
                <div className="flex justify-center gap-1 mb-3">
                  {[65, 80, 45, 90, 75, 85, 95].map((height, i) => (
                    <div key={i} className="w-8 bg-green-500 rounded-t" style={{ height: `${height * 0.6}px` }}></div>
                  ))}
                </div>
                <BarChart3 className="text-green-600 mx-auto mb-2" size={48} />
                <p className="text-green-800 font-medium">Monthly Performance</p>
                <p className="text-green-600 text-sm">Last 7 months trend</p>
              </div>
            </div>
          </div>

          {/* Appointments Chart */}
          <div className="bg-white rounded-2xl shadow-lg border border-gray-200 p-6 hover:shadow-xl transition-all duration-300">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-900">Booking Trends</h3>
              <div className="flex items-center gap-2 text-blue-600 text-sm">
                <TrendingUp size={16} />
                <span>+8%</span>
              </div>
            </div>
            <div className="h-64 bg-gradient-to-br from-blue-50 to-indigo-100 rounded-xl flex items-center justify-center relative overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-t from-blue-100 to-transparent"></div>
              <div className="relative text-center">
                <div className="flex justify-center items-end gap-2 mb-3">
                  {[40, 60, 35, 70, 55, 80, 65].map((height, i) => (
                    <div key={i} className="w-6 bg-blue-500 rounded-t" style={{ height: `${height * 0.6}px` }}></div>
                  ))}
                </div>
                <TrendingUp className="text-blue-600 mx-auto mb-2" size={48} />
                <p className="text-blue-800 font-medium">Weekly Bookings</p>
                <p className="text-blue-600 text-sm">Peak: Wednesday</p>
              </div>
            </div>
          </div>
        </div>

        {/* Additional Charts Row */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
          {/* Service Distribution */}
          <div className="bg-white rounded-2xl shadow-lg border border-gray-200 p-6 hover:shadow-xl transition-all duration-300">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Service Distribution</h3>
            <div className="h-48 bg-gradient-to-br from-purple-50 to-pink-100 rounded-xl flex items-center justify-center relative">
              <div className="w-24 h-24 bg-purple-500 rounded-full mx-auto mb-3 relative">
                <div className="absolute inset-2 bg-pink-400 rounded-full"></div>
                <div className="absolute inset-4 bg-purple-300 rounded-full"></div>
              </div>
              <PieChart className="text-purple-600 absolute top-4 right-4" size={24} />
              <p className="text-purple-800 font-medium absolute bottom-4 left-4">Haircuts: 45%</p>
            </div>
          </div>

          {/* Customer Growth */}
          <div className="bg-white rounded-2xl shadow-lg border border-gray-200 p-6 hover:shadow-xl transition-all duration-300">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Customer Growth</h3>
            <div className="h-48 bg-gradient-to-br from-amber-50 to-orange-100 rounded-xl flex items-center justify-center relative">
              <div className="flex items-end gap-1">
                {[20, 35, 30, 45, 40, 55, 60, 70].map((height, i) => (
                  <div key={i} className="w-3 bg-amber-500 rounded-t" style={{ height: `${height * 0.6}px` }}></div>
                ))}
              </div>
              <TrendingUp className="text-amber-600 absolute top-4 right-4" size={24} />
              <p className="text-amber-800 font-medium absolute bottom-4 left-4">+127 New</p>
            </div>
          </div>

          {/* Rating Analytics */}
          <div className="bg-white rounded-2xl shadow-lg border border-gray-200 p-6 hover:shadow-xl transition-all duration-300">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Rating Analytics</h3>
            <div className="h-48 bg-gradient-to-br from-rose-50 to-red-100 rounded-xl flex items-center justify-center relative">
              <div className="text-center">
                <div className="flex justify-center gap-1 mb-2">
                  {[1, 2, 3, 4, 5].map((star) => (
                    <Star key={star} className="text-yellow-400 fill-current" size={20} />
                  ))}
                </div>
                <div className="text-3xl font-bold text-rose-800">4.8</div>
                <p className="text-rose-600 text-sm">Average Rating</p>
              </div>
              <Star className="text-rose-600 absolute top-4 right-4" size={24} />
            </div>
          </div>
        </div>
      </div>

      <div className="mb-8">
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Quick Actions</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
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
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
