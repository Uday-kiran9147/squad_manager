import Navbar from '@/app/components/Navbar';
import Footer from '@/app/components/Footer';

function FeatureCard({ icon, title, description, accentColor = 'var(--accent)' }: { icon: any, title: string, description: string, accentColor?: string }) {
  return (
    <div style={{
      padding: '40px',
      background: 'var(--surface)',
      borderRadius: '24px',
      transition: 'transform 0.3s, box-shadow 0.3s',
      border: '1px solid rgba(255, 255, 255, 0.05)',
      position: 'relative',
      overflow: 'hidden'
    }} className="feature-card-hover">
      <div style={{
        backgroundColor: `${accentColor}1A`,
        padding: '16px',
        borderRadius: '16px',
        width: 'fit-content',
        marginBottom: '24px',
        color: accentColor
      }}>
        {icon}
      </div>
      <h3 style={{ fontSize: '20px', fontWeight: 800, color: 'white', marginBottom: '16px', fontFamily: 'Sora' }}>{title}</h3>
      <p style={{ color: 'var(--text-secondary)', fontSize: '15px', lineHeight: 1.8 }}>{description}</p>
      
      <div style={{
        position: 'absolute',
        bottom: '-10px',
        right: '-10px',
        width: '100px',
        height: '100px',
        background: `radial-gradient(circle, ${accentColor}1A 0%, transparent 70%)`
      }} />
    </div>
  );
}

export default function Home() {
  return (
    <main style={{ minHeight: '100vh', background: 'var(--background)' }}>
      <Navbar />

      {/* Hero Section */}
      <section style={{
        paddingTop: '200px',
        paddingBottom: '120px',
        position: 'relative',
        overflow: 'hidden'
      }}>
        {/* Background Decorative Elements */}
        <div style={{
          position: 'absolute',
          top: '-20%',
          right: '-10%',
          width: '600px',
          height: '600px',
          background: 'radial-gradient(circle, rgba(233, 69, 96, 0.1) 0%, transparent 70%)',
          zIndex: 0
        }} />
        <div style={{
          position: 'absolute',
          bottom: '-20%',
          left: '-10%',
          width: '400px',
          height: '400px',
          background: 'radial-gradient(circle, rgba(0, 184, 148, 0.05) 0%, transparent 70%)',
          zIndex: 0
        }} />

        <div className="container" style={{ position: 'relative', zIndex: 1, textAlign: 'center' }}>
          <div style={{
            display: 'inline-block',
            padding: '8px 20px',
            background: 'rgba(233, 69, 96, 0.1)',
            borderRadius: '100px',
            color: 'var(--accent)',
            fontSize: '14px',
            fontWeight: 800,
            marginBottom: '32px',
            border: '1px solid rgba(233, 69, 96, 0.3)',
            fontFamily: 'Sora'
          }}>
            🇮🇳 THE #1 SOCIAL PLANNER FOR INDIA
          </div>
          
          <h1 style={{
            fontSize: 'max(48px, 6vw)',
            fontWeight: 800,
            color: 'white',
            lineHeight: 1.1,
            letterSpacing: '-3px',
            marginBottom: '32px',
            fontFamily: 'Sora'
          }}>
            From "Kaha Jaaye?" <br />
            To <span style={{ color: 'var(--accent)' }}>"It's Happening!"</span>
          </h1>

          <p style={{
            maxWidth: '700px',
            margin: '0 auto 48px',
            color: 'var(--text-secondary)',
            fontSize: '20px',
            lineHeight: 1.6
          }}>
            Squad handles the chaos of group planning. Poll on dates, lock in venues, and split bills — all in one social, beautiful app.
          </p>

          <div style={{ display: 'flex', gap: '16px', justifyContent: 'center', alignItems: 'center', marginBottom: '80px', flexWrap: 'wrap' }}>
            <a 
              href="https://play.google.com/store/apps/details?id=com.squad.app.squad" 
              target="_blank" 
              rel="noopener noreferrer" 
              className="btn-primary" 
              style={{ 
                padding: '10px 28px', 
                display: 'inline-flex',
                alignItems: 'center',
                gap: '12px',
                textAlign: 'left',
                textDecoration: 'none',
                height: '56px'
              }}
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" viewBox="0 0 16 16">
                <path d="M14.222 9.374c1.037-.61 1.037-2.137 0-2.748L11.528 5.04 8.32 8l3.207 2.96zm-3.595 2.116L7.583 8.68 1.03 14.73c.201 1.029 1.36 1.61 2.303 1.055zM1 13.396V2.603L6.846 8zM1.03 1.27l6.553 6.05 3.044-2.81L3.333.215C2.39-.341 1.231.24 1.03 1.27"/>
              </svg>
              <div style={{ display: 'flex', flexDirection: 'column' }}>
                <span style={{ fontSize: '9px', opacity: 0.8, fontWeight: 500, textTransform: 'uppercase', letterSpacing: '0.8px', lineHeight: 1.1 }}>Get it on</span>
                <span style={{ fontSize: '16px', fontWeight: 700, fontFamily: 'Sora', lineHeight: 1.1 }}>Google Play</span>
              </div>
            </a>
            <button className="btn-outline" style={{ padding: '0 36px', fontSize: '16px', height: '56px', display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}>Watch Demo</button>
          </div>

          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))',
            gap: '40px',
            marginTop: '80px'
          }}>
            <div className="glass" style={{ padding: '32px', borderRadius: '32px', textAlign: 'left' }}>
              <h4 style={{ color: 'white', marginBottom: '8px', fontSize: '14px' }}>CURRENT STATUS</h4>
              <p style={{ fontSize: '24px', fontWeight: 800 }}>98% Conversion</p>
              <p style={{ color: 'var(--text-secondary)', fontSize: '14px' }}>Draft plans → Confirmed reality</p>
            </div>
            <div className="glass" style={{ padding: '32px', borderRadius: '32px', textAlign: 'left' }}>
              <h4 style={{ color: 'white', marginBottom: '8px', fontSize: '14px' }}>SETTLEMENTS</h4>
              <p style={{ fontSize: '24px', fontWeight: 800 }}>₹4.2M Solved</p>
              <p style={{ color: 'var(--text-secondary)', fontSize: '14px' }}>Via seamless UPI deep-linking</p>
            </div>
            <div className="glass" style={{ padding: '32px', borderRadius: '32px', textAlign: 'left' }}>
              <h4 style={{ color: 'white', marginBottom: '8px', fontSize: '14px' }}>WEB FALLBACK</h4>
              <p style={{ fontSize: '24px', fontWeight: 800 }}>Zero Friction</p>
              <p style={{ color: 'var(--text-secondary)', fontSize: '14px' }}>Non-app friends vote effortlessly</p>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" style={{ padding: '120px 0', background: 'var(--primary)' }}>
        <div className="container">
          <div style={{ textAlign: 'center', marginBottom: '80px' }}>
            <h2 style={{ fontSize: '40px', fontWeight: 800, color: 'white', marginBottom: '16px', fontFamily: 'Sora' }}>
              Built for your <span style={{ color: 'var(--accent)' }}>Inner Circle</span>
            </h2>
            <p style={{ color: 'var(--text-secondary)', maxWidth: '600px', margin: '0 auto', fontSize: '18px' }}>
              No more infinite WhatsApp scrolls. SQUAD is the dedicated home for your friendship.
            </p>
          </div>

          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(350px, 1fr))',
            gap: '32px'
          }}>
            <FeatureCard
              title="Availability Polls"
              description="Organisers set 3-5 date options. Invitees vote in one tap. No app install required for invitees."
              icon={<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M12 20V10M18 20V4M6 20v-4"/></svg>}
            />
            <FeatureCard
              title="Native UPI Splits"
              description="Add expenses, split by shares, and pay back via seamlessly generated UPI deep links to GPay or PhonePe."
              accentColor="var(--success)"
              icon={<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><rect width="20" height="14" x="2" y="5" rx="2"/><line x1="2" x2="22" y1="10" y2="10"/></svg>}
            />
            <FeatureCard
              title="The 'Memory Feed'"
              description="Wait 48h after a plan completes to see the photo dump. Relive the outing where the planning happened."
              accentColor="#FDCB6E"
              icon={<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><rect width="18" height="18" x="3" y="3" rx="2" ry="2"/><circle cx="9" cy="9" r="2"/><path d="m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21"/></svg>}
            />
          </div>
        </div>
      </section>

      {/* Zero Friction Section */}
      <section style={{ padding: '120px 0', position: 'relative' }}>
         <div className="container" style={{
           display: 'flex',
           flexWrap: 'wrap',
           alignItems: 'center',
           gap: '80px'
         }}>
           <div style={{ flex: '1 1 500px' }}>
             <h2 style={{ fontSize: '40px', fontWeight: 800, color: 'white', marginBottom: '24px', lineHeight: 1.2, fontFamily: 'Sora' }}>
               Your friends shouldn't <br />
               <span style={{ color: 'var(--accent)' }}>have to install</span> another app.
             </h2>
             <p style={{ color: 'var(--text-secondary)', fontSize: '18px', marginBottom: '32px', lineHeight: 1.8 }}>
               Non-installers see a beautiful web dashboard where they can vote and RSVP instantly. Low friction is the key to getting a 100% headcount.
             </p>
             <button className="btn-outline">Learn more about Web Fallback</button>
           </div>
           <div style={{ flex: '1 1 400px', padding: '40px', background: 'var(--surface)', borderRadius: '32px', border: '1px solid var(--divider)', boxShadow: '0 20px 40px rgba(0,0,0,0.3)' }}>
              <div style={{ color: 'white', marginBottom: '24px', display: 'flex', alignItems: 'center', gap: '12px' }}>
                 <div style={{ width: '40px', height: '40px', background: '#25D366', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="white"><path d="M12.012 2c-5.506 0-9.989 4.478-9.99 9.984a9.964 9.964 0 0 0 1.333 4.993L2 22l5.233-1.237a9.994 9.994 0 0 0 4.779 1.224h.005c5.505 0 9.988-4.478 9.989-9.984 0-2.669-1.037-5.176-2.922-7.062A9.935 9.935 0 0 0 12.012 2z"/></svg>
                 </div>
                 <p style={{ fontWeight: 800, fontSize: '14px' }}>WhatsApp Preview</p>
              </div>
              <div style={{ background: 'rgba(255,255,255,0.02)', padding: '24px', borderRadius: '16px', color: 'var(--text-secondary)', fontSize: '14px' }}>
                 <p style={{ marginBottom: '16px' }}>Hey! Let's plan <strong>Dinner @ Soho</strong> 🎉</p>
                 <p style={{ marginBottom: '16px' }}>Vote for your preferred date here 👇</p>
                 <p style={{ color: 'var(--accent)', fontWeight: 700 }}>squad.app/invite/soho-123</p>
                 <p style={{ marginTop: '16px' }}>(Tap the link to vote — no app needed!)</p>
              </div>
           </div>
         </div>
      </section>

      {/* Pricing Section */}
      {/* <section id="pricing" style={{ padding: '120px 0', background: 'var(--primary)' }}>
        <div className="container" style={{ textAlign: 'center' }}>
          <h2 style={{ fontSize: '40px', fontWeight: 800, color: 'white', marginBottom: '80px', fontFamily: 'Sora' }}>Simple, <span style={{ color: 'var(--accent)' }}>One-time</span> Pricing</h2>
          <div style={{
            display: 'flex',
            flexWrap: 'wrap',
            justifyContent: 'center',
            gap: '32px'
          }}>
            <div style={{
              padding: '48px',
              background: 'var(--surface)',
              borderRadius: '32px',
              width: '100%',
              maxWidth: '380px',
              textAlign: 'left',
              border: '1px solid var(--divider)'
            }}>
              <h3 style={{ color: 'white', fontSize: '24px', marginBottom: '16px' }}>Squad Free</h3>
              <p style={{ fontSize: '48px', fontWeight: 800, color: 'var(--accent)', marginBottom: '32px' }}>₹0</p>
              <ul style={{ listStyle: 'none', color: 'var(--text-secondary)', lineHeight: 2.5, marginBottom: '40px' }}>
                <li>✓ 3 Active Plans</li>
                <li>✓ Basic Bill Split</li>
                <li>✓ Web Fallback Access</li>
                <li>✓ 8 Members/Plan</li>
              </ul>
              <button className="btn-outline" style={{ width: '100%' }}>Get Started</button>
            </div>
            
            <div style={{
              padding: '48px',
              background: 'linear-gradient(145deg, var(--surface) 0%, rgba(233, 69, 96, 0.1) 100%)',
              borderRadius: '32px',
              width: '100%',
              maxWidth: '380px',
              textAlign: 'left',
              border: '2px solid var(--accent)',
              position: 'relative'
            }}>
              <div style={{
                position: 'absolute',
                top: '24px',
                right: '24px',
                padding: '4px 12px',
                background: 'var(--accent)',
                borderRadius: '100px',
                fontSize: '10px',
                fontWeight: 800,
                color: 'white'
              }}>POPULAR</div>
              <h3 style={{ color: 'white', fontSize: '24px', marginBottom: '16px' }}>Squad Pro</h3>
              <p style={{ fontSize: '48px', fontWeight: 800, color: 'var(--accent)', marginBottom: '32px' }}>₹299</p>
              <ul style={{ listStyle: 'none', color: 'var(--text-secondary)', lineHeight: 2.5, marginBottom: '40px' }}>
                <li>✓ Unlimited Plans</li>
                <li>✓ Custom Shares Bill Split</li>
                <li>✓ Exclusive Memory Feed</li>
                <li>✓ Pro Plan Templates</li>
                <li>✓ 20 Members/Plan</li>
              </ul>
              <button className="btn-primary" style={{ width: '100%' }}>Upgrade to Pro</button>
            </div>
          </div>
        </div>
      </section> */}

      <Footer />
    </main>
  );
}
