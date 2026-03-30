import Navbar from '@/app/components/Navbar';
import Footer from '@/app/components/Footer';

export default function Terms() {
  return (
    <main style={{ background: 'var(--background)' }}>
      <Navbar />
      <div style={{ paddingTop: '160px', paddingBottom: '120px' }}>
        <div className="container" style={{ maxWidth: '800px' }}>
          <h1 style={{ fontSize: '48px', fontWeight: 800, marginBottom: '24px', letterSpacing: '-1.5px', color: 'white' }}>
            Terms & <span style={{ color: 'var(--accent)' }}>Conditions</span>
          </h1>
          <p style={{ color: 'var(--text-secondary)', marginBottom: '80px', fontSize: '18px' }}>
            Last updated March 2026. Please read these terms carefully before using SQUAD.
          </p>

          <section style={{ marginBottom: '60px' }}>
            <h2 style={{ fontSize: '24px', fontWeight: 700, marginBottom: '24px', color: 'white' }}>
              1. Our Agreement
            </h2>
            <p style={{ marginBottom: '16px', color: 'var(--text-secondary)' }}>
              By downloading or using the SQUAD app, these terms will automatically apply to you – you should make sure therefore that you read them carefully before using the app. You’re not allowed to copy, or modify the app, any part of the app, or our trademarks in any way.
            </p>
          </section>

          <section style={{ marginBottom: '60px' }}>
            <h2 style={{ fontSize: '24px', fontWeight: 700, marginBottom: '24px', color: 'white' }}>
              2. User Onboarding (OTP)
            </h2>
            <p style={{ marginBottom: '16px', color: 'var(--text-secondary)' }}>
              SQUAD uses Phone Number OTP (One Time Password) through Firebase Authentication to ensure identity. You are responsible for maintaining the privacy of your mobile number and the OTPs sent to you. We are not liable for unauthorized access resulting from your failure to protect your sensitive info.
            </p>
          </section>

          <section style={{ marginBottom: '60px' }}>
            <h2 style={{ fontSize: '24px', fontWeight: 700, marginBottom: '24px', color: 'white' }}>
              3. Bill Splitting & UPI
            </h2>
            <p style={{ marginBottom: '16px', color: 'var(--text-secondary)' }}>
              The bill splitting feature provided in the SQUAD app is for informational purposes. While we help calculate who owes what, all payments are conducted outside the SQUAD app using third-party UPI applications (GPay, PhonePe, Paytm, etc.). 
            </p>
            <p style={{ color: 'var(--text-secondary)', padding: '20px', background: 'rgba(233, 69, 96, 0.05)', borderRadius: '12px', borderLeft: '4px solid var(--accent)' }}>
              <strong>Disclaimer:</strong> SQUAD is not a payment gateway. We do not store or process your bank credentials. Any transaction disputes must be raised with your respective bank or the third-party payment app used.
            </p>
          </section>

          <section style={{ marginBottom: '60px' }}>
            <h2 style={{ fontSize: '24px', fontWeight: 700, marginBottom: '24px', color: 'white' }}>
              4. Premium Features (SQUAD Pro)
            </h2>
            <p style={{ marginBottom: '16px', color: 'var(--text-secondary)' }}>
              SQUAD Pro is a one-time purchase that unlocks additional features such as Custom Bill Splitting, unlimited plan creation, and the Memory Feed. All purchases are handled through the Google Play Store or Apple App Store.
            </p>
            <ul style={{ color: 'var(--text-secondary)', paddingLeft: '24px', lineHeight: '2.5' }}>
              <li>Purchases are non-refundable after successful activation.</li>
              <li>"Squad Pack" allows gifting Pro access to 4 other users.</li>
              <li>Unauthorized modification of 'isPro' flag in local data will lead to account suspension.</li>
            </ul>
          </section>

          <section style={{ marginBottom: '60px' }}>
            <h2 style={{ fontSize: '24px', fontWeight: 700, marginBottom: '24px', color: 'white' }}>
              5. Content & Media
            </h2>
            <p style={{ marginBottom: '16px', color: 'var(--text-secondary)' }}>
              Users are solely responsible for the content (photos, text) they upload to the "Memory Feed". We reserve the right to remove content that is illegal, offensive, or violates community guidelines.
            </p>
          </section>

          <section id="privacy" style={{ marginBottom: '60px' }}>
            <h2 style={{ fontSize: '24px', fontWeight: 700, marginBottom: '24px', color: 'white' }}>
              6. Privacy & Data Handling
            </h2>
            <p style={{ marginBottom: '16px', color: 'var(--text-secondary)' }}>
              We respect your privacy. SQUAD only collects necessary data to facilitate group planning:
            </p>
            <ul style={{ color: 'var(--text-secondary)', paddingLeft: '24px', lineHeight: '2.5' }}>
              <li><strong>Mobile Number:</strong> For authentication and linking plans.</li>
              <li><strong>Contacts:</strong> Optional, to help you invite friends faster.</li>
              <li><strong>Metadata:</strong> Plan titles, dates, and locations to provide the service.</li>
            </ul>
          </section>

          <section id="refund" style={{ marginBottom: '60px' }}>
            <h2 style={{ fontSize: '24px', fontWeight: 700, marginBottom: '24px', color: 'white' }}>
              7. Refund Policy
            </h2>
            <p style={{ marginBottom: '16px', color: 'var(--text-secondary)' }}>
              Since SQUAD Pro and Squad Pack are digital products delivered instantly, we generally do not offer refunds. However, if you were charged twice or have a billing error, please contact support within 48 hours of purchase with your transaction ID from Play Store or App Store.
            </p>
          </section>

          <div style={{ marginTop: '100px', textAlign: 'center' }}>
            <p style={{ color: 'var(--text-secondary)', fontSize: '14px' }}>
              For support inquiries, reach out to us at <strong>hello@squad.app</strong>
            </p>
          </div>
        </div>
      </div>
      <Footer />
    </main>
  );
}
