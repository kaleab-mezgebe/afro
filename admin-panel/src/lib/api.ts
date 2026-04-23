import axios from 'axios';
import { getAuth } from 'firebase/auth';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001/api/v1';

// Create axios instance
const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth token to requests
apiClient.interceptors.request.use(async (config) => {
  const auth = getAuth();
  const user = auth.currentUser;

  if (user) {
    const token = await user.getIdToken();
    config.headers.Authorization = `Bearer ${token}`;
  }

  return config;
});

// API methods
export const api = {
  // Auth
  verifyToken: (token: string) => apiClient.post('/auth/verify-token', { token }),
  getCurrentUser: () => apiClient.get('/auth/me'),
  assignRole: (userId: string, role: string) =>
    apiClient.post('/auth/assign-role', { userId, role }),
  removeRole: (userId: string, role: string) =>
    apiClient.post('/auth/remove-role', { userId, role }),

  // Admin - Users
  getAllUsers: (params?: any) => apiClient.get('/admin/users', { params }),
  getUserById: (id: string) => apiClient.get(`/admin/users/${id}`),
  createUser: async (userData: any) => {
    try {
      const response = await apiClient.post('/admin/users', userData);
      return response;
    } catch (error: any) {
      console.error('API Error in createUser:', error);
      throw error;
    }
  },
  updateUser: (id: string, userData: any) => apiClient.put(`/admin/users/${id}`, userData),
  suspendUser: (id: string) => apiClient.post(`/admin/users/${id}/suspend`),
  activateUser: (id: string) => apiClient.post(`/admin/users/${id}/activate`),
  deleteUser: (id: string) => apiClient.delete(`/admin/users/${id}`),

  // Admin - Providers
  getAllProviders: (params?: any) => apiClient.get('/admin/providers', { params }),
  getProviderById: (id: string) => apiClient.get(`/admin/providers/${id}`),
  approveProvider: (id: string) => apiClient.post(`/admin/providers/${id}/approve`),
  rejectProvider: (id: string, reason: string) =>
    apiClient.post(`/admin/providers/${id}/reject`, { reason }),
  verifyProvider: (id: string) => apiClient.post(`/admin/providers/${id}/verify`),

  // Admin - Customers
  getAllCustomers: (params?: any) => apiClient.get('/admin/customers', { params }),
  getCustomerById: (id: string) => apiClient.get(`/admin/customers/${id}`),

  // Admin - Appointments
  getAllAppointments: (params?: any) => apiClient.get('/admin/appointments', { params }),
  getAppointmentById: (id: string) => apiClient.get(`/admin/appointments/${id}`),
  resolveDispute: (id: string, resolution: string) =>
    apiClient.post(`/admin/appointments/${id}/resolve`, { resolution }),

  // Admin - Analytics
  getSystemAnalytics: (period?: string) =>
    apiClient.get('/admin/analytics', { params: { period } }),
  getRevenueAnalytics: (period?: string) =>
    apiClient.get('/admin/analytics/revenue', { params: { period } }),
  getUserAnalytics: (period?: string) =>
    apiClient.get('/admin/analytics/users', { params: { period } }),
  getAppointmentAnalytics: (period?: string) =>
    apiClient.get('/admin/analytics/appointments', { params: { period } }),

  // Admin - Audit Logs
  getAuditLogs: (params?: any) => apiClient.get('/admin/audit-logs', { params }),

  // Admin - Reviews
  getAllReviews: (params?: any) => apiClient.get('/admin/reviews', { params }),
  flagReview: (id: string) => apiClient.post(`/admin/reviews/${id}/flag`),
  approveReview: (id: string) => apiClient.post(`/admin/reviews/${id}/approve`),
  deleteReview: (id: string) => apiClient.delete(`/admin/reviews/${id}`),

  // Admin - Reports
  generateReport: (type: string, params: any) =>
    apiClient.post('/admin/reports/generate', { type, ...params }),
  downloadReport: (id: string) => apiClient.get(`/admin/reports/${id}/download`),

  // Services
  getServices: () => apiClient.get('/services'),
  getServicesByCategory: (category: string) => apiClient.get(`/services/category/${category}`),
  getServiceById: (id: string) => apiClient.get(`/services/${id}`),
  createService: (data: any) => apiClient.post('/services', data),
  updateService: (id: string, data: any) => apiClient.put(`/services/${id}`, data),
  deleteService: (id: string) => apiClient.delete(`/services/${id}`),
};

export default apiClient;
