'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
import {
  Scissors,
  Phone,
  Mail,
  Calendar,
  Eye,
  Ban,
  Download,
  Search,
  Filter,
  CheckCircle,
  XCircle,
  Clock,
  Star,
  TrendingUp,
  TrendingDown,
  AlertCircle,
  X,
  MapPin,
  UserPlus,
  Trash2,
  Edit,
  Award,
  DollarSign,
  Users,
  Camera,
  Shield,
} from 'lucide-react';
import { BarbersService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';

interface Barber {
  id: string;
  name: string;
  email: string;
  phone: string;
  shop: string;
  rating: number;
  servicesCount: number;
  totalBookings?: number;
  status: 'active' | 'suspended' | 'pending_approval';
  isActive: boolean;
  joinedDate: string;
  specialization?: string;
  experienceYears?: number;
  lastLogin?: string;
}

export default function BarbersPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [barbers, setBarbers] = useState<Barber[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [selectedBarber, setSelectedBarber] = useState<Barber | null>(null);
  const [showViewModal, setShowViewModal] = useState(false);

  useEffect(() => {
    if (authenticated) {
      loadBarbers();
    }
  }, [authenticated]);

  const loadBarbers = async () => {
    try {
      const response = await BarbersService.getAll({
        page: currentPage,
        limit: 10,
        search: searchTerm,
        status: statusFilter,
        sortBy: 'createdAt',
        sortOrder: 'desc'
      });

      if (response.success && response.data) {
        setBarbers(response.data);
      }
    } catch (error) {
      toast.error('Failed to load barbers');
      console.error('Barbers loading error:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredBarbers = barbers.filter(barber => {
    const matchesSearch = searchTerm === '' ||
      barber.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      barber.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      barber.shop.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesStatus = statusFilter === 'all' || barber.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  const handleView = (barber: Barber) => {
    setSelectedBarber(barber);
    setShowViewModal(true);
  };

  const handleExport = () => {
    toast.success('Barbers data exported successfully');
  };

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

  const totalPages = 1;
  const paginatedBarbers = filteredBarbers;

  return (
    <AdminLayout>
      <div className="page-content">
        {/* Creative Barbers Hub Header */}
        <div className="bg-gradient-to-r from-amber-600 via-orange-600 to-red-600 rounded-3xl p-8 mb-8 text-white shadow-2xl">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="text-4xl font-bold mb-2 flex items-center gap-3">
                <Scissors className="fill-white" size={36} />
                Barbers Hub
              </h1>
              <p className="text-amber-100 text-lg">Master craftsmen of the traditional art</p>
            </div>
            <div className="text-center">
              <div className="text-5xl font-bold text-yellow-300">{barbers.length}</div>
              <div className="text-amber-100">Expert Barbers</div>
            </div>
          </div>

          {/* Barber Tools Preview */}
          <div className="flex gap-4 justify-center">
            <div className="bg-white/20 backdrop-blur rounded-xl p-3 border border-white/30">
              <Scissors className="text-white" size={24} />
            </div>
            <div className="bg-white/20 backdrop-blur rounded-xl p-3 border border-white/30">
              <Shield className="text-white" size={24} />
            </div>
            <div className="bg-white/20 backdrop-blur rounded-xl p-3 border border-white/30">
              <Star className="text-white" size={24} />
            </div>
          </div>
        </div>

        {/* Creative Barber Stats with Professional Theme */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          {/* Total Barbers - Professional Style */}
          <div className="bg-gradient-to-br from-amber-50 to-orange-100 rounded-2xl p-6 border border-amber-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center justify-between mb-4">
              <div className="w-16 h-16 bg-amber-500 rounded-2xl flex items-center justify-center shadow-lg">
                <Scissors className="text-white" size={28} />
              </div>
              <div className="text-right">
                <div className="text-3xl font-bold text-amber-800">{barbers.length}</div>
                <div className="text-amber-600 text-sm">Total</div>
              </div>
            </div>
            <div className="bg-amber-200 rounded-xl p-3">
              <div className="text-amber-800 text-sm font-medium">💈 Master Barbers</div>
            </div>
          </div>

          {/* Active Barbers - Status Style */}
          <div className="bg-gradient-to-br from-green-50 to-emerald-100 rounded-2xl p-6 border border-green-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center justify-between mb-4">
              <div className="w-16 h-16 bg-green-500 rounded-2xl flex items-center justify-center shadow-lg">
                <CheckCircle className="text-white" size={28} />
              </div>
              <div className="text-right">
                <div className="text-3xl font-bold text-green-800">
                  {barbers.filter(b => b.isActive).length}
                </div>
                <div className="text-green-600 text-sm">Active</div>
              </div>
            </div>
            <div className="bg-green-200 rounded-xl p-3">
              <div className="text-green-800 text-sm font-medium">✅ Available Now</div>
            </div>
          </div>

          {/* Average Rating - Star Style */}
          <div className="bg-gradient-to-br from-yellow-50 to-amber-100 rounded-2xl p-6 border border-yellow-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center justify-between mb-4">
              <div className="w-16 h-16 bg-yellow-500 rounded-2xl flex items-center justify-center shadow-lg">
                <Star className="text-white" size={28} />
              </div>
              <div className="text-right">
                <div className="text-3xl font-bold text-yellow-800">
                  {(barbers.reduce((acc, b) => acc + b.rating, 0) / barbers.length || 0).toFixed(1)}
                </div>
                <div className="text-yellow-600 text-sm">Avg Rating</div>
              </div>
            </div>
            <div className="bg-yellow-200 rounded-xl p-3">
              <div className="text-yellow-800 text-sm font-medium">⭐ Top Rated</div>
            </div>
          </div>

          {/* Total Bookings - Calendar Style */}
          <div className="bg-gradient-to-br from-blue-50 to-indigo-100 rounded-2xl p-6 border border-blue-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center justify-between mb-4">
              <div className="w-16 h-16 bg-blue-500 rounded-2xl flex items-center justify-center shadow-lg">
                <Calendar className="text-white" size={28} />
              </div>
              <div className="text-right">
                <div className="text-3xl font-bold text-blue-800">
                  {barbers.reduce((acc, b) => acc + (b.totalBookings || 0), 0)}
                </div>
                <div className="text-blue-600 text-sm">Bookings</div>
              </div>
            </div>
            <div className="bg-blue-200 rounded-xl p-3">
              <div className="text-blue-800 text-sm font-medium">📅 Total Services</div>
            </div>
          </div>
        </div>

        {/* Filters and Actions */}
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-8">
          <div className="flex items-center gap-4">
            <Filter size={20} className="text-gray-400" />
            <select
              className="px-4 py-2 bg-white text-gray-700 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
            >
              <option value="all">All Status</option>
              <option value="active">Active</option>
              <option value="suspended">Suspended</option>
              <option value="pending_approval">Pending Approval</option>
            </select>
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
                <p className="stat-label">Total Barbers</p>
                <p className="stat-value">{barbers.length}</p>
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
                <p className="stat-label">Active Barbers</p>
                <p className="stat-value">{barbers.filter(b => b.isActive).length}</p>
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
                <p className="stat-label">Avg Rating</p>
                <p className="stat-value">{(barbers.reduce((acc, b) => acc + b.rating, 0) / barbers.length || 0).toFixed(1)}</p>
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
                <p className="stat-label">Total Services</p>
                <p className="stat-value">{barbers.reduce((acc, b) => acc + b.servicesCount, 0)}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  22% from last month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-amber-100">
                <Scissors size={24} className="text-amber-600" />
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
                <UserPlus className="text-green-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Add New Barber</p>
                  <p className="text-sm text-gray-600">Register a new barber</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors border border-blue-200">
              <div className="flex items-center gap-3">
                <Download className="text-blue-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Export Barbers</p>
                  <p className="text-sm text-gray-600">Download barber data</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-purple-50 hover:bg-purple-100 rounded-xl transition-colors border border-purple-200">
              <div className="flex items-center gap-3">
                <TrendingUp className="text-purple-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Barber Analytics</p>
                  <p className="text-sm text-gray-600">View barber statistics</p>
                </div>
              </div>
            </button>
          </div>
        </div >

        {/* Barbers Table */}
        < div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden" >
          <div className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">All Barbers</h3>

            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Barber Name
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Shop
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Rating
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Services
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Specialization
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
                  {paginatedBarbers.map((barber) => (
                    <tr key={barber.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                            <Scissors size={20} className="text-gray-500" />
                          </div>
                          <div className="ml-3">
                            <div className="text-sm font-medium text-gray-900">{barber.name}</div>
                            <div className="text-sm text-gray-500">{barber.email}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{barber.shop}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <Star size={16} className="text-amber-400 fill-current mr-1" />
                          <span className="text-sm font-medium text-gray-900">{barber.rating}</span>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{barber.servicesCount}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900 max-w-xs truncate">
                          {barber.specialization}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${barber.status === 'active' ? 'bg-green-100 text-green-800' :
                          barber.status === 'suspended' ? 'bg-red-100 text-red-800' :
                            'bg-amber-100 text-amber-800'
                          }`}>
                          {barber.status.replace('_', ' ')}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <div className="flex items-center gap-2">
                          <button
                            className="text-gray-600 hover:text-gray-900"
                            title="View"
                            onClick={() => handleView(barber)}
                          >
                            <Eye size={16} />
                          </button>
                          <button className="text-gray-600 hover:text-gray-900" title="Edit">
                            <Edit size={16} />
                          </button>
                          <button className="text-red-600 hover:text-red-900" title="Suspend">
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

        {/* View Modal */}
        {
          showViewModal && selectedBarber && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
              <div className="bg-white rounded-lg p-6 max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
                <div className="flex items-center justify-between mb-6">
                  <h2 className="text-xl font-bold text-gray-900">Barber Profile</h2>
                  <button
                    onClick={() => setShowViewModal(false)}
                    className="text-gray-400 hover:text-gray-600"
                  >
                    <X size={24} />
                  </button>
                </div>

                <div className="space-y-6">
                  {/* Barber Info */}
                  <div className="bg-gray-50 rounded-lg p-4">
                    <h3 className="text-lg font-semibold text-gray-900 mb-4">Barber Information</h3>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <p className="text-gray-500 text-sm">Name</p>
                        <p className="text-gray-900 font-medium">{selectedBarber.name}</p>
                      </div>
                      <div>
                        <p className="text-gray-500 text-sm">Email</p>
                        <p className="text-gray-900 font-medium">{selectedBarber.email}</p>
                      </div>
                      <div>
                        <p className="text-gray-500 text-sm">Phone</p>
                        <p className="text-gray-900 font-medium">{selectedBarber.phone}</p>
                      </div>
                      <div>
                        <p className="text-gray-500 text-sm">Shop</p>
                        <p className="text-gray-900 font-medium">{selectedBarber.shop}</p>
                      </div>
                      <div>
                        <p className="text-gray-500 text-sm">Rating</p>
                        <div className="flex items-center">
                          <Star size={14} className="text-amber-400 fill-current mr-1" />
                          <span className="text-gray-900 font-medium">{selectedBarber.rating}</span>
                        </div>
                      </div>
                      <div>
                        <p className="text-gray-500 text-sm">Services Count</p>
                        <p className="text-gray-900 font-medium">{selectedBarber.servicesCount}</p>
                      </div>
                      <div>
                        <p className="text-gray-500 text-sm">Status</p>
                        <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${selectedBarber.status === 'active' ? 'bg-green-100 text-green-800' :
                          selectedBarber.status === 'suspended' ? 'bg-red-100 text-red-800' :
                            'bg-amber-100 text-amber-800'
                          }`}>
                          {selectedBarber.status.replace('_', ' ')}
                        </span>
                      </div>
                      <div>
                        <p className="text-gray-500 text-sm">Experience</p>
                        <p className="text-gray-900 font-medium">{selectedBarber.experienceYears} years</p>
                      </div>
                      <div>
                        <p className="text-gray-500 text-sm">Joined Date</p>
                        <p className="text-gray-900 font-medium">{new Date(selectedBarber.joinedDate).toLocaleDateString()}</p>
                      </div>
                      <div>
                        <p className="text-gray-500 text-sm">Last Login</p>
                        <p className="text-gray-900 font-medium">
                          {selectedBarber.lastLogin ? new Date(selectedBarber.lastLogin).toLocaleDateString() : 'Never'}
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* Professional Info */}
                  {selectedBarber.specialization && (
                    <div className="bg-gray-50 rounded-lg p-4">
                      <h3 className="text-lg font-semibold text-gray-900 mb-4">Professional Details</h3>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                          <p className="text-gray-500 text-sm">Specialization</p>
                          <p className="text-gray-900 font-medium">{selectedBarber.specialization}</p>
                        </div>
                        <div>
                          <p className="text-gray-500 text-sm">Experience Years</p>
                          <p className="text-gray-900 font-medium">{selectedBarber.experienceYears} years</p>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </div>
          )
        }
      </div >
    </AdminLayout >
  );
}
