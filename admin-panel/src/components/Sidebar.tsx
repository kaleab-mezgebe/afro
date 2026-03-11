'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
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
  X
} from 'lucide-react';

const menuItems = [
  { href: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/users', label: 'Users', icon: Users },
  { href: '/providers', label: 'Providers', icon: Scissors },
  { href: '/customers', label: 'Customers', icon: User },
  { href: '/appointments', label: 'Appointments', icon: Calendar },
  { href: '/services', label: 'Services', icon: Scissors },
  { href: '/payments', label: 'Payments', icon: CreditCard },
  { href: '/reviews', label: 'Reviews', icon: Star },
  { href: '/analytics', label: 'Analytics', icon: BarChart3 },
  { href: '/notifications', label: 'Notifications', icon: Bell },
  { href: '/reports', label: 'Reports', icon: FileText },
  { href: '/support', label: 'Support Tickets', icon: Headphones },
  { href: '/promotions', label: 'Promotions / Coupons', icon: Tag },
  { href: '/settings', label: 'Settings', icon: Settings },
];

export default function Sidebar() {
  const pathname = usePathname();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const handleLogout = () => {
    console.log('Logging out...');
    // Clear auth token, redirect to login, etc.
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
          <div className="px-4 mb-4">
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">Main Menu</p>
          </div>

          {menuItems.slice(0, 6).map((item) => {
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

          <div className="px-4 mb-4 mt-6">
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">Management</p>
          </div>

          {menuItems.slice(6, 11).map((item) => {
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
          <div className="sidebar-user-profile">
            <div className="sidebar-user-avatar">
              <User size={16} className="text-white" />
            </div>
            <div className="sidebar-user-info">
              <p className="sidebar-user-name">Admin User</p>
              <p className="sidebar-user-email">admin@afro.com</p>
            </div>
          </div>

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
