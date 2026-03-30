"use client";
import Link from 'next/link';

export default function Navbar() {
  return (
    <nav style={{
      position: 'fixed',
      top: 0,
      width: '100%',
      zIndex: 1000,
      padding: '24px 0',
      background: 'rgba(15, 52, 96, 0.8)',
      backdropFilter: 'blur(10px)',
      borderBottom: '1px solid rgba(255, 255, 255, 0.05)'
    }}>
      <div className="container" style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center'
      }}>
        <Link href="/" style={{
          fontSize: '24px',
          fontWeight: 800,
          color: 'var(--text-primary)',
          letterSpacing: '-1px',
          fontFamily: 'Sora'
        }}>
          SQUAD<span style={{color: 'var(--accent)'}}>.</span>
        </Link>
        <div style={{ display: 'flex', gap: '32px', alignItems: 'center' }}>
          <Link href="#features" style={{ color: 'var(--text-secondary)', fontWeight: 500 }}>Features</Link>
          <Link href="#pricing" style={{ color: 'var(--text-secondary)', fontWeight: 500 }}>Pricing</Link>
          <Link href="/terms" style={{ color: 'var(--text-secondary)', fontWeight: 500 }}>Terms</Link>
          <button className="btn-primary" style={{ padding: '10px 20px', fontSize: '14px' }}>
            Download App
          </button>
        </div>
      </div>
    </nav>
  );
}
