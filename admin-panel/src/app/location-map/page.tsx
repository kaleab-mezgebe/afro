'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
import {
  MapPin,
  Building,
  Users,
  Star,
  RefreshCw,
  Download,
  Search,
  Filter,
  TrendingUp,
  Eye,
  Clock,
  Phone,
  Mail,
  Activity,
} from 'lucide-react';
import { BarbersService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';

interface Location {
  id: string;
  name: string;
  type: 'salon' | 'barbershop';
  address: string;
  city: string;
  state: string;
  coordinates: {
    lat: number;
    lng: number;
  };
  rating: number;
  totalReviews: number;
  phone: string;
  email: string;
  isActive: boolean;
  createdAt: string;
}

export default function LocationMapPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [locations, setLocations] = useState<Location[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState('all');
  const [selectedLocation, setSelectedLocation] = useState<Location | null>(null);

  useEffect(() => {
    if (authenticated) {
      loadLocations();
    }
  }, [authenticated]);

  const loadLocations = async () => {
    try {
      const response = await BarbersService.getAll({
        page: 1,
        limit: 50,
        search: searchTerm,
        status: undefined
      });

      if (response.success && response.data) {
        // Transform barbers data into location map format
        const locationData = response.data.map((barber: any) => ({
          id: barber.id,
          name: barber.name,
          type: 'barbershop' as const,
          address: barber.address || 'Unknown Address',
          city: barber.city || 'Unknown City',
          state: barber.state || 'N/A',
          coordinates: {
            lat: Math.random() * 50, // Mock coordinates for demo
            lng: Math.random() * -100
          },
          rating: barber.rating || 0,
          totalReviews: barber.totalBookings || 0,
          phone: barber.phone || '',
          email: barber.email || '',
          isActive: barber.isActive || false,
          createdAt: barber.createdAt || ''
        }));

        setLocations(locationData);
      }
    } catch (error) {
      toast.error('Failed to load locations');
      console.error('Location map loading error:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredLocations = locations.filter(location => {
    const matchesSearch = searchTerm === '' ||
      location.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      location.city.toLowerCase().includes(searchTerm.toLowerCase()) ||
      location.address.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesType = typeFilter === 'all' || location.type === typeFilter;

    return matchesSearch && matchesType;
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

  const totalSalons = locations.filter(l => l.type === 'salon').length;
  const totalBarbershops = locations.filter(l => l.type === 'barbershop').length;
  const activeLocations = locations.filter(l => l.isActive).length;
  const avgRating = locations.reduce((acc, l) => acc + l.rating, 0) / locations.length || 0;

  return (
    <AdminLayout>
      <div className="page-content">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Location Map</h1>
          <p className="text-gray-600">View all business locations on an interactive map</p>
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
                value={typeFilter}
                onChange={(e) => setTypeFilter(e.target.value)}
              >
                <option value="all">All Types</option>
                <option value="salon">Salons</option>
                <option value="barbershop">Barbershops</option>
              </select>
            </div>
          </div>
          <div className="flex items-center gap-4">
            <button className="flex items-center gap-2 px-4 py-2 bg-amber-500 text-white rounded-lg hover:bg-amber-600">
              <RefreshCw size={20} />
              <span>Refresh</span>
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
                <p className="stat-label">Total Locations</p>
                <p className="stat-value">{locations.length}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  8% from last month
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
                <p className="stat-label">Active Locations</p>
                <p className="stat-value">{activeLocations}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  5% from last week
                </div>
              </div>
              <div className="p-3 rounded-lg bg-green-100">
                <Activity size={24} className="text-green-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Salons</p>
                <p className="stat-value">{totalSalons}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  3 new this month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-purple-100">
                <Building size={24} className="text-purple-600" />
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
                  0.2 from last month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-amber-100">
                <Star size={24} className="text-amber-600" />
              </div>
            </div>
          </div>
        </div>

        {/* Map Container */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
          <div className="lg:col-span-2">
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
              <div className="p-4 border-b border-gray-200">
                <h3 className="text-lg font-semibold text-gray-900">Interactive Map</h3>
              </div>
              <div className="h-96 bg-gray-100 flex items-center justify-center">
                <div className="text-center">
                  <MapPin size={48} className="text-gray-400 mx-auto mb-4" />
                  <p className="text-gray-600 mb-2">Map View</p>
                  <p className="text-sm text-gray-500">Interactive map would be displayed here</p>
                  <p className="text-xs text-gray-400 mt-2">Showing {filteredLocations.length} locations</p>
                </div>
              </div>
            </div>
          </div>

          <div className="lg:col-span-1">
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
              <div className="p-4 border-b border-gray-200">
                <h3 className="text-lg font-semibold text-gray-900">Location Details</h3>
              </div>
              <div className="p-4">
                {selectedLocation ? (
                  <div className="space-y-4">
                    <div>
                      <h4 className="font-medium text-gray-900">{selectedLocation.name}</h4>
                      <p className="text-sm text-gray-600">{selectedLocation.type}</p>
                    </div>
                    <div className="space-y-2">
                      <div className="flex items-center text-sm text-gray-600">
                        <MapPin size={16} className="mr-2" />
                        {selectedLocation.address}, {selectedLocation.city}
                      </div>
                      <div className="flex items-center text-sm text-gray-600">
                        <Phone size={16} className="mr-2" />
                        {selectedLocation.phone}
                      </div>
                      <div className="flex items-center text-sm text-gray-600">
                        <Mail size={16} className="mr-2" />
                        {selectedLocation.email}
                      </div>
                    </div>
                    <div className="flex items-center justify-between">
                      <div className="flex items-center">
                        <Star size={16} className="text-amber-400 fill-current mr-1" />
                        <span className="text-sm font-medium">{selectedLocation.rating}</span>
                        <span className="text-sm text-gray-500 ml-1">({selectedLocation.totalReviews})</span>
                      </div>
                      <span className={`px-2 py-1 text-xs rounded-full ${selectedLocation.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                        }`}>
                        {selectedLocation.isActive ? 'Active' : 'Inactive'}
                      </span>
                    </div>
                  </div>
                ) : (
                  <div className="text-center text-gray-500">
                    <MapPin size={32} className="mx-auto mb-2 text-gray-400" />
                    <p className="text-sm">Select a location to view details</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Locations List */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">All Locations</h3>

            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Location Name
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Type
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Address
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
                  {filteredLocations.map((location) => (
                    <tr key={location.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                            <MapPin size={20} className="text-gray-500" />
                          </div>
                          <div className="ml-3">
                            <div className="text-sm font-medium text-gray-900">{location.name}</div>
                            <div className="text-sm text-gray-500">{location.city}, {location.state}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 text-xs rounded-full ${location.type === 'salon' ? 'bg-purple-100 text-purple-800' : 'bg-blue-100 text-blue-800'
                          }`}>
                          {location.type}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{location.address}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center text-sm text-gray-900">
                          <Star size={16} className="text-amber-400 fill-current mr-1" />
                          {location.rating} ({location.totalReviews})
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${location.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                          }`}>
                          {location.isActive ? 'Active' : 'Inactive'}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <div className="flex items-center gap-2">
                          <button
                            className="text-gray-600 hover:text-gray-900"
                            title="View Details"
                            onClick={() => setSelectedLocation(location)}
                          >
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
