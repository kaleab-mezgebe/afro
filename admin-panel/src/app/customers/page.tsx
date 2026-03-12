'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
import {
  Users,
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
  TrendingUp,
  Star,
  MapPin,
  Clock,
  Heart,
  DollarSign,
  Award,
  ShoppingBag,
  Plus,
  X,
  BarChart3,
  PieChart,
  Activity,
  UserPlus,
  FileText,
  CalendarDays,
  Target,
  Zap,
  ArrowUpRight,
  ArrowDown,
  ArrowUp
} from 'lucide-react';
import { CustomersService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';

interface Customer {
  id: string;
  name: string;
  email: string;
  phone: string;
  city: string;
  totalBookings: number;
  totalSpent: number;
  rating: number;
  joinDate: string;
  lastBooking: string;
  isActive: boolean;
  loyaltyPoints: number;
  avatar?: string;
  preferences?: any;
  notes?: string;
  tags?: string[];
}

interface NewCustomerForm {
  name: string;
  email: string;
  phone: string;
  city: string;
  address?: string;
  notes?: string;
  preferences?: any;
}

interface CustomerAnalytics {
  totalCustomers: number;
  activeCustomers: number;
  newCustomers: number;
  retentionRate: number;
  averageRating: number;
  totalRevenue: number;
  bookingsByMonth: { month: string; bookings: number; revenue: number }[];
  customerDistribution: { city: string; count: number }[];
  topCustomers: { name: string; spent: number; bookings: number }[];
}

export default function CustomersPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [cityFilter, setCityFilter] = useState('all');
  const [showNewCustomerModal, setShowNewCustomerModal] = useState(false);
  const [showExportModal, setShowExportModal] = useState(false);
  const [showAnalyticsModal, setShowAnalyticsModal] = useState(false);
  const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(null);
  const [analyticsData, setAnalyticsData] = useState<CustomerAnalytics | null>(null);
  const [newCustomerForm, setNewCustomerForm] = useState<NewCustomerForm>({
    name: '',
    email: '',
    phone: '',
    city: '',
    address: '',
    notes: '',
    preferences: {}
  });
  const [exportFormat, setExportFormat] = useState<'csv' | 'excel'>('csv');
  const [exportStatus, setExportStatus] = useState<'active' | 'blocked' | 'all'>('all');
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (authenticated) {
      loadCustomers();
    }
  }, [authenticated]);

  const loadCustomers = async () => {
    try {
      const response = await CustomersService.getAll({
        page: 1,
        limit: 50,
        search: searchTerm,
        status: cityFilter === 'all' ? undefined : cityFilter
      });

      if (response.success && response.data) {
        setCustomers(response.data);
      }
    } catch (error) {
      toast.error('Failed to load customers');
      console.error('Customers loading error:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadAnalytics = async () => {
    try {
      setLoading(true);
      const response = await fetch('http://localhost:3001/api/v1/admin/customers/stats', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
          'Content-Type': 'application/json'
        }
      });
      const data = await response.json();

      if (response.ok) {
        setAnalyticsData({
          totalCustomers: customers.length,
          activeCustomers: customers.filter(c => c.isActive).length,
          newCustomers: Math.floor(customers.length * 0.15), // Mock new customers
          retentionRate: 85.5,
          averageRating: customers.reduce((acc, c) => acc + c.rating, 0) / customers.length || 0,
          totalRevenue: customers.reduce((acc, c) => acc + c.totalSpent, 0),
          bookingsByMonth: [
            { month: 'Jan', bookings: 45, revenue: 12500 },
            { month: 'Feb', bookings: 38, revenue: 10200 },
            { month: 'Mar', bookings: 52, revenue: 15600 },
            { month: 'Apr', bookings: 41, revenue: 9800 },
            { month: 'May', bookings: 63, revenue: 18700 },
            { month: 'Jun', bookings: 48, revenue: 14400 }
          ],
          customerDistribution: [
            { city: 'New York', count: 45 },
            { city: 'Los Angeles', count: 32 },
            { city: 'Chicago', count: 28 },
            { city: 'Houston', count: 19 }
          ],
          topCustomers: customers.slice(0, 5).map(c => ({
            name: c.name,
            spent: c.totalSpent,
            bookings: c.totalBookings
          }))
        });
      }
    } catch (error) {
      toast.error('Failed to load analytics');
      console.error('Analytics loading error:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleAddCustomer = async () => {
    if (!newCustomerForm.name || !newCustomerForm.email || !newCustomerForm.phone) {
      toast.error('Please fill in all required fields');
      return;
    }

    try {
      setIsSubmitting(true);

      // Simulate API call to create customer
      const response = await fetch('http://localhost:3001/api/v1/admin/customers', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(newCustomerForm)
      });

      if (response.ok) {
        const newCustomer = await response.json();
        setCustomers([...customers, newCustomer.data]);
        toast.success('Customer added successfully!');
        setShowNewCustomerModal(false);
        setNewCustomerForm({
          name: '',
          email: '',
          phone: '',
          city: '',
          address: '',
          notes: '',
          preferences: {}
        });
      } else {
        toast.error('Failed to add customer');
      }
    } catch (error) {
      toast.error('Failed to add customer');
      console.error('Add customer error:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleExportCustomers = async () => {
    try {
      setIsSubmitting(true);

      const response = await fetch('http://localhost:3001/api/v1/admin/customers/export', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          format: exportFormat,
          status: exportStatus
        })
      });

      if (response.ok) {
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `customers.${exportFormat}`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);

        toast.success(`Customers exported as ${exportFormat.toUpperCase()} successfully!`);
        setShowExportModal(false);
      } else {
        toast.error('Failed to export customers');
      }
    } catch (error) {
      toast.error('Failed to export customers');
      console.error('Export error:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const filteredCustomers = customers.filter(customer => {
    const matchesSearch = searchTerm === '' ||
      customer.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      customer.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      customer.city.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesCity = cityFilter === 'all' || customer.city === cityFilter;

    return matchesSearch && matchesCity;
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

  const totalCustomers = customers.length;
  const activeCustomers = customers.filter(c => c.isActive).length;
  const totalRevenue = customers.reduce((acc, c) => acc + c.totalSpent, 0);
  const avgRating = customers.reduce((acc, c) => acc + c.rating, 0) / customers.length || 0;

  return (
    <AdminLayout>
      <div className="page-content">
        {/* Creative Customer Community Header */}
        <div className="bg-gradient-to-r from-teal-600 via-cyan-600 to-blue-600 rounded-3xl p-8 mb-8 text-white shadow-2xl">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="text-4xl font-bold mb-2 flex items-center gap-3">
                <Users className="fill-white" size={36} />
                Customer Community
              </h1>
              <p className="text-teal-100 text-lg">Valued members of our beauty family</p>
            </div>
            <div className="text-center">
              <div className="text-5xl font-bold text-yellow-300">{totalCustomers}</div>
              <div className="text-teal-100">Happy Clients</div>
            </div>
          </div>

          {/* Customer Avatars Preview */}
          <div className="flex -space-x-3 justify-center">
            {customers.slice(0, 8).map((customer, index) => (
              <div key={customer.id} className="w-12 h-12 bg-white/20 backdrop-blur rounded-full border-2 border-white flex items-center justify-center">
                <span className="text-white font-bold text-sm">
                  {customer.name.charAt(0).toUpperCase()}
                </span>
              </div>
            ))}
            {customers.length > 8 && (
              <div className="w-12 h-12 bg-white/30 backdrop-blur rounded-full border-2 border-white flex items-center justify-center">
                <span className="text-white font-bold text-xs">+{customers.length - 8}</span>
              </div>
            )}
          </div>
        </div>

        {/* Creative Customer Stats with Loyalty Theme */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          {/* Total Customers - Community Style */}
          <div className="bg-gradient-to-br from-teal-50 to-cyan-100 rounded-2xl p-6 border border-teal-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center justify-between mb-4">
              <div className="w-16 h-16 bg-teal-500 rounded-2xl flex items-center justify-center shadow-lg">
                <Users className="text-white" size={28} />
              </div>
              <div className="text-right">
                <div className="text-3xl font-bold text-teal-800">{totalCustomers}</div>
                <div className="text-teal-600 text-sm">Total</div>
              </div>
            </div>
            <div className="bg-teal-200 rounded-xl p-3">
              <div className="text-teal-800 text-sm font-medium">👥 Growing Family</div>
            </div>
          </div>

          {/* Active Customers - Status Style */}
          <div className="bg-gradient-to-br from-green-50 to-emerald-100 rounded-2xl p-6 border border-green-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center justify-between mb-4">
              <div className="w-16 h-16 bg-green-500 rounded-2xl flex items-center justify-center shadow-lg">
                <Heart className="text-white" size={28} />
              </div>
              <div className="text-right">
                <div className="text-3xl font-bold text-green-800">{activeCustomers}</div>
                <div className="text-green-600 text-sm">Active</div>
              </div>
            </div>
            <div className="bg-green-200 rounded-xl p-3">
              <div className="text-green-800 text-sm font-medium">❤️ Loyal Clients</div>
            </div>
          </div>

          {/* Total Revenue - Money Style */}
          <div className="bg-gradient-to-br from-purple-50 to-pink-100 rounded-2xl p-6 border border-purple-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center justify-between mb-4">
              <div className="w-16 h-16 bg-purple-500 rounded-2xl flex items-center justify-center shadow-lg">
                <DollarSign className="text-white" size={28} />
              </div>
              <div className="text-right">
                <div className="text-2xl font-bold text-purple-800">${totalRevenue.toFixed(0)}</div>
                <div className="text-purple-600 text-sm">Revenue</div>
              </div>
            </div>
            <div className="bg-purple-200 rounded-xl p-3">
              <div className="text-purple-800 text-sm font-medium">💰 Total Spent</div>
            </div>
          </div>

          {/* Average Rating - Star Style */}
          <div className="bg-gradient-to-br from-yellow-50 to-amber-100 rounded-2xl p-6 border border-yellow-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center justify-between mb-4">
              <div className="w-16 h-16 bg-yellow-500 rounded-2xl flex items-center justify-center shadow-lg">
                <Star className="text-white" size={28} />
              </div>
              <div className="text-right">
                <div className="text-3xl font-bold text-yellow-800">{avgRating.toFixed(1)}</div>
                <div className="text-yellow-600 text-sm">Rating</div>
              </div>
            </div>
            <div className="bg-yellow-200 rounded-xl p-3">
              <div className="text-yellow-800 text-sm font-medium">⭐ Satisfaction</div>
            </div>
          </div>
        </div>

        {/* Filters and Actions */}
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-8">
          <div className="flex items-center gap-4">
            <div className="relative">
              <Search size={20} className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Search customers..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 bg-gray-50 text-gray-900 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 w-64"
              />
            </div>
            <div className="flex items-center gap-2">
              <Filter size={20} className="text-gray-400" />
              <select
                className="px-4 py-2 bg-white text-gray-700 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500"
                value={cityFilter}
                onChange={(e) => setCityFilter(e.target.value)}
              >
                <option value="all">All Cities</option>
                <option value="New York">New York</option>
                <option value="Los Angeles">Los Angeles</option>
                <option value="Chicago">Chicago</option>
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
                <p className="stat-label">Total Customers</p>
                <p className="stat-value">{totalCustomers}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  18% from last month
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
                <p className="stat-label">Active Customers</p>
                <p className="stat-value">{activeCustomers}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  12% from last week
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
                <p className="stat-label">Total Revenue</p>
                <p className="stat-value">${totalRevenue.toLocaleString()}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  25% from last month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-purple-100">
                <ShoppingBag size={24} className="text-purple-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Avg Rating</p>
                <p className="stat-value">{avgRating.toFixed(1)}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  0.3 from last month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-amber-100">
                <Star size={24} className="text-amber-600" />
              </div>
            </div>
          </div>
        </div >

        {/* Quick Actions */}
        <div className="mb-8">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">Quick Actions</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <button
              onClick={() => setShowNewCustomerModal(true)}
              className="w-full text-left p-4 bg-orange-50 hover:bg-orange-100 rounded-xl transition-all duration-300 border border-orange-200 shadow-md hover:shadow-lg hover:-translate-y-1"
            >
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-orange-500 rounded-xl flex items-center justify-center shadow-md">
                  <UserPlus className="text-white" size={20} />
                </div>
                <div>
                  <p className="font-semibold text-gray-900">Add New Customer</p>
                  <p className="text-sm text-gray-600">Register a new customer</p>
                </div>
              </div>
            </button>

            <button
              onClick={() => setShowExportModal(true)}
              className="w-full text-left p-4 bg-orange-50 hover:bg-orange-100 rounded-xl transition-all duration-300 border border-orange-200 shadow-md hover:shadow-lg hover:-translate-y-1"
            >
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-orange-500 rounded-xl flex items-center justify-center shadow-md">
                  <Download className="text-white" size={20} />
                </div>
                <div>
                  <p className="font-semibold text-gray-900">Export Customers</p>
                  <p className="text-sm text-gray-600">Download customer data</p>
                </div>
              </div>
            </button>

            <button
              onClick={() => {
                loadAnalytics();
                setShowAnalyticsModal(true);
              }}
              className="w-full text-left p-4 bg-orange-50 hover:bg-orange-100 rounded-xl transition-all duration-300 border border-orange-200 shadow-md hover:shadow-lg hover:-translate-y-1"
            >
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-orange-500 rounded-xl flex items-center justify-center shadow-md">
                  <BarChart3 className="text-white" size={20} />
                </div>
                <div>
                  <p className="font-semibold text-gray-900">Customer Analytics</p>
                  <p className="text-sm text-gray-600">View customer statistics</p>
                </div>
              </div>
            </button>
          </div>
        </div>

        {/* Customers Table */}
        < div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden" >
          <div className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">All Customers</h3>

            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Customer Name
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Contact
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Location
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Bookings
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Total Spent
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
                  {filteredCustomers.map((customer) => (
                    <tr key={customer.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                            <Users size={20} className="text-gray-500" />
                          </div>
                          <div className="ml-3">
                            <div className="text-sm font-medium text-gray-900">{customer.name}</div>
                            <div className="text-sm text-gray-500">Member since {new Date(customer.joinDate).toLocaleDateString()}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{customer.email}</div>
                        <div className="text-sm text-gray-500">{customer.phone}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center text-sm text-gray-900">
                          <MapPin size={16} className="mr-1" />
                          {customer.city}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{customer.totalBookings}</div>
                        <div className="text-sm text-gray-500">Last: {new Date(customer.lastBooking).toLocaleDateString()}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">${customer.totalSpent}</div>
                        <div className="text-sm text-gray-500">{customer.loyaltyPoints} points</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center text-sm text-gray-900">
                          <Star size={16} className="text-amber-400 fill-current mr-1" />
                          {customer.rating}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${customer.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                          }`}>
                          {customer.isActive ? 'Active' : 'Inactive'}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <div className="flex items-center gap-2">
                          <button
                            onClick={() => {
                              setSelectedCustomer(customer);
                              // View customer details
                            }}
                            className="text-orange-600 hover:text-orange-800 transition-colors"
                            title="View"
                          >
                            <Eye size={16} />
                          </button>
                          <button
                            onClick={() => {
                              setSelectedCustomer(customer);
                              // Edit customer
                            }}
                            className="text-orange-600 hover:text-orange-800 transition-colors"
                            title="Edit"
                          >
                            <Edit size={16} />
                          </button>
                          <button
                            onClick={() => {
                              // Suspend/unsuspend customer
                              const action = customer.isActive ? 'suspend' : 'activate';
                              if (window.confirm(`Are you sure you want to ${action} ${customer.name}?`)) {
                                // Handle suspend/activate
                              }
                            }}
                            className={`${customer.isActive ? 'text-red-600 hover:text-red-800' : 'text-green-600 hover:text-green-800'} transition-colors`}
                            title={customer.isActive ? 'Suspend' : 'Activate'}
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
        </div>
      </div>

      {/* Add New Customer Modal */}
      {showNewCustomerModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 animate-fade-in">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl mx-4 max-h-[90vh] overflow-y-auto animate-scale-in">
            <div className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-2xl font-bold text-gray-900 flex items-center gap-3">
                  <div className="w-10 h-10 bg-orange-500 rounded-xl flex items-center justify-center">
                    <UserPlus className="text-white" size={20} />
                  </div>
                  Add New Customer
                </h3>
                <button
                  onClick={() => setShowNewCustomerModal(false)}
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
                    value={newCustomerForm.name}
                    onChange={(e) => setNewCustomerForm({ ...newCustomerForm, name: e.target.value })}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 transition-all"
                    placeholder="John Doe"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Email Address *</label>
                  <input
                    type="email"
                    value={newCustomerForm.email}
                    onChange={(e) => setNewCustomerForm({ ...newCustomerForm, email: e.target.value })}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 transition-all"
                    placeholder="john@example.com"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Phone Number *</label>
                  <input
                    type="tel"
                    value={newCustomerForm.phone}
                    onChange={(e) => setNewCustomerForm({ ...newCustomerForm, phone: e.target.value })}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 transition-all"
                    placeholder="+1 (555) 123-4567"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">City *</label>
                  <input
                    type="text"
                    value={newCustomerForm.city}
                    onChange={(e) => setNewCustomerForm({ ...newCustomerForm, city: e.target.value })}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 transition-all"
                    placeholder="New York"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Address</label>
                  <textarea
                    value={newCustomerForm.address}
                    onChange={(e) => setNewCustomerForm({ ...newCustomerForm, address: e.target.value })}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 transition-all"
                    rows={3}
                    placeholder="123 Main St, Apt 4B"
                  />
                </div>
              </div>

              <div className="mb-6">
                <label className="block text-sm font-medium text-gray-700 mb-2">Notes</label>
                <textarea
                  value={newCustomerForm.notes}
                  onChange={(e) => setNewCustomerForm({ ...newCustomerForm, notes: e.target.value })}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 transition-all"
                  rows={4}
                  placeholder="Additional notes about the customer..."
                />
              </div>

              <div className="flex justify-end gap-4">
                <button
                  onClick={() => setShowNewCustomerModal(false)}
                  className="px-6 py-3 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleAddCustomer}
                  disabled={isSubmitting}
                  className="px-6 py-3 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                >
                  {isSubmitting ? (
                    <>
                      <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                      Adding...
                    </>
                  ) : (
                    <>
                      <Zap size={16} />
                      Add Customer
                    </>
                  )}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Export Customers Modal */}
      {showExportModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 animate-fade-in">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-xl mx-4 animate-scale-in">
            <div className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-2xl font-bold text-gray-900 flex items-center gap-3">
                  <div className="w-10 h-10 bg-orange-500 rounded-xl flex items-center justify-center">
                    <Download className="text-white" size={20} />
                  </div>
                  Export Customers
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
                        className="w-4 h-4 text-orange-600 focus:ring-orange-500"
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
                        className="w-4 h-4 text-orange-600 focus:ring-orange-500"
                      />
                      <span className="text-sm font-medium text-gray-700">Excel</span>
                      <span className="text-xs text-gray-500">(.xlsx file)</span>
                    </label>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Customer Status</label>
                  <select
                    value={exportStatus}
                    onChange={(e) => setExportStatus(e.target.value as 'active' | 'blocked' | 'all')}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                  >
                    <option value="all">All Customers</option>
                    <option value="active">Active Only</option>
                    <option value="blocked">Blocked Only</option>
                  </select>
                </div>
              </div>

              <div className="flex justify-end gap-4">
                <button
                  onClick={() => setShowExportModal(false)}
                  className="px-6 py-3 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleExportCustomers}
                  disabled={isSubmitting}
                  className="px-6 py-3 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
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
      )}

      {/* Customer Analytics Modal */}
      {showAnalyticsModal && analyticsData && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 animate-fade-in">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-6xl mx-4 max-h-[90vh] overflow-y-auto animate-scale-in">
            <div className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-2xl font-bold text-gray-900 flex items-center gap-3">
                  <div className="w-10 h-10 bg-orange-500 rounded-xl flex items-center justify-center">
                    <BarChart3 className="text-white" size={20} />
                  </div>
                  Customer Analytics Dashboard
                </h3>
                <button
                  onClick={() => setShowAnalyticsModal(false)}
                  className="text-gray-400 hover:text-gray-600 transition-colors"
                >
                  <X size={24} />
                </button>
              </div>

              {/* Analytics Overview Cards */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <div className="bg-orange-50 rounded-xl p-6 border border-orange-200">
                  <div className="flex items-center justify-between mb-2">
                    <div className="text-3xl font-bold text-orange-900">{analyticsData.totalCustomers}</div>
                    <div className="p-2 bg-orange-100 rounded-lg">
                      <Users size={20} className="text-orange-600" />
                    </div>
                  </div>
                  <div className="text-sm font-medium text-orange-700">Total Customers</div>
                </div>

                <div className="bg-orange-50 rounded-xl p-6 border border-orange-200">
                  <div className="flex items-center justify-between mb-2">
                    <div className="text-3xl font-bold text-orange-900">{analyticsData.activeCustomers}</div>
                    <div className="p-2 bg-orange-100 rounded-lg">
                      <Heart className="text-orange-600" size={20} />
                    </div>
                  </div>
                  <div className="text-sm font-medium text-orange-700">Active Customers</div>
                </div>

                <div className="bg-orange-50 rounded-xl p-6 border border-orange-200">
                  <div className="flex items-center justify-between mb-2">
                    <div className="text-3xl font-bold text-orange-900">{analyticsData.newCustomers}</div>
                    <div className="p-2 bg-orange-100 rounded-lg">
                      <UserPlus className="text-orange-600" size={20} />
                    </div>
                  </div>
                  <div className="text-sm font-medium text-orange-700">New This Month</div>
                </div>

                <div className="bg-orange-50 rounded-xl p-6 border border-orange-200">
                  <div className="flex items-center justify-between mb-2">
                    <div className="text-3xl font-bold text-orange-900">{analyticsData.retentionRate}%</div>
                    <div className="p-2 bg-orange-100 rounded-lg">
                      <Target className="text-orange-600" size={20} />
                    </div>
                  </div>
                  <div className="text-sm font-medium text-orange-700">Retention Rate</div>
                </div>
              </div>

              {/* Charts Section */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
                {/* Bookings by Month Chart */}
                <div className="bg-white rounded-xl p-6 border border-gray-200">
                  <h4 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                    <CalendarDays className="text-orange-600" size={20} />
                    Bookings by Month
                  </h4>
                  <div className="h-64 flex items-end justify-between">
                    {analyticsData.bookingsByMonth.map((month, index) => (
                      <div key={month.month} className="flex flex-col items-center">
                        <div className="text-xs text-gray-600 mb-2">{month.month}</div>
                        <div className="relative w-8 flex-1">
                          <div
                            className="absolute bottom-0 w-full bg-gradient-to-t from-orange-500 to-orange-400 rounded-t"
                            style={{ height: `${(month.bookings / 70) * 100}%` }}
                          ></div>
                        </div>
                        <div className="text-xs text-gray-900 mt-2">{month.bookings}</div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Customer Distribution Chart */}
                <div className="bg-white rounded-xl p-6 border border-gray-200">
                  <h4 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                    <PieChart className="text-orange-600" size={20} />
                    Customer Distribution
                  </h4>
                  <div className="space-y-3">
                    {analyticsData.customerDistribution.map((city, index) => (
                      <div key={city.city} className="flex items-center justify-between">
                        <div className="flex items-center gap-2">
                          <div className={`w-3 h-3 rounded-full ${index === 0 ? 'bg-orange-500' :
                            index === 1 ? 'bg-orange-400' :
                              index === 2 ? 'bg-orange-300' :
                                'bg-orange-200'
                            }`}></div>
                          <span className="text-sm font-medium text-gray-900">{city.city}</span>
                        </div>
                        <div className="flex items-center gap-4">
                          <div className="text-sm text-gray-600">{city.count} customers</div>
                          <div className="text-sm font-semibold text-gray-900">
                            {((city.count / analyticsData.totalCustomers) * 100).toFixed(1)}%
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* Top Customers Table */}
              <div className="bg-white rounded-xl p-6 border border-gray-200">
                <h4 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                  <Award className="text-orange-600" size={20} />
                  Top Customers by Revenue
                </h4>
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead>
                      <tr className="border-b border-gray-200">
                        <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Rank</th>
                        <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Customer</th>
                        <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Bookings</th>
                        <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Revenue</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200">
                      {analyticsData.topCustomers.map((customer, index) => (
                        <tr key={customer.name} className="hover:bg-gray-50">
                          <td className="px-4 py-3">
                            <div className="flex items-center gap-2">
                              <div className={`w-6 h-6 rounded-full flex items-center justify-center text-white text-xs font-bold ${index === 0 ? 'bg-yellow-500' :
                                index === 1 ? 'bg-gray-400' :
                                  index === 2 ? 'bg-orange-400' :
                                    'bg-amber-600'
                                }`}>
                                {index + 1}
                              </div>
                              <span className="text-sm font-medium text-gray-900">{customer.name}</span>
                            </div>
                          </td>
                          <td className="px-4 py-3 text-sm text-gray-900">{customer.bookings || 0}</td>
                          <td className="px-4 py-3 text-sm font-semibold text-gray-900">${(customer.spent || 0).toLocaleString()}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>

              <div className="flex justify-end mt-6">
                <button
                  onClick={() => setShowAnalyticsModal(false)}
                  className="px-6 py-3 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300 transition-colors"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}

// Add custom animations
const style = document.createElement('style');
style.textContent = `
  @keyframes fade-in {
    from { opacity: 0; }
    to { opacity: 1; }
  }
  
  @keyframes scale-in {
    from { 
      opacity: 0;
      transform: scale(0.9);
    }
    to { 
      opacity: 1;
      transform: scale(1);
    }
  }
  
  .animate-fade-in {
    animation: fade-in 0.3s ease-out;
  }
  
  .animate-scale-in {
    animation: scale-in 0.3s ease-out;
  }
`;
if (typeof window !== 'undefined') {
  document.head.appendChild(style);
}
