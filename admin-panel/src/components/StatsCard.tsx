'use client';

import { ReactNode } from 'react';
import { cn, responsive } from '@/styles/design-system';
import { LucideIcon } from 'lucide-react';

interface StatsCardProps {
  title: string;
  value: string | number;
  change?: string;
  changeType?: 'increase' | 'decrease' | 'neutral';
  icon?: LucideIcon;
  description?: string;
  loading?: boolean;
  className?: string;
}

export default function StatsCard({
  title,
  value,
  change,
  changeType = 'neutral',
  icon: Icon,
  description,
  loading = false,
  className = ''
}: StatsCardProps) {
  if (loading) {
    return (
      <div className={cn(
        'bg-white border border-gray-200 overflow-hidden transition-all duration-200',
        responsive.className(
          'rounded-lg p-3',
          'rounded-xl p-4',
          'rounded-xl p-5'
        ),
        className
      )}>
        <div className="animate-pulse">
          <div className="space-y-2">
            <div className={cn(
              'bg-gray-200 rounded',
              responsive.className('h-3 w-1/2', 'h-3 w-1/2', 'h-4 w-1/3')
            )}></div>
            <div className={cn(
              'bg-gray-200 rounded',
              responsive.className('h-6 w-3/4', 'h-7 w-3/4', 'h-8 w-3/4')
            )}></div>
            <div className={cn(
              'bg-gray-200 rounded',
              responsive.className('h-3 w-1/3', 'h-3 w-1/3', 'h-3 w-1/4')
            )}></div>
          </div>
        </div>
      </div>
    );
  }

  const getChangeColor = () => {
    switch (changeType) {
      case 'increase':
        return 'text-green-600 bg-green-50';
      case 'decrease':
        return 'text-red-600 bg-red-50';
      default:
        return 'text-gray-600 bg-gray-50';
    }
  };

  const getChangeIcon = () => {
    if (changeType === 'increase') return '↗';
    if (changeType === 'decrease') return '↘';
    return '→';
  };

  return (
    <div className={cn(
      'bg-white border border-gray-200 overflow-hidden transition-all duration-200 hover:shadow-md hover:-translate-y-1',
      responsive.className(
        'rounded-lg p-3',
        'rounded-xl p-4',
        'rounded-xl p-5'
      ),
      className
    )}>
      {/* Header */}
      <div className={cn(
        'flex items-start justify-between',
        responsive.className('gap-2 mb-3', 'gap-3 mb-4', 'gap-3 mb-4')
      )}>
        <div className="flex-1 min-w-0">
          <h3 className={cn(
            'font-medium text-gray-600 truncate',
            responsive.className('text-xs mb-1', 'text-sm mb-1', 'text-sm mb-1')
          )}>
            {title}
          </h3>
          <p className={cn(
            'font-bold text-gray-900 truncate',
            responsive.className('text-lg', 'text-xl', 'text-2xl')
          )}>
            {value}
          </p>
        </div>
        {Icon && (
          <div className={cn(
            'flex items-center justify-center bg-orange-50 rounded-lg flex-shrink-0',
            responsive.className('w-8 h-8', 'w-9 h-9', 'w-10 h-10')
          )}>
            <Icon
              size={20}
              className="text-orange-500"
            />
          </div>
        )}
      </div>

      {/* Change indicator */}
      {change && (
        <div className={cn(
          'flex items-center',
          responsive.className('space-x-1', 'space-x-2', 'space-x-2')
        )}>
          <span className={cn(
            'inline-flex items-center font-medium rounded-full',
            getChangeColor(),
            responsive.className('px-2 py-0.5 text-xs', 'px-2 py-1 text-xs', 'px-3 py-1 text-sm')
          )}>
            <span className="mr-1">{getChangeIcon()}</span>
            {change}
          </span>
        </div>
      )}

      {/* Description */}
      {description && (
        <p className={cn(
          'text-gray-500 mt-2 line-clamp-2',
          responsive.className('text-xs', 'text-xs', 'text-sm')
        )}>
          {description}
        </p>
      )}
    </div>
  );
}
