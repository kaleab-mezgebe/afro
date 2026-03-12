'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
import {
  Scissors,
  Sparkles,
  Heart,
  Palette,
  Search,
  Filter,
  Download,
  Edit,
  Trash2,
  Plus,
  Clock,
  DollarSign,
  Eye,
  CheckCircle,
  TrendingUp,
  Package,
  Grid,
} from 'lucide-react';
import { ServicesService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';

interface Service {
  id: string;
  name: string;
  category: string;
  price: number;
  durationMinutes: number;
  description: string;
  isActive: boolean;
  createdAt: string;
}

export default function ServicesPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [services, setServices] = useState<Service[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('all');

  useEffect(() => {
    if (authenticated) {
      loadServices();
    }
  }, [authenticated]);

  const loadServices = async () => {
    try {
      const response = await ServicesService.getAll({
        page: 1,
        limit: 50,
        search: searchTerm,
        category: categoryFilter
      });

      if (response && (response as any).success && (response as any).data) {
        setServices(Array.isArray((response as any).data) ? (response as any).data : ((response as any).data.services || []));
      } else if (Array.isArray(response)) {
        setServices(response);
      }
    } catch (error) {
      toast.error('Failed to load services');
      console.error('Services loading error:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredServices = services.filter(service => {
    const matchesSearch = searchTerm === '' ||
      service.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      service.description.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesCategory = categoryFilter === 'all' || service.category === categoryFilter;

    return matchesSearch && matchesCategory;
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

  return (
    <AdminLayout>
      <div className="page-content">
        <h1>Services</h1>
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-4xl font-bold mb-2 flex items-center gap-3">
              <Scissors className="fill-white" size={36} />
              Service Menu
            </h1>
            <p className="text-rose-100 text-lg">Curated beauty experiences for every style</p>
          </div>
          <div className="text-center">
            <div className="text-5xl font-bold text-yellow-300">{services.length}</div>
            <div className="text-rose-100">Premium Services</div>
          </div>
        </div>

        {/* Service Categories Preview */}
        <div className="flex gap-3 flex-wrap">
          {['Haircut', 'Color', 'Beard', 'Treatment'].map((category, index) => (
            <div key={category} className="bg-white/20 backdrop-blur px-4 py-2 rounded-full border border-white/30">
              <span className="text-white font-medium">{category}</span>
            </div>
          ))}
        </div>


        {/* Creative Service Stats with Price Tags */}
        < div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8" >
          {/* Total Services - Catalog Style */}
          < div className="bg-gradient-to-br from-rose-50 to-pink-100 rounded-2xl p-6 border border-rose-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1" >
            <div className="flex items-center justify-between mb-4">
              <div className="w-14 h-14 bg-rose-500 rounded-2xl flex items-center justify-center shadow-lg">
                <Scissors className="text-white" size={24} />
              </div>
              <div className="text-right">
                <div className="text-2xl font-bold text-rose-800">{services.length}</div>
                <div className="text-rose-600 text-xs">Services</div>
              </div>
            </div>
            <div className="bg-rose-200 rounded-lg p-2 text-center">
              <div className="text-rose-800 text-xs font-medium">Complete Catalog</div>
            </div>
          </div >

          {/* Average Price - Money Style */}
          < div className="bg-gradient-to-br from-green-50 to-emerald-100 rounded-2xl p-6 border border-green-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1" >
            <div className="flex items-center justify-between mb-4">
              <div className="w-14 h-14 bg-green-500 rounded-2xl flex items-center justify-center shadow-lg">
                <DollarSign className="text-white" size={24} />
              </div>
              <div className="text-right">
                <div className="text-2xl font-bold text-green-800">
                  ${Math.round(services.reduce((acc, s) => acc + (Number(s.price) || 0), 0) / (services.length || 1))}
                </div>
                <div className="text-green-600 text-xs">Avg Price</div>
              </div>
            </div>
            <div className="bg-green-200 rounded-lg p-2 text-center">
              <div className="text-green-800 text-xs font-medium">Fair Pricing</div>
            </div>
          </div >

          {/* Active Services - Toggle Style */}
          < div className="bg-gradient-to-br from-blue-50 to-indigo-100 rounded-2xl p-6 border border-blue-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1" >
            <div className="flex items-center justify-between mb-4">
              <div className="w-14 h-14 bg-blue-500 rounded-2xl flex items-center justify-center shadow-lg">
                <CheckCircle className="text-white" size={24} />
              </div>
              <div className="text-right">
                <div className="text-2xl font-bold text-blue-800">
                  {services.filter(s => s.isActive).length}
                </div>
                <div className="text-blue-600 text-xs">Available</div>
              </div>
            </div>
            <div className="bg-blue-200 rounded-lg p-2 text-center">
              <div className="text-blue-800 text-xs font-medium">Book Now</div>
            </div>
          </div >

          {/* Categories - Grid Style */}
          < div className="bg-gradient-to-br from-purple-50 to-pink-100 rounded-2xl p-6 border border-purple-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1" >
            <div className="flex items-center justify-between mb-4">
              <div className="w-14 h-14 bg-purple-500 rounded-2xl flex items-center justify-center shadow-lg">
                <Grid className="text-white" size={24} />
              </div>
              <div className="text-right">
                <div className="text-2xl font-bold text-purple-800">4</div>
                <div className="text-purple-600 text-xs">Categories</div>
              </div>
            </div>
            <div className="bg-purple-200 rounded-lg p-2 text-center">
              <div className="text-purple-800 text-xs font-medium">Variety</div>
            </div>
          </div >
        </div >

        {/* Creative Search & Filters */}
        < div className="bg-white rounded-2xl shadow-lg border border-gray-200 p-6 mb-8" >
          <div className="flex flex-wrap items-center justify-between gap-4">
            <div className="flex items-center gap-4">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-rose-400" size={20} />
                <input
                  type="text"
                  placeholder="Search services by name or description..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10 pr-4 py-3 bg-rose-50 text-gray-900 rounded-xl border border-rose-200 focus:outline-none focus:ring-2 focus:ring-rose-500 focus:border-rose-500 w-96"
                />
              </div>
              <div className="flex items-center gap-2 bg-rose-50 px-4 py-3 rounded-xl border border-rose-200">
                <Filter size={20} className="text-rose-500" />
                <select
                  className="bg-transparent text-rose-700 focus:outline-none font-medium"
                  value={categoryFilter}
                  onChange={(e) => setCategoryFilter(e.target.value)}
                >
                  <option value="all">All Categories</option>
                  <option value="hair">Hair Services</option>
                  <option value="beard">Beard Services</option>
                  <option value="skin">Skin Services</option>
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
                  <p className="stat-label">Total Services</p>
                  <p className="stat-value">{services.length}</p>
                  <div className="stat-change positive">
                    <TrendingUp size={12} />
                    12% from last month
                  </div>
                </div>
                <div className="p-3 rounded-lg bg-blue-100">
                  <Package size={24} className="text-blue-600" />
                </div>
              </div>
            </div>
            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="stat-label">Active Services</p>
                  <p className="stat-value">{services.filter(s => s.isActive).length}</p>
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
                  <p className="stat-label">Avg Price</p>
                  <p className="stat-value">${Math.round(services.reduce((acc, s) => acc + (Number(s.price) || 0), 0) / (services.length || 1))}</p>
                  <div className="stat-change positive">
                    <TrendingUp size={12} />
                    5% from last month
                  </div>
                </div>
                <div className="p-3 rounded-lg bg-purple-100">
                  <DollarSign size={24} className="text-purple-600" />
                </div>
              </div>
            </div>
            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="stat-label">Categories</p>
                  <p className="stat-value">{new Set(services.map(s => s.category)).size}</p>
                  <div className="stat-change positive">
                    <TrendingUp size={12} />
                    2 new this month
                  </div>
                </div>
                <div className="p-3 rounded-lg bg-amber-100">
                  <Sparkles size={24} className="text-amber-600" />
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
                  <Plus className="text-green-700" size={20} />
                  <div>
                    <p className="font-medium text-gray-900">Add New Service</p>
                    <p className="text-sm text-gray-600">Create a new service</p>
                  </div>
                </div>
              </button>
              <button className="w-full text-left p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors border border-blue-200">
                <div className="flex items-center gap-3">
                  <Download className="text-blue-700" size={20} />
                  <div>
                    <p className="font-medium text-gray-900">Export Services</p>
                    <p className="text-sm text-gray-600">Download service data</p>
                  </div>
                </div>
              </button>
              <button className="w-full text-left p-4 bg-purple-50 hover:bg-purple-100 rounded-xl transition-colors border border-purple-200">
                <div className="flex items-center gap-3">
                  <TrendingUp className="text-purple-700" size={20} />
                  <div>
                    <p className="font-medium text-gray-900">Service Analytics</p>
                    <p className="text-sm text-gray-600">View service statistics</p>
                  </div>
                </div>
              </button>
            </div>
          </div>

          {/* Services Table */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
            <div className="p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">All Services</h3>

              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="border-b border-gray-200">
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Service Name
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Category
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Price
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Duration
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
                    {filteredServices.map((service) => (
                      <tr key={service.id} className="hover:bg-gray-50">
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex items-center">
                            <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                              <Scissors size={20} className="text-gray-500" />
                            </div>
                            <div className="ml-3">
                              <div className="text-sm font-medium text-gray-900">{service.name}</div>
                              <div className="text-sm text-gray-500">{service.description}</div>
                            </div>
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className={`px-2 py-1 text-xs bg-gray-100 text-gray-700 rounded-full capitalize`}>
                            {service.category}
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="text-sm font-medium text-gray-900">${(Number(service.price) || 0).toFixed(2)}</div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex items-center text-sm text-gray-900">
                            <Clock size={16} className="mr-1" />
                            {service.durationMinutes} min
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${service.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                            }`}>
                            {service.isActive ? 'Active' : 'Inactive'}
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                          <div className="flex items-center gap-2">
                            <button className="text-gray-600 hover:text-gray-900" title="View">
                              <Eye size={16} />
                            </button>
                            <button className="text-gray-600 hover:text-gray-900" title="Edit">
                              <Edit size={16} />
                            </button>
                            <button className="text-red-600 hover:text-red-900" title="Delete">
                              <Trash2 size={16} />
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
      </div>
    </AdminLayout>
  );
}
