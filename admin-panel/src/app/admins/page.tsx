'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
import {
  Shield,
  Phone,
  Mail,
  Calendar,
  Eye,
  Edit,
  CheckCircle,
  Ban,
  Search,
  Filter,
  Download,
  Users,
  TrendingUp,
  Award,
  Clock,
  Crown,
  Key
} from 'lucide-react';
import { AdminsService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';

interface Admin {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: string;
  permissions: string[];
  isActive: boolean;
  lastLogin: string;
  createdAt: string;
}

export default function AdminsPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [admins, setAdmins] = useState<Admin[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState('all');

  useEffect(() => {
    if (authenticated) {
      loadAdmins();
    }
  }, [authenticated]);

  const loadAdmins = async () => {
    try {
      const response = await AdminsService.getAll({
        page: 1,
        limit: 50,
        search: searchTerm,
        role: roleFilter === 'all' ? undefined : roleFilter,
        status: undefined
      });

      if (response.success && response.data) {
        setAdmins(response.data);
      }
    } catch (error) {
      toast.error('Failed to load admins');
      console.error('Admins loading error:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredAdmins = admins.filter(admin => {
    const matchesSearch = searchTerm === '' ||
      admin.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      admin.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      admin.role.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesRole = roleFilter === 'all' || admin.role === roleFilter;

    return matchesSearch && matchesRole;
  });

  if (authLoading || loading) {
    return (
      <AdminLayout>
        <div className="page-content">
          <div className="flex items-center justify-center h-64">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-amber-500"></div>
          </div>
        </div>
      </AdminLayout>
    );
  }

  if (!authenticated) {
    return (
      <AdminLayout>
        <div className="page-content">
          <div className="flex items-center justify-center h-64">
            <div className="text-gray-500">Please login to access this page.</div>
          </div>
        </div>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout>
      <div className="page-content">
        {/* Creative Admin Control Center Header */}
        <div className="bg-gradient-to-r from-slate-700 via-gray-700 to-zinc-700 rounded-3xl p-8 mb-8 text-white shadow-2xl">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="text-4xl font-bold mb-2 flex items-center gap-3">
                <Shield className="fill-white" size={36} />
                Admin Control Center
              </h1>
              <p className="text-gray-300 text-lg">System administrators and guardians</p>
            </div>
            <div className="text-center">
              <div className="text-5xl font-bold text-yellow-300">{admins.length}</div>
              <div className="text-gray-300">System Admins</div>
            </div>
          </div>

          {/* Admin Roles Preview */}
          <div className="flex gap-3 justify-center">
            {['Super Admin', 'Admin', 'Finance', 'Support'].map((role, index) => (
              <div key={role} className="bg-white/20 backdrop-blur px-4 py-2 rounded-full border border-white/30">
                <span className="text-white font-medium text-sm">{role}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Creative Admin Stats with Authority Theme */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          {/* Total Admins - Authority Style */}
          <div className="bg-gradient-to-br from-slate-50 to-gray-100 rounded-2xl p-6 border border-slate-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center justify-between mb-4">
              <div className="w-16 h-16 bg-slate-700 rounded-2xl flex items-center justify-center shadow-lg">
                <Shield className="text-white" size={28} />
              </div>
              <div className="text-right">
                <div className="text-3xl font-bold text-slate-800">{admins.length}</div>
                <div className="text-slate-600 text-sm">Total</div>
              </div>
            </div>
            <div className="bg-slate-200 rounded-xl p-3">
              <div className="text-slate-800 text-sm font-medium">🛡️ System Guardians</div>
            </div>
          </div>

          {/* Active Admins - Status Style */}
          <div className="bg-gradient-to-br from-green-50 to-emerald-100 rounded-2xl p-6 border border-green-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center justify-between mb-4">
              <div className="w-16 h-16 bg-green-600 rounded-2xl flex items-center justify-center shadow-lg">
                <CheckCircle className="text-white" size={28} />
              </div>
              <div className="text-right">
                <div className="text-3xl font-bold text-green-800">
                  {admins.filter(a => a.isActive).length}
                </div>
                <div className="text-green-600 text-sm">Active</div>
              </div>
            </div>
            <div className="bg-green-200 rounded-xl p-3">
              <div className="text-green-800 text-sm font-medium">✅ On Duty</div>
            </div>
          </div>

          {/* Super Admins - Crown Style */}
          <div className="bg-gradient-to-br from-yellow-50 to-amber-100 rounded-2xl p-6 border border-yellow-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center justify-between mb-4">
              <div className="w-16 h-16 bg-yellow-600 rounded-2xl flex items-center justify-center shadow-lg">
                <Crown className="text-white" size={28} />
              </div>
              <div className="text-right">
                <div className="text-3xl font-bold text-yellow-800">
                  {admins.filter(a => a.role === 'super_admin').length}
                </div>
                <div className="text-yellow-600 text-sm">Super</div>
              </div>
            </div>
            <div className="bg-yellow-200 rounded-xl p-3">
              <div className="text-yellow-800 text-sm font-medium">👑 Supreme Authority</div>
            </div>
          </div>

          {/* Regular Admins - User Style */}
          <div className="bg-gradient-to-br from-blue-50 to-indigo-100 rounded-2xl p-6 border border-blue-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center justify-between mb-4">
              <div className="w-16 h-16 bg-blue-600 rounded-2xl flex items-center justify-center shadow-lg">
                <Users className="text-white" size={28} />
              </div>
              <div className="text-right">
                <div className="text-3xl font-bold text-blue-800">
                  {admins.filter(a => a.role === 'admin').length}
                </div>
                <div className="text-blue-600 text-sm">Regular</div>
              </div>
            </div>
            <div className="bg-blue-200 rounded-xl p-3">
              <div className="text-blue-800 text-sm font-medium">👥 Team Members</div>
            </div>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Filter size={20} className="text-gray-400" />
          <select
            className="px-4 py-2 bg-white text-gray-700 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500"
            value={roleFilter}
            onChange={(e) => setRoleFilter(e.target.value)}
          >
            <option value="all">All Roles</option>
            <option value="Super Admin">Super Admin</option>
            <option value="Content Manager">Content Manager</option>
            <option value="Support Admin">Support Admin</option>
          </select>
        </div>
      </div>
      <div className="flex items-center gap-4">
        <button className="flex items-center gap-2 px-4 py-2 bg-amber-500 text-white rounded-lg hover:bg-amber-600">
          <Download size={20} />
          <span>Export</span>
        </button>
      </div>



      {/* Stats Cards */}
      < div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8" >
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Total Admins</p>
              <p className="stat-value">{admins.length}</p>
              <div className="stat-change positive">
                <TrendingUp size={12} />
                2 new this month
              </div>
            </div>
            <div className="p-3 rounded-lg bg-blue-100">
              <Shield size={24} className="text-blue-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Active Admins</p>
              <p className="stat-value">{admins.filter(a => a.isActive).length}</p>
              <div className="stat-change positive">
                <TrendingUp size={12} />
                1 activated this week
              </div>
            </div>
            <div className="p-3 rounded-lg bg-green-100">
              <CheckCircle size={24} className="text-green-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Super Admins</p>
              <p className="stat-value">{admins.filter(a => a.role === 'Super Admin').length}</p>
              <div className="stat-change negative">
                <TrendingUp size={12} />
                No change
              </div>
            </div>
            <div className="p-3 rounded-lg bg-purple-100">
              <Key size={24} className="text-purple-600" />
            </div>
          </div>
        </div>
        <div className="stat-card">
          <div className="flex items-center justify-between">
            <div>
              <p className="stat-label">Today Logins</p>
              <p className="stat-value">{admins.filter(a => {
                const lastLogin = new Date(a.lastLogin);
                const today = new Date();
                return lastLogin.toDateString() === today.toDateString();
              }).length}</p>
              <div className="stat-change positive">
                <TrendingUp size={12} />
                25% from yesterday
              </div>
            </div>
            <div className="p-3 rounded-lg bg-amber-100">
              <Clock size={24} className="text-amber-600" />
            </div>
          </div>
        </div>
      </div >

      {/* Quick Actions */}
      < div className="mb-8" >
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Quick Actions</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <button className="w-full text-left p-4 bg-green-50 hover:bg-green-100 rounded-xl transition-colors border border-green-200">
            <div className="flex items-center gap-3">
              <Shield className="text-green-700" size={20} />
              <div>
                <p className="font-medium text-gray-900">Add New Admin</p>
                <p className="text-sm text-gray-600">Create a new admin account</p>
              </div>
            </div>
          </button>
          <button className="w-full text-left p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors border border-blue-200">
            <div className="flex items-center gap-3">
              <Download className="text-blue-700" size={20} />
              <div>
                <p className="font-medium text-gray-900">Export Admins</p>
                <p className="text-sm text-gray-600">Download admin data</p>
              </div>
            </div>
          </button>
          <button className="w-full text-left p-4 bg-purple-50 hover:bg-purple-100 rounded-xl transition-colors border border-purple-200">
            <div className="flex items-center gap-3">
              <TrendingUp className="text-purple-700" size={20} />
              <div>
                <p className="font-medium text-gray-900">Admin Analytics</p>
                <p className="text-sm text-gray-600">View admin statistics</p>
              </div>
            </div>
          </button>
        </div>
      </div >

      {/* Admins Table */}
      < div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden" >
        <div className="p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">All Admins</h3>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-200">
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Admin Name
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Role
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Permissions
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Last Login
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filteredAdmins.map((admin) => (
                  <tr key={admin.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                          <Shield size={20} className="text-gray-500" />
                        </div>
                        <div className="ml-3">
                          <div className="text-sm font-medium text-gray-900">{admin.name}</div>
                          <div className="text-sm text-gray-500">{admin.email}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 text-xs rounded-full ${admin.role === 'Super Admin' ? 'bg-purple-100 text-purple-800' :
                        admin.role === 'Content Manager' ? 'bg-blue-100 text-blue-800' :
                          'bg-green-100 text-green-800'
                        }`}>
                        {admin.role}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex flex-wrap gap-1">
                        {admin.permissions.map((permission, index) => (
                          <span key={index} className="px-2 py-1 text-xs bg-gray-100 text-gray-700 rounded">
                            {permission}
                          </span>
                        ))}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">
                        {new Date(admin.lastLogin).toLocaleDateString()}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${admin.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                        }`}>
                        {admin.isActive ? 'Active' : 'Inactive'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex items-center gap-2">
                        <button className="text-gray-600 hover:text-gray-900" title="View">
                          <Eye size={16} />
                        </button>
                        <button className="text-gray-600 hover:text-gray-900" title="Edit">
                          <Edit size={16} />
                        </button>
                        <button className="text-red-600 hover:text-red-900" title="Deactivate">
                          <Ban size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div >
    </AdminLayout >
  );
}
