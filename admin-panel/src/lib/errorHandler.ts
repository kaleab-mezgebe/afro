import { AxiosError } from 'axios';
import toast from 'react-hot-toast';

export interface ApiError {
  message: string;
  statusCode?: number;
  details?: any;
}

export class ErrorHandler {
  /**
   * Handle Axios errors and return user-friendly messages
   */
  static handleAxiosError(error: AxiosError): ApiError {
    if (error.response) {
      // Server responded with error status
      const statusCode = error.response.status;
      const message = this.getStatusMessage(statusCode);
      
      return {
        message,
        statusCode,
        details: error.response.data,
      };
    } else if (error.request) {
      // Request made but no response
      return {
        message: 'No response from server. Please check your internet connection.',
      };
    } else {
      // Error in request setup
      return {
        message: error.message || 'An unexpected error occurred.',
      };
    }
  }

  /**
   * Get user-friendly message for HTTP status codes
   */
  private static getStatusMessage(statusCode: number): string {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication failed. Please log in again.';
      case 403:
        return 'Access denied. You don\'t have permission for this action.';
      case 404:
        return 'Resource not found.';
      case 408:
        return 'Request timeout. Please try again.';
      case 409:
        return 'Conflict. This resource already exists.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again later.';
      default:
        return `An error occurred (Code: ${statusCode}). Please try again.`;
    }
  }

  /**
   * Show error toast notification
   */
  static showError(error: any, customMessage?: string) {
    let message = customMessage;

    if (!message) {
      if (error instanceof AxiosError) {
        const apiError = this.handleAxiosError(error);
        message = apiError.message;
      } else if (error instanceof Error) {
        message = error.message;
      } else if (typeof error === 'string') {
        message = error;
      } else {
        message = 'An unexpected error occurred.';
      }
    }

    toast.error(message, {
      duration: 4000,
      position: 'bottom-right',
    });
  }

  /**
   * Show success toast notification
   */
  static showSuccess(message: string) {
    toast.success(message, {
      duration: 3000,
      position: 'bottom-right',
    });
  }

  /**
   * Show info toast notification
   */
  static showInfo(message: string) {
    toast(message, {
      duration: 3000,
      position: 'bottom-right',
      icon: 'ℹ️',
    });
  }

  /**
   * Retry operation with exponential backoff
   */
  static async withRetry<T>(
    operation: () => Promise<T>,
    maxRetries: number = 3,
    baseDelay: number = 1000
  ): Promise<T> {
    let lastError: any;

    for (let attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await operation();
      } catch (error) {
        lastError = error;
        
        if (attempt < maxRetries - 1) {
          const delay = baseDelay * Math.pow(2, attempt);
          await new Promise(resolve => setTimeout(resolve, delay));
        }
      }
    }

    throw lastError;
  }

  /**
   * Check if error is network-related
   */
  static isNetworkError(error: any): boolean {
    if (error instanceof AxiosError) {
      return !error.response && !!error.request;
    }
    return false;
  }

  /**
   * Check if error requires authentication
   */
  static isAuthError(error: any): boolean {
    if (error instanceof AxiosError) {
      return error.response?.status === 401 || error.response?.status === 403;
    }
    return false;
  }
}
