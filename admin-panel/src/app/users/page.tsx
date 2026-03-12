'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
import { UsersService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';
import {
  Search,
  Filter,
  Download,
  UserPlus,
  Eye,
  Edit,
  CheckCircle,
  Trash2,
  Users,
  TrendingUp,
  Calendar,
  Briefcase,
} from 'lucide-react';

interface User {
  id: string;
  name: string;
  email: string;
  phone?: string;
  role: string;
  isActive: boolean;
  createdAt: string;
}

export default function UsersPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage] = useState(10);
  const [totalItems, setTotalItems] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [statusFilter, setStatusFilter] = useState('all');

  useEffect(() => {
    if (authenticated) {
      loadUsers();
    }
  }, [authenticated]);

  const loadUsers = async () => {
    try {
      const response = await UsersService.getAll({
        page: currentPage,
        limit: itemsPerPage,
        search: searchTerm,
        status: statusFilter,
        sortBy: 'createdAt',
        sortOrder: 'desc'
      });

      if (response.success && response.data) {
        setUsers(response.data);
        setTotalItems(response.total);
        setTotalPages(response.totalPages);
      }
    } catch (error) {
      toast.error('Failed to load users');
    } finally {
      setLoading(false);
    }
  };

  const filteredUsers = users.filter(user => {
    const matchesSearch = searchTerm === '' ||
      user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.email.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesRole = roleFilter === 'all' || user.role === roleFilter;

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
        {/* Creative Header with Avatar Grid */}
        <div className="bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-600 rounded-3xl p-8 mb-8 text-white shadow-2xl">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="text-4xl font-bold mb-2 flex items-center gap-3">
                <Users className="fill-white" size={36} />
                User Universe
              </h1>
              <p className="text-indigo-100 text-lg">Manage your community of beauty enthusiasts</p>
            </div>
            <div className="text-center">
              <div className="text-5xl font-bold text-yellow-300">{users.length}</div>
              <div className="text-indigo-100">Total Members</div>
            </div>
          </div>
        </div>
        <div className="flex items-center gap-4">
          <button className="flex items-center gap-2 px-4 py-2 bg-amber-500 text-white rounded-lg hover:bg-amber-600">
            <Download size={20} />
            <span>Export</span>
          </button>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Total Users</p>
                <p className="stat-value">{users.length}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  15% from last month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-blue-100">
                <Users size={24} className="text-blue-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Active Users</p>
                <p className="stat-value">{users.filter(u => u.isActive).length}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  8% from last week
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
                <p className="stat-label">Staff Members</p>
                <p className="stat-value">{users.filter(u => u.role === 'staff').length}</p>
                <div className="stat-change negative">
                  <TrendingUp size={12} />
                  3% from last month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-purple-100">
                <Briefcase size={24} className="text-purple-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">New This Week</p>
                <p className="stat-value">{users.filter(u => {
                  const createdAt = new Date(u.createdAt);
                  const weekAgo = new Date();
                  weekAgo.setDate(weekAgo.getDate() - 7);
                  return createdAt > weekAgo;
                }).length}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  22% from last week
                </div>
              </div>
              <div className="p-3 rounded-lg bg-amber-100">
                <Calendar size={24} className="text-amber-600" />
              </div>
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="mb-8">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">Quick Actions</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <button className="w-full text-left p-4 bg-green-50 hover:bg-green-100 rounded-xl transition-colors border border-green-200">
              <div className="flex items-center gap-3">
                <UserPlus className="text-green-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Add New User</p>
                  <p className="text-sm text-gray-600">Create a new user account</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors border border-blue-200">
              <div className="flex items-center gap-3">
                <Download className="text-blue-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Export Users</p>
                  <p className="text-sm text-gray-600">Download user data as CSV</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-purple-50 hover:bg-purple-100 rounded-xl transition-colors border border-purple-200">
              <div className="flex items-center gap-3">
                <TrendingUp className="text-purple-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">User Analytics</p>
                  <p className="text-sm text-gray-600">View user statistics and trends</p>
                </div>
              </div>
            </button>
          </div>
        </div>

        {/* Users Table */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">All Users</h3>

            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Name
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Email
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Role
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
                  {filteredUsers.map((user) => (
                    <tr key={user.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                            <Users size={20} className="text-gray-500" />
                          </div>
                          <div className="ml-3">
                            <div className="text-sm font-medium text-gray-900">{user.name}</div>
                            <div className="text-sm text-gray-500">{user.email}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{user.phone || 'N/A'}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${user.role === 'admin' ? 'bg-purple-100 text-purple-800' :
                          user.role === 'staff' ? 'bg-blue-100 text-blue-800' :
                            'bg-green-100 text-green-800'
                          }`}>
                          {user.role}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${user.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                          }`}>
                          {user.isActive ? 'Active' : 'Inactive'}
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
                          <button className="text-red-600 hover:text-red-900" title="Delete">
                            <Trash2 size={16} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
