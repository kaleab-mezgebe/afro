'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
import {
  DollarSign,
  TrendingUp,
  Search,
  Filter,
  Download,
  Eye,
  Calendar,
  CreditCard,
  Wallet,
  Send,
  CheckCircle,
  Clock,
  AlertCircle,
  Users,
  Building,
} from 'lucide-react';
import { PayoutsService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';

interface Payout {
  id: string;
  recipientName: string;
  recipientType: string;
  providerName: string;
  providerType: string;
  shopName?: string;
  amount: number;
  currency: string;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  period?: string;
  bankAccount: string;
  requestDate: string;
  scheduledDate: string;
  processedDate?: string;
  completedDate?: string;
  transactionCount: number;
  commission: number;
  netAmount: number;
  notes?: string;
  description: string;
  failureReason?: string;
  frequency: string;
  paymentMethod: string;
  reference: string;
}

export default function PayoutsPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [payouts, setPayouts] = useState<Payout[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [typeFilter, setTypeFilter] = useState('all');

  useEffect(() => {
    if (authenticated) {
      loadPayouts();
    }
  }, [authenticated]);

  const loadPayouts = async () => {
    try {
      const response = await PayoutsService.getAll({
        page: 1,
        limit: 50,
        search: searchTerm,
        status: statusFilter === 'all' ? undefined : statusFilter,
        type: typeFilter === 'all' ? undefined : typeFilter
      });

      if (response.success && response.data) {
        // Handle the correct API response structure: data.payouts
        let payoutsData: any[] = [];

        const responseData = response.data as any;

        if (responseData && Array.isArray(responseData.payouts)) {
          payoutsData = responseData.payouts.map((payout: any) => ({
            ...payout,
            amount: parseFloat(payout.amount) || 0,
            netAmount: parseFloat(payout.netAmount) || 0,
            commission: parseFloat(payout.commission) || 0,
            transactionCount: parseInt(payout.transactionCount) || 0
          }));
        } else if (Array.isArray(responseData)) {
          payoutsData = responseData.map((payout: any) => ({
            ...payout,
            amount: parseFloat(payout.amount) || 0,
            netAmount: parseFloat(payout.netAmount) || 0,
            commission: parseFloat(payout.commission) || 0,
            transactionCount: parseInt(payout.transactionCount) || 0
          }));
        } else if (responseData && responseData.data && Array.isArray(responseData.data.payouts)) {
          payoutsData = responseData.data.payouts.map((payout: any) => ({
            ...payout,
            amount: parseFloat(payout.amount) || 0,
            netAmount: parseFloat(payout.netAmount) || 0,
            commission: parseFloat(payout.commission) || 0,
            transactionCount: parseInt(payout.transactionCount) || 0
          }));
        }

        setPayouts(payoutsData);
      } else {
        setPayouts([]); // Set to empty array if no data
      }
    } catch (error) {
      toast.error('Failed to load payouts');
      console.error('Payouts loading error:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredPayouts = (payouts || []).filter(payout => {
    const matchesSearch = searchTerm === '' ||
      payout.recipientName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      payout.reference?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      payout.description?.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesStatus = statusFilter === 'all' || payout.status === statusFilter;
    const matchesType = typeFilter === 'all' || payout.recipientType === typeFilter;

    return matchesSearch && matchesStatus && matchesType;
  });

  const totalPayouts = (payouts || []).reduce((acc, p) => acc + (p.amount || 0), 0);
  const completedPayouts = (payouts || []).filter(p => p.status === 'completed').reduce((acc, p) => acc + (p.amount || 0), 0);
  const pendingPayouts = (payouts || []).filter(p => p.status === 'pending').reduce((acc, p) => acc + (p.amount || 0), 0);
  const processingPayouts = (payouts || []).filter(p => p.status === 'processing').reduce((acc, p) => acc + (p.amount || 0), 0);

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
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Payout Management</h1>
          <p className="text-gray-600">Manage payments to providers, salons, and barbershops</p>
        </div>

        {/* Actions Bar */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4 mb-6 flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
              <input
                type="text"
                placeholder="Search payouts..."
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
                <option value="processing">Processing</option>
                <option value="completed">Completed</option>
                <option value="failed">Failed</option>
              </select>
              <select
                className="px-4 py-2 bg-white text-gray-700 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500"
                value={typeFilter}
                onChange={(e) => setTypeFilter(e.target.value)}
              >
                <option value="all">All Types</option>
                <option value="provider">Providers</option>
                <option value="salon">Salons</option>
                <option value="barbershop">Barbershops</option>
              </select>
            </div>
          </div>
          <div className="flex items-center gap-4">
            <button className="flex items-center gap-2 px-4 py-2 bg-amber-500 text-white rounded-lg hover:bg-amber-600">
              <Send size={20} />
              <span>Process Payouts</span>
            </button>
            <button className="flex items-center gap-2 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">
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
                <p className="stat-label">Total Payouts</p>
                <p className="stat-value">${totalPayouts.toLocaleString()}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  22% from last month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-blue-100">
                <DollarSign size={24} className="text-blue-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Completed</p>
                <p className="stat-value">${completedPayouts.toLocaleString()}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  18% from last week
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
                <p className="stat-label">Pending</p>
                <p className="stat-value">${pendingPayouts.toLocaleString()}</p>
                <div className="stat-change positive">
                  <Clock size={12} />
                  {payouts.filter(p => p.status === 'pending').length} pending
                </div>
              </div>
              <div className="p-3 rounded-lg bg-amber-100">
                <AlertCircle size={24} className="text-amber-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Processing</p>
                <p className="stat-value">${processingPayouts.toLocaleString()}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  {payouts.filter(p => p.status === 'processing').length} in progress
                </div>
              </div>
              <div className="p-3 rounded-lg bg-purple-100">
                <Send size={24} className="text-purple-600" />
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
                <Send className="text-green-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Process All Pending</p>
                  <p className="text-sm text-gray-600">Process pending payouts</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors border border-blue-200">
              <div className="flex items-center gap-3">
                <Download className="text-blue-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Export Payouts</p>
                  <p className="text-sm text-gray-600">Download payout reports</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-purple-50 hover:bg-purple-100 rounded-xl transition-colors border border-purple-200">
              <div className="flex items-center gap-3">
                <Wallet className="text-purple-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Payment Settings</p>
                  <p className="text-sm text-gray-600">Configure payment methods</p>
                </div>
              </div>
            </button>
          </div>
        </div>

        {/* Payouts Table */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">All Payouts</h3>

            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Recipient
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Type
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Amount
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Scheduled Date
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Payment Method
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Reference
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {filteredPayouts.map((payout) => (
                    <tr key={payout.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                            {payout.recipientType === 'provider' ? (
                              <Users size={20} className="text-gray-500" />
                            ) : (
                              <Building size={20} className="text-gray-500" />
                            )}
                          </div>
                          <div className="ml-3">
                            <div className="text-sm font-medium text-gray-900">{payout.recipientName}</div>
                            <div className="text-sm text-gray-500">{payout.description}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 text-xs rounded-full ${payout.recipientType === 'provider' ? 'bg-blue-100 text-blue-800' :
                          payout.recipientType === 'salon' ? 'bg-purple-100 text-purple-800' :
                            'bg-green-100 text-green-800'
                          }`}>
                          {payout.recipientType}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">
                          {payout.currency} {payout.amount.toLocaleString()}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">
                          {new Date(payout.scheduledDate).toLocaleDateString()}
                        </div>
                        {payout.processedDate && (
                          <div className="text-sm text-gray-500">
                            Processed: {new Date(payout.processedDate).toLocaleDateString()}
                          </div>
                        )}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center text-sm text-gray-900">
                          <CreditCard size={16} className="mr-1" />
                          {payout.paymentMethod}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${payout.status === 'completed' ? 'bg-green-100 text-green-800' :
                          payout.status === 'processing' ? 'bg-blue-100 text-blue-800' :
                            payout.status === 'pending' ? 'bg-amber-100 text-amber-800' :
                              'bg-red-100 text-red-800'
                          }`}>
                          {payout.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{payout.reference}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <div className="flex items-center gap-2">
                          <button className="text-gray-600 hover:text-gray-900" title="View">
                            <Eye size={16} />
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
