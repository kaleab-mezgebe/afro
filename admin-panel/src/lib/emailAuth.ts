import { 
  sendSignInLinkToEmail, 
  isSignInWithEmailLink, 
  signInWithEmailLink,
  ActionCodeSettings 
} from 'firebase/auth';
import { auth } from './firebase';

/**
 * Firebase Email Link Authentication Service
 * Implements passwordless authentication using email links
 */

// Action code settings for email link authentication
const actionCodeSettings: ActionCodeSettings = {
  // URL must be whitelisted in Firebase Console
  url: process.env.NODE_ENV === 'production' 
    ? 'https://your-domain.com/admin/auth/complete' 
    : 'http://localhost:3000/admin/auth/complete',
  handleCodeInApp: true,
  // Add your iOS and Android app info if needed
  iOS: {
    bundleId: 'com.afro.admin'
  },
  android: {
    packageName: 'com.afro.admin',
    installApp: true,
    minimumVersion: '12'
  }
};

/**
 * Send authentication link to admin email
 */
export async function sendAdminSignInLink(email: string): Promise<void> {
  try {
    // Validate admin email (you can customize this validation)
    if (!isValidAdminEmail(email)) {
      throw new Error('Invalid admin email address');
    }

    await sendSignInLinkToEmail(auth, email, actionCodeSettings);
    
    // Store email locally for completion on same device
    if (typeof window !== 'undefined') {
      window.localStorage.setItem('emailForSignIn', email);
      window.localStorage.setItem('signInTimestamp', Date.now().toString());
    }
    
    console.log('Sign-in link sent successfully to:', email);
  } catch (error: any) {
    console.error('Error sending sign-in link:', error);
    
    // Handle specific Firebase errors
    switch (error.code) {
      case 'auth/invalid-email':
        throw new Error('Invalid email address format');
      case 'auth/user-not-found':
        throw new Error('Admin account not found');
      case 'auth/operation-not-allowed':
        throw new Error('Email link sign-in is not enabled. Please contact support.');
      case 'auth/too-many-requests':
        throw new Error('Too many requests. Please try again later.');
      default:
        throw new Error('Failed to send sign-in link. Please try again.');
    }
  }
}

/**
 * Complete sign-in with email link
 */
export async function completeEmailLinkSignIn(url: string, email?: string): Promise<any> {
  try {
    // Check if the URL is a valid sign-in link
    if (!isSignInWithEmailLink(auth, url)) {
      throw new Error('Invalid sign-in link');
    }

    // Get email from parameter or local storage
    let userEmail = email;
    
    if (!userEmail && typeof window !== 'undefined') {
      userEmail = window.localStorage.getItem('emailForSignIn');
    }

    if (!userEmail) {
      // Prompt user for email if not available (different device scenario)
      userEmail = window.prompt('Please provide your email for confirmation');
    }

    if (!userEmail) {
      throw new Error('Email is required to complete sign-in');
    }

    // Validate admin email
    if (!isValidAdminEmail(userEmail)) {
      throw new Error('Unauthorized email address');
    }

    // Complete the sign-in
    const result = await signInWithEmailLink(auth, userEmail, url);
    
    // Clean up local storage
    if (typeof window !== 'undefined') {
      window.localStorage.removeItem('emailForSignIn');
      window.localStorage.removeItem('signInTimestamp');
    }

    console.log('Email link sign-in successful:', result.user.email);
    return result;
    
  } catch (error: any) {
    console.error('Error completing email link sign-in:', error);
    
    switch (error.code) {
      case 'auth/invalid-action-code':
        throw new Error('Invalid or expired sign-in link');
      case 'auth/invalid-email':
        throw new Error('Invalid email address');
      case 'auth/user-disabled':
        throw new Error('Admin account has been disabled');
      default:
        throw new Error('Failed to complete sign-in. Please try again.');
    }
  }
}

/**
 * Check if current URL is a sign-in link
 */
export function isCurrentUrlSignInLink(): boolean {
  if (typeof window === 'undefined') return false;
  return isSignInWithEmailLink(auth, window.location.href);
}

/**
 * Get stored email for sign-in (if available)
 */
export function getStoredEmailForSignIn(): string | null {
  if (typeof window === 'undefined') return null;
  return window.localStorage.getItem('emailForSignIn');
}

/**
 * Check if sign-in link has expired (24 hours)
 */
export function isSignInLinkExpired(): boolean {
  if (typeof window === 'undefined') return false;
  
  const timestamp = window.localStorage.getItem('signInTimestamp');
  if (!timestamp) return false;
  
  const signInTime = parseInt(timestamp);
  const now = Date.now();
  const twentyFourHours = 24 * 60 * 60 * 1000;
  
  return (now - signInTime) > twentyFourHours;
}

/**
 * Validate admin email addresses
 * Customize this function based on your admin email requirements
 */
function isValidAdminEmail(email: string): boolean {
  // Basic email validation
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) return false;
  
  // Admin email whitelist (customize as needed)
  const adminDomains = [
    'afro.com',
    'admin.afro.com',
    'yourdomain.com' // Add your admin domains
  ];
  
  const adminEmails = [
    'admin@afro.com',
    'support@afro.com',
    'manager@afro.com'
    // Add specific admin emails
  ];
  
  // Check if email is in whitelist
  if (adminEmails.includes(email.toLowerCase())) {
    return true;
  }
  
  // Check if domain is allowed
  const domain = email.split('@')[1]?.toLowerCase();
  return adminDomains.includes(domain);
}

/**
 * Clear stored sign-in data
 */
export function clearSignInData(): void {
  if (typeof window === 'undefined') return;
  
  window.localStorage.removeItem('emailForSignIn');
  window.localStorage.removeItem('signInTimestamp');
}

/**
 * Get sign-in link configuration for display
 */
export function getSignInLinkConfig() {
  return {
    url: actionCodeSettings.url,
    handleCodeInApp: actionCodeSettings.handleCodeInApp,
    isProduction: process.env.NODE_ENV === 'production'
  };
}