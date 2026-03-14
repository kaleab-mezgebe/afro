'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
import {
  BarChart3,
  PieChart,
  TrendingUp,
  Search,
  Filter,
  Download,
  Eye,
  Calendar,
  FileText,
  Users,
  DollarSign,
  Star,
  Clock,
  CheckCircle,
  AlertCircle,
  Activity,
} from 'lucide-react';
import { ReportsService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';

interface Report {
  id: string;
  title: string;
  type: 'financial' | 'customer' | 'performance' | 'operational';
  description: string;
  generatedDate: string;
  period: string;
  status: 'completed' | 'generating' | 'scheduled';
  fileSize: string;
  downloadUrl?: string;
}

export default function ReportsPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [reports, setReports] = useState<Report[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');

  useEffect(() => {
    if (authenticated) {
      loadReports();
    }
  }, [authenticated]);

  const loadReports = async () => {
    try {
      const response = await ReportsService.getAll({
        search: searchTerm,
        type: typeFilter === 'all' ? undefined : typeFilter,
        status: statusFilter === 'all' ? undefined : statusFilter
      });

      if (response.success && response.data) {
        setReports(response.data);
      }
    } catch (error) {
      toast.error('Failed to load reports');
      console.error('Reports loading error:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleGenerateReport = async (reportType: string, params: any) => {
    try {
      const response = await ReportsService.generate(reportType, params);
      if (response.success) {
        toast.success('Report generation started successfully');
        loadReports(); // Reload to show new report
      }
    } catch (error) {
      toast.error('Failed to generate report');
    }
  };

  const handleDownloadReport = async (reportId: string) => {
    try {
      const response = await ReportsService.download(reportId);
      if (response.success) {
        // Create download link
        const link = document.createElement('a');
        link.href = response.data.downloadUrl;
        link.download = response.data.title;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        toast.success('Report downloaded successfully');
      }
    } catch (error) {
      toast.error('Failed to download report');
    }
  };

  const handleScheduleReport = async (reportConfig: any) => {
    try {
      const response = await ReportsService.schedule(reportConfig);
      if (response.success) {
        toast.success('Report scheduled successfully');
        loadReports();
      }
    } catch (error) {
      toast.error('Failed to schedule report');
    }
  };

  const handleViewReport = async (reportId: string) => {
    try {
      console.log('View report:', reportId);
      // TODO: Show report details modal
    } catch (error) {
      toast.error('Failed to load report details');
    }
  };

  const filteredReports = reports.filter(report => {
    const matchesSearch = searchTerm === '' ||
      report.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      report.description.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesType = typeFilter === 'all' || report.type === typeFilter;
    const matchesStatus = statusFilter === 'all' || report.status === statusFilter;

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

  const completedReports = reports.filter(r => r.status === 'completed').length;
  const generatingReports = reports.filter(r => r.status === 'generating').length;
  const scheduledReports = reports.filter(r => r.status === 'scheduled').length;

  return (
    <AdminLayout>
      <div className="page-content">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Reports Center</h1>
          <p className="text-gray-600">Generate and manage business reports and analytics</p>
        </div>

        {/* Actions Bar */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4 mb-6 flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
              <input
                type="text"
                placeholder="Search reports..."
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
                <option value="financial">Financial</option>
                <option value="customer">Customer</option>
                <option value="performance">Performance</option>
                <option value="operational">Operational</option>
              </select>
              <select
                className="px-4 py-2 bg-white text-gray-700 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500"
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
              >
                <option value="all">All Status</option>
                <option value="completed">Completed</option>
                <option value="generating">Generating</option>
                <option value="scheduled">Scheduled</option>
              </select>
            </div>
          </div>
          <div className="flex items-center gap-4">
            <button
              onClick={() => handleGenerateReport('financial', { period: 'monthly' })}
              className="flex items-center gap-2 px-4 py-2 bg-amber-500 text-white rounded-lg hover:bg-amber-600"
            >
              <FileText size={20} />
              <span>Generate Report</span>
            </button>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Total Reports</p>
                <p className="stat-value">{reports.length}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  8 new this month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-blue-100">
                <FileText size={24} className="text-blue-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Completed</p>
                <p className="stat-value">{completedReports}</p>
                <div className="stat-change positive">
                  <CheckCircle size={12} />
                  Ready to download
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
                <p className="stat-label">Generating</p>
                <p className="stat-value">{generatingReports}</p>
                <div className="stat-change positive">
                  <Clock size={12} />
                  In progress
                </div>
              </div>
              <div className="p-3 rounded-lg bg-amber-100">
                <Activity size={24} className="text-amber-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Scheduled</p>
                <p className="stat-value">{scheduledReports}</p>
                <div className="stat-change positive">
                  <Calendar size={12} />
                  Auto-generated
                </div>
              </div>
              <div className="p-3 rounded-lg bg-purple-100">
                <Calendar size={24} className="text-purple-600" />
              </div>
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="mb-8">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">Quick Actions</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <button className="w-full text-left p-4 bg-green-50 hover:bg-green-100 rounded-xl transition-colors border border-green-200">
              <div className="flex items-center gap-3">
                <BarChart3 className="text-green-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Financial Report</p>
                  <p className="text-sm text-gray-600">Revenue & expenses</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors border border-blue-200">
              <div className="flex items-center gap-3">
                <Users className="text-blue-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Customer Report</p>
                  <p className="text-sm text-gray-600">Analytics & insights</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-purple-50 hover:bg-purple-100 rounded-xl transition-colors border border-purple-200">
              <div className="flex items-center gap-3">
                <Star className="text-purple-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Performance Report</p>
                  <p className="text-sm text-gray-600">Provider metrics</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-amber-50 hover:bg-amber-100 rounded-xl transition-colors border border-amber-200">
              <div className="flex items-center gap-3">
                <Activity className="text-amber-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Operational Report</p>
                  <p className="text-sm text-gray-600">System performance</p>
                </div>
              </div>
            </button>
          </div>
        </div>

        {/* Reports Table */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">All Reports</h3>

            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Report Title
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Type
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Period
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Generated Date
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      File Size
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
                  {filteredReports.map((report) => (
                    <tr key={report.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                            <FileText size={20} className="text-gray-500" />
                          </div>
                          <div className="ml-3">
                            <div className="text-sm font-medium text-gray-900">{report.title}</div>
                            <div className="text-sm text-gray-500">{report.description}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 text-xs rounded-full ${report.type === 'financial' ? 'bg-green-100 text-green-800' :
                          report.type === 'customer' ? 'bg-blue-100 text-blue-800' :
                            report.type === 'performance' ? 'bg-purple-100 text-purple-800' :
                              'bg-amber-100 text-amber-800'
                          }`}>
                          {report.type}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{report.period}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">
                          {new Date(report.generatedDate).toLocaleDateString()}
                        </div>
                        <div className="text-sm text-gray-500">
                          {new Date(report.generatedDate).toLocaleTimeString()}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{report.fileSize}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${report.status === 'completed' ? 'bg-green-100 text-green-800' :
                          report.status === 'generating' ? 'bg-amber-100 text-amber-800' :
                            'bg-blue-100 text-blue-800'
                          }`}>
                          {report.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <div className="flex items-center gap-2">
                          <button className="text-gray-600 hover:text-gray-900" title="View">
                            <Eye size={16} />
                          </button>
                          {report.status === 'completed' && (
                            <button className="text-blue-600 hover:text-blue-900" title="Download">
                              <Download size={16} />
                            </button>
                          )}
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
