'use client';

import { useState, useEffect } from 'react';
import { ReactNode } from 'react';
import { cn } from '@/styles/design-system';
import CollapsibleSidebar from './CollapsibleSidebar';

interface AdminLayoutProps {
  children: ReactNode;
}

export default function AdminLayout({ children }: AdminLayoutProps) {
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(false);

  // Load saved state from localStorage
  useEffect(() => {
    const savedState = localStorage.getItem('sidebar-collapsed');
    if (savedState !== null) {
      setIsSidebarCollapsed(JSON.parse(savedState));
    }
  }, []);

  // Save state to localStorage when it changes
  useEffect(() => {
    localStorage.setItem('sidebar-collapsed', JSON.stringify(isSidebarCollapsed));
  }, [isSidebarCollapsed]);

  const handleSidebarToggle = () => {
    setIsSidebarCollapsed(!isSidebarCollapsed);
  };

  return (
    <div className={cn(
      'min-h-screen bg-gray-50',
      'flex'
    )}>
      <CollapsibleSidebar
        isCollapsed={isSidebarCollapsed}
        onToggle={handleSidebarToggle}
      />
      <main className={cn(
        'flex-1',
        'transition-all duration-300 ease-in-out',
        isSidebarCollapsed ? 'md:ml-4' : 'md:ml-4'
      )}>
        <div className="p-4">
          {children}
        </div>
      </main>
    </div>
  );
}
