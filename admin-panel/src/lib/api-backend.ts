// Backend API Service - Real CRUD Operations
// Connects all 22 admin pages to NestJS backend

import { toast } from 'react-hot-toast';

// API Configuration
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001/api/v1';

// Mock data for development when backend is not available
const USE_MOCK_DATA = false; // Use real backend data

// Types for API responses
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}

export interface PaginatedResponse<T> {
  success: boolean;
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface QueryParams {
  page?: number;
  limit?: number;
  search?: string;
  status?: string;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  [key: string]: any;
}

// Force-refresh the Firebase token and persist it to localStorage.
// Returns the new token or null if not possible.
async function refreshFirebaseToken(): Promise<string | null> {
  try {
    // Development bypass – never refresh, just keep the static token
    const stored = typeof window !== 'undefined' ? localStorage.getItem('authToken') : null;
    if (stored === 'dev-bypass-token') return stored;

    const { getAuth } = await import('firebase/auth');
    const { app } = await import('@/lib/firebase');
    const auth = getAuth(app);
    const user = auth.currentUser;
    if (!user) return null;

    const newToken = await user.getIdToken(/* forceRefresh */ true);
    if (typeof window !== 'undefined') {
      localStorage.setItem('authToken', newToken);
    }
    console.log('[ApiService] Firebase token refreshed successfully');
    return newToken;
  } catch (err) {
    console.error('[ApiService] Failed to refresh Firebase token:', err);
    return null;
  }
}

// Main API Service Class
class ApiService {
  private baseURL: string;

  constructor() {
    this.baseURL = API_BASE_URL;
  }

  // ALWAYS read from localStorage – never cache in memory.
  private getToken(): string | null {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('authToken');
    }
    return null;
  }

  // Public method to set authentication token
  public setAuthToken(token: string): void {
    if (typeof window !== 'undefined') {
      localStorage.setItem('authToken', token);
    }
  }

  // Public method to clear authentication token
  public clearAuthToken(): void {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('authToken');
    }
  }

  // Check if user is authenticated
  public isAuthenticated(): boolean {
    return !!this.getToken();
  }

  // Internal fetch wrapper – does NOT auto-retry.
  private async fetchOnce<T>(
    endpoint: string,
    options: RequestInit,
    token: string | null,
  ): Promise<{ response: Response; data: any }> {
    const url = `${this.baseURL}${endpoint}`;
    const config: RequestInit = {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...(token && { Authorization: `Bearer ${token}` }),
        ...(options.headers as Record<string, string> | undefined),
      },
    };
    const response = await fetch(url, config);
    const data = await response.json();
    return { response, data };
  }

  // Generic HTTP Methods – reads a fresh token on every call and retries
  // exactly once if the server returns 401 (token expired / invalid).
  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<ApiResponse<T>> {
    if (USE_MOCK_DATA) {
      return this.getMockResponse<T>(endpoint);
    }

    let token = this.getToken();

    if (endpoint.startsWith('/admin/') && !token) {
      throw new Error('No authentication token provided. Please log in again.');
    }

    try {
      let { response, data } = await this.fetchOnce<T>(endpoint, options, token);

      // If we get a 401, the token may have just expired – refresh and retry once.
      if (response.status === 401) {
        console.warn('[ApiService] 401 received – attempting token refresh…');
        const newToken = await refreshFirebaseToken();
        if (newToken) {
          token = newToken;
          ({ response, data } = await this.fetchOnce<T>(endpoint, options, token));
        }
      }

      if (!response.ok) {
        throw new Error(data?.message || `HTTP ${response.status}`);
      }

      return data;
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Network error';
      toast.error(message);
      throw error;
    }
  }

  // Mock data responses for development
  public getMockResponse<T>(endpoint: string): Promise<ApiResponse<T>> {
    return new Promise((resolve) => {
      setTimeout(() => {
        if (endpoint.includes('/dashboard/stats')) {
          resolve({
            success: true,
            data: {
              totalCustomers: 1250,
              totalBarbers: 45,
              totalAppointments: 3420,
              totalRevenue: 125000,
              newCustomersThisMonth: 85,
              newBarbersThisMonth: 3,
              appointmentsThisMonth: 285,
              revenueThisMonth: 15000,
              growthPercentage: 12.5
            } as T
          });
        } else if (endpoint.includes('/dashboard/activities')) {
          resolve({
            success: true,
            data: [
              {
                id: 1,
                type: 'new_customer',
                description: 'New customer John Doe registered',
                timestamp: new Date(Date.now() - 1000 * 60 * 5),
                user: 'John Doe'
              },
              {
                id: 2,
                type: 'new_appointment',
                description: 'Appointment booked with Barber Smith',
                timestamp: new Date(Date.now() - 1000 * 60 * 15),
                user: 'Jane Smith'
              }
            ] as T
          });
        } else if (endpoint.includes('/customers')) {
          resolve({
            success: true,
            data: {
              customers: [
                {
                  id: '1',
                  name: 'John Doe',
                  email: 'john@example.com',
                  phone: '+1234567890',
                  totalBookings: 5,
                  lastBooking: new Date(Date.now() - 1000 * 60 * 60 * 24),
                  status: 'active',
                  isActive: true,
                  createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 30)
                },
                {
                  id: '2',
                  name: 'Jane Smith',
                  email: 'jane@example.com',
                  phone: '+0987654321',
                  totalBookings: 3,
                  lastBooking: new Date(Date.now() - 1000 * 60 * 60 * 48),
                  status: 'active',
                  isActive: true,
                  createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 60)
                }
              ],
              total: 2,
              page: 1,
              limit: 50,
              totalPages: 1
            } as T
          });
        } else {
          resolve({
            success: true,
            data: {} as T
          });
        }
      }, 500); // Simulate network delay
    });
  }

  // Generic CRUD Operations
  async getAll<T>(endpoint: string, params?: QueryParams): Promise<PaginatedResponse<T>> {
    let queryString = '';
    if (params) {
      const cleanParams: any = {};
      Object.keys(params).forEach(key => {
        const val = (params as any)[key];
        if (val !== undefined && val !== null && val !== 'undefined' && val !== 'all') {
          cleanParams[key] = val;
        }
      });
      if (Object.keys(cleanParams).length > 0) {
        queryString = `?${new URLSearchParams(cleanParams).toString()}`;
      }
    }
    const response = await this.request<PaginatedResponse<T>>(`${endpoint}${queryString}`);

    // If the response is already a PaginatedResponse (has success and data)
    // we return it as is so the pages can access response.success and response.data
    if (response.success && response.data && Array.isArray(response.data)) {
      // Check if it's actually the paginated envelope
      if ('total' in response || 'totalPages' in response) {
        return response as unknown as PaginatedResponse<T>;
      }
      return response.data as any;
    }

    return response as any;
  }

  async get<T>(endpoint: string): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint);
  }

  async getById<T>(endpoint: string, id: string): Promise<ApiResponse<T>> {
    return this.request<T>(`${endpoint}/${id}`);
  }

  async create<T>(endpoint: string, data: any): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async update<T>(endpoint: string, id: string, data: any): Promise<ApiResponse<T>> {
    return this.request<T>(`${endpoint}/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async delete(endpoint: string, id: string): Promise<ApiResponse<void>> {
    return this.request<void>(`${endpoint}/${id}`, {
      method: 'DELETE',
    });
  }

  async patch<T>(endpoint: string, id: string, data: any): Promise<ApiResponse<T>> {
    return this.request<T>(`${endpoint}/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(data),
    });
  }

  // File Upload
  async upload(endpoint: string, file: File, additionalData?: any): Promise<ApiResponse<any>> {
    const formData = new FormData();
    formData.append('file', file);

    if (additionalData) {
      Object.keys(additionalData).forEach(key => {
        formData.append(key, additionalData[key]);
      });
    }

    return this.request<any>(endpoint, {
      method: 'POST',
      body: formData,
      headers: {
        // Don't set Content-Type for FormData - browser sets it with boundary
        ...(this.getToken() && { Authorization: `Bearer ${this.getToken()}` }),
      },
    });
  }

  // Export Data
  async export(endpoint: string, params?: QueryParams): Promise<void> {
    const queryString = params ? `?${new URLSearchParams(params as any).toString()}` : '';
    const url = `${this.baseURL}${endpoint}/export${queryString}`;

    try {
      const response = await fetch(url, {
        headers: {
          ...(this.getToken() && { Authorization: `Bearer ${this.getToken()}` }),
        },
      });

      if (!response.ok) {
        throw new Error(`Export failed: ${response.status}`);
      }

      // Download file
      const blob = await response.blob();
      const downloadUrl = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = downloadUrl;
      a.download = `export-${Date.now()}.csv`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      window.URL.revokeObjectURL(downloadUrl);

      toast.success('Export completed successfully');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Export failed';
      toast.error(message);
      throw error;
    }
  }
}

// Create singleton instance
export const api = new ApiService();

// Development helper - add global function to set mock token
if (typeof window !== 'undefined' && process.env.NODE_ENV === 'development') {
  (window as any).setMockAdminToken = () => {
    // Development bypass token
    api.setAuthToken('dev-bypass-token');
    console.log('Development bypass token set!');
    console.log('This will work only in development mode');
  };
}

// Specific API Services for Each Module
export class DashboardService {
  static async getStats() {
    return api.get<any>('/admin/dashboard/stats');
  }

  static async getRecentActivities(limit = 10) {
    return api.getAll<any>('/admin/dashboard/activities', { limit });
  }

  static async getRevenueChart(period = '30d') {
    return api.get<any>(`/admin/dashboard/revenue?period=${period}`);
  }

  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/dashboard', params);
  }

  static async create(data: any) {
    return api.create<any>('/admin/dashboard', data);
  }
}

export class UsersService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/users', params);
  }

  static async getById(id: string) {
    return api.getById<any>('/admin/users', id);
  }

  static async create(userData: any) {
    return api.create<any>('/admin/users', userData);
  }

  static async update(id: string, userData: any) {
    return api.update<any>('/admin/users', id, userData);
  }

  static async delete(id: string) {
    return api.delete('/admin/users', id);
  }

  static async toggleStatus(id: string, isActive: boolean) {
    return api.patch<any>('/admin/users', id, { isActive });
  }
}

export class BarbersService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/barbers', params);
  }

  static async getById(id: string) {
    return api.getById<any>('/admin/barbers', id);
  }

  static async create(barberData: any) {
    return api.create<any>('/admin/barbers', barberData);
  }

  static async update(id: string, barberData: any) {
    return api.update<any>('/admin/barbers', id, barberData);
  }

  static async delete(id: string) {
    return api.delete('/admin/barbers', id);
  }

  static async toggleStatus(id: string, isActive: boolean) {
    return api.patch<any>('/admin/barbers', id, { isActive });
  }

  static async updateServices(id: string, services: any[]) {
    return api.patch<any>('/admin/barbers', id, { services });
  }

  static async export(params?: QueryParams) {
    return api.export('/admin/barbers', params);
  }
}

export class ServicesService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/services', params);
  }

  static async getById(id: string) {
    return api.getById<any>('/services', id);
  }

  static async create(serviceData: any) {
    return api.create<any>('/services', serviceData);
  }

  static async update(id: string, serviceData: any) {
    return api.update<any>('/services', id, serviceData);
  }

  static async delete(id: string) {
    return api.delete('/services', id);
  }

  static async toggleStatus(id: string, isActive: boolean) {
    return api.patch<any>('/services', id, { isActive });
  }
}

export class AppointmentsService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/appointments', params);
  }

  static async getById(id: string) {
    return api.getById<any>('/admin/appointments', id);
  }

  static async create(appointmentData: any) {
    return api.create<any>('/admin/appointments', appointmentData);
  }

  static async update(id: string, appointmentData: any) {
    return api.update<any>('/admin/appointments', id, appointmentData);
  }

  static async updateStatus(id: string, status: string) {
    return api.patch<any>('/admin/appointments', id, { status });
  }

  static async delete(id: string) {
    return api.delete('/admin/appointments', id);
  }

  static async export(params?: QueryParams) {
    return api.export('/admin/appointments', params);
  }
}

export class CustomersService {
  static async getAll(params?: QueryParams) {
    // Use real backend endpoint
    return api.getAll<any>('/admin/customers', params);
  }

  static async getById(id: string) {
    // Use real backend endpoint
    return api.getById<any>('/admin/customers', id);
  }

  static async create(customerData: any) {
    // Use real backend endpoint
    return api.create<any>('/admin/customers', customerData);
  }

  static async update(id: string, customerData: any) {
    // Use real backend endpoint
    return api.update<any>('/admin/customers', id, customerData);
  }

  static async delete(id: string) {
    // Use real backend endpoint
    return api.delete('/admin/customers', id);
  }

  static async toggleStatus(id: string, isActive: boolean) {
    // Use real backend endpoint
    return api.patch<any>('/admin/customers', id, { isActive });
  }

  static async suspend(id: string) {
    const token = localStorage.getItem('authToken');
    const response = await fetch(`${API_BASE_URL}/admin/customers/${id}/block`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        ...(token && { Authorization: `Bearer ${token}` }),
      },
    });

    if (!response.ok) {
      throw new Error(`Failed to suspend customer: ${response.status}`);
    }

    return response.json();
  }

  static async unsuspend(id: string) {
    const token = localStorage.getItem('authToken');
    const response = await fetch(`${API_BASE_URL}/admin/customers/${id}/unblock`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        ...(token && { Authorization: `Bearer ${token}` }),
      },
    });

    if (!response.ok) {
      throw new Error(`Failed to unsuspend customer: ${response.status}`);
    }

    return response.json();
  }

  static async export(params?: any) {
    // Use real backend endpoint
    return api.export('/admin/customers', params);
  }
}

export class TransactionsService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/transactions', params);
  }

  static async getById(id: string) {
    return api.getById<any>('/admin/transactions', id);
  }

  static async create(transactionData: any) {
    return api.create<any>('/admin/transactions', transactionData);
  }

  static async updateStatus(id: string, status: string) {
    return api.patch<any>('/admin/transactions', id, { status });
  }

  static async refund(id: string, reason: string) {
    return api.patch<any>('/admin/transactions', id, { reason });
  }

  static async export(params?: QueryParams) {
    return api.export('/admin/transactions', params);
  }
}

export class ReviewsService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/reviews', params);
  }

  static async getById(id: string) {
    return api.getById<any>('/admin/reviews', id);
  }

  static async approve(id: string) {
    return api.patch<any>('/admin/reviews', id, {});
  }

  static async hide(id: string) {
    return api.patch<any>('/admin/reviews', id, {});
  }

  static async respond(id: string, response: string) {
    return api.patch<any>('/admin/reviews', id, { response });
  }

  static async delete(id: string) {
    return api.delete('/admin/reviews', id);
  }

  static async export(params?: QueryParams) {
    return api.export('/admin/reviews', params);
  }
}

export class ReportsService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/reports', params);
  }

  static async generate(reportType: string, params: any) {
    return api.create<any>('/admin/reports/generate', { type: reportType, ...params });
  }

  static async download(id: string) {
    return api.getById<any>('/admin/reports', id);
  }

  static async schedule(reportConfig: any) {
    return api.create<any>('/admin/reports/schedule', reportConfig);
  }
}

export class FinanceService {
  static async getStats(period = '30d') {
    return api.get<any>(`/admin/finance/stats?period=${period}`);
  }

  static async getTransactions(params?: QueryParams) {
    return api.getAll<any>('/admin/finance/transactions', params);
  }

  static async getExpenses(params?: QueryParams) {
    return api.getAll<any>('/admin/finance/expenses', params);
  }

  static async createExpense(expenseData: any) {
    return api.create<any>('/admin/finance/expenses', expenseData);
  }

  static async updateExpense(id: string, expenseData: any) {
    return api.update<any>('/admin/finance/expenses', id, expenseData);
  }
}

export class SettingsService {
  static async getAll() {
    return api.get<any>('/admin/settings');
  }

  static async update(settings: any) {
    return api.update<any>('/admin/settings', 'general', settings);
  }

  static async updateNotifications(notifications: any) {
    return api.update<any>('/admin/settings', 'notifications', notifications);
  }

  static async updateSecurity(security: any) {
    return api.update<any>('/admin/settings', 'security', security);
  }

  static async updatePayment(payment: any) {
    return api.update<any>('/admin/settings', 'payment', payment);
  }
}

// Additional services for remaining pages...
export class AdminsService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/admins', params);
  }

  static async getById(id: string) {
    return api.getById<any>('/admin/admins', id);
  }

  static async getProfile(email: string) {
    return api.getAll<any>('/admin/admins', { search: email });
  }

  static async create(adminData: any) {
    return api.create<any>('/admin/admins', adminData);
  }

  static async update(id: string, adminData: any) {
    return api.update<any>('/admin/admins', id, adminData);
  }

  static async delete(id: string) {
    return api.delete('/admin/admins', id);
  }
}

export class ModerationService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/moderation/reports', params);
  }

  static async getById(id: string) {
    return api.getById<any>('/admin/moderation/reports', id);
  }

  static async approve(id: string) {
    return api.patch<any>('/admin/moderation/reports', id, { action: 'approve' });
  }

  static async dismiss(id: string) {
    return api.patch<any>('/admin/moderation/reports', id, { action: 'dismiss' });
  }

  static async remove(id: string) {
    return api.patch<any>('/admin/moderation/reports', id, { action: 'remove' });
  }
}

export class PayoutsService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/payouts', params);
  }

  static async create(payoutData: any) {
    return api.create<any>('/admin/payouts', payoutData);
  }

  static async approve(id: string) {
    return api.patch<any>('/admin/payouts', id, {});
  }

  static async process(id: string) {
    return api.patch<any>('/admin/payouts', id, {});
  }
}

export default api;
