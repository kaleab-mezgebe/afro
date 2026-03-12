'use client';

import { useEffect, useState } from 'react';
import AdminLayout from '@/components/AdminLayout';
import {
  Star,
  Search,
  Filter,
  Download,
  Eye,
  Edit,
  Trash2,
  CheckCircle,
  XCircle,
  MessageSquare,
  Users,
  Calendar,
  TrendingUp,
  TrendingDown,
  AlertCircle,
  ThumbsUp,
  ThumbsDown,
} from 'lucide-react';
import { ReviewsService } from '@/lib/api-backend';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';

interface Review {
  id: string;
  customerName: string;
  providerName: string;
  serviceName: string;
  rating: number;
  comment: string;
  date: string;
  status: 'published' | 'pending' | 'hidden' | 'flagged';
  helpful: number;
  notHelpful: number;
  verified: boolean;
}

export default function ReviewsPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [reviews, setReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [ratingFilter, setRatingFilter] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');

  useEffect(() => {
    if (authenticated) {
      loadReviews();
    }
  }, [authenticated]);

  const loadReviews = async () => {
    try {
      const response = await ReviewsService.getAll({
        page: 1,
        limit: 50,
        search: searchTerm,
        rating: ratingFilter === 'all' ? undefined : parseInt(ratingFilter),
        status: statusFilter === 'all' ? undefined : statusFilter
      });

      if (response.success && response.data) {
        setReviews(response.data);
      }
    } catch (error) {
      toast.error('Failed to load reviews');
      console.error('Reviews loading error:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredReviews = reviews.filter(review => {
    const matchesSearch = searchTerm === '' ||
      review.customerName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      review.providerName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      review.serviceName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      review.comment?.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesRating = ratingFilter === 'all' || review.rating.toString() === ratingFilter;
    const matchesStatus = statusFilter === 'all' || review.status === statusFilter;

    return matchesSearch && matchesRating && matchesStatus;
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

  const totalReviews = reviews.length;
  const avgRating = reviews.reduce((acc, r) => acc + r.rating, 0) / reviews.length || 0;
  const publishedReviews = reviews.filter(r => r.status === 'published').length;
  const pendingReviews = reviews.filter(r => r.status === 'pending').length;
  const flaggedReviews = reviews.filter(r => r.status === 'flagged').length;
  const fiveStarReviews = reviews.filter(r => r.rating === 5).length;
  const verifiedReviews = reviews.filter(r => r.verified).length;

  return (
    <AdminLayout>
      <div className="page-content">
        {/* Creative Header with Gradient */}
        <div className="bg-gradient-to-r from-purple-600 via-pink-600 to-amber-600 rounded-2xl p-8 mb-8 text-white shadow-xl">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-4xl font-bold mb-2 flex items-center gap-3">
                <Star className="fill-yellow-300 text-yellow-300" size={36} />
                Reviews Hub
              </h1>
              <p className="text-purple-100 text-lg">Customer voices that shape our excellence</p>
            </div>
            <div className="text-right">
              <div className="text-5xl font-bold text-yellow-300">{totalReviews}</div>
              <div className="text-purple-100">Total Reviews</div>
            </div>
          </div>
        </div>

        {/* Creative Stats Cards with Different Styles */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {/* Average Rating - Circular Progress Style */}
          <div className="bg-gradient-to-br from-green-50 to-emerald-100 rounded-2xl p-6 border border-green-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center justify-between mb-4">
              <div className="w-16 h-16 bg-green-500 rounded-full flex items-center justify-center shadow-lg">
                <span className="text-white text-2xl font-bold">{avgRating.toFixed(1)}</span>
              </div>
              <div className="flex flex-col items-end">
                <div className="flex text-yellow-400">
                  {[...Array(5)].map((_, i) => (
                    <Star key={i} size={16} className={i < Math.floor(avgRating) ? 'fill-current' : ''} />
                  ))}
                </div>
                <span className="text-green-700 text-sm font-medium">Avg Rating</span>
              </div>
            </div>
            <div className="text-green-800 font-semibold">Customer Satisfaction</div>
          </div>

          {/* Published Reviews - Book Style */}
          <div className="bg-gradient-to-br from-blue-50 to-indigo-100 rounded-2xl p-6 border border-blue-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-12 h-12 bg-blue-500 rounded-lg flex items-center justify-center shadow-md">
                <MessageSquare className="text-white" size={24} />
              </div>
              <div>
                <div className="text-3xl font-bold text-blue-800">{publishedReviews}</div>
                <div className="text-blue-600 text-sm">Published</div>
              </div>
            </div>
            <div className="bg-blue-200 rounded-full h-2 mb-2">
              <div className="bg-blue-500 h-2 rounded-full" style={{ width: `${(publishedReviews / totalReviews) * 100}%` }}></div>
            </div>
            <div className="text-blue-700 text-xs">Live on platform</div>
          </div>

          {/* Pending Reviews - Alert Style */}
          <div className="bg-gradient-to-br from-amber-50 to-orange-100 rounded-2xl p-6 border border-amber-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-12 h-12 bg-amber-500 rounded-full flex items-center justify-center shadow-md animate-pulse">
                <AlertCircle className="text-white" size={24} />
              </div>
              <div>
                <div className="text-3xl font-bold text-amber-800">{pendingReviews}</div>
                <div className="text-amber-600 text-sm">Pending</div>
              </div>
            </div>
            <div className="bg-amber-200 rounded-lg p-2 text-center">
              <div className="text-amber-800 text-xs font-medium">Awaiting Review</div>
            </div>
          </div>

          {/* Verified Reviews - Badge Style */}
          <div className="bg-gradient-to-br from-purple-50 to-pink-100 rounded-2xl p-6 border border-purple-200 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-12 h-12 bg-purple-500 rounded-xl flex items-center justify-center shadow-md">
                <CheckCircle className="text-white" size={24} />
              </div>
              <div>
                <div className="text-3xl font-bold text-purple-800">{verifiedReviews}</div>
                <div className="text-purple-600 text-sm">Verified</div>
              </div>
            </div>
            <div className="flex flex-wrap gap-1">
              <span className="bg-purple-200 text-purple-800 text-xs px-2 py-1 rounded-full">Authentic</span>
              <span className="bg-purple-200 text-purple-800 text-xs px-2 py-1 rounded-full">Trusted</span>
            </div>
          </div>
        </div>

        {/* Creative Actions Bar */}
        <div className="bg-white rounded-2xl shadow-lg border border-gray-200 p-6 mb-8">
          <div className="flex flex-wrap items-center justify-between gap-4">
            <div className="flex items-center gap-4">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-purple-400" size={20} />
                <input
                  type="text"
                  placeholder="Search reviews..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10 pr-4 py-3 bg-purple-50 text-gray-900 rounded-xl border border-purple-200 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-purple-500 w-80"
                />
              </div>
              <div className="flex items-center gap-2 bg-purple-50 px-4 py-3 rounded-xl border border-purple-200">
                <Filter size={20} className="text-purple-500" />
                <select
                  className="bg-transparent text-purple-700 focus:outline-none"
                  value={ratingFilter}
                  onChange={(e) => setRatingFilter(e.target.value)}
                >
                  <option value="all">All Ratings</option>
                  <option value="5">5 Stars</option>
                  <option value="4">4 Stars</option>
                  <option value="3">3 Stars</option>
                  <option value="2">2 Stars</option>
                  <option value="1">1 Star</option>
                </select>
                <select
                  className="px-4 py-2 bg-white text-gray-700 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-amber-500"
                  value={statusFilter}
                  onChange={(e) => setStatusFilter(e.target.value)}
                >
                  <option value="all">All Status</option>
                  <option value="published">Published</option>
                  <option value="pending">Pending</option>
                  <option value="hidden">Hidden</option>
                  <option value="flagged">Flagged</option>
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
                  <p className="stat-label">Total Reviews</p>
                  <p className="stat-value">{totalReviews}</p>
                  <div className="stat-change positive">
                    <TrendingUp size={12} />
                    25% from last month
                  </div>
                </div>
                <div className="p-3 rounded-lg bg-blue-100">
                  <MessageSquare size={24} className="text-blue-600" />
                </div>
              </div>
            </div>
            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="stat-label">Average Rating</p>
                  <p className="stat-value">{avgRating.toFixed(1)}</p>
                  <div className="stat-change positive">
                    <TrendingUp size={12} />
                    0.3 from last month
                  </div>
                </div>
                <div className="p-3 rounded-lg bg-green-100">
                  <Star size={24} className="text-green-600" />
                </div>
              </div>
            </div>
            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="stat-label">5 Star Reviews</p>
                  <p className="stat-value">{fiveStarReviews}</p>
                  <div className="stat-change positive">
                    <TrendingUp size={12} />
                    18% from last week
                  </div>
                </div>
                <div className="p-3 rounded-lg bg-purple-100">
                  <ThumbsUp size={24} className="text-purple-600" />
                </div>
              </div>
            </div>
            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="stat-label">Pending Review</p>
                  <p className="stat-value">{pendingReviews + flaggedReviews}</p>
                  <div className="stat-change negative">
                    <AlertCircle size={12} />
                    Need attention
                  </div>
                </div>
                <div className="p-3 rounded-lg bg-amber-100">
                  <AlertCircle size={24} className="text-amber-600" />
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
                  <CheckCircle className="text-green-700" size={20} />
                  <div>
                    <p className="font-medium text-gray-900">Approve Pending</p>
                    <p className="text-sm text-gray-600">Approve pending reviews</p>
                  </div>
                </div>
              </button>
              <button className="w-full text-left p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors border border-blue-200">
                <div className="flex items-center gap-3">
                  <Download className="text-blue-700" size={20} />
                  <div>
                    <p className="font-medium text-gray-900">Export Reviews</p>
                    <p className="text-sm text-gray-600">Download review data</p>
                  </div>
                </div>
              </button>
              <button className="w-full text-left p-4 bg-purple-50 hover:bg-purple-100 rounded-xl transition-colors border border-purple-200">
                <div className="flex items-center gap-3">
                  <TrendingUp className="text-purple-700" size={20} />
                  <div>
                    <p className="font-medium text-gray-900">Review Analytics</p>
                    <p className="text-sm text-gray-600">View review trends</p>
                  </div>
                </div>
              </button>
            </div>
          </div>

          {/* Reviews Table */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
            <div className="p-6">
              {/* Creative Reviews Cards Grid */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {filteredReviews.map((review) => (
                  <div key={review.id} className="group relative bg-white rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 hover:-translate-y-2 overflow-hidden border border-gray-100">
                    {/* Review Header with Gradient */}
                    <div className={`bg-gradient-to-r from-${review.rating >= 4 ? 'green' : review.rating >= 3 ? 'amber' : 'red'}-400 to-${review.rating >= 4 ? 'emerald' : review.rating >= 3 ? 'orange' : 'rose'}-500 p-4 text-white`}>
                      <div className="flex items-center justify-between mb-2">
                        <div className="flex items-center gap-3">
                          <div className="w-12 h-12 bg-white/20 backdrop-blur rounded-full flex items-center justify-center">
                            <Users className="text-white" size={20} />
                          </div>
                          <div>
                            <div className="font-semibold text-white">{review.customerName}</div>
                            <div className="text-white/80 text-sm">{review.providerName}</div>
                          </div>
                        </div>
                        {review.verified && (
                          <div className="bg-white/20 backdrop-blur px-2 py-1 rounded-full">
                            <div className="flex items-center gap-1">
                              <CheckCircle size={12} className="text-white" />
                              <span className="text-xs text-white">Verified</span>
                            </div>
                          </div>
                        )}
                      </div>

                      {/* Rating Stars */}
                      <div className="flex items-center gap-2">
                        <div className="flex text-yellow-300">
                          {[...Array(5)].map((_, i) => (
                            <Star key={i} size={16} className={i < review.rating ? 'fill-current' : ''} />
                          ))}
                        </div>
                        <span className="text-white font-bold">{review.rating}.0</span>
                      </div>
                    </div>

                    {/* Review Content */}
                    <div className="p-4">
                      <div className="mb-3">
                        <div className="inline-block bg-gray-100 text-gray-700 text-xs px-3 py-1 rounded-full font-medium">
                          {review.serviceName}
                        </div>
                      </div>

                      <div className="text-gray-700 mb-4 line-clamp-3">
                        "{review.comment}"
                      </div>

                      {/* Review Footer */}
                      <div className="flex items-center justify-between pt-3 border-t border-gray-100">
                        <div className="flex items-center gap-3 text-xs text-gray-500">
                          <div className="flex items-center gap-1 text-green-600">
                            <ThumbsUp size={14} />
                            <span>{review.helpful || 0}</span>
                          </div>
                          <div className="flex items-center gap-1 text-red-600">
                            <ThumbsDown size={14} />
                            <span>{review.notHelpful || 0}</span>
                          </div>
                        </div>

                        <div className="flex items-center gap-2">
                          <span className="text-xs text-gray-400">{review.date}</span>
                          <div className={`w-2 h-2 rounded-full ${review.status === 'published' ? 'bg-green-500' :
                            review.status === 'pending' ? 'bg-amber-500' : 'bg-red-500'
                            }`}></div>
                        </div>
                      </div>

                      {/* Action Buttons */}
                      <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity duration-200">
                        <div className="flex flex-col gap-1">
                          <button className="w-8 h-8 bg-white/90 backdrop-blur rounded-lg flex items-center justify-center hover:bg-white transition-colors shadow-md">
                            <Eye size={14} className="text-gray-700" />
                          </button>
                          <button className="w-8 h-8 bg-white/90 backdrop-blur rounded-lg flex items-center justify-center hover:bg-white transition-colors shadow-md">
                            <Edit size={14} className="text-blue-600" />
                          </button>
                          <button className="w-8 h-8 bg-white/90 backdrop-blur rounded-lg flex items-center justify-center hover:bg-white transition-colors shadow-md">
                            <Trash2 size={14} className="text-red-600" />
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
