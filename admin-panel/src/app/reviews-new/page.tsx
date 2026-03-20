'use client';

import React, { useEffect, useState } from 'react';
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
  Sparkles,
  AlertTriangle,
  TrendingUp,
  Calendar,
  TrendingDown
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
  status: 'published' | 'flagged' | 'removed' | 'pending' | 'approved';
  isVerified: boolean;
  createdAt: string;
  flaggedReason?: string;
}

interface StatCardProps {
  title: string;
  value: string | number;
  icon: any;
  trend?: { value: number; isPositive: boolean };
  color?: 'primary' | 'blue' | 'amber' | 'green' | 'red' | 'purple';
}

const StatCard: React.FC<StatCardProps> = ({ title, value, icon: Icon, trend, color = 'primary' }) => (
  <div className="stat-card bg-white p-6 rounded-xl shadow-sm border border-gray-100">
    <div className="flex items-center justify-between">
      <div>
        <p className="stat-label text-gray-500 text-sm">{title}</p>
        <p className="stat-value text-2xl font-bold mt-1">{value}</p>
        {trend && (
          <div className={`text-xs mt-2 flex items-center gap-1 ${trend.isPositive ? 'text-green-600' : 'text-red-600'}`}>
            {trend.isPositive ? <TrendingUp size={12} /> : <TrendingDown size={12} />}
            {trend.value}% from last month
          </div>
        )}
      </div>
      <div className={`p-3 rounded-lg bg-${color}-100`}>
        <Icon size={24} className={`text-${color}-600`} />
      </div>
    </div>
  </div>
);

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

  const handleApproveReview = (reviewId: string) => {
    toast.success('Review approved successfully');
    setReviews(reviews.map(r => r.id === reviewId ? { ...r, status: 'approved' } : r));
  };

  const handleFlagReview = (reviewId: string) => {
    toast.success('Review flagged for review');
    setReviews(reviews.map(r => r.id === reviewId ? { ...r, status: 'flagged' } : r));
  };

  const filteredReviews = reviews.filter(review =>
    review.customerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
    review.providerName.toLowerCase().includes(searchTerm.toLowerCase())
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

  const actionsBar = (
    <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4 flex flex-wrap items-center justify-between gap-4 mb-6">
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
      <AdminLayout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
        </div>
      </AdminLayout>
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
        {actionsBar}

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
                          <span className="text-sm text-gray-500">{new Date(review.createdAt).toLocaleDateString()}</span>
                        </div>
                      </div>

                      <div className="text-gray-700 mb-2">{review.comment}</div>

                      <div className="flex items-center gap-2 text-sm text-gray-500">
                        <span>Provider: {review.providerName}</span>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${review.status === 'approved' || review.status === 'published' ? 'bg-green-100 text-green-700' :
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
