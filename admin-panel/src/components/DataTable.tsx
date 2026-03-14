'use client';

import { ReactNode } from 'react';
import { cn, responsive } from '@/styles/design-system';

interface Column {
  key: string;
  label: string;
  sortable?: boolean;
  width?: string;
  align?: 'left' | 'center' | 'right';
  responsive?: {
    mobile?: boolean;
    tablet?: boolean;
    desktop?: boolean;
  };
}

interface DataTableProps {
  columns: Column[];
  data: any[];
  loading?: boolean;
  empty?: string;
  className?: string;
  children?: (item: any, index: number) => ReactNode;
}

export default function DataTable({
  columns,
  data,
  loading = false,
  empty = 'No data available',
  className = '',
  children
}: DataTableProps) {
  if (loading) {
    return (
      <div className={cn(
        'bg-white border border-gray-200 overflow-hidden',
        responsive.className(
          'rounded-lg',
          'rounded-xl',
          'rounded-xl'
        ),
        className
      )}>
        <div className={responsive.className('p-4', 'p-6', 'p-8')}>
          <div className="space-y-4">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="animate-pulse">
                <div className={cn(
                  'flex space-x-4',
                  responsive.className('flex-col space-y-2', 'flex-row space-x-4', 'flex-row space-x-4')
                )}>
                  {columns.map((column, j) => (
                    <div
                      key={j}
                      className={cn(
                        'bg-gray-200 rounded',
                        responsive.className(
                          'h-3 w-full',
                          column.responsive?.mobile ? 'h-4 w-20' : 'h-4 w-24',
                          column.responsive?.tablet ? 'h-4 w-32' : 'h-4 w-40'
                        )
                      )}
                      style={{ width: column.width || 'auto' }}
                    ></div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  if (data.length === 0) {
    return (
      <div className={cn(
        'bg-white border border-gray-200 overflow-hidden',
        responsive.className(
          'rounded-lg',
          'rounded-xl',
          'rounded-xl'
        ),
        className
      )}>
        <div className={cn(
          'text-center',
          responsive.className('p-6', 'p-8', 'p-10')
        )}>
          <div className={cn(
            'text-gray-400',
            responsive.className('text-sm', 'text-sm', 'text-base')
          )}>
            {empty}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className={cn(
      'bg-white border border-gray-200 overflow-hidden',
      responsive.className(
        'rounded-lg',
        'rounded-xl',
        'rounded-xl'
      ),
      className
    )}>
      {/* Table Header */}
      <div className="bg-gray-50 border-b border-gray-200">
        <div className={cn(
          'flex items-center',
          responsive.className('px-4 py-2', 'px-5 py-3', 'px-6 py-3')
        )}>
          {columns.map((column) => {
            // Hide columns on mobile if not responsive
            const isHiddenOnMobile = column.responsive?.mobile === false;

            return (
              <div
                key={column.key}
                className={cn(
                  'font-semibold text-gray-600 uppercase tracking-wider flex-shrink-0',
                  responsive.className(
                    isHiddenOnMobile ? 'hidden' : 'text-xs',
                    'text-xs',
                    'text-xs'
                  ),
                  column.align === 'center' ? 'text-center' : '',
                  column.align === 'right' ? 'text-right' : '',
                  !column.align ? 'text-left' : ''
                )}
                style={{ width: column.width || 'auto' }}
              >
                {column.label}
              </div>
            );
          })}
        </div>
      </div>

      {/* Table Body */}
      <div className="divide-y divide-gray-200">
        {data.map((item, index) => (
          <div
            key={index}
            className={cn(
              'flex items-center transition-colors',
              responsive.className(
                'px-4 py-3 flex-col space-y-2',
                'px-5 py-4 flex-row',
                'px-6 py-4 flex-row'
              ),
              'hover:bg-gray-50',
              children ? 'cursor-pointer' : ''
            )}
          >
            {children ? (
              children(item, index)
            ) : (
              columns.map((column) => {
                const isHiddenOnMobile = column.responsive?.mobile === false;

                return (
                  <div
                    key={column.key}
                    className={cn(
                      'text-gray-900 flex-shrink-0',
                      responsive.className(
                        isHiddenOnMobile ? 'hidden' : 'text-sm',
                        'text-sm',
                        'text-sm'
                      ),
                      column.align === 'center' ? 'text-center' : '',
                      column.align === 'right' ? 'text-right' : '',
                      !column.align ? 'text-left' : ''
                    )}
                    style={{ width: column.width || 'auto' }}
                  >
                    {item[column.key]}
                  </div>
                );
              })
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
