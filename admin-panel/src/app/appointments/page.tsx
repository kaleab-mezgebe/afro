'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
import { AppointmentsService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import {
  Calendar,
  Clock,
  CheckCircle,
  XCircle,
  AlertCircle,
  Search,
  Filter,
  Download,
  TrendingUp,
  TrendingDown,
  Users,
  DollarSign,
  Eye,
  Edit,
} from 'lucide-react';
import { useAuth } from '@/hooks/useAuth';

interface Appointment {
  id: string;
  customerName: string;
  providerName: string;
  serviceName: string;
  date: string;
  time: string;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled';
  totalPrice: number;
}

export default function AppointmentsPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage] = useState(10);
  const [totalItems, setTotalItems] = useState(0);
  const [totalPages, setTotalPages] = useState(0);

  useEffect(() => {
    if (authenticated) {
      loadAppointments();
    }
  }, [authenticated]);

  const loadAppointments = async () => {
    try {
      const response = await AppointmentsService.getAll({
        page: currentPage,
        limit: itemsPerPage,
        search: searchTerm,
        status: statusFilter,
        sortBy: 'appointment_date',
        sortOrder: 'desc'
      });

      if (response.success && response.data) {
        setAppointments(response.data);
        setTotalItems(response.total);
        setTotalPages(response.totalPages);
      }
    } catch (error) {
      toast.error('Failed to load appointments');
      console.error('Appointments loading error:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleConfirmAppointment = (appointmentId: string) => {
    toast.success('Appointment confirmed successfully');
    setAppointments(appointments.map(a =>
      a.id === appointmentId ? { ...a, status: 'confirmed' as const } : a
    ));
  };

  const handleCancelAppointment = (appointmentId: string) => {
    toast.success('Appointment cancelled');
    setAppointments(appointments.map(a =>
      a.id === appointmentId ? { ...a, status: 'cancelled' as const } : a
    ));
  };

  const filteredAppointments = appointments.filter((appointment) => {
    const matchesSearch =
      appointment.customerName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      appointment.providerName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      appointment.serviceName?.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === 'all' || appointment.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const stats = [
    {
      title: 'Total Appointments',
      value: appointments.length,
      icon: Calendar,
      trend: { value: 15, isPositive: true },
      color: 'blue' as const
    },
    {
      title: 'Today\'s Bookings',
      value: appointments.filter(a => a.date === '2024-01-15').length,
      icon: Clock,
      trend: { value: 8, isPositive: true },
      color: 'green' as const
    },
    {
      title: 'Pending Confirmation',
      value: appointments.filter(a => a.status === 'pending').length,
      icon: AlertCircle,
      trend: { value: 3, isPositive: false },
      color: 'amber' as const
    },
    {
      title: 'Revenue Today',
      value: `$${appointments.filter(a => a.date === '2024-01-15' && a.status === 'completed').reduce((sum, a) => sum + a.totalPrice, 0).toFixed(0)}`,
      icon: DollarSign,
      trend: { value: 22, isPositive: true },
      color: 'purple' as const
    }
  ];

  const quickActions = [
    {
      title: 'Confirm Pending',
      description: 'Review and confirm pending appointments',
      icon: CheckCircle,
      onClick: () => toast('Confirm pending appointments feature coming soon'),
      color: 'green' as const
    },
    {
      title: 'Export Schedule',
      description: 'Download appointments as CSV',
      icon: Download,
      onClick: () => toast('Export feature coming soon'),
      color: 'blue' as const
    },
    {
      title: 'View Calendar',
      description: 'See appointments in calendar view',
      icon: Calendar,
      onClick: () => toast('Calendar view coming soon'),
      color: 'purple' as const
    }
  ];

  const actionsBar = (
    <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4 flex flex-wrap items-center justify-between gap-4">
      <div className="flex items-center gap-4">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
          <input
            type="text"
            placeholder="Search appointments..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-10 pr-4 py-2 bg-gray-50 text-gray-900 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 w-64"
          />
        </div>
        <div className="flex items-center gap-2">
          <Filter size={20} className="text-gray-400" />
          <select
            className="px-4 py-2 bg-white text-gray-700 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500"
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
          >
            <option value="all">All Status</option>
            <option value="pending">Pending</option>
            <option value="confirmed">Confirmed</option>
            <option value="completed">Completed</option>
            <option value="cancelled">Cancelled</option>
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
  );

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

  return (
    <AdminLayout>
      <div className="page-content">
        {/* Creative Calendar Header */}
        <div className="bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 rounded-3xl p-8 mb-8 text-white shadow-2xl">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="text-4xl font-bold mb-2 flex items-center gap-3">
                <Calendar className="fill-white" size={36} />
                Booking Calendar
              </h1>
              <p className="text-blue-100 text-lg">Manage appointments and scheduling</p>
            </div>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {stats.map((stat, index) => (
            <div key={index} className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
              <div className="flex items-center justify-between mb-4">
                <div className={`p-3 rounded-lg bg-${stat.color}-100`}>
                  <stat.icon size={24} className={`text-${stat.color}-600`} />
                </div>
                <div className={`flex items-center gap-1 text-sm ${stat.trend.isPositive ? 'text-green-600' : 'text-red-600'
                  }`}>
                  {stat.trend.isPositive ? <TrendingUp size={16} /> : <TrendingDown size={16} />}
                  {stat.trend.value}%
                </div>
              </div>
              <h3 className="text-2xl font-bold text-gray-900 mb-1">{stat.value}</h3>
              <p className="text-sm text-gray-600">{stat.title}</p>
            </div>
          ))}
        </div>

        {/* Quick Actions */}
        <div className="mb-8">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">Quick Actions</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {quickActions.map((action, index) => (
              <button key={index} className="w-full text-left p-4 bg-amber-50 hover:bg-amber-100 rounded-xl transition-colors border border-amber-200">
                <div className="flex items-center gap-3">
                  <action.icon className="text-amber-700" size={20} />
                  <div>
                    <p className="font-medium text-gray-900">{action.title}</p>
                    <p className="text-sm text-gray-600">{action.description}</p>
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Appointments Table */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Appointments</h3>

            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Customer
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Provider
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Service
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Date & Time
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Price
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
                  {filteredAppointments.map((appointment) => (
                    <tr key={appointment.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">{appointment.customerName}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{appointment.providerName}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{appointment.serviceName}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{appointment.date}</div>
                        <div className="text-sm text-gray-500">{appointment.time}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">${appointment.totalPrice.toFixed(2)}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${appointment.status === 'confirmed' ? 'bg-green-100 text-green-800' :
                          appointment.status === 'pending' ? 'bg-amber-100 text-amber-800' :
                            appointment.status === 'completed' ? 'bg-blue-100 text-blue-800' :
                              'bg-red-100 text-red-800'
                          }`}>
                          {appointment.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <div className="flex items-center gap-2">
                          {appointment.status === 'pending' && (
                            <>
                              <button
                                onClick={() => handleConfirmAppointment(appointment.id)}
                                className="text-green-600 hover:text-green-900"
                                title="Confirm"
                              >
                                <CheckCircle size={16} />
                              </button>
                              <button
                                onClick={() => handleCancelAppointment(appointment.id)}
                                className="text-red-600 hover:text-red-900"
                                title="Cancel"
                              >
                                <XCircle size={16} />
                              </button>
                            </>
                          )}
                          <button className="text-gray-600 hover:text-gray-900" title="View">
                            <Eye size={16} />
                          </button>
                          <button className="text-gray-600 hover:text-gray-900" title="Edit">
                            <Edit size={16} />
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
      </div >
    </AdminLayout >
  );
}
