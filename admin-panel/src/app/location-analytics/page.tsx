'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
import {
  MapPin,
  TrendingUp,
  Search,
  Filter,
  Download,
  Eye,
  BarChart3,
  PieChart,
  Activity,
  Users,
  Building,
  Calendar,
  Clock,
  Award,
} from 'lucide-react';
import { BarbersService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';

interface LocationData {
  id: string;
  city: string;
  state: string;
  totalSalons: number;
  totalBarbershops: number;
  totalCustomers: number;
  totalRevenue: number;
  growthRate: number;
  avgRating: number;
  isActive: boolean;
}

export default function LocationAnalyticsPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [locations, setLocations] = useState<LocationData[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [stateFilter, setStateFilter] = useState('all');

  useEffect(() => {
    if (authenticated) {
      loadLocationData();
    }
  }, [authenticated]);

  const loadLocationData = async () => {
    try {
      const response = await BarbersService.getAll({
        page: 1,
        limit: 50,
        search: searchTerm,
        status: undefined
      });

      if (response.success && response.data) {
        // Transform barbers data into location analytics format
        const locationMap = response.data.reduce((acc: any, barber: any) => {
          const city = barber.city || 'Unknown';
          if (!acc[city]) {
            acc[city] = {
              id: city,
              city: city,
              state: barber.state || 'N/A',
              totalSalons: 0,
              totalBarbershops: 0,
              totalCustomers: 0,
              totalRevenue: 0,
              growthRate: 0,
              avgRating: 0,
              isActive: true
            };
          }
          acc[city].totalBarbershops++;
          acc[city].totalCustomers += barber.totalBookings || 0;
          acc[city].totalRevenue += (barber.totalBookings || 0) * 100; // Estimate
          acc[city].avgRating = (acc[city].avgRating + barber.rating) / 2;
          return acc;
        }, {});

        setLocations(Object.values(locationMap));
      }
    } catch (error) {
      toast.error('Failed to load location analytics');
      console.error('Location analytics loading error:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredLocations = locations.filter(location => {
    const matchesSearch = searchTerm === '' ||
      location.city.toLowerCase().includes(searchTerm.toLowerCase()) ||
      location.state.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesState = stateFilter === 'all' || location.state === stateFilter;

    return matchesSearch && matchesState;
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

  const totalSalons = locations.reduce((acc, loc) => acc + loc.totalSalons, 0);
  const totalBarbershops = locations.reduce((acc, loc) => acc + loc.totalBarbershops, 0);
  const totalCustomers = locations.reduce((acc, loc) => acc + loc.totalCustomers, 0);
  const totalRevenue = locations.reduce((acc, loc) => acc + loc.totalRevenue, 0);
  const avgGrowthRate = locations.reduce((acc, loc) => acc + loc.growthRate, 0) / locations.length || 0;

  return (
    <AdminLayout>
      <div className="page-content">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Location Analytics</h1>
          <p className="text-gray-600">Analyze performance metrics across different locations</p>
        </div>

        {/* Actions Bar */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4 mb-6 flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
              <input
                type="text"
                placeholder="Search locations..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 bg-gray-50 text-gray-900 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 w-64"
              />
            </div>
            <div className="flex items-center gap-2">
              <Filter size={20} className="text-gray-400" />
              <select
                className="px-4 py-2 bg-white text-gray-700 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500"
                value={stateFilter}
                onChange={(e) => setStateFilter(e.target.value)}
              >
                <option value="all">All States</option>
                <option value="NY">New York</option>
                <option value="CA">California</option>
                <option value="IL">Illinois</option>
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
                <p className="stat-label">Total Locations</p>
                <p className="stat-value">{locations.length}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  3 new this month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-blue-100">
                <MapPin size={24} className="text-blue-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Total Businesses</p>
                <p className="stat-value">{totalSalons + totalBarbershops}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  18% from last month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-green-100">
                <Building size={24} className="text-green-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Total Customers</p>
                <p className="stat-value">{totalCustomers.toLocaleString()}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  25% from last month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-purple-100">
                <Users size={24} className="text-purple-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Total Revenue</p>
                <p className="stat-value">${(totalRevenue / 1000).toFixed(0)}K</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  {avgGrowthRate.toFixed(1)}% avg growth
                </div>
              </div>
              <div className="p-3 rounded-lg bg-amber-100">
                <Award size={24} className="text-amber-600" />
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
                <BarChart3 className="text-green-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Revenue Report</p>
                  <p className="text-sm text-gray-600">View detailed revenue analytics</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors border border-blue-200">
              <div className="flex items-center gap-3">
                <PieChart className="text-blue-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Market Share</p>
                  <p className="text-sm text-gray-600">Analyze market distribution</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-purple-50 hover:bg-purple-100 rounded-xl transition-colors border border-purple-200">
              <div className="flex items-center gap-3">
                <Activity className="text-purple-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Growth Trends</p>
                  <p className="text-sm text-gray-600">Track growth patterns</p>
                </div>
              </div>
            </button>
          </div>
        </div>

        {/* Location Analytics Table */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Location Performance</h3>

            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Location
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Businesses
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Customers
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Revenue
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Growth Rate
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Avg Rating
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {filteredLocations.map((location) => (
                    <tr key={location.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                            <MapPin size={20} className="text-gray-500" />
                          </div>
                          <div className="ml-3">
                            <div className="text-sm font-medium text-gray-900">{location.city}</div>
                            <div className="text-sm text-gray-500">{location.state}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">
                          <div>{location.totalSalons} Salons</div>
                          <div className="text-gray-500">{location.totalBarbershops} Barbershops</div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">{location.totalCustomers.toLocaleString()}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">${location.totalRevenue.toLocaleString()}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className={`flex items-center text-sm ${location.growthRate > 10 ? 'text-green-600' :
                          location.growthRate > 5 ? 'text-amber-600' : 'text-red-600'
                          }`}>
                          <TrendingUp size={16} className="mr-1" />
                          {location.growthRate}%
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center text-sm text-gray-900">
                          <div className="flex text-amber-400">
                            {[...Array(5)].map((_, i) => (
                              <span key={i} className={i < Math.floor(location.avgRating) ? 'fill-current' : ''}>
                                ★
                              </span>
                            ))}
                          </div>
                          <span className="ml-1">{location.avgRating}</span>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <div className="flex items-center gap-2">
                          <button className="text-gray-600 hover:text-gray-900" title="View Details">
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
