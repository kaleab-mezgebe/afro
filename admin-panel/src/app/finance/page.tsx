'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
import {
  DollarSign,
  TrendingUp,
  TrendingDown,
  Search,
  Filter,
  Download,
  Eye,
  Calendar,
  CreditCard,
  Wallet,
  PiggyBank,
  BarChart3,
  PieChart,
  Activity,
  Clock,
  AlertCircle,
  CheckCircle,
} from 'lucide-react';
import { TransactionsService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';

interface Transaction {
  id: string;
  type: 'revenue' | 'expense' | 'refund';
  amount: number;
  description: string;
  category: string;
  date: string;
  status: 'completed' | 'pending' | 'failed';
  paymentMethod: string;
}

export default function FinancePage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');

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
        type: typeFilter === 'all' ? undefined : typeFilter,
        status: statusFilter === 'all' ? undefined : statusFilter
      });

      if (response.success && response.data) {
        setTransactions(response.data);
      }
    } catch (error) {
      toast.error('Failed to load finance data');
      console.error('Finance loading error:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredTransactions = transactions.filter(transaction => {
    const matchesSearch = searchTerm === '' ||
      transaction.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
      transaction.category.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesType = typeFilter === 'all' || transaction.type === typeFilter;
    const matchesStatus = statusFilter === 'all' || transaction.status === statusFilter;

    return matchesSearch && matchesType && matchesStatus;
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

  const totalRevenue = transactions.filter(t => t.type === 'revenue').reduce((acc, t) => acc + t.amount, 0);
  const totalExpenses = transactions.filter(t => t.type === 'expense').reduce((acc, t) => acc + t.amount, 0);
  const totalRefunds = Math.abs(transactions.filter(t => t.type === 'refund').reduce((acc, t) => acc + t.amount, 0));
  const netProfit = totalRevenue - totalExpenses - totalRefunds;
  const pendingTransactions = transactions.filter(t => t.status === 'pending').length;

  return (
    <AdminLayout>
      <div className="page-content">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Financial Dashboard</h1>
          <p className="text-gray-600">Monitor revenue, expenses, and financial performance</p>
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
                value={typeFilter}
                onChange={(e) => setTypeFilter(e.target.value)}
              >
                <option value="all">All Types</option>
                <option value="revenue">Revenue</option>
                <option value="expense">Expenses</option>
                <option value="refund">Refunds</option>
              </select>
              <select
                className="px-4 py-2 bg-white text-gray-700 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500"
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
              >
                <option value="all">All Status</option>
                <option value="completed">Completed</option>
                <option value="pending">Pending</option>
                <option value="failed">Failed</option>
              </select>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <button className="px-4 py-2 bg-amber-500 text-white rounded-lg hover:bg-amber-600 transition-colors flex items-center gap-2">
              <Download size={16} />
              Export
            </button>
          </div>
        </div>

        {/* Summary Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <div className="flex items-center justify-between mb-4">
              <div className="p-2 bg-green-100 rounded-lg">
                <DollarSign className="text-green-600" size={24} />
              </div>
              <div className="flex items-center text-green-600 text-sm">
                <TrendingUp size={16} className="mr-1" />
                +12%
              </div>
            </div>
            <h3 className="text-2xl font-bold text-gray-900">${totalRevenue.toLocaleString()}</h3>
            <p className="text-gray-600 text-sm">Total Revenue</p>
          </div>

          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <div className="flex items-center justify-between mb-4">
              <div className="p-2 bg-red-100 rounded-lg">
                <CreditCard className="text-red-600" size={24} />
              </div>
              <div className="flex items-center text-red-600 text-sm">
                <TrendingDown size={16} className="mr-1" />
                -8%
              </div>
            </div>
            <h3 className="text-2xl font-bold text-gray-900">${totalExpenses.toLocaleString()}</h3>
            <p className="text-gray-600 text-sm">Total Expenses</p>
          </div>

          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <div className="flex items-center justify-between mb-4">
              <div className="p-3 bg-amber-100 rounded-lg">
                <PiggyBank className="text-amber-700" size={24} />
              </div>
              <Wallet className="text-amber-500" size={20} />
            </div>
            <h3 className="text-2xl font-bold text-gray-900">${netProfit.toLocaleString()}</h3>
            <p className="text-gray-600 text-sm mt-1">Net Profit</p>
          </div>

          <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
            <div className="flex items-center justify-between mb-4">
              <div className="p-3 bg-blue-100 rounded-lg">
                <Clock className="text-blue-700" size={24} />
              </div>
              <AlertCircle className="text-blue-500" size={20} />
            </div>
            <h3 className="text-2xl font-bold text-gray-900">{pendingTransactions}</h3>
            <p className="text-gray-600 text-sm mt-1">Pending Transactions</p>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <button className="w-full text-left p-4 bg-green-50 hover:bg-green-100 rounded-xl transition-colors border border-green-200">
            <div className="flex items-center gap-3">
              <BarChart3 className="text-green-700" size={20} />
              <div>
                <p className="font-medium text-gray-900">Generate Report</p>
                <p className="text-sm text-gray-600">Create financial report</p>
              </div>
            </div>
          </button>
          <button className="w-full text-left p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors border border-blue-200">
            <div className="flex items-center gap-3">
              <PieChart className="text-blue-700" size={20} />
              <div>
                <p className="font-medium text-gray-900">Expense Analysis</p>
                <p className="text-sm text-gray-600">View expense breakdown</p>
              </div>
            </div>
          </button>
          <button className="w-full text-left p-4 bg-purple-50 hover:bg-purple-100 rounded-xl transition-colors border border-purple-200">
            <div className="flex items-center gap-3">
              <Activity className="text-purple-700" size={20} />
              <div>
                <p className="font-medium text-gray-900">Revenue Trends</p>
                <p className="text-sm text-gray-600">Track revenue patterns</p>
              </div>
            </div>
          </button>
        </div>

        {/* Transactions Table */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Transactions</h3>

            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Date
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Description
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Category
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
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {filteredTransactions.map((transaction) => (
                    <tr key={transaction.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">
                          {new Date(transaction.date).toLocaleDateString()}
                        </div>
                        <div className="text-sm text-gray-500">
                          {new Date(transaction.date).toLocaleTimeString()}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{transaction.description}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="px-2 py-1 text-xs bg-gray-100 text-gray-700 rounded">
                          {transaction.category}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 text-xs rounded-full ${transaction.type === 'revenue' ? 'bg-green-100 text-green-800' :
                          transaction.type === 'expense' ? 'bg-red-100 text-red-800' :
                            'bg-amber-100 text-amber-800'
                          }`}>
                          {transaction.type}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className={`text-sm font-medium ${transaction.type === 'revenue' ? 'text-green-600' :
                          transaction.type === 'expense' ? 'text-red-600' :
                            'text-amber-600'
                          }`}>
                          {transaction.type === 'revenue' ? '+' : ''}
                          ${transaction.amount.toLocaleString()}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center text-sm text-gray-900">
                          <CreditCard size={16} className="mr-1" />
                          {transaction.paymentMethod}
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
