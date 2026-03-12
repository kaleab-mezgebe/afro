'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { getAuth, signInWithEmailAndPassword } from 'firebase/auth';
import { app } from '@/lib/firebase';
import toast from 'react-hot-toast';

/* ─────────────────────────────────────────────────
   Tiny SVG icon helpers (no extra deps needed)
───────────────────────────────────────────────── */
const ScissorsIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"
    strokeLinecap="round" strokeLinejoin="round" className="w-full h-full">
    <circle cx="6" cy="6" r="3" /><circle cx="6" cy="18" r="3" />
    <line x1="20" y1="4" x2="8.12" y2="15.88" />
    <line x1="14.47" y1="14.48" x2="20" y2="20" />
    <line x1="8.12" y1="8.12" x2="12" y2="12" />
  </svg>
);

const EyeIcon = ({ open }: { open: boolean }) => open ? (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"
    strokeLinecap="round" strokeLinejoin="round" className="w-5 h-5">
    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
    <circle cx="12" cy="12" r="3" />
  </svg>
) : (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"
    strokeLinecap="round" strokeLinejoin="round" className="w-5 h-5">
    <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94" />
    <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19" />
    <line x1="1" y1="1" x2="23" y2="23" />
  </svg>
);

/* ─────────────────────────────────────────────────
   Floating decorative particle
───────────────────────────────────────────────── */
type Particle = { id: number; x: number; y: number; size: number; delay: number; duration: number };

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [focusedField, setFocusedField] = useState<'email' | 'password' | null>(null);
  const [mounted, setMounted] = useState(false);
  const [particles, setParticles] = useState<Particle[]>([]);
  const router = useRouter();

  useEffect(() => {
    setMounted(true);
    // Generate particles only on client
    setParticles(
      Array.from({ length: 20 }, (_, i) => ({
        id: i,
        x: Math.random() * 100,
        y: Math.random() * 100,
        size: Math.random() * 3 + 1,
        delay: Math.random() * 5,
        duration: Math.random() * 10 + 8,
      }))
    );
  }, []);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      toast.error('Please enter both email and password');
      return;
    }
    setLoading(true);
    try {
      // Development bypass for mock data
      if (process.env.NODE_ENV === 'development' && email === 'admin@test.com' && password === 'admin123') {
        localStorage.setItem('authToken', 'dev-bypass-token');
        toast.success('Welcome back, Admin! (Development Mode)');
        router.push('/dashboard');
        return;
      }

      const auth = getAuth(app);
      const result = await signInWithEmailAndPassword(auth, email, password);

      // Get Firebase ID token and store it for API requests
      const token = await result.user.getIdToken();
      localStorage.setItem('authToken', token);

      toast.success('Welcome back, Admin!');
      router.push('/dashboard');
    } catch (error: any) {
      const msg =
        error.code === 'auth/invalid-credential' || error.code === 'auth/wrong-password'
          ? 'Invalid email or password'
          : error.code === 'auth/user-not-found'
            ? 'Admin account not found'
            : error.code === 'auth/too-many-requests'
              ? 'Too many attempts. Try again later.'
              : 'Login failed. Please try again.';
      toast.error(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      {/* ── Google Fonts ── */}
      <style dangerouslySetInnerHTML={{
        __html: mounted ? `
        @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700&family=Inter:wght@300;400;500;600&display=swap');

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body { font-family: 'Inter', sans-serif; }

        @keyframes float {
          0%, 100% { transform: translateY(0px) rotate(0deg); opacity: 0.4; }
          50%       { transform: translateY(-30px) rotate(180deg); opacity: 0.8; }
        }
        @keyframes shimmer {
          0%   { background-position: -200% center; }
          100% { background-position: 200% center; }
        }
        @keyframes pulse-ring {
          0%   { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(245,158,11,0.4); }
          70%  { transform: scale(1);    box-shadow: 0 0 0 15px rgba(245,158,11,0); }
          100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(245,158,11,0); }
        }
        @keyframes slide-up {
          from { opacity: 0; transform: translateY(30px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes slide-right {
          from { opacity: 0; transform: translateX(-30px); }
          to   { opacity: 1; transform: translateX(0); }
        }
        @keyframes spin-slow {
          from { transform: rotate(0deg); }
          to   { transform: rotate(360deg); }
        }
        @keyframes gradient-shift {
          0%   { background-position: 0% 50%; }
          50%  { background-position: 100% 50%; }
          100% { background-position: 0% 50%; }
        }
        @keyframes scissors-snip {
          0%, 90%, 100% { transform: rotate(0deg); }
          95%            { transform: rotate(-20deg); }
        }
        @keyframes bar-grow {
          from { transform: scaleX(0); }
          to   { transform: scaleX(1); }
        }

        .animate-float    { animation: float var(--dur, 10s) var(--delay, 0s) ease-in-out infinite; }
        .animate-slide-up { animation: slide-up 0.7s ease forwards; }
        .animate-slide-right { animation: slide-right 0.7s ease forwards; }
        .animate-spin-slow { animation: spin-slow 20s linear infinite; }
        .animate-scissors { animation: scissors-snip 3s ease-in-out infinite; }

        .gold-shimmer {
          background: linear-gradient(90deg,
            transparent 0%, rgba(245,158,11,0.6) 40%,
            rgba(251,191,36,0.8) 50%, rgba(245,158,11,0.6) 60%, transparent 100%);
          background-size: 200% auto;
          animation: shimmer 3s linear infinite;
          -webkit-background-clip: text;
          background-clip: text;
          -webkit-text-fill-color: transparent;
        }

        .gradient-bg {
          background: linear-gradient(135deg, #FEF3C7 0%, #FED7AA 30%, #FFEDD5 60%, #FEE2E2 100%);
          background-size: 400% 400%;
          animation: gradient-shift 15s ease infinite;
        }

        .glass-card {
          background: rgba(255, 255, 255, 0.85);
          backdrop-filter: blur(20px);
          -webkit-backdrop-filter: blur(20px);
          border: 1px solid rgba(245, 158, 11, 0.3);
          box-shadow:
            0 25px 50px rgba(245,158,11,0.15),
            0 0 0 1px rgba(255,255,255,0.5),
            inset 0 1px 0 rgba(255,255,255,0.9);
        }

        .input-field {
          background: rgba(255,255,255,0.9);
          border: 1.5px solid rgba(245,158,11,0.3);
          color: #1F2937;
          transition: all 0.3s ease;
          caret-color: #F59E0B;
        }
        .input-field:focus {
          outline: none;
          background: rgba(255,255,255,1);
          border-color: rgba(245,158,11,0.8);
          box-shadow: 0 0 0 3px rgba(245,158,11,0.15), 0 0 20px rgba(245,158,11,0.1);
        }
        .input-field::placeholder { color: rgba(107,114,128,0.7); }

        .gold-btn {
          background: linear-gradient(135deg, #D97706 0%, #F59E0B 40%, #FBBF24 60%, #F59E0B 100%);
          background-size: 200% 100%;
          transition: all 0.4s ease;
          box-shadow: 0 4px 20px rgba(245,158,11,0.3);
          position: relative;
          overflow: hidden;
        }
        .gold-btn::before {
          content: '';
          position: absolute;
          top: 0; left: -100%;
          width: 100%; height: 100%;
          background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
          transition: left 0.5s ease;
        }
        .gold-btn:hover::before { left: 100%; }
        .gold-btn:hover {
          background-position: right center;
          box-shadow: 0 6px 30px rgba(245,158,11,0.5);
          transform: translateY(-1px);
        }
        .gold-btn:active { transform: translateY(0); }
        .gold-btn:disabled {
          opacity: 0.6;
          transform: none;
          box-shadow: 0 4px 20px rgba(245,158,11,0.15);
        }

        .stat-card {
          background: rgba(255,255,255,0.7);
          border: 1px solid rgba(245,158,11,0.2);
          backdrop-filter: blur(10px);
          transition: all 0.3s ease;
        }
        .stat-card:hover {
          background: rgba(255,255,255,0.9);
          border-color: rgba(245,158,11,0.4);
          transform: translateY(-2px);
        }

        .divider-line {
          background: linear-gradient(90deg, transparent, rgba(245,158,11,0.4), transparent);
        }

        .scroll-bar::-webkit-scrollbar { display: none; }

        .btn-icon-spin { animation: spin-slow 4s linear infinite; }
        ` : ''
      }} />

      <div className="min-h-screen gradient-bg flex overflow-hidden relative">

        {/* ── Ambient glow orbs ── */}
        <div style={{
          position: 'absolute', top: '10%', left: '5%',
          width: 400, height: 400, borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(245,158,11,0.08) 0%, transparent 70%)',
          filter: 'blur(40px)', pointerEvents: 'none',
        }} />
        <div style={{
          position: 'absolute', bottom: '15%', right: '8%',
          width: 350, height: 350, borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(245,158,11,0.06) 0%, transparent 70%)',
          filter: 'blur(40px)', pointerEvents: 'none',
        }} />

        {/* ── Floating particles ── */}
        {mounted && particles.map(p => (
          <div key={p.id}
            className="animate-float"
            style={{
              position: 'absolute',
              left: `${p.x}%`,
              top: `${p.y}%`,
              width: p.size,
              height: p.size,
              borderRadius: '50%',
              background: 'rgba(245,158,11,0.5)',
              pointerEvents: 'none',
              '--dur': `${p.duration}s`,
              '--delay': `${p.delay}s`,
            } as React.CSSProperties}
          />
        ))}

        {/* ══════════════════════════════════
            LEFT PANEL — Branding
        ══════════════════════════════════ */}
        <div className="hidden lg:flex flex-col flex-1 relative" style={{ maxWidth: '55%' }}>

          {/* Vertical gold bar accent */}
          <div style={{
            position: 'absolute', top: 0, right: 0, width: 1, height: '100%',
            background: 'linear-gradient(180deg, transparent, rgba(245,158,11,0.4) 30%, rgba(245,158,11,0.6) 50%, rgba(245,158,11,0.4) 70%, transparent)',
          }} />

          {/* Top-left logo area */}
          <div className="p-10 animate-slide-right" style={{ animationDelay: '0.1s', opacity: 0, animationFillMode: 'forwards' }}>
            <div className="flex items-center gap-3">
              <div style={{
                width: 44, height: 44,
                background: 'linear-gradient(135deg, #F59E0B, #FBBF24)',
                borderRadius: 12,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                boxShadow: '0 4px 15px rgba(245,158,11,0.4)',
                padding: 10,
                color: '#0a0a0a',
              }}>
                <ScissorsIcon />
              </div>
              <div>
                <div style={{
                  fontFamily: "'Playfair Display', serif",
                  fontWeight: 700,
                  fontSize: 20,
                  color: '#D97706',
                  letterSpacing: '0.05em',
                  lineHeight: 1,
                }}>AFRO</div>
                <div style={{ fontSize: 10, color: 'rgba(107,114,128,0.8)', letterSpacing: '0.2em', textTransform: 'uppercase' }}>ADMIN SYSTEM</div>
              </div>
            </div>
          </div>

          {/* Central hero content */}
          <div className="flex-1 flex flex-col justify-center px-10 pb-10">

            {/* Big decorative scissors */}
            <div className="animate-slide-right" style={{ animationDelay: '0.2s', opacity: 0, animationFillMode: 'forwards', marginBottom: 32 }}>
              <div style={{
                width: 90, height: 90,
                background: 'linear-gradient(135deg, rgba(245,158,11,0.15), rgba(245,158,11,0.05))',
                borderRadius: 24,
                border: '1px solid rgba(245,158,11,0.25)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: '#F59E0B',
                padding: 22,
                marginBottom: 28,
              }}
                className="animate-scissors"
              >
                <ScissorsIcon />
              </div>
            </div>

            <div className="animate-slide-right" style={{ animationDelay: '0.3s', opacity: 0, animationFillMode: 'forwards' }}>
              <div style={{ fontFamily: "'Playfair Display', serif", fontSize: 15, color: 'rgba(217,119,6,0.8)', letterSpacing: '0.3em', textTransform: 'uppercase', marginBottom: 12 }}>
                Premium Management
              </div>
              <h1 style={{
                fontFamily: "'Playfair Display', serif",
                fontSize: 52,
                fontWeight: 700,
                lineHeight: 1.1,
                marginBottom: 20,
              }}>
                <span style={{ color: '#1F2937' }}>Salon &amp;</span><br />
                <span className="gold-shimmer">Barber</span><br />
                <span style={{ color: '#1F2937' }}>Admin Hub</span>
              </h1>
              <p style={{ color: 'rgba(107,114,128,0.8)', fontSize: 16, lineHeight: 1.7, maxWidth: 400 }}>
                Your complete command center for managing bookings, staff, analytics, and customer experiences — all in one elegant dashboard.
              </p>
            </div>

            {/* Thin gold divider */}
            <div className="animate-slide-right" style={{ animationDelay: '0.4s', opacity: 0, animationFillMode: 'forwards', margin: '32px 0' }}>
              <div className="divider-line" style={{ height: 1, width: 200, animation: 'bar-grow 1s 0.8s ease forwards', transformOrigin: 'left', transform: 'scaleX(0)' }} />
            </div>

            {/* Stats row */}
            <div className="animate-slide-right" style={{ animationDelay: '0.5s', opacity: 0, animationFillMode: 'forwards' }}>
              <div style={{ display: 'flex', gap: 16 }}>
                {[
                  { label: 'Bookings', value: '1.2K+' },
                  { label: 'Providers', value: '80+' },
                  { label: 'Reviews', value: '4.9★' },
                ].map(stat => (
                  <div key={stat.label} className="stat-card" style={{ padding: '14px 20px', borderRadius: 12, flex: 1, textAlign: 'center' }}>
                    <div style={{ fontFamily: "'Playfair Display', serif", fontSize: 22, fontWeight: 700, color: '#D97706', lineHeight: 1 }}>{stat.value}</div>
                    <div style={{ fontSize: 11, color: 'rgba(107,114,128,0.8)', marginTop: 4, letterSpacing: '0.1em', textTransform: 'uppercase' }}>{stat.label}</div>
                  </div>
                ))}
              </div>
            </div>

            {/* Feature bullets */}
            <div className="animate-slide-right" style={{ animationDelay: '0.6s', opacity: 0, animationFillMode: 'forwards', marginTop: 32 }}>
              {[
                { icon: '✦', text: 'Real-time booking & appointment management' },
                { icon: '✦', text: 'Provider & staff analytics dashboard' },
                { icon: '✦', text: 'Customer insights & loyalty tracking' },
              ].map((item, i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
                  <span style={{ color: '#D97706', fontSize: 10 }}>{item.icon}</span>
                  <span style={{ color: 'rgba(107,114,128,0.8)', fontSize: 14 }}>{item.text}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Bottom footer on left panel */}
          <div style={{ padding: '20px 40px', borderTop: '1px solid rgba(107,114,128,0.2)' }}>
            <div style={{ fontSize: 12, color: 'rgba(107,114,128,0.6)', letterSpacing: '0.05em' }}>
              © 2026 AFRO Booking Platform · All Rights Reserved
            </div>
          </div>
        </div>

        {/* ══════════════════════════════════
            RIGHT PANEL — Login Form
        ══════════════════════════════════ */}
        <div style={{
          flex: 1,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '40px 24px',
          position: 'relative',
        }}>

          {/* Mobile logo (only on small screens) */}
          <div className="lg:hidden" style={{
            position: 'absolute', top: 30, left: '50%', transform: 'translateX(-50%)',
            display: 'flex', alignItems: 'center', gap: 10,
          }}>
            <div style={{
              width: 38, height: 38,
              background: 'linear-gradient(135deg, #F59E0B, #FBBF24)',
              borderRadius: 10,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              padding: 9, color: '#0a0a0a',
            }}>
              <ScissorsIcon />
            </div>
            <span style={{ fontFamily: "'Playfair Display', serif", color: '#D97706', fontSize: 18, fontWeight: 700 }}>AFRO Admin</span>
          </div>

          {/* Form card */}
          <div
            className="glass-card animate-slide-up"
            style={{
              width: '100%',
              maxWidth: 420,
              borderRadius: 24,
              padding: '40px 36px',
              animationDelay: '0.2s',
              opacity: 0,
              animationFillMode: 'forwards',
            }}
          >
            {/* Card header */}
            <div style={{ textAlign: 'center', marginBottom: 36 }}>
              {/* Pulsing avatar ring */}
              <div style={{
                width: 70, height: 70,
                background: 'linear-gradient(135deg, rgba(245,158,11,0.2), rgba(245,158,11,0.05))',
                borderRadius: '50%',
                border: '2px solid rgba(245, 158, 11, 0.4)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                margin: '0 auto 20px',
                color: '#F59E0B',
                padding: 18,
                animation: 'pulse-ring 2.5s infinite',
              }}>
                <ScissorsIcon />
              </div>

              <h2 style={{
                fontFamily: "'Playfair Display', serif",
                fontSize: 28,
                fontWeight: 700,
                color: '#1F2937',
                marginBottom: 6,
              }}>
                Welcome Back
              </h2>
              <p style={{ fontSize: 14, color: 'rgba(107,114,128,0.8)' }}>
                Sign in to your admin dashboard
              </p>

              {/* Gold underline accent */}
              <div style={{
                width: 40, height: 2,
                background: 'linear-gradient(90deg, transparent, #F59E0B, transparent)',
                margin: '16px auto 0',
                borderRadius: 2,
              }} />
            </div>

            {/* Form */}
            <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>

              {/* Email field */}
              <div>
                <label style={{
                  display: 'block', fontSize: 12, fontWeight: 500,
                  color: focusedField === 'email' ? '#D97706' : 'rgba(107,114,128,0.8)',
                  marginBottom: 8, letterSpacing: '0.08em', textTransform: 'uppercase',
                  transition: 'color 0.3s ease',
                }}>
                  Email Address
                </label>
                <div style={{ position: 'relative' }}>
                  <input
                    id="email"
                    type="email"
                    required
                    placeholder="admin@afro.com"
                    value={email}
                    onChange={e => setEmail(e.target.value)}
                    onFocus={() => setFocusedField('email')}
                    onBlur={() => setFocusedField(null)}
                    className="input-field"
                    style={{
                      width: '100%',
                      padding: '14px 16px 14px 44px',
                      borderRadius: 12,
                      fontSize: 14,
                    }}
                  />
                  <div style={{
                    position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)',
                    color: focusedField === 'email' ? '#D97706' : 'rgba(107,114,128,0.5)',
                    transition: 'color 0.3s ease',
                    pointerEvents: 'none',
                  }}>
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
                      <polyline points="22,6 12,13 2,6" />
                    </svg>
                  </div>
                </div>
              </div>

              {/* Password field */}
              <div>
                <label style={{
                  display: 'block', fontSize: 12, fontWeight: 500,
                  color: focusedField === 'password' ? '#D97706' : 'rgba(107,114,128,0.8)',
                  marginBottom: 8, letterSpacing: '0.08em', textTransform: 'uppercase',
                  transition: 'color 0.3s ease',
                }}>
                  Password
                </label>
                <div style={{ position: 'relative' }}>
                  <input
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    required
                    placeholder="••••••••••"
                    value={password}
                    onChange={e => setPassword(e.target.value)}
                    onFocus={() => setFocusedField('password')}
                    onBlur={() => setFocusedField(null)}
                    className="input-field"
                    style={{
                      width: '100%',
                      padding: '14px 46px 14px 44px',
                      borderRadius: 12,
                      fontSize: 14,
                    }}
                  />
                  {/* Lock icon */}
                  <div style={{
                    position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)',
                    color: focusedField === 'password' ? '#D97706' : 'rgba(107,114,128,0.5)',
                    transition: 'color 0.3s ease',
                    pointerEvents: 'none',
                  }}>
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                      <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                    </svg>
                  </div>
                  {/* Eye toggle */}
                  <button
                    type="button"
                    onClick={() => setShowPassword(v => !v)}
                    title={showPassword ? 'Hide password' : 'Show password'}
                    aria-label={showPassword ? 'Hide password' : 'Show password'}
                    style={{
                      position: 'absolute', right: 14, top: '50%', transform: 'translateY(-50%)',
                      background: 'none', border: 'none', cursor: 'pointer',
                      color: 'rgba(107,114,128,0.6)',
                      padding: 2,
                      transition: 'color 0.3s ease',
                    }}
                    onMouseEnter={e => (e.currentTarget.style.color = '#D97706')}
                    onMouseLeave={e => (e.currentTarget.style.color = 'rgba(107,114,128,0.6)')}
                  >
                    <EyeIcon open={showPassword} />
                  </button>
                </div>
              </div>

              {/* Auth options */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: -8 }}>
                <button
                  type="button"
                  onClick={() => router.push('/auth/email-link')}
                  style={{
                    background: 'none', border: 'none', cursor: 'pointer',
                    fontSize: 13, color: 'rgba(217,119,6,0.8)',
                    textDecoration: 'none', transition: 'color 0.2s ease',
                  }}
                  onMouseEnter={e => (e.currentTarget.style.color = '#D97706')}
                  onMouseLeave={e => (e.currentTarget.style.color = 'rgba(217,119,6,0.8)')}
                >
                  Sign in with email link
                </button>

                <a href="#" style={{
                  fontSize: 13, color: 'rgba(217,119,6,0.8)',
                  textDecoration: 'none', transition: 'color 0.2s ease',
                }}
                  onMouseEnter={e => (e.currentTarget.style.color = '#D97706')}
                  onMouseLeave={e => (e.currentTarget.style.color = 'rgba(217,119,6,0.8)')}
                >
                  Forgot password?
                </a>
              </div>

              {/* Submit button */}
              <button
                type="submit"
                id="login-submit"
                disabled={loading}
                className="gold-btn"
                style={{
                  width: '100%',
                  padding: '15px 24px',
                  borderRadius: 12,
                  border: 'none',
                  cursor: loading ? 'not-allowed' : 'pointer',
                  fontSize: 15,
                  fontWeight: 600,
                  color: '#0a0a0a',
                  letterSpacing: '0.05em',
                  marginTop: 4,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: 10,
                }}
              >
                {loading ? (
                  <>
                    <svg className="btn-icon-spin" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
                      <line x1="12" y1="2" x2="12" y2="6" />
                      <line x1="12" y1="18" x2="12" y2="22" />
                      <line x1="4.93" y1="4.93" x2="7.76" y2="7.76" />
                      <line x1="16.24" y1="16.24" x2="19.07" y2="19.07" />
                      <line x1="2" y1="12" x2="6" y2="12" />
                      <line x1="18" y1="12" x2="22" y2="12" />
                      <line x1="4.93" y1="19.07" x2="7.76" y2="16.24" />
                      <line x1="16.24" y1="7.76" x2="19.07" y2="4.93" />
                    </svg>
                    Signing In…
                  </>
                ) : (
                  <>
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4" />
                      <polyline points="10 17 15 12 10 7" />
                      <line x1="15" y1="12" x2="3" y2="12" />
                    </svg>
                    Sign In to Dashboard
                  </>
                )}
              </button>
            </form>

            {/* Footer inside card */}
            <div style={{ marginTop: 32, borderTop: '1px solid rgba(107,114,128,0.2)', paddingTop: 24 }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, marginBottom: 12 }}>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="rgba(217,119,6,0.6)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                </svg>
                <span style={{ fontSize: 12, color: 'rgba(107,114,128,0.7)' }}>
                  Secured by Firebase Authentication
                </span>
              </div>
              <div style={{ textAlign: 'center', fontSize: 12, color: 'rgba(107,114,128,0.6)' }}>
                Authorized administrators only
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
