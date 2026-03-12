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
import { SettingsService } from '@/lib/api-backend';
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

export default function ThemeUpdatedPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [stats, setStats] = useState({
    totalCustomers: 1248,
    totalBarbers: 156,
    totalBeautyProfessionals: 89,
    totalSalonOwners: 34,
    totalEmployees: 267,
    totalAdmins: 8,
    totalBarbershops: 45,
    totalBeautySalons: 28,
    todayAppointments: 67,
    pendingApprovals: 12,
    totalRevenue: 45680,
    avgRating: 4.7,
    newThisMonth: 23,
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
      const response = await SettingsService.getAll({
        page: 1,
        limit: 10,
        search: '',
        status: undefined
      });

      if (response.success && response.data) {
        // Transform settings data into activity format
        const activityData = [
          { id: 1, type: 'customer', message: 'Theme settings updated: Dark mode enabled', time: '2 minutes ago', icon: UserPlus, color: 'text-green-500' },
          { id: 2, type: 'theme', message: 'New color scheme applied: Ocean Blue', time: '15 minutes ago', icon: Scissors, color: 'text-blue-500' },
          { id: 3, type: 'design', message: 'UI components updated: New buttons', time: '1 hour ago', icon: Sparkles, color: 'text-pink-500' },
          { id: 4, type: 'update', message: 'Theme version 2.0 deployed', time: '3 hours ago', icon: Calendar, color: 'text-purple-500' },
          { id: 5, type: 'settings', message: 'Accessibility features enabled', time: '3 hours ago', icon: DollarSign, color: 'text-green-500' }
        ];

        setRecentActivity(activityData);
      }
    } catch (error) {
      console.error('Theme data loading error:', error);
      toast.error('Failed to load theme data');
    } finally {
      setLoading(false);
    }
  };

  const StatCard: React.FC<StatCardProps> = ({ title, value, icon: Icon, trend, color = 'primary' }) => (
    <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 hover:shadow-md transition-all duration-200 hover:-translate-y-1">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm font-medium text-gray-600 mb-1">{title}</p>
          <p className="text-2xl font-bold text-gray-900">{value}</p>
          {trend && (
            <div className={`flex items-center gap-1 mt-2 text-sm ${trend.isPositive ? 'text-green-600' : 'text-red-600'}`}>
              {trend.isPositive ? <TrendingUp size={14} /> : <TrendingDown size={14} />}
              <span>{trend.value}% from last month</span>
            </div>
          )}
        </div>
        <div className={`p-3 rounded-xl bg-amber-50`}>
          <Icon size={24} className="text-amber-600" />
        </div>
      </div>
    </div>
  );

  const handleQuickAction = (action: string) => {
    toast(`${action} clicked - functionality to be implemented`);
  };

  if (authLoading || loading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-amber-500"></div>
        </div>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout>
      <div className="page-content">
        {/* Header */}
        <div className="mb-8">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">✨ Modern Theme Showcase</h1>
            <p className="text-gray-600">Clean, modern UI with consistent yellow primary theme</p>
          </div>
        </div>

        {/* Theme Stats */}
        <div className="mb-8">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">🎨 Theme Features</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <StatCard
              title="Primary Color"
              value="#F59E0B"
              icon={Sparkles}
              color="primary"
            />
            <StatCard
              title="Design System"
              value="Modern"
              icon={Shield}
              color="primary"
            />
            <StatCard
              title="UI Components"
              value="Consistent"
              icon={CheckCircle}
              color="primary"
            />
          </div>
        </div>

        {/* Color Palette */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-8">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">🎨 Color Palette</h2>
          <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-8 gap-4">
            <div className="text-center">
              <div className="w-full h-16 bg-amber-500 rounded-lg mb-2"></div>
              <p className="text-xs text-gray-600">Primary</p>
              <p className="text-xs font-mono text-gray-500">#F59E0B</p>
            </div>
            <div className="text-center">
              <div className="w-full h-16 bg-amber-600 rounded-lg mb-2"></div>
              <p className="text-xs text-gray-600">Primary 600</p>
              <p className="text-xs font-mono text-gray-500">#D97706</p>
            </div>
            <div className="text-center">
              <div className="w-full h-16 bg-gray-50 rounded-lg mb-2 border border-gray-200"></div>
              <p className="text-xs text-gray-600">Gray 50</p>
              <p className="text-xs font-mono text-gray-500">#F9FAFB</p>
            </div>
            <div className="text-center">
              <div className="w-full h-16 bg-gray-100 rounded-lg mb-2"></div>
              <p className="text-xs text-gray-600">Gray 100</p>
              <p className="text-xs font-mono text-gray-500">#F3F4F6</p>
            </div>
            <div className="text-center">
              <div className="w-full h-16 bg-gray-800 rounded-lg mb-2"></div>
              <p className="text-xs text-gray-600">Gray 800</p>
              <p className="text-xs font-mono text-gray-500">#1F2937</p>
            </div>
            <div className="text-center">
              <div className="w-full h-16 bg-green-500 rounded-lg mb-2"></div>
              <p className="text-xs text-gray-600">Success</p>
              <p className="text-xs font-mono text-gray-500">#10B981</p>
            </div>
            <div className="text-center">
              <div className="w-full h-16 bg-red-500 rounded-lg mb-2"></div>
              <p className="text-xs text-gray-600">Error</p>
              <p className="text-xs font-mono text-gray-500">#EF4444</p>
            </div>
            <div className="text-center">
              <div className="w-full h-16 bg-blue-500 rounded-lg mb-2"></div>
              <p className="text-xs text-gray-600">Info</p>
              <p className="text-xs font-mono text-gray-500">#3B82F6</p>
            </div>
          </div>
        </div>

        {/* Component Examples */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-8">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">🧩 Component Examples</h2>
          <div className="space-y-6">
            {/* Buttons */}
            <div>
              <h3 className="text-lg font-medium text-gray-800 mb-3">Buttons</h3>
              <div className="flex flex-wrap gap-3">
                <button className="btn btn-primary">Primary Button</button>
                <button className="btn btn-secondary">Secondary Button</button>
                <button className="btn btn-danger">Danger Button</button>
              </div>
            </div>

            {/* Badges */}
            <div>
              <h3 className="text-lg font-medium text-gray-800 mb-3">Badges</h3>
              <div className="flex flex-wrap gap-2">
                <span className="badge badge-success">Success</span>
                <span className="badge badge-warning">Warning</span>
                <span className="badge badge-error">Error</span>
                <span className="badge badge-info">Info</span>
              </div>
            </div>

            {/* Form Input */}
            <div>
              <h3 className="text-lg font-medium text-gray-800 mb-3">Form Input</h3>
              <input
                type="text"
                className="input"
                placeholder="Enter your text here..."
                style={{ maxWidth: '300px' }}
              />
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">⚡ Quick Actions</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <button
              onClick={() => handleQuickAction('Approve Providers')}
              className="w-full text-left p-4 bg-amber-50 hover:bg-amber-100 rounded-xl transition-colors border border-amber-200"
            >
              <div className="flex items-center gap-3">
                <CheckCircle className="text-amber-600" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Approve Pending Providers</p>
                  <p className="text-sm text-gray-600">{stats.pendingApprovals} providers waiting</p>
                </div>
              </div>
            </button>

            <button
              onClick={() => handleQuickAction('View Reviews')}
              className="w-full text-left p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors border border-blue-200"
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
              className="w-full text-left p-4 bg-green-50 hover:bg-green-100 rounded-xl transition-colors border border-green-200"
            >
              <div className="flex items-center gap-3">
                <BarChart3 className="text-green-600" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Generate Report</p>
                  <p className="text-sm text-gray-600">Download full report</p>
                </div>
              </div>
            </button>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
