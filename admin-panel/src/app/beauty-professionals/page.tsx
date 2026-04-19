'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
import {
  Crown,
  Phone,
  Mail,
  Calendar,
  Eye,
  Ban,
  Download,
  Search,
  Filter,
  ChevronLeft,
  ChevronRight,
  CheckCircle,
  XCircle,
  Clock,
  Star,
  MapPin,
  TrendingUp,
  TrendingDown,
  AlertCircle,
  BarChart3,
  User,
  UserPlus,
  Trash2,
  Edit,
  Award,
  DollarSign,
  Users,
  Camera,
  CheckSquare,
  Sparkles,
  Palette,
  Heart,
  Scissors,
  X
} from 'lucide-react';
import { BarbersService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';

export type ProfessionalRole =
  | 'barber'
  | 'hair_stylist'
  | 'hair_color_specialist'
  | 'nail_technician'
  | 'makeup_artist'
  | 'eyelash_technician'
  | 'brow_specialist'
  | 'esthetician'
  | 'massage_therapist'
  | 'beard_specialist'
  | 'waxing_specialist'
  | 'threading_specialist'
  | 'receptionist'
  | 'manager'
  | 'owner';

export const PROFESSIONAL_ROLE_LABELS: Record<ProfessionalRole, string> = {
  barber: 'Barber',
  hair_stylist: 'Hair Stylist',
  hair_color_specialist: 'Hair Color Specialist',
  nail_technician: 'Nail Technician',
  makeup_artist: 'Makeup Artist',
  eyelash_technician: 'Eyelash Technician',
  brow_specialist: 'Brow Specialist',
  esthetician: 'Esthetician',
  massage_therapist: 'Massage Therapist',
  beard_specialist: 'Beard Specialist',
  waxing_specialist: 'Waxing Specialist',
  threading_specialist: 'Threading Specialist',
  receptionist: 'Receptionist',
  manager: 'Manager',
  owner: 'Owner',
};

export const PROFESSIONAL_DEFAULT_SERVICES: Record<string, string[]> = {
  barber: ['Haircut', 'Beard Trim', 'Beard Shaping', 'Clean Shave', 'Line-up / Edge-up', 'Hair Styling', 'Hair Coloring', 'Kids Haircut', 'Head Massage'],
  hair_stylist: ['Haircut', 'Blow Dry', 'Hair Styling', 'Hair Coloring', 'Highlights', 'Balayage', 'Hair Wash', 'Hair Treatment', 'Bridal Hairstyling'],
  hair_color_specialist: ['Full Hair Coloring', 'Root Touch-up', 'Highlights', 'Balayage / Ombre', 'Color Correction', 'Toner Application'],
  nail_technician: ['Manicure', 'Pedicure', 'Gel Polish', 'Acrylic Nails', 'Nail Extensions', 'Nail Art', 'Nail Repair', 'French Tips'],
  makeup_artist: ['Full Makeup', 'Bridal Makeup', 'Natural Makeup', 'Party Makeup', 'Makeup Consultation', 'Touch-up Services'],
  eyelash_technician: ['Eyelash Extensions', 'Lash Lift', 'Lash Tint', 'Lash Removal'],
  brow_specialist: ['Eyebrow Shaping', 'Threading', 'Brow Tinting', 'Brow Lamination'],
  esthetician: ['Facial', 'Deep Cleansing Facial', 'Acne Treatment', 'Anti-aging Facial', 'Skin Consultation', 'Exfoliation / Peeling', 'Blackhead Removal'],
  massage_therapist: ['Full Body Massage', 'Back Massage', 'Head Massage', 'Foot Massage', 'Relaxation Massage', 'Deep Tissue Massage'],
  beard_specialist: ['Beard Styling', 'Beard Coloring', 'Beard Treatment', 'Precision Shaping'],
  waxing_specialist: ['Full Body Waxing', 'Arm Waxing', 'Leg Waxing', 'Facial Waxing', 'Bikini Waxing'],
  threading_specialist: ['Eyebrow Threading', 'Upper Lip Threading', 'Full Face Threading'],
};

interface BeautyProfessional {
  id: string;
  name: string;
  email: string;
  phone: string;
  salon: string;
  rating: number;
  services: string[];
  status: 'active' | 'suspended' | 'pending_approval';
  isActive: boolean;
  joinedDate: string;
  specialization?: string;
  experienceYears?: number;
  role?: ProfessionalRole;
}

export default function BeautyProfessionalsPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [professionals, setProfessionals] = useState<BeautyProfessional[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedProfessionals, setSelectedProfessionals] = useState<string[]>([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [showViewModal, setShowViewModal] = useState(false);
  const [showPortfolioModal, setShowPortfolioModal] = useState(false);
  const [showBookingModal, setShowBookingModal] = useState(false);
  const [selectedProfessional, setSelectedProfessional] = useState<BeautyProfessional | null>(null);
  const [roleFilter, setRoleFilter] = useState<string>('all');

  useEffect(() => {
    if (authenticated) {
      loadProfessionals();
    }
  }, [authenticated, currentPage, searchTerm]);

  const loadProfessionals = async () => {
    try {
      setLoading(true);
      const response = await BarbersService.getAll({
        page: currentPage,
        limit: 10,
        search: searchTerm,
        status: undefined
      });

      if (response.success && response.data) {
        setProfessionals(response.data);
        setTotalPages(response.totalPages || 1);
      }
    } catch (error) {
      console.error('Failed to load beauty professionals:', error);
      toast.error('Failed to load beauty professionals');
    } finally {
      setLoading(false);
    }
  };

  const handleApproveProfessional = async (professionalId: string) => {
    try {
      await BarbersService.update(professionalId, { isActive: true, status: 'active' });
      toast.success('Beauty professional approved successfully');
      loadProfessionals();
    } catch (error) {
      console.error('Failed to approve professional:', error);
      toast.error('Failed to approve professional');
    }
  };

  const handleRejectProfessional = async (professionalId: string) => {
    try {
      await BarbersService.update(professionalId, { isActive: false, status: 'suspended' });
      toast.success('Beauty professional rejected successfully');
      loadProfessionals();
    } catch (error) {
      console.error('Failed to reject professional:', error);
      toast.error('Failed to reject professional');
    }
  };

  const handleSuspendProfessional = async (professionalId: string) => {
    try {
      await BarbersService.update(professionalId, { isActive: false, status: 'suspended' });
      toast.success('Beauty professional suspended successfully');
      loadProfessionals();
    } catch (error) {
      console.error('Failed to suspend professional:', error);
      toast.error('Failed to suspend professional');
    }
  };

  const handleViewProfessional = (professional: BeautyProfessional) => {
    setSelectedProfessional(professional);
    setShowViewModal(true);
  };

  const handleViewPortfolio = (professional: BeautyProfessional) => {
    setSelectedProfessional(professional);
    setShowPortfolioModal(true);
  };

  const handleViewBookings = (professional: BeautyProfessional) => {
    setSelectedProfessional(professional);
    setShowBookingModal(true);
  };

  const handleSelectProfessional = (professionalId: string) => {
    setSelectedProfessionals(prev =>
      prev.includes(professionalId)
        ? prev.filter(id => id !== professionalId)
        : [...prev, professionalId]
    );
  };

  const handleSelectAll = () => {
    if (selectedProfessionals.length === professionals.length) {
      setSelectedProfessionals([]);
    } else {
      setSelectedProfessionals(professionals.map(p => p.id));
    }
  };

  const handleExport = async () => {
    try {
      const professionalsToExport = selectedProfessionals.length > 0
        ? professionals.filter(p => selectedProfessionals.includes(p.id))
        : professionals;

      // Create CSV content
      const csv = [
        ['Name', 'Salon', 'Phone', 'Rating', 'Services', 'Service Type', 'Status', 'Joined Date'],
        ...professionalsToExport.map(p => [
          p.name,
          p.salon,
          p.phone,
          p.rating,
          p.services.join('; '),
          p.role,
          p.status,
          p.joinedDate
        ])
      ].map(row => row.join(',')).join('\n');

      // Download CSV
      const blob = new Blob([csv], { type: 'text/csv' });
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'beauty-professionals.csv';
      a.click();

      toast.success(`Exported ${professionalsToExport.length} beauty professionals`);
    } catch (error) {
      console.error('Export failed:', error);
      toast.error('Failed to export beauty professionals');
    }
  };

  const getServiceTypeIcon = (role?: string) => {
    switch (role) {
      case 'barber': return <Scissors size={16} />;
      case 'hair_stylist': return <Scissors size={16} />;
      case 'hair_color_specialist': return <Palette size={16} />;
      case 'nail_technician': return <Sparkles size={16} />;
      case 'makeup_artist': return <Palette size={16} />;
      case 'eyelash_technician': return <Sparkles size={16} />;
      case 'brow_specialist': return <Sparkles size={16} />;
      case 'esthetician': return <Heart size={16} />;
      case 'massage_therapist': return <Heart size={16} />;
      case 'beard_specialist': return <Scissors size={16} />;
      case 'waxing_specialist': return <Heart size={16} />;
      case 'threading_specialist': return <Sparkles size={16} />;
      default: return <Crown size={16} />;
    }
  };

  const getServiceTypeName = (role?: string) => {
    return PROFESSIONAL_ROLE_LABELS[role as ProfessionalRole] ?? 'Beauty Professional';
  };

  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-white">Loading...</div>
      </div>
    );
  }

  if (!authenticated) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-white">Please login to access this page.</div>
      </div>
    );
  }

  return (
    <AdminLayout>
      <div className="page-content">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Beauty Professionals</h1>
          <p className="text-gray-600">Manage female beauty service providers on your platform</p>
        </div>

        {/* Actions Bar */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4 mb-6 flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            {/* Search */}
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
              <input
                type="text"
                placeholder="Search beauty professionals..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 bg-gray-50 text-gray-900 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 w-64"
              />
            </div>

            {/* Filter */}
            <select
              aria-label="Filter by professional role"
              value={roleFilter}
              onChange={(e) => setRoleFilter(e.target.value)}
              className="flex items-center gap-2 px-4 py-2 bg-white text-gray-700 rounded-lg border border-gray-200 hover:bg-gray-50 text-sm"
            >
              <option value="all">All Roles</option>
              {(Object.entries(PROFESSIONAL_ROLE_LABELS) as [ProfessionalRole, string][]).map(([key, label]) => (
                <option key={key} value={key}>{label}</option>
              ))}
            </select>
          </div>

          <div className="flex items-center gap-4">
            {/* Export */}
            <button
              onClick={handleExport}
              className="flex items-center gap-2 px-4 py-2 bg-amber-500 text-white rounded-lg hover:bg-amber-600"
            >
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
                <p className="stat-label">Total Professionals</p>
                <p className="stat-value">{professionals.length}</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  12% from last month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-pink-100">
                <Crown size={24} className="text-pink-600" />
              </div>
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Active Today</p>
                <p className="stat-value">47</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  8% from yesterday
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
                <p className="stat-label">Pending Approval</p>
                <p className="stat-value">{professionals.filter(p => p.status === 'pending_approval').length}</p>
                <div className="stat-change negative">
                  <TrendingDown size={12} />
                  3% from last week
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
                <p className="stat-label">Avg Rating</p>
                <p className="stat-value">4.7</p>
                <div className="stat-change positive">
                  <TrendingUp size={12} />
                  0.2 from last month
                </div>
              </div>
              <div className="p-3 rounded-lg bg-purple-100">
                <Star size={24} className="text-purple-600" />
              </div>
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="mb-8">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">Quick Actions</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <button className="w-full text-left p-4 bg-pink-50 hover:bg-pink-100 rounded-xl transition-colors border border-pink-200">
              <div className="flex items-center gap-3">
                <Crown className="text-pink-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Approve Professionals</p>
                  <p className="text-sm text-gray-600">Review pending applications</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors border border-blue-200">
              <div className="flex items-center gap-3">
                <Download className="text-blue-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">Export Data</p>
                  <p className="text-sm text-gray-600">Download professional list</p>
                </div>
              </div>
            </button>
            <button className="w-full text-left p-4 bg-purple-50 hover:bg-purple-100 rounded-xl transition-colors border border-purple-200">
              <div className="flex items-center gap-3">
                <BarChart3 className="text-purple-700" size={20} />
                <div>
                  <p className="font-medium text-gray-900">View Analytics</p>
                  <p className="text-sm text-gray-600">Performance metrics</p>
                </div>
              </div>
            </button>
          </div>
        </div>

        {/* Professionals Table */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Beauty Professionals</h3>

            {professionals.length > 0 && (
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="border-b border-gray-200">
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Name
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Services
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
                    {professionals
                      .filter(p => roleFilter === 'all' || p.role === roleFilter)
                      .map((professional) => (
                      <tr key={professional.id} className="hover:bg-gray-50">
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex items-center">
                            <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
                              <User size={20} className="text-gray-500" />
                            </div>
                            <div className="ml-3">
                              <div className="text-sm font-medium text-gray-900">{professional.name}</div>
                              <div className="text-sm text-gray-500">{professional.email}</div>
                            </div>
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex flex-wrap gap-1">
                            {professional.services?.map((service, index) => (
                              <span key={index} className="px-2 py-1 text-xs bg-gray-100 text-gray-700 rounded-full">
                                {service}
                              </span>
                            ))}
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex items-center">
                            <Star size={16} className="text-amber-400 fill-current" />
                            <span className="ml-1 text-sm text-gray-900">{professional.rating}</span>
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${professional.status === 'active' ? 'bg-green-100 text-green-800' :
                            professional.status === 'pending_approval' ? 'bg-amber-100 text-amber-800' :
                              'bg-red-100 text-red-800'
                            }`}>
                            {professional.status === 'active' ? 'Active' :
                              professional.status === 'pending_approval' ? 'Pending' : 'Suspended'}
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-gray-300">{professional.joinedDate}</td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex items-center gap-2">
                            <button
                              onClick={() => handleViewProfessional(professional)}
                              className="text-blue-400 hover:text-blue-300"
                              title="View Profile"
                            >
                              <Eye size={16} />
                            </button>
                            <button
                              onClick={() => handleViewPortfolio(professional)}
                              className="text-purple-400 hover:text-purple-300"
                              title="View Portfolio"
                            >
                              <Camera size={16} />
                            </button>
                            <button
                              onClick={() => handleViewBookings(professional)}
                              className="text-green-400 hover:text-green-300"
                              title="View Bookings"
                            >
                              <Calendar size={16} />
                            </button>
                            {professional.status === 'pending_approval' ? (
                              <div className="flex gap-2">
                                <button
                                  onClick={() => handleApproveProfessional(professional.id)}
                                  className="text-green-400 hover:text-green-300"
                                  title="Approve Professional"
                                >
                                  <CheckSquare size={16} />
                                </button>
                                <button
                                  onClick={() => handleRejectProfessional(professional.id)}
                                  className="text-red-400 hover:text-red-300"
                                  title="Reject Professional"
                                >
                                  <XCircle size={16} />
                                </button>
                              </div>
                            ) : professional.status === 'active' ? (
                              <button
                                onClick={() => handleSuspendProfessional(professional.id)}
                                className="text-yellow-400 hover:text-yellow-300"
                                title="Suspend Professional"
                              >
                                <Ban size={16} />
                              </button>
                            ) : (
                              <button
                                onClick={() => handleApproveProfessional(professional.id)}
                                className="text-green-400 hover:text-green-300"
                                title="Reactivate Professional"
                              >
                                <CheckCircle size={16} />
                              </button>
                            )}
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}

            {/* Pagination */}
            {totalPages > 1 && (
              <div className="mt-6 flex items-center justify-center gap-4">
                <button
                  onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
                  disabled={currentPage === 1}
                  className="p-2 bg-gray-700 text-white rounded-lg disabled:opacity-50"
                >
                  <ChevronLeft size={20} />
                </button>

                <span className="text-white">
                  Page {currentPage} of {totalPages}
                </span>

                <button
                  onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
                  disabled={currentPage === totalPages}
                  className="p-2 bg-gray-700 text-white rounded-lg disabled:opacity-50"
                >
                  <ChevronRight size={20} />
                </button>
              </div>
            )}
          </div>

          {/* View Professional Modal */}
          {showViewModal && selectedProfessional && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
              <div className="bg-gray-800 rounded-lg p-6 max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
                <div className="flex items-center justify-between mb-6">
                  <h2 className="text-xl font-bold text-white">Beauty Professional Profile</h2>
                  <button
                    onClick={() => setShowViewModal(false)}
                    className="text-gray-400 hover:text-white"
                  >
                    <X size={24} />
                  </button>
                </div>

                <div className="space-y-6">
                  {/* Professional Info */}
                  <div className="bg-gray-700 rounded-lg p-4">
                    <h3 className="text-lg font-semibold text-white mb-4">Professional Information</h3>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <p className="text-gray-400 text-sm">Name</p>
                        <p className="text-white font-medium">{selectedProfessional.name}</p>
                      </div>
                      <div>
                        <p className="text-gray-400 text-sm">Email</p>
                        <p className="text-white font-medium">{selectedProfessional.email}</p>
                      </div>
                      <div>
                        <p className="text-gray-400 text-sm">Phone</p>
                        <p className="text-white font-medium">{selectedProfessional.phone}</p>
                      </div>
                      <div>
                        <p className="text-gray-400 text-sm">Salon</p>
                        <p className="text-white font-medium">{selectedProfessional.salon}</p>
                      </div>
                      <div>
                        <p className="text-gray-400 text-sm">Rating</p>
                        <div className="flex items-center">
                          <Star className="text-yellow-400 mr-1" size={14} />
                          <span className="text-white font-medium">{selectedProfessional.rating}</span>
                        </div>
                      </div>
                      <div>
                        <p className="text-gray-400 text-sm">Service Type</p>
                        <div className="flex items-center gap-2">
                          {getServiceTypeIcon(selectedProfessional.role)}
                          <span className="text-white">{getServiceTypeName(selectedProfessional.role)}</span>
                        </div>
                      </div>
                      <div>
                        <p className="text-gray-400 text-sm">Status</p>
                        <span className={`px-2 py-1 text-xs rounded-full ${selectedProfessional.status === 'active'
                          ? 'bg-green-100 text-green-800'
                          : selectedProfessional.status === 'pending_approval'
                            ? 'bg-yellow-100 text-yellow-800'
                            : 'bg-red-100 text-red-800'
                          }`}>
                          {selectedProfessional.status === 'active' ? 'Active' :
                            selectedProfessional.status === 'pending_approval' ? 'Pending' : 'Suspended'}
                        </span>
                      </div>
                      <div>
                        <p className="text-gray-400 text-sm">Joined Date</p>
                        <p className="text-white font-medium">{selectedProfessional.joinedDate}</p>
                      </div>
                    </div>
                  </div>

                  {/* Services */}
                  <div className="bg-gray-700 rounded-lg p-4">
                    <h3 className="text-lg font-semibold text-white mb-4">Services Offered</h3>
                    <div className="flex flex-wrap gap-2">
                      {selectedProfessional.services.map((service, idx) => (
                        <span key={idx} className="px-3 py-1 bg-pink-100 text-pink-800 rounded-full text-sm">
                          {service}
                        </span>
                      ))}
                    </div>
                  </div>

                  {/* Professional Details */}
                  {selectedProfessional.specialization && (
                    <div className="bg-gray-700 rounded-lg p-4">
                      <h3 className="text-lg font-semibold text-white mb-4">Professional Details</h3>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                          <p className="text-gray-400 text-sm">Specialization</p>
                          <p className="text-white font-medium">{selectedProfessional.specialization}</p>
                        </div>
                        <div>
                          <p className="text-gray-400 text-sm">Experience</p>
                          <p className="text-white font-medium">{selectedProfessional.experienceYears} years</p>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </div>
          )}

          {/* Portfolio Modal */}
          {showPortfolioModal && selectedProfessional && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
              <div className="bg-gray-800 rounded-lg p-6 max-w-4xl w-full mx-4 max-h-[90vh] overflow-y-auto">
                <div className="flex items-center justify-between mb-6">
                  <h2 className="text-xl font-bold text-white">Portfolio Gallery</h2>
                  <button
                    onClick={() => setShowPortfolioModal(false)}
                    className="text-gray-400 hover:text-white"
                  >
                    <X size={24} />
                  </button>
                </div>

                <div className="text-center text-gray-400 py-8">
                  <Camera size={48} className="mx-auto mb-4" />
                  <p>Portfolio gallery will be implemented here</p>
                </div>
              </div>
            </div>
          )}

          {/* Booking History Modal */}
          {showBookingModal && selectedProfessional && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
              <div className="bg-gray-800 rounded-lg p-6 max-w-4xl w-full mx-4 max-h-[90vh] overflow-y-auto">
                <div className="flex items-center justify-between mb-6">
                  <h2 className="text-xl font-bold text-white">Booking History</h2>
                  <button
                    onClick={() => setShowBookingModal(false)}
                    className="text-gray-400 hover:text-white"
                  >
                    <X size={24} />
                  </button>
                </div>

                <div className="text-center text-gray-400 py-8">
                  <Calendar size={48} className="mx-auto mb-4" />
                  <p>Booking history will be implemented here</p>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}
