import Link from 'next/link';

export default function Footer() {
  return (
    <footer style={{
      padding: '80px 0 40px',
      background: 'var(--primary)',
      borderTop: '1px solid var(--divider)',
      color: 'var(--text-secondary)'
    }}>
      <div className="container">
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
          gap: '64px',
          marginBottom: '64px'
        }}>
          <div>
            <h3 style={{ color: 'white', marginBottom: '24px', fontWeight: 800 }}>SQUAD.</h3>
            <p style={{ fontSize: '14px', lineHeight: 1.8 }}>The only tool you need to get your squad from "kaha jaaye?" to "it's happening!". Built for India's college and early career friend groups.</p>
          </div>
          <div>
            <h4 style={{ color: 'white', marginBottom: '16px', fontSize: '16px' }}>Product</h4>
            <ul style={{ listStyle: 'none', lineHeight: 2.2, fontSize: '14px' }}>
              <li><Link href="#features">Features</Link></li>
              <li><Link href="#pricing">Pricing</Link></li>
              <li><Link href="/terms">Terms & Conditions</Link></li>
              <li><Link href="/privacy">Privacy Policy</Link></li>
            </ul>
          </div>
          <div>
            <h4 style={{ color: 'white', marginBottom: '16px', fontSize: '16px' }}>Company</h4>
            <ul style={{ listStyle: 'none', lineHeight: 2.2, fontSize: '14px' }}>
              <li><Link href="/">About Us</Link></li>
              <li><Link href="/">Twitter</Link></li>
              <li><Link href="/">Instagram</Link></li>
              <li><Link href="/">LinkedIn</Link></li>
            </ul>
          </div>
          <div>
            <h4 style={{ color: 'white', marginBottom: '16px', fontSize: '16px' }}>Legal</h4>
            <ul style={{ listStyle: 'none', lineHeight: 2.2, fontSize: '14px' }}>
              <li><Link href="/terms">Terms of Service</Link></li>
              <li><Link href="/terms#privacy">Privacy</Link></li>
              <li><Link href="/terms#refund">Refund Policy</Link></li>
            </ul>
          </div>
        </div>
        <div style={{
          paddingTop: '32px',
          borderTop: '1px solid var(--divider)',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          fontSize: '12px'
        }}>
          <p>© 2026 Squad Mobile App India. All rights reserved.</p>
          <div style={{ display: 'flex', gap: '24px' }}>
            <p>Made in Hyderabad 🇮🇳</p>
          </div>
        </div>
      </div>
    </footer>
  );
}
