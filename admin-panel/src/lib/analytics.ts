import { getAnalytics, logEvent, setUserId, setUserProperties } from 'firebase/analytics';
import { app } from './firebase';

class AnalyticsService {
  private analytics: any;
  private isInitialized = false;

  constructor() {
    if (typeof window !== 'undefined') {
      try {
        this.analytics = getAnalytics(app);
        this.isInitialized = true;
      } catch (error) {
        console.error('Failed to initialize analytics:', error);
      }
    }
  }

  /**
   * Log page view
   */
  logPageView(pageName: string, pageTitle?: string) {
    if (!this.isInitialized) return;

    try {
      logEvent(this.analytics, 'page_view', {
        page_name: pageName,
        page_title: pageTitle || pageName,
      });
    } catch (error) {
      console.error('Error logging page view:', error);
    }
  }

  /**
   * Log custom event
   */
  logEvent(eventName: string, params?: Record<string, any>) {
    if (!this.isInitialized) return;

    try {
      logEvent(this.analytics, eventName, params);
    } catch (error) {
      console.error('Error logging event:', error);
    }
  }

  /**
   * Log user action
   */
  logUserAction(action: string, details?: Record<string, any>) {
    this.logEvent('admin_action', {
      action,
      ...details,
    });
  }

  /**
   * Log data modification
   */
  logDataModification(type: 'create' | 'update' | 'delete', resource: string, resourceId?: string) {
    this.logEvent('data_modification', {
      modification_type: type,
      resource,
      resource_id: resourceId,
    });
  }

  /**
   * Log search
   */
  logSearch(searchTerm: string, category?: string) {
    if (!this.isInitialized) return;

    try {
      logEvent(this.analytics, 'search', {
        search_term: searchTerm,
        category,
      });
    } catch (error) {
      console.error('Error logging search:', error);
    }
  }

  /**
   * Log filter usage
   */
  logFilter(filterType: string, filterValue: string) {
    this.logEvent('filter_applied', {
      filter_type: filterType,
      filter_value: filterValue,
    });
  }

  /**
   * Log export action
   */
  logExport(dataType: string, format: string) {
    this.logEvent('data_export', {
      data_type: dataType,
      format,
    });
  }

  /**
   * Log error
   */
  logError(error: string, context?: string) {
    this.logEvent('admin_error', {
      error_message: error,
      context,
    });
  }

  /**
   * Set user ID
   */
  setUser(userId: string) {
    if (!this.isInitialized) return;

    try {
      setUserId(this.analytics, userId);
    } catch (error) {
      console.error('Error setting user ID:', error);
    }
  }

  /**
   * Set user properties
   */
  setUserProperty(properties: Record<string, any>) {
    if (!this.isInitialized) return;

    try {
      setUserProperties(this.analytics, properties);
    } catch (error) {
      console.error('Error setting user properties:', error);
    }
  }

  /**
   * Log login
   */
  logLogin(method: string) {
    this.logEvent('login', {
      method,
    });
  }

  /**
   * Log logout
   */
  logLogout() {
    this.logEvent('logout');
  }
}

export const analytics = new AnalyticsService();
