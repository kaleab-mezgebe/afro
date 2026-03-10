'use client';

import { useEffect, useState } from 'react';
import Sidebar from '@/components/Sidebar';
import { api } from '@/lib/api';
import toast from 'react-hot-toast';
import {
  Search,
  Download,
  User,
  MoreVertical,
  Eye,
  Edit,
  Ban,
  Mail,
  Phone,
  Calendar,
  MapPin,
  TrendingUp,
  Users,
  Trash2
} from 'lucide-react';

interface Customer {
  id: string;
  email: string;
  name: string;
  phone?: string;
  gender?: string;
  address?: string;
  totalBookings?: number;
  lastAppointment?: string;
  isActive: boolean;
  createdAt: string;
  preferredServices?: string[];
  hairType?: string;
  skinType?: string;
}

export default function CustomersPage() {
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [showDropdown, setShowDropdown] = useState<string | null>(null);

  useEffect(() => {
    loadCustomers();
  }, []);

  const loadCustomers = async () => {
    try {
      const response = await api.getAllCustomers();
      setCustomers(response.data);
    } catch (error) {
      toast.error('Failed to load customers');
    } finally {
      setLoading(false);
    }
  };

  const handleSuspend = async (customerId: string) => {
    try {
      await api.suspendUser(customerId);
      toast.success('Customer suspended');
      loadCustomers();
    } catch (error) {
      toast.error('Failed to suspend customer');
    }
  };

  const handleDelete = async (customerId: string) => {
    if (confirm('Are you sure you want to delete this customer? This action cannot be undone.')) {
      try {
        await api.deleteUser(customerId);
        toast.success('Customer deleted');
        loadCustomers();
      } catch (error) {
        toast.error('Failed to delete customer');
      }
    }
  };

  const filteredCustomers = customers.filter(customer =>
    customer.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    customer.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    customer.phone?.includes(searchTerm) ||
    customer.address?.toLowerCase().includes(searchTerm.toLowerCase())
  );

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
            <h1 className="text-2xl font-bold text-gray-900">Customers Management</h1>
            <p className="text-gray-600">View and manage customer accounts and preferences</p>
          </div>
          <div className="flex gap-3">
            <button className="btn btn-secondary">
              <Download size={16} />
              Export
            </button>
            <button className="btn btn-primary">
              <User size={16} />
              Add Customer
            </button>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="stats-grid">
          <div className="card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Total Customers</p>
                <p className="stat-value">{customers.length}</p>
              </div>
              <div className="p-3 rounded-lg bg-blue-100">
                <Users size={24} className="text-blue-600" />
              </div>
            </div>
          </div>

          <div className="card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Active Customers</p>
                <p className="stat-value">{customers.filter(c => c.isActive).length}</p>
              </div>
              <div className="p-3 rounded-lg bg-green-100">
                <TrendingUp size={24} className="text-green-600" />
              </div>
            </div>
          </div>

          <div className="card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Total Bookings</p>
                <p className="stat-value">{customers.reduce((sum, c) => sum + (c.totalBookings || 0), 0)}</p>
              </div>
              <div className="p-3 rounded-lg bg-purple-100">
                <Calendar size={24} className="text-purple-600" />
              </div>
            </div>
          </div>

          <div className="card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Avg Bookings/Customer</p>
                <p className="stat-value">
                  {customers.length > 0 ? (customers.reduce((sum, c) => sum + (c.totalBookings || 0), 0) / customers.length).toFixed(1) : '0'}
                </p>
              </div>
              <div className="p-3 rounded-lg bg-orange-100">
                <User size={24} className="text-orange-600" />
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
                placeholder="Search customers by name, email, phone, or address..."
                className="input pl-10"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
          </div>
        </div>

        {/* Customers Table */}
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>Customer</th>
                <th>Contact</th>
                <th>Total Bookings</th>
                <th>Last Appointment</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredCustomers.length === 0 ? (
                <tr>
                  <td colSpan={6} className="text-center py-8 text-gray-500">
                    No customers found
                  </td>
                </tr>
              ) : (
                filteredCustomers.map((customer) => (
                  <tr key={customer.id}>
                    <td>
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-yellow-100 rounded-full flex items-center justify-center">
                          <User size={20} className="text-yellow-600" />
                        </div>
                        <div>
                          <p className="font-medium text-gray-900">{customer.name}</p>
                          <div className="flex items-center gap-2 text-sm text-gray-500">
                            {customer.gender && <span>{customer.gender}</span>}
                            {customer.hairType && <span>• Hair: {customer.hairType}</span>}
                            {customer.skinType && <span>• Skin: {customer.skinType}</span>}
                          </div>
                          {customer.preferredServices && customer.preferredServices.length > 0 && (
                            <div className="flex flex-wrap gap-1 mt-1">
                              {customer.preferredServices.slice(0, 2).map((service, idx) => (
                                <span key={idx} className="badge badge-info text-xs">
                                  {service}
                                </span>
                              ))}
                              {customer.preferredServices.length > 2 && (
                                <span className="text-xs text-gray-500">+{customer.preferredServices.length - 2}</span>
                              )}
                            </div>
                          )}
                        </div>
                      </div>
                    </td>
                    <td>
                      <div className="space-y-1">
                        <div className="flex items-center gap-2 text-sm text-gray-500">
                          <Mail size={12} />
                          {customer.email}
                        </div>
                        {customer.phone && (
                          <div className="flex items-center gap-2 text-sm text-gray-500">
                            <Phone size={12} />
                            {customer.phone}
                          </div>
                        )}
                        {customer.address && (
                          <div className="flex items-center gap-2 text-sm text-gray-500">
                            <MapPin size={12} />
                            {customer.address}
                          </div>
                        )}
                      </div>
                    </td>
                    <td>
                      <span className="font-medium">{customer.totalBookings || 0}</span>
                    </td>
                    <td>
                      {customer.lastAppointment ? (
                        <div className="flex items-center gap-1 text-sm text-gray-500">
                          <Calendar size={14} />
                          {new Date(customer.lastAppointment).toLocaleDateString()}
                        </div>
                      ) : (
                        <span className="text-sm text-gray-400">No appointments</span>
                      )}
                    </td>
                    <td>
                      <span className={`badge ${customer.isActive ? 'badge-success' : 'badge-error'}`}>
                        {customer.isActive ? 'Active' : 'Inactive'}
                      </span>
                    </td>
                    <td>
                      <div className="relative">
                        <button
                          onClick={() => setShowDropdown(showDropdown === customer.id ? null : customer.id)}
                          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                        >
                          <MoreVertical size={16} />
                        </button>

                        {showDropdown === customer.id && (
                          <div className="absolute right-0 top-full mt-1 w-48 bg-white rounded-lg shadow-lg border border-gray-200 z-10">
                            <button
                              onClick={() => {
                                // View profile logic
                                setShowDropdown(null);
                              }}
                              className="w-full text-left px-4 py-2 hover:bg-gray-50 flex items-center gap-2"
                            >
                              <Eye size={16} />
                              View Profile
                            </button>
                            <button
                              onClick={() => {
                                // Edit customer logic
                                setShowDropdown(null);
                              }}
                              className="w-full text-left px-4 py-2 hover:bg-gray-50 flex items-center gap-2"
                            >
                              <Edit size={16} />
                              Edit Customer
                            </button>
                            <hr className="my-1" />
                            <button
                              onClick={() => {
                                handleSuspend(customer.id);
                                setShowDropdown(null);
                              }}
                              className="w-full text-left px-4 py-2 hover:bg-gray-50 flex items-center gap-2 text-yellow-600"
                            >
                              <Ban size={16} />
                              Suspend
                            </button>
                            <button
                              onClick={() => {
                                handleDelete(customer.id);
                                setShowDropdown(null);
                              }}
                              className="w-full text-left px-4 py-2 hover:bg-gray-50 flex items-center gap-2 text-red-600"
                            >
                              <Trash2 size={16} />
                              Delete
                            </button>
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
