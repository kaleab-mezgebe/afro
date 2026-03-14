'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAuth } from '@/hooks/useAuth';
import { cn, getSidebarItemStyles } from '@/styles/design-system';
import {
  LayoutDashboard,
  Users,
  Scissors,
  Calendar,
  CreditCard,
  Star,
  BarChart3,
  Bell,
  FileText,
  Headphones,
  Tag,
  Settings,
  LogOut,
  User,
  Menu,
  X,
  UserPlus,
  Crown,
  Building,
  Store,
  Briefcase,
  MessageSquare,
  DollarSign,
  TrendingUp,
  Shield,
  MapPin,
  ChevronLeft,
  ChevronRight
} from 'lucide-react';

interface MenuItem {
  href: string;
  label: string;
  icon: any;
  category?: string;
}

interface CollapsibleSidebarProps {
  isCollapsed?: boolean;
  onToggle?: () => void;
}

const menuItems: MenuItem[] = [
  // Main Dashboard
  { href: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },

  // People Management Section
  { href: '/customers', label: 'Customers', icon: Users, category: 'people' },
  { href: '/barbers', label: 'Barbers', icon: Scissors, category: 'people' },
  { href: '/beauty-professionals', label: 'Beauty Professionals', icon: Crown, category: 'people' },
  { href: '/salons', label: 'Salon Owners', icon: Store, category: 'people' },
  { href: '/employees', label: 'Employees', icon: Briefcase, category: 'people' },
  { href: '/admins', label: 'Admins', icon: Shield, category: 'people' },

  // Business Management Section
  { href: '/barbershops', label: 'Barbershops', icon: Building, category: 'business' },
  { href: '/beauty-salons', label: 'Beauty Salons', icon: Store, category: 'business' },

  // Operations Section
  { href: '/bookings', label: 'Bookings', icon: Calendar, category: 'operations' },
  { href: '/services', label: 'Services', icon: Scissors, category: 'operations' },
  { href: '/reviews', label: 'Reviews & Ratings', icon: Star, category: 'operations' },

  // Finance Section
  { href: '/transactions', label: 'Transactions', icon: CreditCard, category: 'finance' },
  { href: '/payouts', label: 'Provider Payouts', icon: DollarSign, category: 'finance' },

  // Analytics Section
  { href: '/location-analytics', label: 'Location Analytics', icon: MapPin, category: 'analytics' },
  { href: '/reports', label: 'Reports', icon: FileText, category: 'analytics' },
  { href: '/analytics', label: 'Analytics', icon: BarChart3, category: 'analytics' },

  // Support & Settings
  { href: '/support', label: 'Support Tickets', icon: Headphones, category: 'support' },
  { href: '/promotions', label: 'Promotions', icon: Tag, category: 'support' },
  { href: '/settings', label: 'Settings', icon: Settings, category: 'support' },
];

const categories = [
  { id: 'people', label: 'People Management', icon: Users },
  { id: 'business', label: 'Business Management', icon: Building },
  { id: 'operations', label: 'Operations', icon: Calendar },
  { id: 'finance', label: 'Finance', icon: DollarSign },
  { id: 'analytics', label: 'Analytics', icon: BarChart3 },
  { id: 'support', label: 'Support & Settings', icon: Headphones },
];

export default function CollapsibleSidebar({ isCollapsed = false, onToggle }: CollapsibleSidebarProps) {
  const pathname = usePathname();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isCollapsedState, setIsCollapsedState] = useState(isCollapsed);
  const { logout } = useAuth();

  useEffect(() => {
    setIsCollapsedState(isCollapsed);
  }, [isCollapsed]);

  const handleToggle = () => {
    const newState = !isCollapsedState;
    setIsCollapsedState(newState);
    if (onToggle) {
      onToggle();
    }
  };

  const handleLogout = async () => {
    await logout();
    setIsMobileMenuOpen(false);
  };

  const renderMenuItem = (item: MenuItem) => {
    const Icon = item.icon;
    const isActive = pathname === item.href;

    return (
      <Link
        key={item.href}
        href={item.href}
        className={cn(
          getSidebarItemStyles(isActive),
          'w-full'
        )}
        onClick={() => setIsMobileMenuOpen(false)}
      >
        <Icon size={18} className={cn(
          'flex-shrink-0',
          isActive ? 'text-orange-500' : 'text-gray-400'
        )} />
        {!isCollapsedState && (
          <span className="ml-3">{item.label}</span>
        )}
        {isCollapsedState && (
          <div className="absolute left-full ml-2 px-2 py-1 bg-gray-900 text-white text-xs rounded opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none whitespace-nowrap">
            {item.label}
          </div>
        )}
      </Link>
    );
  };

  const renderCategory = (categoryId: string) => {
    const category = categories.find(cat => cat.id === categoryId);
    if (!category) return null;

    const CategoryIcon = category.icon;

    return (
      <div className="sidebar-category">
        <CategoryIcon size={14} className="sidebar-category-icon" />
        {!isCollapsedState && (
          <span className="sidebar-category-label">{category.label}</span>
        )}
      </div>
    );
  };

  return (
    <>
      {/* Mobile menu button */}
      <button
        onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
        className="md:hidden fixed top-4 left-4 z-50 p-2 bg-orange-500 text-white rounded-lg shadow-lg hover:bg-orange-600 transition-colors"
      >
        {isMobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
      </button>

      {/* Sidebar */}
      <div className={cn(
        'fixed inset-y-0 left-0 z-40 bg-gray-900 transition-all duration-300 ease-in-out md:relative md:inset-0',
        isCollapsedState ? 'w-16' : 'w-64',
        isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'
      )}>
        {/* Toggle Button */}
        <div className="absolute -right-3 top-6">
          <button
            onClick={handleToggle}
            className="hidden md:flex items-center justify-center w-6 h-6 bg-orange-500 text-white rounded-full hover:bg-orange-600 transition-colors"
            title={isCollapsedState ? 'Expand sidebar' : 'Collapse sidebar'}
          >
            {isCollapsedState ? <ChevronRight size={16} /> : <ChevronLeft size={16} />}
          </button>
        </div>

        {/* Logo */}
        <div className="flex items-center p-4 border-b border-gray-800">
          <div className="flex items-center justify-center w-10 h-10 bg-orange-500 rounded-lg">
            <LayoutDashboard size={20} className="text-white" />
          </div>
          {!isCollapsedState && (
            <div className="ml-3">
              <h1 className="text-lg font-semibold text-white">AFRO Admin</h1>
              <p className="text-xs text-gray-400">Salon Management</p>
            </div>
          )}
        </div>

        {/* Navigation */}
        <nav className="flex-1 px-2 py-4 space-y-6 overflow-y-auto">
          {/* Dashboard (always visible) */}
          <div className="space-y-1">
            {renderMenuItem(menuItems[0])}
          </div>

          {categories.map((category) => {
            const categoryItems = menuItems.filter(item => item.category === category.id);

            return (
              <div key={category.id} className="space-y-1">
                {!isCollapsedState && (
                  <div className="px-3 py-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">
                    {category.label}
                  </div>
                )}
                <div className="space-y-1">
                  {categoryItems.map(renderMenuItem)}
                </div>
              </div>
            );
          })}
        </nav>

        {/* Bottom section */}
        <div className="border-t border-gray-800 p-4 space-y-2">
          {/* User Profile */}
          <Link
            href="/profile"
            className={cn(
              'flex items-center p-2 rounded-lg transition-colors group',
              'hover:bg-gray-800'
            )}
            onClick={() => setIsMobileMenuOpen(false)}
          >
            <div className="flex items-center justify-center w-8 h-8 bg-gray-700 rounded-lg">
              <User size={16} className="text-gray-300" />
            </div>
            {!isCollapsedState && (
              <div className="ml-3">
                <p className="text-sm font-medium text-white">Admin User</p>
                <p className="text-xs text-gray-400">admin@afro.com</p>
              </div>
            )}
          </Link>

          {/* Logout Button */}
          <button
            onClick={handleLogout}
            className={cn(
              'flex items-center w-full p-2 rounded-lg transition-colors',
              'text-gray-400 hover:bg-red-900 hover:text-white'
            )}
            title="Logout"
          >
            <LogOut size={18} />
            {!isCollapsedState && <span className="ml-3">Logout</span>}
          </button>
        </div>
      </div>

      {/* Mobile overlay */}
      {isMobileMenuOpen && (
        <div
          className="fixed inset-0 bg-black bg-opacity-50 z-30 md:hidden"
          onClick={() => setIsMobileMenuOpen(false)}
        />
      )}
    </>
  );
}
