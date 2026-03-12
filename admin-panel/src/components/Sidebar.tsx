'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAuth } from '@/hooks/useAuth';
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
  MapPin
} from 'lucide-react';

const menuItems = [
  // Main Dashboard
  { href: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },

  // People Management Section
  { href: '/customers', label: 'Customers', icon: User, category: 'people' },
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

export default function Sidebar() {
  const pathname = usePathname();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const { logout } = useAuth();

  const handleLogout = async () => {
    await logout();
    setIsMobileMenuOpen(false);
  };

  return (
    <>
      {/* Mobile menu button */}
      <button
        onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
        className="md:hidden fixed top-4 left-4 z-50 p-2 bg-primary text-white rounded-lg shadow-lg"
      >
        {isMobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
      </button>

      {/* Sidebar */}
      <div className={`sidebar ${isMobileMenuOpen ? 'open' : ''}`}>
        {/* Logo */}
        <div className="p-6 border-b border-gray-700">
          <h1 className="text-2xl font-bold text-white">AFRO Admin</h1>
          <p className="text-gray-400 text-sm mt-1">Salon Management System</p>
        </div>

        {/* Navigation */}
        <nav className="py-4">
          {/* People Management */}
          <div className="px-4 mb-4">
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider flex items-center gap-2">
              <Users size={12} />
              People Management
            </p>
          </div>
          {menuItems.filter(item => item.category === 'people').map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href;

            return (
              <Link
                key={item.href}
                href={item.href}
                className={`sidebar-item ${isActive ? 'active' : ''}`}
                onClick={() => setIsMobileMenuOpen(false)}
              >
                <Icon size={18} />
                <span>{item.label}</span>
              </Link>
            );
          })}

          {/* Business Management */}
          <div className="px-4 mb-4 mt-6">
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider flex items-center gap-2">
              <Building size={12} />
              Business Management
            </p>
          </div>
          {menuItems.filter(item => item.category === 'business').map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href;

            return (
              <Link
                key={item.href}
                href={item.href}
                className={`sidebar-item ${isActive ? 'active' : ''}`}
                onClick={() => setIsMobileMenuOpen(false)}
              >
                <Icon size={18} />
                <span>{item.label}</span>
              </Link>
            );
          })}

          {/* Operations */}
          <div className="px-4 mb-4 mt-6">
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider flex items-center gap-2">
              <Calendar size={12} />
              Operations
            </p>
          </div>
          {menuItems.filter(item => item.category === 'operations').map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href;

            return (
              <Link
                key={item.href}
                href={item.href}
                className={`sidebar-item ${isActive ? 'active' : ''}`}
                onClick={() => setIsMobileMenuOpen(false)}
              >
                <Icon size={18} />
                <span>{item.label}</span>
              </Link>
            );
          })}

          {/* Finance */}
          <div className="px-4 mb-4 mt-6">
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider flex items-center gap-2">
              <DollarSign size={12} />
              Finance
            </p>
          </div>
          {menuItems.filter(item => item.category === 'finance').map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href;

            return (
              <Link
                key={item.href}
                href={item.href}
                className={`sidebar-item ${isActive ? 'active' : ''}`}
                onClick={() => setIsMobileMenuOpen(false)}
              >
                <Icon size={18} />
                <span>{item.label}</span>
              </Link>
            );
          })}

          {/* Analytics & Reports */}
          <div className="px-4 mb-4 mt-6">
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider flex items-center gap-2">
              <BarChart3 size={12} />
              Analytics & Reports
            </p>
          </div>
          {menuItems.filter(item => item.category === 'analytics').map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href;

            return (
              <Link
                key={item.href}
                href={item.href}
                className={`sidebar-item ${isActive ? 'active' : ''}`}
                onClick={() => setIsMobileMenuOpen(false)}
              >
                <Icon size={18} />
                <span>{item.label}</span>
              </Link>
            );
          })}

          {/* Support & Settings */}
          <div className="px-4 mb-4 mt-6">
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider flex items-center gap-2">
              <Headphones size={12} />
              Support & Settings
            </p>
          </div>
          {menuItems.filter(item => item.category === 'support').map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href;

            return (
              <Link
                key={item.href}
                href={item.href}
                className={`sidebar-item ${isActive ? 'active' : ''}`}
                onClick={() => setIsMobileMenuOpen(false)}
              >
                <Icon size={18} />
                <span>{item.label}</span>
              </Link>
            );
          })}

          {/* Dashboard (always visible) */}
          <div className="px-4 mb-4 mt-6 border-t border-gray-700 pt-4">
            <Link
              href="/dashboard"
              className={`sidebar-item ${pathname === '/dashboard' ? 'active' : ''}`}
              onClick={() => setIsMobileMenuOpen(false)}
            >
              <LayoutDashboard size={18} />
              <span>Dashboard</span>
            </Link>
          </div>

          <div className="px-4 mb-4 mt-6">
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">System</p>
          </div>

          {menuItems.slice(11).map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href;

            return (
              <Link
                key={item.href}
                href={item.href}
                className={`sidebar-item ${isActive ? 'active' : ''}`}
                onClick={() => setIsMobileMenuOpen(false)}
              >
                <Icon size={20} />
                <span>{item.label}</span>
              </Link>
            );
          })}
        </nav>

        {/* Bottom section - Fixed */}
        <div className="sidebar-bottom">
          {/* User Profile */}
          <Link
            href="/profile"
            className="sidebar-user-profile"
            onClick={() => setIsMobileMenuOpen(false)}
          >
            <div className="sidebar-user-avatar">
              <User size={16} className="text-white" />
            </div>
            <div className="sidebar-user-info">
              <p className="sidebar-user-name">Admin User</p>
              <p className="sidebar-user-email">admin@afro.com</p>
            </div>
          </Link>

          {/* Logout Button */}
          <button
            onClick={handleLogout}
            className="sidebar-logout-btn"
          >
            <LogOut size={18} />
            <span>Logout</span>
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
