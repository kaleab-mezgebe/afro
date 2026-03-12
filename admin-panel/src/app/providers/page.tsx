'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
import { BarbersService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import {
  Search,
  Filter,
  Download,
  Scissors,
  Eye,
  Edit,
  CheckCircle,
  Ban,
  Star,
  MapPin,
  Calendar,
  Phone,
  Mail,
  TrendingUp,
  Award,
  Users,
  Briefcase,
} from 'lucide-react';
import { useAuth } from '@/hooks/useAuth';

interface Provider {
  id: string;
  name: string;
  email: string;
  phone: string;
  specialty: string;
  rating: number;
  totalBookings: number;
  isActive: boolean;
  createdAt: string;
  address?: string;
}

export default function ProvidersPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [providers, setProviders] = useState<Provider[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [specialtyFilter, setSpecialtyFilter] = useState('all');

  useEffect(() => {
    if (authenticated) {
      loadProviders();
    }
  }, [authenticated]);

  const loadProviders = async () => {
    try {
      const response = await BarbersService.getAll({
        page: 1,
        limit: 50,
        search: searchTerm,
        specialty: undefined,
        status: undefined
      });

      if (response.success && response.data) {
        setProviders(response.data);
      }
    } catch (error) {
      toast.error('Failed to load providers');
      console.error('Providers loading error:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredProviders = providers.filter(provider => {
    const matchesSearch = searchTerm === '' ||
      provider.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      provider.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      provider.specialty.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesSpecialty = specialtyFilter === 'all' || provider.specialty === specialtyFilter;

    return matchesSearch && matchesSpecialty;
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
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Provider Management</h1>
          <p className="text-gray-600">Manage all service providers on your platform</p>
        </div>

        {/* Actions Bar */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4 mb-6 flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
              <input
                type="text"
                placeholder="Search providers..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 bg-gray-50 text-gray-900 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 w-64"
              />
            </div>
            <div className="flex items-center gap-2">
              <Filter size={20} className="text-gray-400" />
              <select
                className="px-4 py-2 bg-white text-gray-700 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500"
                value={specialtyFilter}
                onChange={(e) => setSpecialtyFilter(e.target.value)}
              >
                <option value="all">All Specialties</option>
                <option value="Hair Styling">Hair Styling</option>
                <option value="Beard Grooming">Beard Grooming</option>
                <option value="Hair Coloring">Hair Coloring</option>
                <option value="Skin Care">Skin Care</option>
              </select>
            </div>
          </div>
          <div className="flex items-center gap-4">
            <button className="flex items-center gap-2 px-4 py-2 bg-amber-500 text-white rounded-lg hover:bg-amber-600">
              <Download size={20} />
              <span>Export</span>
            </button>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Total Providers</p>
                <p className="stat-value">{providers.length}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  22% from last month
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
                <p className="stat-label">Active Providers</p>
                <p className="stat-value">{providers.filter(p => p.isActive).length}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  15% from last week
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
                <p className="stat-label">Avg Rating</p>
                <p className="stat-value">{(providers.reduce((acc, p) => acc + p.rating, 0) / providers.length || 0).toFixed(1)}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  0.4 from last month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-purple-100">
                <Star size={24} className="text-purple-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Total Bookings</p>
                <p className="stat-value">{providers.reduce((acc, p) => acc + p.totalBookings, 0)}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  38% from last month
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
                <Users className="text-green-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Add New Provider</p>
                  <p className="text-sm text-gray-600">Register a new provider</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors border border-blue-200">
              <div className="flex items-center gap-3">
                <Download className="text-blue-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Export Providers</p>
                  <p className="text-sm text-gray-600">Download provider data</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-purple-50 hover:bg-purple-100 rounded-xl transition-colors border border-purple-200">
              <div className="flex items-center gap-3">
                <TrendingUp className="text-purple-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Provider Analytics</p>
                  <p className="text-sm text-gray-600">View provider statistics</p>
                </div>
              </div>
            </button>
          </div>
        </div>

        {/* Providers Table */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">All Providers</h3>

            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Provider Name
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Contact
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Specialty
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Rating
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
                  {filteredProviders.map((provider) => (
                    <tr key={provider.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                            <Scissors size={20} className="text-gray-500" />
                          </div>
                          <div className="ml-3">
                            <div className="text-sm font-medium text-gray-900">{provider.name}</div>
                            <div className="text-sm text-gray-500">{provider.email}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{provider.phone}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="px-2 py-1 text-xs bg-gray-100 text-gray-700 rounded-full">
                          {provider.specialty}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center text-sm text-gray-900">
                          <Star size={16} className="text-amber-400 fill-current mr-1" />
                          {provider.rating}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${provider.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                          }`}>
                          {provider.isActive ? 'Active' : 'Inactive'}
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
        </div>
      </div>
    </AdminLayout>
  );
}
