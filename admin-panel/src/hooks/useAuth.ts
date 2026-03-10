import { useEffect, useState } from 'react';
import { getAuth, onAuthStateChanged } from 'firebase/auth';
import { useRouter } from 'next/navigation';
import toast from 'react-hot-toast';
import { app } from '@/lib/firebase';

export function useAuth() {
  const [loading, setLoading] = useState(true);
  const [authenticated, setAuthenticated] = useState(false);
  const router = useRouter();

  useEffect(() => {
    const auth = getAuth(app);
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      if (user) {
        // Check if user email is admin
        const adminEmails = ['admin@afro.com', 'support@afro.com', 'manager@afro.com'];
        if (adminEmails.includes(user.email || '')) {
          setAuthenticated(true);
          setLoading(false);
        } else {
          setAuthenticated(false);
          setLoading(false);
          router.push('/login');
          toast.error('Access denied. Admin privileges required.');
        }
      } else {
        // No user, redirect to login
        setAuthenticated(false);
        setLoading(false);
        router.push('/login');
        toast.error('Please login to access the admin panel');
      }
    });

    // Cleanup subscription
    return () => unsubscribe();
  }, [router]);

  return { loading, authenticated };
}
