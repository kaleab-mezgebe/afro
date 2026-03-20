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
  const [showNewBarberModal, setShowNewBarberModal] = useState(false);
  const [showViewModal, setShowViewModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [selectedBarber, setSelectedBarber] = useState<Barber | null>(null);
  const [editForm, setEditForm] = useState({
    name: '',
    email: '',
    phone: '',
    shop: '',
    specialization: '',
    experienceYears: 0,
    isActive: true
  });
  const [showAnalyticsModal, setShowAnalyticsModal] = useState(false);
  const [showExportModal, setShowExportModal] = useState(false);
  const [exportFormat, setExportFormat] = useState<'csv' | 'excel'>('csv');
  const [exportStatus, setExportStatus] = useState<'active' | 'suspended' | 'pending_approval' | 'all'>('all');
  const [isSubmitting, setIsSubmitting] = useState(false);

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

  const handleEditBarber = async (barber: Barber) => {
    try {
      setSelectedBarber(barber);
      setEditForm({
        name: barber.name,
        email: barber.email,
        phone: barber.phone,
        shop: barber.shop,
        specialization: barber.specialization || '',
        experienceYears: barber.experienceYears || 0,
        isActive: barber.isActive
      });
      setShowEditModal(true);
    } catch (error) {
      toast.error('Failed to load barber for editing');
    }
  };

  const handleUpdateBarber = async () => {
    if (!selectedBarber || !editForm.name || !editForm.email) {
      toast.error('Please fill in all required fields');
      return;
    }

    try {
      const response = await BarbersService.update(selectedBarber.id, editForm);

      if (response.success) {
        setBarbers(prev => prev.map(b =>
          b.id === selectedBarber.id ? { ...b, ...editForm } : b
        ));
        toast.success('Barber updated successfully!');
        setShowEditModal(false);
        setSelectedBarber(null);
        setEditForm({
          name: '',
          email: '',
          phone: '',
          shop: '',
          specialization: '',
          experienceYears: 0,
          isActive: true
        });
      }
    } catch (error) {
      toast.error('Failed to update barber');
    }
  };

  const handleAddBarber = async () => {
    if (!editForm.name || !editForm.email) {
      toast.error('Please fill in all required fields');
      return;
    }

    try {
      const response = await BarbersService.create(editForm);

      if (response.success) {
        setBarbers(prev => [...prev, response.data]);
        toast.success('Barber added successfully!');
        setShowNewBarberModal(false);
        setEditForm({
          name: '',
          email: '',
          phone: '',
          shop: '',
          specialization: '',
          experienceYears: 0,
          isActive: true
        });
      }
    } catch (error) {
      toast.error('Failed to add barber');
    }
  };

  const handleToggleStatus = async (barber: Barber) => {
    const action = barber.isActive ? 'suspend' : 'activate';
    if (!window.confirm(`Are you sure you want to ${action} ${barber.name}?`)) {
      return;
    }

    try {
      const response = await BarbersService.toggleStatus(barber.id, !barber.isActive);

      if (response.success) {
        setBarbers(prev => prev.map(b =>
          b.id === barber.id ? { ...b, isActive: !barber.isActive, status: !barber.isActive ? 'active' : 'suspended' } : b
        ));
        toast.success(`Barber ${barber.isActive ? 'suspended' : 'activated'} successfully`);
      }
    } catch (error) {
      toast.error(`Failed to ${action} barber`);
    }
  };

  const handleExportBarbers = async () => {
    try {
      setIsSubmitting(true);

      const response = await BarbersService.export(exportFormat, {
        status: exportStatus === 'all' ? undefined : exportStatus,
        search: searchTerm
      });

      // The export service handles the download automatically
      toast.success(`Barbers exported as ${exportFormat.toUpperCase()} successfully!`);
      setShowExportModal(false);
    } catch (error) {
      toast.error('Failed to export barbers');
      console.error('Export error:', error);
    } finally {
      setIsSubmitting(false);
    }
  };



  const handleDeleteBarber = async (barber: Barber) => {
    if (!window.confirm(`Are you sure you want to delete ${barber.name}? This action cannot be undone.`)) {
      return;
    }

    try {
      const response = await BarbersService.delete(barber.id);
      if (response.success) {
        setBarbers(prev => prev.filter(b => b.id !== barber.id));
        toast.success('Barber deleted successfully');
      }
    } catch (error) {
      toast.error('Failed to delete barber');
    }
  };

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
            <button
              onClick={() => setShowNewBarberModal(true)}
              className="w-full text-left p-4 bg-green-50 hover:bg-green-100 rounded-xl transition-colors border border-green-200"
            >
              <div className="flex items-center gap-3">
                <UserPlus className="text-green-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Add New Barber</p>
                  <p className="text-sm text-gray-600">Register a new barber</p>
                </div>
              </div>
            </button>
            <button
              onClick={() => setShowExportModal(true)}
              className="w-full text-left p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors border border-blue-200"
            >
              <div className="flex items-center gap-3">
                <Download className="text-blue-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Export Barbers</p>
                  <p className="text-sm text-gray-600">Download barber data</p>
                </div>
              </div>
            </button>
            <button
              onClick={() => setShowAnalyticsModal(true)}
              className="w-full text-left p-4 bg-purple-50 hover:bg-purple-100 rounded-xl transition-colors border border-purple-200"
            >
              <div className="flex items-center gap-3">
                <TrendingUp className="text-purple-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Barber Analytics</p>
                  <p className="text-sm text-gray-600">View barber statistics</p>
                </div>
              </div>
            </button>
          </div>
        </div>

        {/* Beautiful Barbers Table - Professional One Look Design */}
        <div className="bg-white rounded-2xl shadow-lg border border-gray-100 overflow-hidden">
          <div className="bg-gradient-to-r from-amber-50 to-orange-50 px-6 py-4 border-b border-gray-200">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-xl font-bold text-gray-900">Barber Directory</h3>
                <p className="text-sm text-gray-600 mt-1">Professional barbers overview at a glance</p>
              </div>
              <div className="flex items-center gap-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-amber-600">{barbers.length}</div>
                  <div className="text-xs text-gray-500">Total</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-green-600">{barbers.filter(b => b.isActive).length}</div>
                  <div className="text-xs text-gray-500">Active</div>
                </div>
              </div>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-gray-50 border-b-2 border-gray-200">
                  <th className="px-6 py-4 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                    Barber Profile
                  </th>
                  <th className="px-6 py-4 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                    Shop & Contact
                  </th>
                  <th className="px-6 py-4 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                    Expertise
                  </th>
                  <th className="px-6 py-4 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">
                    Performance
                  </th>
                  <th className="px-6 py-4 text-center text-xs font-bold text-gray-700 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-4 text-center text-xs font-bold text-gray-700 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {paginatedBarbers.map((barber, index) => (
                  <tr key={barber.id} className={`hover:bg-gradient-to-r hover:from-amber-50 hover:to-orange-50 transition-all duration-200 ${index % 2 === 0 ? 'bg-white' : 'bg-gray-50'}`}>
                    <td className="px-6 py-5">
                      <div className="flex items-center space-x-4">
                        <div className="relative">
                          <div className="w-14 h-14 rounded-full bg-gradient-to-br from-amber-400 to-orange-600 flex items-center justify-center shadow-lg ring-4 ring-amber-100">
                            <span className="text-white font-bold text-lg">
                              {barber.name.charAt(0).toUpperCase()}
                            </span>
                          </div>
                          <div className={`absolute -bottom-1 -right-1 w-4 h-4 rounded-full ${barber.isActive ? 'bg-green-500' : 'bg-red-500'} border-2 border-white`}></div>
                        </div>
                        <div>
                          <div className="font-semibold text-gray-900 text-base">{barber.name}</div>
                          <div className="text-xs text-gray-500 flex items-center gap-1">
                            <Calendar size={12} className="text-gray-400" />
                            Joined {new Date(barber.joinedDate).toLocaleDateString()}
                          </div>
                        </div>
                      </div>
                    </td>

                    <td className="px-6 py-5">
                      <div className="space-y-2">
                        <div className="flex items-center text-sm text-gray-700">
                          <Scissors size={14} className="text-amber-500 mr-2" />
                          <span className="font-medium">{barber.shop}</span>
                        </div>
                        <div className="flex items-center text-sm text-gray-600">
                          <Mail size={14} className="text-blue-500 mr-2" />
                          <span>{barber.email}</span>
                        </div>
                        <div className="flex items-center text-sm text-gray-600">
                          <Phone size={14} className="text-green-500 mr-2" />
                          <span>{barber.phone}</span>
                        </div>
                      </div>
                    </td>

                    <td className="px-6 py-5">
                      <div className="space-y-2">
                        <div className="flex items-center text-sm text-gray-700">
                          <Award size={14} className="text-purple-500 mr-2" />
                          <span className="font-medium">{barber.specialization || 'General'}</span>
                        </div>
                        <div className="flex items-center text-sm text-gray-600">
                          <Shield size={14} className="text-indigo-500 mr-2" />
                          <span>{barber.servicesCount || 0} services</span>
                        </div>
                      </div>
                    </td>

                    <td className="px-6 py-5">
                      <div className="space-y-2">
                        <div className="flex items-center justify-between">
                          <span className="text-sm text-gray-600">Rating</span>
                          <div className="flex items-center space-x-1">
                            {[...Array(5)].map((_, i) => (
                              <Star
                                key={i}
                                size={14}
                                className={`${i < Math.floor(barber.rating || 0) ? 'text-amber-400 fill-current' : 'text-gray-300'}`}
                              />
                            ))}
                            <span className="ml-2 font-semibold text-gray-700">{(barber.rating || 0).toFixed(1)}</span>
                          </div>
                        </div>
                        <div className="flex items-center justify-between">
                          <span className="text-sm text-gray-600">Bookings</span>
                          <span className="font-semibold text-blue-600 text-base">{barber.totalBookings || 0}</span>
                        </div>
                      </div>
                    </td>

                    <td className="px-6 py-5 text-center">
                      <div className="flex justify-center">
                        <span className={`inline-flex items-center px-4 py-2 rounded-full text-sm font-bold ${barber.isActive
                          ? 'bg-gradient-to-r from-green-100 to-emerald-100 text-green-800 border border-green-300'
                          : 'bg-gradient-to-r from-red-100 to-pink-100 text-red-800 border border-red-300'
                          }`}>
                          <div className={`w-2 h-2 rounded-full mr-2 animate-pulse ${barber.isActive ? 'bg-green-500' : 'bg-red-500'}`}></div>
                          {barber.isActive ? 'ACTIVE' : 'SUSPENDED'}
                        </span>
                      </div>
                    </td>

                    <td className="px-6 py-5">
                      <div className="flex items-center justify-center space-x-2">
                        <button
                          onClick={() => handleView(barber)}
                          className="p-2 bg-purple-100 text-purple-600 rounded-lg hover:bg-purple-200 transition-all duration-200 hover:scale-110"
                          title="View Details"
                        >
                          <Eye size={16} />
                        </button>
                        <button
                          onClick={() => handleEditBarber(barber)}
                          className="p-2 bg-amber-100 text-amber-600 rounded-lg hover:bg-amber-200 transition-all duration-200 hover:scale-110"
                          title="Edit Barber"
                        >
                          <Edit size={16} />
                        </button>
                        <button
                          onClick={() => handleToggleStatus(barber)}
                          className={`p-2 rounded-lg transition-all duration-200 hover:scale-110 ${barber.isActive
                            ? 'bg-red-100 text-red-600 hover:bg-red-200'
                            : 'bg-green-100 text-green-600 hover:bg-green-200'
                            }`}
                          title={barber.isActive ? 'Suspend Barber' : 'Activate Barber'}
                        >
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

        {/* Add New Barber Modal */}
        {
          showNewBarberModal && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 animate-fade-in">
              <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl mx-4 max-h-[90vh] overflow-y-auto animate-scale-in">
                <div className="p-6">
                  <div className="flex items-center justify-between mb-6">
                    <h3 className="text-2xl font-bold text-gray-900 flex items-center gap-3">
                      <div className="w-10 h-10 bg-green-500 rounded-xl flex items-center justify-center">
                        <UserPlus className="text-white" size={20} />
                      </div>
                      Add New Barber
                    </h3>
                    <button
                      onClick={() => setShowNewBarberModal(false)}
                      className="text-gray-400 hover:text-gray-600 transition-colors"
                    >
                      <X size={24} />
                    </button>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Full Name *</label>
                      <input
                        type="text"
                        value={editForm.name}
                        onChange={(e) => setEditForm(prev => ({ ...prev, name: e.target.value }))}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500"
                        placeholder="Enter full name"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Email Address *</label>
                      <input
                        type="email"
                        value={editForm.email}
                        onChange={(e) => setEditForm(prev => ({ ...prev, email: e.target.value }))}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500"
                        placeholder="Enter email address"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Phone Number</label>
                      <input
                        type="tel"
                        value={editForm.phone}
                        onChange={(e) => setEditForm(prev => ({ ...prev, phone: e.target.value }))}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500"
                        placeholder="Enter phone number"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Shop Name</label>
                      <input
                        type="text"
                        value={editForm.shop}
                        onChange={(e) => setEditForm(prev => ({ ...prev, shop: e.target.value }))}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500"
                        placeholder="Enter shop name"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Specialization</label>
                      <input
                        type="text"
                        value={editForm.specialization}
                        onChange={(e) => setEditForm(prev => ({ ...prev, specialization: e.target.value }))}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500"
                        placeholder="Enter specialization"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Experience Years</label>
                      <input
                        type="number"
                        value={editForm.experienceYears}
                        onChange={(e) => setEditForm(prev => ({ ...prev, experienceYears: parseInt(e.target.value) || 0 }))}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500"
                        placeholder="Enter years of experience"
                      />
                    </div>
                  </div>

                  <div className="mt-6">
                    <label className="flex items-center gap-3">
                      <input
                        type="checkbox"
                        checked={editForm.isActive}
                        onChange={(e) => setEditForm(prev => ({ ...prev, isActive: e.target.checked }))}
                        className="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                      />
                      <span className="text-sm font-medium text-gray-700">Active Barber</span>
                    </label>
                  </div>

                  <div className="flex justify-end gap-3 mt-8">
                    <button
                      onClick={() => setShowNewBarberModal(false)}
                      className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                    >
                      Cancel
                    </button>
                    <button
                      onClick={handleAddBarber}
                      className="px-6 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
                    >
                      Add Barber
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )
        }

        {/* Edit Barber Modal */}
        {
          showEditModal && selectedBarber && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 animate-fade-in">
              <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl mx-4 max-h-[90vh] overflow-y-auto animate-scale-in">
                <div className="p-6">
                  <div className="flex items-center justify-between mb-6">
                    <h3 className="text-2xl font-bold text-gray-900 flex items-center gap-3">
                      <div className="w-10 h-10 bg-amber-500 rounded-xl flex items-center justify-center">
                        <Edit className="text-white" size={20} />
                      </div>
                      Edit Barber
                    </h3>
                    <button
                      onClick={() => setShowEditModal(false)}
                      className="text-gray-400 hover:text-gray-600 transition-colors"
                    >
                      <X size={24} />
                    </button>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Full Name *</label>
                      <input
                        type="text"
                        value={editForm.name}
                        onChange={(e) => setEditForm(prev => ({ ...prev, name: e.target.value }))}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
                        placeholder="Enter full name"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Email Address *</label>
                      <input
                        type="email"
                        value={editForm.email}
                        onChange={(e) => setEditForm(prev => ({ ...prev, email: e.target.value }))}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
                        placeholder="Enter email address"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Phone Number</label>
                      <input
                        type="tel"
                        value={editForm.phone}
                        onChange={(e) => setEditForm(prev => ({ ...prev, phone: e.target.value }))}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
                        placeholder="Enter phone number"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Shop Name</label>
                      <input
                        type="text"
                        value={editForm.shop}
                        onChange={(e) => setEditForm(prev => ({ ...prev, shop: e.target.value }))}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
                        placeholder="Enter shop name"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Specialization</label>
                      <input
                        type="text"
                        value={editForm.specialization}
                        onChange={(e) => setEditForm(prev => ({ ...prev, specialization: e.target.value }))}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
                        placeholder="Enter specialization"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Experience Years</label>
                      <input
                        type="number"
                        value={editForm.experienceYears}
                        onChange={(e) => setEditForm(prev => ({ ...prev, experienceYears: parseInt(e.target.value) || 0 }))}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
                        placeholder="Enter years of experience"
                      />
                    </div>
                  </div>

                  <div className="mt-6">
                    <label className="flex items-center gap-3">
                      <input
                        type="checkbox"
                        checked={editForm.isActive}
                        onChange={(e) => setEditForm(prev => ({ ...prev, isActive: e.target.checked }))}
                        className="w-4 h-4 text-amber-600 border-gray-300 rounded focus:ring-amber-500"
                      />
                      <span className="text-sm font-medium text-gray-700">Active Barber</span>
                    </label>
                  </div>

                  <div className="flex justify-end gap-3 mt-8">
                    <button
                      onClick={() => setShowEditModal(false)}
                      className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                    >
                      Cancel
                    </button>
                    <button
                      onClick={handleUpdateBarber}
                      className="px-6 py-2 bg-amber-500 text-white rounded-lg hover:bg-amber-600 transition-colors"
                    >
                      Update Barber
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )
        }

        {/* Export Barbers Modal */}
        {
          showExportModal && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 animate-fade-in">
              <div className="bg-white rounded-2xl shadow-2xl w-full max-w-xl mx-4 animate-scale-in">
                <div className="p-6">
                  <div className="flex items-center justify-between mb-6">
                    <h3 className="text-2xl font-bold text-gray-900 flex items-center gap-3">
                      <div className="w-10 h-10 bg-amber-500 rounded-xl flex items-center justify-center">
                        <Download className="text-white" size={20} />
                      </div>
                      Export Barbers
                    </h3>
                    <button
                      onClick={() => setShowExportModal(false)}
                      className="text-gray-400 hover:text-gray-600 transition-colors"
                    >
                      <X size={24} />
                    </button>
                  </div>

                  <div className="space-y-6">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Export Format</label>
                      <div className="grid grid-cols-2 gap-4">
                        <label className="flex items-center space-x-3 cursor-pointer">
                          <input
                            type="radio"
                            name="format"
                            value="csv"
                            checked={exportFormat === 'csv'}
                            onChange={(e) => setExportFormat(e.target.value as 'csv' | 'excel')}
                            className="w-4 h-4 text-amber-600 focus:ring-amber-500"
                          />
                          <span className="text-sm font-medium text-gray-700">CSV</span>
                          <span className="text-xs text-gray-500">(.csv file)</span>
                        </label>
                        <label className="flex items-center space-x-3 cursor-pointer">
                          <input
                            type="radio"
                            name="format"
                            value="excel"
                            checked={exportFormat === 'excel'}
                            onChange={(e) => setExportFormat(e.target.value as 'csv' | 'excel')}
                            className="w-4 h-4 text-amber-600 focus:ring-amber-500"
                          />
                          <span className="text-sm font-medium text-gray-700">Excel</span>
                          <span className="text-xs text-gray-500">(.xlsx file)</span>
                        </label>
                      </div>
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Barber Status</label>
                      <select
                        value={exportStatus}
                        onChange={(e) => setExportStatus(e.target.value as 'active' | 'suspended' | 'pending_approval' | 'all')}
                        className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
                      >
                        <option value="all">All Barbers</option>
                        <option value="active">Active Only</option>
                        <option value="suspended">Suspended Only</option>
                        <option value="pending_approval">Pending Approval Only</option>
                      </select>
                    </div>
                  </div>

                  <div className="flex justify-end gap-3">
                    <button
                      onClick={() => setShowExportModal(false)}
                      className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                    >
                      Cancel
                    </button>
                    <button
                      onClick={handleExportBarbers}
                      disabled={isSubmitting}
                      className="px-6 py-2 bg-amber-500 text-white rounded-lg hover:bg-amber-600 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                    >
                      {isSubmitting ? (
                        <>
                          <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                          Exporting...
                        </>
                      ) : (
                        <>
                          <Download size={16} />
                          Export {exportFormat.toUpperCase()}
                        </>
                      )}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )
        }

        {/* Analytics Modal */}
        {
          showAnalyticsModal && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 animate-fade-in">
              <div className="bg-white rounded-2xl shadow-2xl w-full max-w-4xl mx-4 max-h-[90vh] overflow-y-auto animate-scale-in">
                <div className="p-6">
                  <div className="flex items-center justify-between mb-6">
                    <h3 className="text-2xl font-bold text-gray-900 flex items-center gap-3">
                      <div className="w-10 h-10 bg-purple-500 rounded-xl flex items-center justify-center">
                        <TrendingUp className="text-white" size={20} />
                      </div>
                      Barber Analytics
                    </h3>
                    <button
                      onClick={() => setShowAnalyticsModal(false)}
                      className="text-gray-400 hover:text-gray-600 transition-colors"
                    >
                      <X size={24} />
                    </button>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    {/* Overview Stats */}
                    <div className="bg-amber-50 rounded-xl p-6 border border-amber-200">
                      <h4 className="text-lg font-semibold text-amber-800 mb-4">Overview</h4>
                      <div className="space-y-3">
                        <div className="flex justify-between">
                          <span className="text-amber-600">Total Barbers:</span>
                          <span className="font-bold text-amber-800">{barbers.length}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-amber-600">Active Barbers:</span>
                          <span className="font-bold text-amber-800">{barbers.filter(b => b.isActive).length}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-amber-600">Avg Rating:</span>
                          <span className="font-bold text-amber-800">{(barbers.reduce((acc, b) => acc + b.rating, 0) / barbers.length || 0).toFixed(1)}</span>
                        </div>
                      </div>
                    </div>

                    {/* Performance Stats */}
                    <div className="bg-purple-50 rounded-xl p-6 border border-purple-200">
                      <h4 className="text-lg font-semibold text-purple-800 mb-4">Performance</h4>
                      <div className="space-y-3">
                        <div className="flex justify-between">
                          <span className="text-purple-600">Total Bookings:</span>
                          <span className="font-bold text-purple-800">{barbers.reduce((acc, b) => acc + (b.totalBookings || 0), 0)}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-purple-600">Est. Revenue:</span>
                          <span className="font-bold text-purple-800">${barbers.reduce((acc, b) => acc + (b.totalBookings || 0) * 50, 0).toLocaleString()}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-purple-600">New This Month:</span>
                          <span className="font-bold text-purple-800">5</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div className="flex justify-end mt-8">
                    <button
                      onClick={() => setShowAnalyticsModal(false)}
                      className="px-6 py-2 bg-purple-500 text-white rounded-lg hover:bg-purple-600 transition-colors"
                    >
                      Close
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )
        }

      </div >
    </AdminLayout >
  );
}
