'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { 
  completeEmailLinkSignIn, 
  isCurrentUrlSignInLink, 
  getStoredEmailForSignIn,
  clearSignInData 
} from '@/lib/emailAuth';
import toast from 'react-hot-toast';

/* ─────────────────────────────────────────────────
   Email Link Sign-In Completion Page
───────────────────────────────────────────────── */

const LoadingSpinner = () => (
  <div className="animate-spin w-8 h-8 border-3 border-gold border-t-transparent rounded-full" />
);

const CheckIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"
    strokeLinecap="round" strokeLinejoin="round" className="w-8 h-8">
    <polyline points="20,6 9,17 4,12" />
  </svg>
);

const ErrorIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"
    strokeLinecap="round" strokeLinejoin="round" className="w-8 h-8">
    <circle cx="12" cy="12" r="10" />
    <line x1="15" y1="9" x2="9" y2="15" />
    <line x1="9" y1="9" x2="15" y2="15" />
  </svg>
);

type AuthState = 'loading' | 'success' | 'error' | 'email-required';

export default function EmailLinkCompletePage() {
  const [authState, setAuthState] = useState<AuthState>('loading');
  const [email, setEmail] = useState('');
  const [error, setError] = useState('');
  const [mounted, setMounted] = useState(false);
  const [processing, setProcessing] = useState(false);
  
  const router = useRouter();
  const searchParams = useSearchParams();

  useEffect(() => {
    setMounted(true);
    handleEmailLinkSignIn();
  }, []);

  const handleEmailLinkSignIn = async () => {
    try {
      // Check if this is a valid sign-in link
      if (!isCurrentUrlSignInLink()) {
        setError('Invalid or expired sign-in link');
        setAuthState('error');
        return;
      }

      // Try to get email from storage first
      const storedEmail = getStoredEmailForSignIn();
      
      if (storedEmail) {
        // Complete sign-in with stored email
        await completeSignIn(storedEmail);
      } else {
        // Need to ask for email (different device scenario)
        setAuthState('email-required');
      }
    } catch (error: any) {
      console.error('Email link sign-in error:', error);
      setError(error.message || 'Failed to complete sign-in');
      setAuthState('error');
    }
  };

  const completeSignIn = async (userEmail: string) => {
    try {
      setProcessing(true);
      
      const result = await completeEmailLinkSignIn(window.location.href, userEmail);
      
      if (result?.user) {
        setAuthState('success');
        toast.success('Welcome back, Admin!');
        
        // Redirect to dashboard after a short delay
        setTimeout(() => {
          router.push('/dashboard');
        }, 2000);
      } else {
        throw new Error('Sign-in completed but no user data received');
      }
    } catch (error: any) {
      console.error('Complete sign-in error:', error);
      setError(error.message || 'Failed to complete sign-in');
      setAuthState('error');
    } finally {
      setProcessing(false);
    }
  };

  const handleEmailSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!email) {
      toast.error('Please enter your email address');
      return;
    }

    await completeSignIn(email);
  };

  const handleRetry = () => {
    clearSignInData();
    router.push('/auth/email-link');
  };

  if (!mounted) return null;

  return (
    <>
      {/* Styles */}
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700&family=Inter:wght@300;400;500;600&display=swap');

        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; }

        @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
        @keyframes slide-up { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }
        @keyframes bounce { 0%, 20%, 53%, 80%, 100% { transform: translateY(0); } 40%, 43% { transform: translateY(-10px); } 70% { transform: translateY(-5px); } }

        .animate-spin { animation: spin 1s linear infinite; }
        .animate-pulse { animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite; }
        .animate-slide-up { animation: slide-up 0.7s ease forwards; }
        .animate-bounce { animation: bounce 1s infinite; }

        .gradient-bg {
          background: linear-gradient(135deg, #0a0a0a 0%, #1a1208 30%, #0d0d0d 60%, #120c04 100%);
        }

        .glass-card {
          background: rgba(255, 255, 255, 0.03);
          backdrop-filter: blur(20px);
          border: 1px solid rgba(212, 175, 55, 0.15);
          box-shadow: 0 25px 50px rgba(0,0,0,0.6);
        }

        .success-card { background: rgba(34, 197, 94, 0.1); border-color: rgba(34, 197, 94, 0.3); }
        .error-card { background: rgba(239, 68, 68, 0.1); border-color: rgba(239, 68, 68, 0.3); }

        .input-field {
          background: rgba(255,255,255,0.04);
          border: 1.5px solid rgba(212,175,55,0.2);
          color: #fff;
          transition: all 0.3s ease;
        }
        .input-field:focus {
          outline: none;
          background: rgba(212,175,55,0.06);
          border-color: rgba(212,175,55,0.7);
          box-shadow: 0 0 0 3px rgba(212,175,55,0.1);
        }

        .gold-btn {
          background: linear-gradient(135deg, #c9a227 0%, #e8c84a 40%, #d4af37 60%, #b8942a 100%);
          transition: all 0.4s ease;
          box-shadow: 0 4px 20px rgba(212,175,55,0.3);
        }
        .gold-btn:hover { box-shadow: 0 6px 30px rgba(212,175,55,0.5); transform: translateY(-1px); }
        .gold-btn:disabled { opacity: 0.6; transform: none; }
      `}</style>

      <div className="min-h-screen gradient-bg flex items-center justify-center p-6">
        <div className="w-full max-w-md">
          
          {authState === 'loading' && (
            <div className="glass-card animate-slide-up rounded-2xl p-8 text-center" style={{ opacity: 0, animationFillMode: 'forwards' }}>
              <div className="animate-pulse mb-6">
                <LoadingSpinner />
              </div>
              
              <h2 style={{
                fontFamily: "'Playfair Display', serif",
                fontSize: 24,
                fontWeight: 700,
                color: '#ffffff',
                marginBottom: 12,
              }}>
                Completing Sign-In
              </h2>
              
              <p style={{ fontSize: 14, color: 'rgba(255,255,255,0.6)' }}>
                Please wait while we verify your authentication...
              </p>
            </div>
          )}

          {authState === 'email-required' && (
            <div className="glass-card animate-slide-up rounded-2xl p-8" style={{ opacity: 0, animationFillMode: 'forwards' }}>
              <div className="text-center mb-6">
                <div style={{
                  width: 60, height: 60,
                  background: 'rgba(212,175,55,0.2)',
                  borderRadius: '50%',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  margin: '0 auto 16px',
                  color: '#d4af37',
                }}>
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
                    <polyline points="22,6 12,13 2,6" />
                  </svg>
                </div>

                <h2 style={{
                  fontFamily: "'Playfair Display', serif",
                  fontSize: 24,
                  fontWeight: 700,
                  color: '#ffffff',
                  marginBottom: 8,
                }}>
                  Confirm Your Email
                </h2>
                
                <p style={{ fontSize: 14, color: 'rgba(255,255,255,0.6)', marginBottom: 24 }}>
                  Please enter your email address to complete the sign-in process
                </p>
              </div>

              <form onSubmit={handleEmailSubmit} className="space-y-4">
                <input
                  type="email"
                  required
                  placeholder="admin@afro.com"
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  className="input-field w-full px-4 py-3 rounded-xl text-sm"
                />
                
                <button
                  type="submit"
                  disabled={processing}
                  className="gold-btn w-full py-3 px-6 rounded-xl border-none cursor-pointer text-sm font-semibold text-black flex items-center justify-center gap-2"
                >
                  {processing ? (
                    <>
                      <LoadingSpinner />
                      Verifying...
                    </>
                  ) : (
                    'Complete Sign-In'
                  )}
                </button>
              </form>
            </div>
          )}

          {authState === 'success' && (
            <div className="success-card animate-slide-up rounded-2xl p-8 text-center" style={{ opacity: 0, animationFillMode: 'forwards' }}>
              <div className="animate-bounce mb-6" style={{ color: '#22c55e' }}>
                <CheckIcon />
              </div>
              
              <h2 style={{
                fontFamily: "'Playfair Display', serif",
                fontSize: 28,
                fontWeight: 700,
                color: '#ffffff',
                marginBottom: 12,
              }}>
                Welcome Back!
              </h2>
              
              <p style={{ fontSize: 16, color: 'rgba(255,255,255,0.7)', marginBottom: 24 }}>
                Sign-in successful. Redirecting to your dashboard...
              </p>

              <div className="animate-pulse">
                <LoadingSpinner />
              </div>
            </div>
          )}

          {authState === 'error' && (
            <div className="error-card animate-slide-up rounded-2xl p-8 text-center" style={{ opacity: 0, animationFillMode: 'forwards' }}>
              <div className="mb-6" style={{ color: '#ef4444' }}>
                <ErrorIcon />
              </div>
              
              <h2 style={{
                fontFamily: "'Playfair Display', serif",
                fontSize: 24,
                fontWeight: 700,
                color: '#ffffff',
                marginBottom: 12,
              }}>
                Sign-In Failed
              </h2>
              
              <p style={{ fontSize: 14, color: 'rgba(255,255,255,0.7)', marginBottom: 24 }}>
                {error}
              </p>

              <div className="space-y-3">
                <button
                  onClick={handleRetry}
                  className="gold-btn w-full py-3 px-6 rounded-xl border-none cursor-pointer text-sm font-semibold text-black"
                >
                  Try Again
                </button>
                
                <button
                  onClick={() => router.push('/login')}
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.2)',
                    color: '#ffffff',
                    width: '100%',
                    padding: '12px 24px',
                    borderRadius: 12,
                    fontSize: 14,
                    cursor: 'pointer',
                  }}
                >
                  Use Password Instead
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </>
  );
}