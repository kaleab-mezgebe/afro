import { useEffect, useState } from 'react';
import { getAuth, onAuthStateChanged, signOut } from 'firebase/auth';
import { useRouter } from 'next/navigation';
import toast from 'react-hot-toast';
import { app } from '@/lib/firebase';

export function useAuth() {
  const [loading, setLoading] = useState(true);
  const [authenticated, setAuthenticated] = useState(false);
  const router = useRouter();

  useEffect(() => {
    const auth = getAuth(app);
    let refreshInterval: NodeJS.Timeout;

    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        // 1. Check if user email is admin
        const adminEmails = ['admin@afro.com', 'support@afro.com', 'manager@afro.com', 'admin@afr.com'];
        if (adminEmails.includes(user.email || '')) {
          // 2. Synchronize token with ApiService
          try {
            const token = await user.getIdToken();
            localStorage.setItem('authToken', token);

            // 3. Setup periodic token refresh (Firebase tokens expire in 1 hour)
            // Refresh 5 minutes before expiration
            if (refreshInterval) clearInterval(refreshInterval);
            refreshInterval = setInterval(async () => {
              const newToken = await user.getIdToken(true);
              localStorage.setItem('authToken', newToken);
              console.log('[useAuth] Token refreshed successfully');
            }, 55 * 60 * 1000);

            setAuthenticated(true);
            setLoading(false);
          } catch (tokenError) {
            console.error('Token synchronization error:', tokenError);
            toast.error('Session error. Please login again.');
            setLoading(false);
          }
        } else {
          setAuthenticated(false);
          setLoading(false);
          router.push('/login');
          toast.error('Access denied. Admin privileges required.');
        }
      } else {
        // No user, check if we have a dev-bypass-token
        const token = localStorage.getItem('authToken');
        if (process.env.NODE_ENV === 'development' && token === 'dev-bypass-token') {
          setAuthenticated(true);
          setLoading(false);
          return;
        }

        setAuthenticated(false);
        setLoading(false);
        router.push('/login');
      }
    });

    // Cleanup subscription
    return () => {
      unsubscribe();
      if (refreshInterval) clearInterval(refreshInterval);
    };
  }, [router]);

  const logout = async () => {
    try {
      const auth = getAuth(app);
      await signOut(auth);
      toast.success('Logged out successfully');
      router.push('/login');
    } catch (error) {
      console.error('Logout error:', error);
      toast.error('Failed to logout');
    }
  };

  return { loading, authenticated, logout };
}
