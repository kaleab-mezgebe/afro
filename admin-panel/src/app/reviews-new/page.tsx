'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
import {
  Star,
  MessageSquare,
  User,
  Search,
  Filter,
  Download,
  Eye,
  Trash2,
  Flag,
  CheckCircle,
  XCircle,
  ChevronLeft,
  ChevronRight,
  X,
  Scissors,
  Sparkles
} from 'lucide-react';
import { ReviewsService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';

interface Review {
  id: string;
  customerName: string;
  providerName: string;
  providerType: 'barber' | 'beauty_professional';
  serviceName: string;
  shopName: string;
  rating: number;
  comment: string;
  status: 'published' | 'flagged' | 'removed';
  isVerified: boolean;
  createdAt: string;
  flaggedReason?: string;
}

export default function ReviewsPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [reviews, setReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedReviews, setSelectedReviews] = useState<string[]>([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [showViewModal, setShowViewModal] = useState(false);
  const [selectedReview, setSelectedReview] = useState<Review | null>(null);

  useEffect(() => {
    if (authenticated) {
      loadReviews();
    }
  }, [authenticated, currentPage, searchTerm]);

  const loadReviews = async () => {
    try {
      setLoading(true);
      const response = await ReviewsService.getAll({
        page: currentPage,
        limit: 10,
        search: searchTerm,
        status: undefined
      });

      if (response.success && response.data) {
        setReviews(response.data);
      }
    } catch (error) {
      console.error('Reviews loading error:', error);
      toast.error('Failed to load reviews');
    } finally {
      setLoading(false);
    }
  };

  const handleApproveReview = (reviewId: number) => {
    toast.success('Review approved successfully');
    setReviews(reviews.map(r => r.id === reviewId ? { ...r, status: 'approved' as const } : r));
  };

  const handleFlagReview = (reviewId: number) => {
    toast.success('Review flagged for review');
    setReviews(reviews.map(r => r.id === reviewId ? { ...r, status: 'flagged' as const } : r));
  };

  const filteredReviews = reviews.filter(review =>
    review.customerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
    review.barberName.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const stats = [
    {
      title: 'Total Reviews',
      value: reviews.length,
      icon: MessageSquare,
      trend: { value: 12, isPositive: true },
      color: 'blue' as const
    },
    {
      title: 'Average Rating',
      value: '4.6',
      icon: Star,
      trend: { value: 8, isPositive: true },
      color: 'amber' as const
    },
    {
      title: 'Pending Approval',
      value: reviews.filter(r => r.status === 'pending').length,
      icon: AlertTriangle,
      trend: { value: 3, isPositive: false },
      color: 'amber' as const
    },
    {
      title: 'Flagged Reviews',
      value: reviews.filter(r => r.status === 'flagged').length,
      icon: Flag,
      trend: { value: 5, isPositive: false },
      color: 'red' as const
    }
  ];

  const quickActions = [
    {
      title: 'Approve Pending',
      description: 'Review and approve pending reviews',
      icon: CheckCircle,
      onClick: () => toast('Approve pending reviews feature coming soon'),
      color: 'green' as const
    },
    {
      title: 'Export Reviews',
      description: 'Download reviews data as CSV',
      icon: Download,
      onClick: () => toast('Export feature coming soon'),
      color: 'blue' as const
    },
    {
      title: 'Review Analytics',
      description: 'View detailed review analytics',
      icon: TrendingUp,
      onClick: () => toast('Analytics feature coming soon'),
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
            placeholder="Search reviews..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-10 pr-4 py-2 bg-gray-50 text-gray-900 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 w-64"
          />
        </div>
        <button className="flex items-center gap-2 px-4 py-2 bg-white text-gray-700 rounded-lg border border-gray-200 hover:bg-gray-50">
          <Filter size={20} />
          <span>Filter</span>
        </button>
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
      <DashboardTemplate
        title="Reviews & Ratings"
        description="Loading reviews data..."
      />
    );
  }

  return (
    <AdminLayout>
      <div className="p-6">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Reviews & Ratings Management</h1>
          <p className="text-gray-600">Manage customer feedback and ratings across your platform</p>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {stats.map((stat, index) => (
            <StatCard key={index} {...stat} />
          ))}
        </div>

        {/* Actions Bar */}
        <div className="flex flex-col sm:flex-row gap-4 mb-6">
          {actionsBar.map((action, index) => (
            <button
              key={index}
              onClick={action.onClick}
              className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-colors ${action.primary
                ? 'bg-blue-600 text-white hover:bg-blue-700'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
            >
              {React.createElement(action.icon, { size: 16 })}
              {action.label}
            </button>
          ))}
        </div>

        {/* Reviews Table */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div className="p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Reviews</h3>

            <div className="space-y-4">
              {filteredReviews.map((review) => (
                <div key={review.id} className="border border-gray-200 rounded-lg p-4 hover:bg-gray-50 transition-colors">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-4 mb-2">
                        <div className="flex items-center gap-2">
                          <User size={16} className="text-gray-400" />
                          <span className="font-medium text-gray-900">{review.customerName}</span>
                        </div>
                        <div className="flex items-center gap-1">
                          {[...Array(5)].map((_, i) => (
                            <Star
                              key={i}
                              size={16}
                              className={i < review.rating ? 'text-amber-400 fill-current' : 'text-gray-300'}
                            />
                          ))}
                          <span className="text-sm text-gray-600 ml-1">{review.rating}.0</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <Calendar size={14} className="text-gray-400" />
                          <span className="text-sm text-gray-500">{review.date}</span>
                        </div>
                      </div>

                      <div className="text-gray-700 mb-2">{review.comment}</div>

                      <div className="flex items-center gap-2 text-sm text-gray-500">
                        <span>Barber: {review.barberName}</span>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${review.status === 'approved' ? 'bg-green-100 text-green-700' :
                          review.status === 'pending' ? 'bg-amber-100 text-amber-700' :
                            'bg-red-100 text-red-700'
                          }`}>
                          {review.status}
                        </span>
                      </div>
                    </div>

                    <div className="flex items-center gap-2 ml-4">
                      {review.status === 'pending' && (
                        <>
                          <button
                            onClick={() => handleApproveReview(review.id)}
                            className="p-2 text-green-600 hover:bg-green-50 rounded-lg transition-colors"
                            title="Approve"
                          >
                            <CheckCircle size={16} />
                          </button>
                          <button
                            onClick={() => handleFlagReview(review.id)}
                            className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                            title="Flag"
                          >
                            <Flag size={16} />
                          </button>
                        </>
                      )}
                      <button className="p-2 text-gray-600 hover:bg-gray-50 rounded-lg transition-colors">
                        <Eye size={16} />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
