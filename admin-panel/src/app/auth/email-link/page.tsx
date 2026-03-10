'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { sendAdminSignInLink, isCurrentUrlSignInLink, getStoredEmailForSignIn } from '@/lib/emailAuth';
import toast from 'react-hot-toast';

/* ─────────────────────────────────────────────────
   Email Link Authentication Page
───────────────────────────────────────────────── */

const EmailIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"
    strokeLinecap="round" strokeLinejoin="round" className="w-full h-full">
    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
    <polyline points="22,6 12,13 2,6" />
  </svg>
);

const CheckIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"
    strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6">
    <polyline points="20,6 9,17 4,12" />
  </svg>
);

export default function EmailLinkAuthPage() {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [emailSent, setEmailSent] = useState(false);
  const [focusedField, setFocusedField] = useState(false);
  const [mounted, setMounted] = useState(false);
  const router = useRouter();

  useEffect(() => {
    setMounted(true);
    
    // Check if this is a sign-in link completion
    if (isCurrentUrlSignInLink()) {
      router.push('/auth/complete');
      return;
    }
    
    // Pre-fill email if stored
    const storedEmail = getStoredEmailForSignIn();
    if (storedEmail) {
      setEmail(storedEmail);
    }
  }, [router]);

  const handleSendLink = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!email) {
      toast.error('Please enter your admin email address');
      return;
    }

    setLoading(true);
    
    try {
      await sendAdminSignInLink(email);
      setEmailSent(true);
      toast.success('Sign-in link sent! Check your email.');
    } catch (error: any) {
      toast.error(error.message || 'Failed to send sign-in link');
    } finally {
      setLoading(false);
    }
  };

  const handleResendLink = async () => {
    setEmailSent(false);
    await handleSendLink({ preventDefault: () => {} } as React.FormEvent);
  };

  if (!mounted) return null;

  return (
    <>
      {/* Styles */}
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700&family=Inter:wght@300;400;500;600&display=swap');

        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; }

        @keyframes float {
          0%, 100% { transform: translateY(0px); opacity: 0.4; }
          50%       { transform: translateY(-20px); opacity: 0.8; }
        }
        @keyframes pulse-ring {
          0%   { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(212,175,55,0.4); }
          70%  { transform: scale(1);    box-shadow: 0 0 0 15px rgba(212,175,55,0); }
          100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(212,175,55,0); }
        }
        @keyframes slide-up {
          from { opacity: 0; transform: translateY(30px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes gradient-shift {
          0%   { background-position: 0% 50%; }
          50%  { background-position: 100% 50%; }
          100% { background-position: 0% 50%; }
        }
        @keyframes spin {
          from { transform: rotate(0deg); }
          to   { transform: rotate(360deg); }
        }

        .animate-float { animation: float 3s ease-in-out infinite; }
        .animate-slide-up { animation: slide-up 0.7s ease forwards; }
        .animate-spin { animation: spin 1s linear infinite; }

        .gradient-bg {
          background: linear-gradient(135deg, #0a0a0a 0%, #1a1208 30%, #0d0d0d 60%, #120c04 100%);
          background-size: 400% 400%;
          animation: gradient-shift 15s ease infinite;
        }

        .glass-card {
          background: rgba(255, 255, 255, 0.03);
          backdrop-filter: blur(20px);
          -webkit-backdrop-filter: blur(20px);
          border: 1px solid rgba(212, 175, 55, 0.15);
          box-shadow: 0 25px 50px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,255,255,0.03);
        }

        .input-field {
          background: rgba(255,255,255,0.04);
          border: 1.5px solid rgba(212,175,55,0.2);
          color: #fff;
          transition: all 0.3s ease;
          caret-color: #d4af37;
        }
        .input-field:focus {
          outline: none;
          background: rgba(212,175,55,0.06);
          border-color: rgba(212,175,55,0.7);
          box-shadow: 0 0 0 3px rgba(212,175,55,0.1);
        }
        .input-field::placeholder { color: rgba(255,255,255,0.25); }

        .gold-btn {
          background: linear-gradient(135deg, #c9a227 0%, #e8c84a 40%, #d4af37 60%, #b8942a 100%);
          transition: all 0.4s ease;
          box-shadow: 0 4px 20px rgba(212,175,55,0.3);
        }
        .gold-btn:hover {
          box-shadow: 0 6px 30px rgba(212,175,55,0.5);
          transform: translateY(-1px);
        }
        .gold-btn:disabled {
          opacity: 0.6;
          transform: none;
        }

        .success-card {
          background: rgba(34, 197, 94, 0.1);
          border: 1px solid rgba(34, 197, 94, 0.3);
        }
      `}</style>

      <div className="min-h-screen gradient-bg flex items-center justify-center p-6 relative overflow-hidden">
        
        {/* Background elements */}
        <div style={{
          position: 'absolute', top: '20%', left: '10%',
          width: 300, height: 300, borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(212,175,55,0.08) 0%, transparent 70%)',
          filter: 'blur(40px)', pointerEvents: 'none',
        }} />
        
        <div style={{
          position: 'absolute', bottom: '20%', right: '10%',
          width: 250, height: 250, borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(212,175,55,0.06) 0%, transparent 70%)',
          filter: 'blur(40px)', pointerEvents: 'none',
        }} />

        {/* Floating particles */}
        {[...Array(8)].map((_, i) => (
          <div key={i}
            className="animate-float"
            style={{
              position: 'absolute',
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              width: Math.random() * 4 + 2,
              height: Math.random() * 4 + 2,
              borderRadius: '50%',
              background: 'rgba(212,175,55,0.4)',
              pointerEvents: 'none',
              animationDelay: `${Math.random() * 3}s`,
            }}
          />
        ))}

        {/* Main content */}
        <div className="w-full max-w-md">
          
          {!emailSent ? (
            /* Email input form */
            <div className="glass-card animate-slide-up rounded-2xl p-8" style={{ opacity: 0, animationFillMode: 'forwards' }}>
              
              {/* Header */}
              <div className="text-center mb-8">
                <div style={{
                  width: 80, height: 80,
                  background: 'linear-gradient(135deg, rgba(212,175,55,0.2), rgba(212,175,55,0.05))',
                  borderRadius: '50%',
                  border: '2px solid rgba(212, 175, 55, 0.4)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  margin: '0 auto 24px',
                  color: '#d4af37',
                  padding: 20,
                  animation: 'pulse-ring 2.5s infinite',
                }}>
                  <EmailIcon />
                </div>

                <h1 style={{
                  fontFamily: "'Playfair Display', serif",
                  fontSize: 32,
                  fontWeight: 700,
                  color: '#ffffff',
                  marginBottom: 8,
                }}>
                  Admin Sign In
                </h1>
                
                <p style={{ 
                  fontSize: 16, 
                  color: 'rgba(255,255,255,0.6)',
                  lineHeight: 1.5 
                }}>
                  Enter your admin email to receive a secure sign-in link
                </p>

                <div style={{
                  width: 50, height: 2,
                  background: 'linear-gradient(90deg, transparent, #d4af37, transparent)',
                  margin: '20px auto 0',
                  borderRadius: 2,
                }} />
              </div>

              {/* Form */}
              <form onSubmit={handleSendLink} className="space-y-6">
                <div>
                  <label style={{
                    display: 'block', 
                    fontSize: 13, 
                    fontWeight: 500,
                    color: focusedField ? '#d4af37' : 'rgba(255,255,255,0.5)',
                    marginBottom: 8, 
                    letterSpacing: '0.08em', 
                    textTransform: 'uppercase',
                    transition: 'color 0.3s ease',
                  }}>
                    Admin Email Address
                  </label>
                  
                  <div className="relative">
                    <input
                      type="email"
                      required
                      placeholder="admin@afro.com"
                      value={email}
                      onChange={e => setEmail(e.target.value)}
                      onFocus={() => setFocusedField(true)}
                      onBlur={() => setFocusedField(false)}
                      className="input-field w-full px-4 py-4 pl-12 rounded-xl text-sm"
                    />
                    
                    <div style={{
                      position: 'absolute', 
                      left: 16, 
                      top: '50%', 
                      transform: 'translateY(-50%)',
                      color: focusedField ? '#d4af37' : 'rgba(255,255,255,0.25)',
                      transition: 'color 0.3s ease',
                      pointerEvents: 'none',
                      width: 18,
                      height: 18,
                    }}>
                      <EmailIcon />
                    </div>
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  className="gold-btn w-full py-4 px-6 rounded-xl border-none cursor-pointer text-sm font-semibold text-black flex items-center justify-center gap-3"
                >
                  {loading ? (
                    <>
                      <div className="animate-spin w-5 h-5 border-2 border-black border-t-transparent rounded-full" />
                      Sending Link...
                    </>
                  ) : (
                    <>
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M22 2L11 13" />
                        <polygon points="22,2 15,22 11,13 2,9" />
                      </svg>
                      Send Sign-In Link
                    </>
                  )}
                </button>
              </form>

              {/* Footer */}
              <div className="mt-8 pt-6 border-t border-white/10 text-center">
                <p style={{ fontSize: 12, color: 'rgba(255,255,255,0.3)' }}>
                  Secure passwordless authentication powered by Firebase
                </p>
                
                <button
                  onClick={() => router.push('/login')}
                  style={{
                    background: 'none',
                    border: 'none',
                    color: 'rgba(212,175,55,0.7)',
                    fontSize: 13,
                    marginTop: 12,
                    cursor: 'pointer',
                    textDecoration: 'underline',
                  }}
                  onMouseEnter={e => (e.currentTarget.style.color = '#d4af37')}
                  onMouseLeave={e => (e.currentTarget.style.color = 'rgba(212,175,55,0.7)')}
                >
                  Use password instead
                </button>
              </div>
            </div>
          ) : (
            /* Success message */
            <div className="success-card animate-slide-up rounded-2xl p-8" style={{ opacity: 0, animationFillMode: 'forwards' }}>
              
              <div className="text-center">
                <div style={{
                  width: 80, height: 80,
                  background: 'rgba(34, 197, 94, 0.2)',
                  borderRadius: '50%',
                  border: '2px solid rgba(34, 197, 94, 0.4)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  margin: '0 auto 24px',
                  color: '#22c55e',
                }}>
                  <CheckIcon />
                </div>

                <h2 style={{
                  fontFamily: "'Playfair Display', serif",
                  fontSize: 28,
                  fontWeight: 700,
                  color: '#ffffff',
                  marginBottom: 12,
                }}>
                  Check Your Email
                </h2>
                
                <p style={{ 
                  fontSize: 16, 
                  color: 'rgba(255,255,255,0.7)',
                  lineHeight: 1.6,
                  marginBottom: 8,
                }}>
                  We've sent a secure sign-in link to:
                </p>
                
                <p style={{
                  fontSize: 16,
                  color: '#d4af37',
                  fontWeight: 600,
                  marginBottom: 24,
                }}>
                  {email}
                </p>

                <div style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.1)',
                  borderRadius: 12,
                  padding: 16,
                  marginBottom: 24,
                }}>
                  <p style={{ 
                    fontSize: 14, 
                    color: 'rgba(255,255,255,0.6)',
                    lineHeight: 1.5,
                  }}>
                    Click the link in your email to sign in securely. The link will expire in 24 hours.
                  </p>
                </div>

                <div className="space-y-3">
                  <button
                    onClick={handleResendLink}
                    disabled={loading}
                    className="gold-btn w-full py-3 px-6 rounded-xl border-none cursor-pointer text-sm font-semibold text-black"
                  >
                    {loading ? 'Sending...' : 'Resend Link'}
                  </button>
                  
                  <button
                    onClick={() => setEmailSent(false)}
                    style={{
                      background: 'rgba(255,255,255,0.05)',
                      border: '1px solid rgba(255,255,255,0.2)',
                      color: '#ffffff',
                      width: '100%',
                      padding: '12px 24px',
                      borderRadius: 12,
                      fontSize: 14,
                      cursor: 'pointer',
                      transition: 'all 0.3s ease',
                    }}
                    onMouseEnter={e => {
                      e.currentTarget.style.background = 'rgba(255,255,255,0.1)';
                      e.currentTarget.style.borderColor = 'rgba(255,255,255,0.3)';
                    }}
                    onMouseLeave={e => {
                      e.currentTarget.style.background = 'rgba(255,255,255,0.05)';
                      e.currentTarget.style.borderColor = 'rgba(255,255,255,0.2)';
                    }}
                  >
                    Use Different Email
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </>
  );
}