// API Service for Admin Panel
import { toast } from 'react-hot-toast';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001/api/v1';

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

class ApiService {
  private baseURL: string;

  constructor() {
    this.baseURL = API_BASE_URL;
  }

  private getToken(): string | null {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('authToken');
    }
    return null;
  }

  public setAuthToken(token: string): void {
    if (typeof window !== 'undefined') {
      localStorage.setItem('authToken', token);
    }
  }

  public isAuthenticated(): boolean {
    return !!this.getToken();
  }

  private async request<T>(endpoint: string, options: RequestInit = {}): Promise<ApiResponse<T>> {
    const token = this.getToken();
    const url = `${this.baseURL}${endpoint}`;

    try {
      const response = await fetch(url, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...(token && { Authorization: `Bearer ${token}` }),
          ...options.headers,
        },
      });

      const data = await response.json();

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

    if (response.success && response.data && Array.isArray(response.data)) {
      if ('total' in response || 'totalPages' in response) {
        return response as unknown as PaginatedResponse<T>;
      }
      return response.data as any;
    }

    return response as any;
  }

  async getById<T>(endpoint: string, id: string): Promise<ApiResponse<T>> {
    return this.request<T>(`${endpoint}/${id}`);
  }

  async get<T>(endpoint: string, params?: any): Promise<ApiResponse<T>> {
    let queryString = '';
    if (params) {
      queryString = `?${new URLSearchParams(params).toString()}`;
    }
    return this.request<T>(`${endpoint}${queryString}`);
  }

  async post<T>(endpoint: string, data: any): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async put<T>(endpoint: string, id: string, data: any): Promise<ApiResponse<T>> {
    return this.request<T>(`${endpoint}/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async create<T>(endpoint: string, data: any): Promise<ApiResponse<T>> {
    return this.post<T>(endpoint, data);
  }

  async update<T>(endpoint: string, id: string, data: any): Promise<ApiResponse<T>> {
    return this.put<T>(endpoint, id, data);
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
}

export const api = new ApiService();

export class BarbersService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/providers', params);
  }

  static async getById(id: string) {
    return api.getById<any>('/admin/providers', id);
  }

  static async create(barberData: any) {
    return api.post<any>('/admin/providers', barberData);
  }

  static async update(id: string, barberData: any) {
    return api.put<any>('/admin/providers', id, barberData);
  }

  static async delete(id: string) {
    return api.delete('/admin/providers', id);
  }

  static async verify(id: string) {
    return api.post<any>(`/admin/providers/${id}/verify`, {});
  }

  static async approve(id: string) {
    return api.post<any>(`/admin/providers/${id}/approve`, {});
  }

  static async reject(id: string, reason: string) {
    return api.post<any>(`/admin/providers/${id}/reject`, { reason });
  }

  static async toggleStatus(id: string, isActive: boolean) {
    const endpoint = isActive ? 'activate' : 'suspend';
    return api.post<any>(`/admin/users/${id}/${endpoint}`, {});
  }

  static async export(format: string, filter?: any) {
    return api.get<any>(`/admin/providers/export`, { ...filter, format });
  }
}

export class CustomersService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/customers', params);
  }

  static async getById(id: string) {
    return api.getById<any>('/admin/customers', id);
  }

  static async getStats() {
    return api.get<any>('/admin/dashboard/stats');
  }

  static async create(customerData: any) {
    return api.post<any>('/admin/users', { ...customerData, role: 'customer' });
  }

  static async update(id: string, customerData: any) {
    return api.put<any>('/admin/users', id, customerData);
  }

  static async delete(id: string) {
    return api.delete('/admin/users', id);
  }

  static async toggleStatus(id: string, isActive: boolean) {
    const endpoint = isActive ? 'activate' : 'suspend';
    return api.post<any>(`/admin/users/${id}/${endpoint}`, {});
  }

  static async export(format: string, filter?: any) {
    return api.get<any>(`/admin/customers/export`, { ...filter, format });
  }
}

export class UsersService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/users', params);
  }

  static async getById(id: string) {
    return api.getById<any>('/admin/users', id);
  }

  static async update(id: string, userData: any) {
    return api.put<any>('/admin/users', id, userData);
  }

  static async delete(id: string) {
    return api.delete('/admin/users', id);
  }
}

export class ServicesService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/services', params);
  }

  static async create(serviceData: any) {
    return api.post<any>('/services', serviceData);
  }

  static async update(id: string, serviceData: any) {
    return api.put<any>('/services', id, serviceData);
  }

  static async delete(id: string) {
    return api.delete('/services', id);
  }
}

export class DashboardService {
  static async getStats() {
    return api.get<any>('/admin/dashboard/stats');
  }

  static async getActivities() {
    return api.get<any>('/admin/dashboard/activities');
  }

  static async getAdvancedAnalytics() {
    return api.get<any>('/admin/dashboard/analytics');
  }
}

export class AppointmentsService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/appointments', params);
  }

  static async getById(id: string) {
    return api.getById<any>('/admin/appointments', id);
  }

  static async updateStatus(id: string, status: string) {
    return api.patch<any>('/admin/appointments', id, { status });
  }

  static async resolveDispute(id: string, resolution: string) {
    return api.post<any>(`/admin/appointments/${id}/resolve`, { resolution });
  }

  static async export(format?: string, filter?: any) {
    return api.get<any>('/admin/appointments/export', { ...filter, format });
  }
}

export class TransactionsService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/transactions', params);
  }

  static async getById(id: string) {
    return api.getById<any>('/admin/transactions', id);
  }

  static async refund(id: string, reason: string, amount?: number) {
    return api.post<any>(`/admin/transactions/${id}/refund`, { reason, amount });
  }

  static async updateStatus(id: string, status: string) {
    return api.patch<any>('/admin/transactions', id, { status });
  }

  static async export(format?: string, filter?: any) {
    return api.get<any>('/admin/transactions/export', { ...filter, format });
  }
}

export class PayoutsService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/payouts', params);
  }

  static async getStats() {
    return api.get<any>('/admin/payouts/stats');
  }

  static async process(id: string, data?: any) {
    return api.post<any>(`/admin/payouts/${id}/process`, data || {});
  }

  static async complete(id: string, transactionId: string) {
    return api.post<any>(`/admin/payouts/${id}/complete`, { transactionId });
  }

  static async fail(id: string, reason: string) {
    return api.post<any>(`/admin/payouts/${id}/fail`, { reason });
  }
}

export class ReportsService {
  static async getRevenue(params?: QueryParams) {
    return api.get<any>('/reports/revenue', params);
  }

  static async getBookings(params?: QueryParams) {
    return api.get<any>('/reports/bookings', params);
  }

  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/reports', params);
  }
}

export class ReviewsService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/admin/reviews', params);
  }

  static async approve(id: string) {
    return api.post<any>(`/admin/reviews/${id}/approve`, {});
  }

  static async flag(id: string) {
    return api.post<any>(`/admin/reviews/${id}/flag`, {});
  }

  static async delete(id: string) {
    return api.delete('/admin/reviews', id);
  }

  static async export(format?: string, filter?: any) {
    return api.get<any>('/admin/reviews/export', { ...filter, format });
  }
}

export class SettingsService {
  static async get() {
    return api.get<any>('/settings');
  }

  static async update(data: any) {
    return api.post<any>('/settings', data);
  }
}

export class ModerationService {
  static async getAll(params?: QueryParams) {
    return api.getAll<any>('/moderation', params);
  }

  static async getById(id: string) {
    return api.getById<any>('/moderation', id);
  }

  static async approve(id: string) {
    return api.patch<any>('/moderation', id, { status: 'resolved' });
  }

  static async dismiss(id: string) {
    return api.patch<any>('/moderation', id, { status: 'dismissed' });
  }

  static async remove(id: string) {
    return api.delete('/moderation', id);
  }
}

export class AdminsService {
  static async getAll() {
    return api.get<any>('/admin/admins');
  }

  static async create(adminData: any) {
    return api.post<any>('/admin/users', { ...adminData, role: 'admin' });
  }

  static async update(id: string, adminData: any) {
    return api.put<any>('/admin/users', id, adminData);
  }

  static async delete(id: string) {
    return api.delete('/admin/users', id);
  }
}

export default api;
