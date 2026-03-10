'use client';

import { useEffect, useState } from 'react';
import Sidebar from '@/components/Sidebar';
import { api } from '@/lib/api';
import toast from 'react-hot-toast';
import {
  Search,
  Filter,
  Download,
  Scissors,
  MoreVertical,
  Eye,
  Edit,
  CheckCircle,
  X,
  Ban,
  Star,
  MapPin,
  Calendar,
  Phone,
  Mail,
  TrendingUp,
  Award
} from 'lucide-react';

interface Provider {
  id: string;
  email: string;
  name: string;
  phone?: string;
  salonName: string;
  description?: string;
  address?: string;
  rating?: number;
  totalReviews?: number;
  totalAppointments?: number;
  isVerified: boolean;
  isActive: boolean;
  createdAt: string;
  specialties?: string[];
  workingHours?: any;
}

export default function ProvidersPage() {
  const [providers, setProviders] = useState<Provider[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [verificationFilter, setVerificationFilter] = useState('all');
  const [showDropdown, setShowDropdown] = useState<string | null>(null);

  useEffect(() => {
    loadProviders();
  }, []);

  const loadProviders = async () => {
    try {
      const response = await api.getAllProviders();
      setProviders(response.data);
    } catch (error) {
      toast.error('Failed to load providers');
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (providerId: string) => {
    try {
      await api.approveProvider(providerId);
      toast.success('Provider approved');
      loadProviders();
    } catch (error) {
      toast.error('Failed to approve provider');
    }
  };

  const handleReject = async (providerId: string) => {
    const reason = prompt('Please provide a reason for rejection:');
    if (reason) {
      try {
        await api.rejectProvider(providerId, reason);
        toast.success('Provider rejected');
        loadProviders();
      } catch (error) {
        toast.error('Failed to reject provider');
      }
    }
  };

  const handleSuspend = async (providerId: string) => {
    try {
      await api.suspendUser(providerId);
      toast.success('Provider suspended');
      loadProviders();
    } catch (error) {
      toast.error('Failed to suspend provider');
    }
  };

  const filteredProviders = providers.filter(provider => {
    const matchesSearch = provider.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      provider.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      provider.salonName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      provider.phone?.includes(searchTerm);
    const matchesStatus = statusFilter === 'all' ||
      (statusFilter === 'active' && provider.isActive) ||
      (statusFilter === 'inactive' && !provider.isActive);
    const matchesVerification = verificationFilter === 'all' ||
      (verificationFilter === 'verified' && provider.isVerified) ||
      (verificationFilter === 'unverified' && !provider.isVerified);
    return matchesSearch && matchesStatus && matchesVerification;
  });

  if (loading) {
    return (
      <div className="flex">
        <Sidebar />
        <div className="main-content flex items-center justify-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-yellow-500"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex">
      <Sidebar />
      <div className="main-content">
        {/* Header */}
        <div className="header">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Providers Management</h1>
            <p className="text-gray-600">Manage barbers, salons, and service providers</p>
          </div>
          <div className="flex gap-3">
            <button className="btn btn-secondary">
              <Download size={16} />
              Export
            </button>
            <button className="btn btn-primary">
              <Scissors size={16} />
              Add Provider
            </button>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="stats-grid">
          <div className="card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Total Providers</p>
                <p className="stat-value">{providers.length}</p>
              </div>
              <div className="p-3 rounded-lg bg-blue-100">
                <Scissors size={24} className="text-blue-600" />
              </div>
            </div>
          </div>

          <div className="card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Verified</p>
                <p className="stat-value">{providers.filter(p => p.isVerified).length}</p>
              </div>
              <div className="p-3 rounded-lg bg-green-100">
                <CheckCircle size={24} className="text-green-600" />
              </div>
            </div>
          </div>

          <div className="card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Pending Approval</p>
                <p className="stat-value">{providers.filter(p => !p.isVerified).length}</p>
              </div>
              <div className="p-3 rounded-lg bg-yellow-100">
                <Award size={24} className="text-yellow-600" />
              </div>
            </div>
          </div>

          <div className="card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Active</p>
                <p className="stat-value">{providers.filter(p => p.isActive).length}</p>
              </div>
              <div className="p-3 rounded-lg bg-purple-100">
                <TrendingUp size={24} className="text-purple-600" />
              </div>
            </div>
          </div>
        </div>

        {/* Filters */}
        <div className="card mb-6">
          <div className="flex flex-col lg:flex-row gap-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
              <input
                type="text"
                placeholder="Search providers by name, salon, email, or phone..."
                className="input pl-10"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>

            <div className="flex items-center gap-2">
              <Filter size={20} className="text-gray-400" />
              <select
                className="input"
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
              >
                <option value="all">All Status</option>
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>

            <div className="flex items-center gap-2">
              <select
                className="input"
                value={verificationFilter}
                onChange={(e) => setVerificationFilter(e.target.value)}
              >
                <option value="all">All Verification</option>
                <option value="verified">Verified</option>
                <option value="unverified">Unverified</option>
              </select>
            </div>
          </div>
        </div>

        {/* Providers Table */}
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>Provider</th>
                <th>Salon Name</th>
                <th>Rating</th>
                <th>Total Bookings</th>
                <th>Status</th>
                <th>Verification</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredProviders.length === 0 ? (
                <tr>
                  <td colSpan={7} className="text-center py-8 text-gray-500">
                    No providers found
                  </td>
                </tr>
              ) : (
                filteredProviders.map((provider) => (
                  <tr key={provider.id}>
                    <td>
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-yellow-100 rounded-full flex items-center justify-center">
                          <Scissors size={20} className="text-yellow-600" />
                        </div>
                        <div>
                          <p className="font-medium text-gray-900">{provider.name}</p>
                          <div className="flex items-center gap-2 text-sm text-gray-500">
                            <Mail size={12} />
                            {provider.email}
                          </div>
                          {provider.phone && (
                            <div className="flex items-center gap-2 text-sm text-gray-500">
                              <Phone size={12} />
                              {provider.phone}
                            </div>
                          )}
                        </div>
                      </div>
                    </td>
                    <td>
                      <div>
                        <p className="font-medium text-gray-900">{provider.salonName}</p>
                        {provider.address && (
                          <div className="flex items-center gap-1 text-sm text-gray-500">
                            <MapPin size={12} />
                            {provider.address}
                          </div>
                        )}
                      </div>
                    </td>
                    <td>
                      <div className="flex items-center gap-1">
                        <Star size={16} className="text-yellow-500 fill-current" />
                        <span className="font-medium">{provider.rating || '0.0'}</span>
                        <span className="text-sm text-gray-500">({provider.totalReviews || 0})</span>
                      </div>
                    </td>
                    <td>
                      <span className="font-medium">{provider.totalAppointments || 0}</span>
                    </td>
                    <td>
                      <span className={`badge ${provider.isActive ? 'badge-success' : 'badge-error'}`}>
                        {provider.isActive ? 'Active' : 'Inactive'}
                      </span>
                    </td>
                    <td>
                      <span className={`badge ${provider.isVerified ? 'badge-success' : 'badge-warning'}`}>
                        {provider.isVerified ? 'Verified' : 'Pending'}
                      </span>
                    </td>
                    <td>
                      <div className="relative">
                        <button
                          onClick={() => setShowDropdown(showDropdown === provider.id ? null : provider.id)}
                          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                        >
                          <MoreVertical size={16} />
                        </button>

                        {showDropdown === provider.id && (
                          <div className="absolute right-0 top-full mt-1 w-48 bg-white rounded-lg shadow-lg border border-gray-200 z-10">
                            <button
                              onClick={() => {
                                // View salon profile logic
                                setShowDropdown(null);
                              }}
                              className="w-full text-left px-4 py-2 hover:bg-gray-50 flex items-center gap-2"
                            >
                              <Eye size={16} />
                              View Salon Profile
                            </button>
                            <button
                              onClick={() => {
                                // Edit provider logic
                                setShowDropdown(null);
                              }}
                              className="w-full text-left px-4 py-2 hover:bg-gray-50 flex items-center gap-2"
                            >
                              <Edit size={16} />
                              Edit Provider
                            </button>
                            <hr className="my-1" />
                            {!provider.isVerified ? (
                              <>
                                <button
                                  onClick={() => {
                                    handleApprove(provider.id);
                                    setShowDropdown(null);
                                  }}
                                  className="w-full text-left px-4 py-2 hover:bg-gray-50 flex items-center gap-2 text-green-600"
                                >
                                  <CheckCircle size={16} />
                                  Approve Provider
                                </button>
                                <button
                                  onClick={() => {
                                    handleReject(provider.id);
                                    setShowDropdown(null);
                                  }}
                                  className="w-full text-left px-4 py-2 hover:bg-gray-50 flex items-center gap-2 text-red-600"
                                >
                                  <X size={16} />
                                  Reject Provider
                                </button>
                              </>
                            ) : (
                              <button
                                onClick={() => {
                                  handleSuspend(provider.id);
                                  setShowDropdown(null);
                                }}
                                className="w-full text-left px-4 py-2 hover:bg-gray-50 flex items-center gap-2 text-yellow-600"
                              >
                                <Ban size={16} />
                                Suspend
                              </button>
                            )}
                          </div>
                        )}
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
