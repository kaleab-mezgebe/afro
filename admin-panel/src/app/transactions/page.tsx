'use client';

import { useState, useEffect } from 'react';
import AdminLayout from '@/components/AdminLayout';
import {
  DollarSign,
  TrendingUp,
  TrendingDown,
  Search,
  Filter,
  Download,
  Eye,
  CreditCard,
  ArrowUpRight,
  ArrowDownRight,
  Calendar,
  Users,
  Activity,
  CheckCircle,
  Clock,
  AlertCircle,
} from 'lucide-react';
import { TransactionsService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';

interface Transaction {
  id: string;
  type: 'payment' | 'refund' | 'fee';
  amount: number;
  currency: string;
  status: 'completed' | 'pending' | 'failed';
  customerName: string;
  providerName?: string;
  serviceName: string;
  date: string;
  paymentMethod: string;
  transactionId: string;
  description: string;
}

export default function TransactionsPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<string>('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [dateRange, setDateRange] = useState('7d');

  useEffect(() => {
    if (authenticated) {
      loadTransactions();
    }
  }, [authenticated]);

  const loadTransactions = async () => {
    try {
      const response = await TransactionsService.getAll({
        page: 1,
        limit: 50,
        search: searchTerm,
        type: filter === 'all' ? undefined : filter,
        dateRange: dateRange
      });

      if (response.success && response.data) {
        // Handle both raw array and paginated object formats just in case
        const data = response.data as any;
        const transactionData = Array.isArray(data)
          ? data
          : (data.transactions || []);

        setTransactions(transactionData);
      }
    } catch (error) {
      toast.error('Failed to load transactions');
      console.error('Transactions loading error:', error);
    } finally {
      setLoading(false);
    }
  };

  const validTransactions = Array.isArray(transactions) ? transactions : ((transactions as any)?.transactions || []);

  const filteredTransactions = validTransactions.filter((transaction: Transaction) => {
    const matchesSearch = searchTerm === '' ||
      transaction.customerName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      transaction.providerName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      transaction.serviceName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      transaction.transactionId?.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesFilter = filter === 'all' || transaction.type === filter;

    return matchesSearch && matchesFilter;
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

  const totalRevenue = validTransactions.filter((t: Transaction) => t.type === 'payment' && t.status === 'completed').reduce((acc: number, t: Transaction) => acc + (Number(t.amount) || 0), 0);
  const totalRefunds = Math.abs(validTransactions.filter((t: Transaction) => t.type === 'refund' && t.status === 'completed').reduce((acc: number, t: Transaction) => acc + (Number(t.amount) || 0), 0));
  const pendingTransactions = validTransactions.filter((t: Transaction) => t.status === 'pending').length;
  const failedTransactions = validTransactions.filter((t: Transaction) => t.status === 'failed').length;
  const netRevenue = totalRevenue - totalRefunds;

  return (
    <AdminLayout>
      <div className="page-content">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Transactions</h1>
          <p className="text-gray-600">Monitor all financial transactions and payments</p>
        </div>

        {/* Actions Bar */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4 mb-6 flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
              <input
                type="text"
                placeholder="Search transactions..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 bg-gray-50 text-gray-900 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 w-64"
              />
            </div>
            <div className="flex items-center gap-2">
              <Filter size={20} className="text-gray-400" />
              <select
                className="px-4 py-2 bg-white text-gray-700 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500"
                value={filter}
                onChange={(e) => setFilter(e.target.value)}
              >
                <option value="all">All Types</option>
                <option value="payment">Payments</option>
                <option value="refund">Refunds</option>
                <option value="fee">Fees</option>
              </select>
              <select
                className="px-4 py-2 bg-white text-gray-700 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500"
                value={dateRange}
                onChange={(e) => setDateRange(e.target.value)}
              >
                <option value="7d">Last 7 days</option>
                <option value="30d">Last 30 days</option>
                <option value="90d">Last 90 days</option>
                <option value="all">All time</option>
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
                <p className="stat-label">Total Revenue</p>
                <p className="stat-value">${(Number(totalRevenue) || 0).toFixed(2)}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  18% from last month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-green-100">
                <DollarSign size={24} className="text-green-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Net Revenue</p>
                <p className="stat-value">${(Number(netRevenue) || 0).toFixed(2)}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  15% from last month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-blue-100">
                <Activity size={24} className="text-blue-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Pending</p>
                <p className="stat-value">{pendingTransactions}</p>
                <div className="stat-change positive">
                  <Clock size={12} />
                  Need attention
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
                <p className="stat-label">Failed</p>
                <p className="stat-value">{failedTransactions}</p>
                <div className="stat-change negative">
                  <TrendingDown size={12} />
                  {failedTransactions} failed
                </div>
              </div>
              <div className="p-3 rounded-lg bg-red-100">
                <AlertCircle size={24} className="text-red-600" />
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
                <Download className="text-green-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Export Transactions</p>
                  <p className="text-sm text-gray-600">Download transaction data</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors border border-blue-200">
              <div className="flex items-center gap-3">
                <Activity className="text-blue-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Transaction Analytics</p>
                  <p className="text-sm text-gray-600">View payment trends</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-purple-50 hover:bg-purple-100 rounded-xl transition-colors border border-purple-200">
              <div className="flex items-center gap-3">
                <CreditCard className="text-purple-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Payment Methods</p>
                  <p className="text-sm text-gray-600">Configure payment options</p>
                </div>
              </div>
            </button>
          </div>
        </div>

        {/* Transactions Table */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">All Transactions</h3>

            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Transaction ID
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Customer
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Service
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Type
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Amount
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Payment Method
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Date
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
                  {filteredTransactions.map((transaction: Transaction) => (
                    <tr key={transaction.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">{transaction.transactionId}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center mr-3">
                            <Users size={16} className="text-gray-500" />
                          </div>
                          <div>
                            <div className="text-sm font-medium text-gray-900">{transaction.customerName}</div>
                            {transaction.providerName && (
                              <div className="text-sm text-gray-500">Provider: {transaction.providerName}</div>
                            )}
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{transaction.serviceName}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 text-xs rounded-full ${transaction.type === 'payment' ? 'bg-green-100 text-green-800' :
                          transaction.type === 'refund' ? 'bg-red-100 text-red-800' :
                            'bg-amber-100 text-amber-800'
                          }`}>
                          {transaction.type}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className={`text-sm font-medium ${transaction.type === 'payment' ? 'text-green-600' :
                          transaction.type === 'refund' ? 'text-red-600' :
                            'text-amber-600'
                          }`}>
                          {transaction.type === 'payment' ? '+' : ''}
                          ${(Number(transaction.amount) || 0).toFixed(2)}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center text-sm text-gray-900">
                          <CreditCard size={16} className="mr-1" />
                          {transaction.paymentMethod}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">
                          {new Date(transaction.date).toLocaleDateString()}
                        </div>
                        <div className="text-sm text-gray-500">
                          {new Date(transaction.date).toLocaleTimeString()}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${transaction.status === 'completed' ? 'bg-green-100 text-green-800' :
                          transaction.status === 'pending' ? 'bg-amber-100 text-amber-800' :
                            'bg-red-100 text-red-800'
                          }`}>
                          {transaction.status}
                        </span>
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
