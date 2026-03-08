'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  FiHome, 
  FiUsers, 
  FiUserCheck, 
  FiCalendar, 
  FiBarChart2, 
  FiSettings,
  FiLogOut
} from 'react-icons/fi';
import { getAuth, signOut } from 'firebase/auth';
import { app } from '@/lib/firebase';
import toast from 'react-hot-toast';

const menuItems = [
  { name: 'Dashboard', href: '/dashboard', icon: FiHome },
  { name: 'Users', href: '/users', icon: FiUsers },
  { name: 'Providers', href: '/providers', icon: FiUserCheck },
  { name: 'Customers', href: '/customers', icon: FiUsers },
  { name: 'Appointments', href: '/appointments', icon: FiCalendar },
  { name: 'Analytics', href: '/analytics', icon: FiBarChart2 },
  { name: 'Settings', href: '/settings', icon: FiSettings },
];

export default function Sidebar() {
  const pathname = usePathname();

  const handleLogout = async () => {
    try {
      const auth = getAuth(app);
      await signOut(auth);
      toast.success('Logged out successfully');
    } catch (error) {
      toast.error('Logout failed');
    }
  };

  return (
    <div className="flex flex-col w-64 bg-gray-800 min-h-screen">
      <div className="flex items-center justify-center h-16 bg-gray-900">
        <span className="text-white text-xl font-bold">AFRO Admin</span>
      </div>
      
      <nav className="flex-1 px-2 py-4 space-y-1">
        {menuItems.map((item) => {
          const Icon = item.icon;
          const isActive = pathname === item.href;
          
          return (
            <Link
              key={item.name}
              href={item.href}
              className={`flex items-center px-4 py-3 text-sm font-medium rounded-md transition-colors ${
                isActive
                  ? 'bg-gray-900 text-white'
                  : 'text-gray-300 hover:bg-gray-700 hover:text-white'
              }`}
            >
              <Icon className="mr-3 h-5 w-5" />
              {item.name}
            </Link>
          );
        })}
      </nav>

      <div className="p-4 border-t border-gray-700">
        <button
          onClick={handleLogout}
          className="flex items-center w-full px-4 py-3 text-sm font-medium text-gray-300 rounded-md hover:bg-gray-700 hover:text-white transition-colors"
        >
          <FiLogOut className="mr-3 h-5 w-5" />
          Logout
        </button>
      </div>
    </div>
  );
}
