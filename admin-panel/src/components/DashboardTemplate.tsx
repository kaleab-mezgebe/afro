'use client';

import { ReactNode } from 'react';
import { TrendingUp, TrendingDown } from 'lucide-react';
import AdminLayout from '@/components/AdminLayout';

interface StatCardProps {
  title: string;
  value: string | number;
  icon: React.ComponentType<{ size?: number; className?: string }>;
  trend?: { value: number; isPositive: boolean };
  color?: 'blue' | 'green' | 'amber' | 'purple' | 'red' | 'pink';
}

interface QuickActionProps {
  title: string;
  description: string;
  icon: React.ComponentType<{ size?: number; className?: string }>;
  onClick: () => void;
  color?: 'blue' | 'green' | 'amber' | 'purple';
}

interface DashboardTemplateProps {
  title: string;
  description: string;
  children?: ReactNode;
  stats?: StatCardProps[];
  quickActions?: QuickActionProps[];
  actionsBar?: ReactNode;
}

const StatCard: React.FC<StatCardProps> = ({ title, value, icon: Icon, trend, color = 'blue' }) => {
  const colorClasses = {
    blue: 'bg-blue-100 text-blue-600',
    green: 'bg-green-100 text-green-600',
    amber: 'bg-amber-100 text-amber-600',
    purple: 'bg-purple-100 text-purple-600',
    red: 'bg-red-100 text-red-600',
    pink: 'bg-pink-100 text-pink-600',
  };

  return (
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
        <div className={`p-3 rounded-lg ${colorClasses[color]}`}>
          <Icon size={24} />
        </div>
      </div>
    </div>
  );
};

const QuickAction: React.FC<QuickActionProps> = ({ title, description, icon: Icon, onClick, color = 'blue' }) => {
  const colorClasses = {
    blue: 'bg-blue-50 hover:bg-blue-100 border-blue-200 text-blue-700',
    green: 'bg-green-50 hover:bg-green-100 border-green-200 text-green-700',
    amber: 'bg-amber-50 hover:bg-amber-100 border-amber-200 text-amber-700',
    purple: 'bg-purple-50 hover:bg-purple-100 border-purple-200 text-purple-700',
  };

  return (
    <button
      onClick={onClick}
      className={`w-full text-left p-4 rounded-xl transition-colors border ${colorClasses[color]}`}
    >
      <div className="flex items-center gap-3">
        <Icon size={20} />
        <div>
          <p className="font-medium text-gray-900">{title}</p>
          <p className="text-sm text-gray-600">{description}</p>
        </div>
      </div>
    </button>
  );
};

export default function DashboardTemplate({ 
  title, 
  description, 
  children, 
  stats, 
  quickActions, 
  actionsBar 
}: DashboardTemplateProps) {
  return (
    <AdminLayout>
      <div className="page-content">
        {/* Header */}
        <div className="mb-8">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">{title}</h1>
            <p className="text-gray-600">{description}</p>
          </div>
        </div>

        {/* Stats Overview */}
        {stats && stats.length > 0 && (
          <div className="mb-8">
            <h2 className="text-xl font-semibold text-gray-900 mb-4">Overview</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {stats.map((stat, index) => (
                <StatCard key={index} {...stat} />
              ))}
            </div>
          </div>
        )}

        {/* Actions Bar */}
        {actionsBar && (
          <div className="mb-8">
            {actionsBar}
          </div>
        )}

        {/* Quick Actions */}
        {quickActions && quickActions.length > 0 && (
          <div className="mb-8">
            <h2 className="text-xl font-semibold text-gray-900 mb-4">Quick Actions</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {quickActions.map((action, index) => (
                <QuickAction key={index} {...action} />
              ))}
            </div>
          </div>
        )}

        {/* Main Content */}
        {children && (
          <div className="mb-8">
            {children}
          </div>
        )}
      </div>
    </AdminLayout>
  );
}

export { StatCard, QuickAction };
