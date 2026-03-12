'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAuth } from '@/hooks/useAuth';
import './CollapsibleSidebar.css';
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
        className={`sidebar-item ${isActive ? 'active' : ''}`}
        onClick={() => setIsMobileMenuOpen(false)}
      >
        <Icon size={20} className="sidebar-item-icon" />
        <span className="sidebar-item-label">{item.label}</span>
        {isCollapsedState && (
          <div className="sidebar-item-tooltip">
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
        className="md:hidden fixed top-4 left-4 z-50 p-2 bg-primary text-white rounded-lg shadow-lg hover:bg-primary-dark transition-colors"
      >
        {isMobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
      </button>

      {/* Sidebar */}
      <div className={`sidebar ${isCollapsedState ? 'collapsed' : 'expanded'} ${isMobileMenuOpen ? 'mobile-open' : ''}`}>
        {/* Toggle Button */}
        <div className="sidebar-toggle-container">
          <button
            onClick={handleToggle}
            className="sidebar-toggle-btn"
            title={isCollapsedState ? 'Expand sidebar' : 'Collapse sidebar'}
          >
            {isCollapsedState ? <ChevronRight size={20} /> : <ChevronLeft size={20} />}
          </button>
        </div>

        {/* Logo */}
        <div className="sidebar-logo">
          <div className="sidebar-logo-icon">
            <LayoutDashboard size={24} />
          </div>
          {!isCollapsedState && (
            <div className="sidebar-logo-text">
              <h1 className="sidebar-logo-title">AFRO Admin</h1>
              <p className="sidebar-logo-subtitle">Salon Management</p>
            </div>
          )}
        </div>

        {/* Navigation */}
        <nav className="sidebar-nav">
          {categories.map((category) => {
            const categoryItems = menuItems.filter(item => item.category === category.id);

            return (
              <div key={category.id} className="sidebar-section">
                {renderCategory(category.id)}
                <div className="sidebar-items">
                  {categoryItems.map(renderMenuItem)}
                </div>
              </div>
            );
          })}

          {/* Dashboard (always visible) */}
          <div className="sidebar-section sidebar-section-dashboard">
            <div className="sidebar-items">
              {renderMenuItem(menuItems[0])}
            </div>
          </div>
        </nav>

        {/* Bottom section */}
        <div className="sidebar-bottom">
          {/* User Profile */}
          <Link
            href="/profile"
            className="sidebar-user-profile"
            onClick={() => setIsMobileMenuOpen(false)}
          >
            <div className="sidebar-user-avatar">
              <User size={20} />
            </div>
            {!isCollapsedState && (
              <div className="sidebar-user-info">
                <p className="sidebar-user-name">Admin User</p>
                <p className="sidebar-user-email">admin@afro.com</p>
              </div>
            )}
          </Link>

          {/* Logout Button */}
          <button
            onClick={handleLogout}
            className="sidebar-logout-btn"
            title="Logout"
          >
            <LogOut size={20} />
            {!isCollapsedState && <span>Logout</span>}
          </button>
        </div>
      </div>

      {/* Mobile overlay */}
      {isMobileMenuOpen && (
        <div
          className="md:hidden fixed inset-0 bg-black bg-opacity-50 z-40"
          onClick={() => setIsMobileMenuOpen(false)}
        />
      )}
    </>
  );
}
