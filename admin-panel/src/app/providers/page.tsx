'use client';

import { useEffect, useState } from 'react';
import Sidebar from '@/components/layout/Sidebar';
import { api } from '@/lib/api';
import toast from 'react-hot-toast';
import { FiSearch, FiFilter, FiCheck, FiX } from 'react-icons/fi';

interface Provider {
  id: string;
  name: string;
  email: string;
  shopName: string;
  status: string;
  verificationStatus: string;
  createdAt: string;
}

export default function ProvidersPage() {
  const [providers, setProviders] = useState<Provider[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

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
    const reason = prompt('Enter rejection reason:');
    if (!reason) return;

    try {
      await api.rejectProvider(providerId, reason);
      toast.success('Provider rejected');
      loadProviders();
    } catch (error) {
      toast.error('Failed to reject provider');
    }
  };

  const filteredProviders = providers.filter(provider => {
    const matchesSearch = provider.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         provider.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         provider.shopName?.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === 'all' || provider.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  return (
    <div className="flex">
      <Sidebar />
      <div className="flex-1 p-8 bg-gray-50">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Provider Management</h1>
          <p className="text-gray-600 mt-2">Approve, verify, and manage service providers</p>
        </div>

        <div className="bg-white rounded-lg shadow mb-6">
          <div className="p-6 border-b">
            <div className="flex flex-col md:flex-row gap-4">
              <div className="flex-1 relative">
                <FiSearch className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                <input
                  type="text"
                  placeholder="Search providers..."
                  className="w-full pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
              <div className="flex items-center gap-2">
                <FiFilter className="text-gray-400" />
                <select
                  className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={statusFilter}
                  onChange={(e) => setStatusFilter(e.target.value)}
                >
                  <option value="all">All Status</option>
                  <option value="pending">Pending</option>
                  <option value="approved">Approved</option>
                  <option value="rejected">Rejected</option>
                </select>
              </div>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Provider
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Shop Name
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Verification
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Registered
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {loading ? (
                  <tr>
                    <td colSpan={6} className="px-6 py-4 text-center">
                      <div className="flex justify-center">
                        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
                      </div>
                    </td>
                  </tr>
                ) : filteredProviders.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="px-6 py-4 text-center text-gray-500">
                      No providers found
                    </td>
                  </tr>
                ) : (
                  filteredProviders.map((provider) => (
                    <tr key={provider.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div>
                          <div className="text-sm font-medium text-gray-900">{provider.name || 'N/A'}</div>
                          <div className="text-sm text-gray-500">{provider.email}</div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {provider.shopName || 'N/A'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                          provider.status === 'approved' ? 'bg-green-100 text-green-800' :
                          provider.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                          'bg-red-100 text-red-800'
                        }`}>
                          {provider.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                          provider.verificationStatus === 'verified' ? 'bg-blue-100 text-blue-800' :
                          'bg-gray-100 text-gray-800'
                        }`}>
                          {provider.verificationStatus || 'unverified'}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {new Date(provider.createdAt).toLocaleDateString()}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        {provider.status === 'pending' && (
                          <>
                            <button
                              onClick={() => handleApprove(provider.id)}
                              className="text-green-600 hover:text-green-900 mr-3"
                              title="Approve"
                            >
                              <FiCheck className="inline h-5 w-5" />
                            </button>
                            <button
                              onClick={() => handleReject(provider.id)}
                              className="text-red-600 hover:text-red-900 mr-3"
                              title="Reject"
                            >
                              <FiX className="inline h-5 w-5" />
                            </button>
                          </>
                        )}
                        <button className="text-blue-600 hover:text-blue-900">
                          View Details
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
