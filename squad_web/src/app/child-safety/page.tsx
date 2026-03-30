'use client';

import Link from 'next/link';
import Navbar from '@/app/components/Navbar';
import Footer from '@/app/components/Footer';

export default function ChildSafety() {
  return (
    <main style={{ minHeight: '100vh', background: 'var(--background)' }}>
      <Navbar />
      
      <section style={{
        paddingTop: '120px',
        paddingBottom: '80px',
        position: 'relative'
      }}>
        <div className="container" style={{ maxWidth: '900px' }}>
          <h1 style={{
            fontSize: '48px',
            fontWeight: 800,
            color: 'white',
            marginBottom: '32px',
            fontFamily: 'Sora'
          }}>
            Child Safety Standards
          </h1>

          <p style={{
            fontSize: '18px',
            color: 'var(--text-secondary)',
            lineHeight: 1.8,
            marginBottom: '48px'
          }}>
            Squad is committed to protecting the safety of all users, especially children. We comply with Google Play's Child Safety Standards policy and have implemented comprehensive measures to prevent child sexual abuse and exploitation.
          </p>

          <div style={{
            background: 'var(--surface)',
            padding: '48px',
            borderRadius: '24px',
            border: '1px solid rgba(255, 255, 255, 0.05)',
            marginBottom: '48px'
          }}>
            <h2 style={{
              fontSize: '28px',
              fontWeight: 800,
              color: 'white',
              marginBottom: '32px',
              fontFamily: 'Sora'
            }}>
              Our Child Safety Commitments
            </h2>

            <div style={{ lineHeight: 2.2 }}>
              <h3 style={{
                fontSize: '18px',
                fontWeight: 700,
                color: 'var(--accent)',
                marginTop: '24px',
                marginBottom: '12px'
              }}>
                1. Published Safety Standards
              </h3>
              <p style={{ color: 'var(--text-secondary)' }}>
                We maintain and publish clear standards against child sexual abuse and exploitation (CSAE). Our policies are designed to prevent exploitation and protect vulnerable users.
              </p>

              <h3 style={{
                fontSize: '18px',
                fontWeight: 700,
                color: 'var(--accent)',
                marginTop: '24px',
                marginBottom: '12px'
              }}>
                2. In-App Reporting Mechanism
              </h3>
              <p style={{ color: 'var(--text-secondary)' }}>
                Users can easily report abuse and concerning content directly through the app. We have a dedicated feedback system accessible from the home screen to ensure reports are handled promptly.
              </p>

              <h3 style={{
                fontSize: '18px',
                fontWeight: 700,
                color: 'var(--accent)',
                marginTop: '24px',
                marginBottom: '12px'
              }}>
                3. Content Moderation
              </h3>
              <p style={{ color: 'var(--text-secondary)' }}>
                We address all reports of child sexual abuse material (CSAM) and take appropriate action to protect child safety. Our team investigates reports and takes swift action.
              </p>

              <h3 style={{
                fontSize: '18px',
                fontWeight: 700,
                color: 'var(--accent)',
                marginTop: '24px',
                marginBottom: '12px'
              }}>
                4. Legal Compliance
              </h3>
              <p style={{ color: 'var(--text-secondary)' }}>
                Squad complies with all applicable child safety laws and regulations across jurisdictions where we operate.
              </p>

              <h3 style={{
                fontSize: '18px',
                fontWeight: 700,
                color: 'var(--accent)',
                marginTop: '24px',
                marginBottom: '12px'
              }}>
                5. Child Safety Contact
              </h3>
              <p style={{ color: 'var(--text-secondary)' }}>
                We have designated a child safety point of contact to address all child safety concerns and reports. Contact us at: <strong>thehustler.dev@gmail.com</strong>
              </p>
            </div>
          </div>

          <div style={{
            background: 'rgba(233, 69, 96, 0.1)',
            padding: '32px',
            borderRadius: '16px',
            border: '1px solid rgba(233, 69, 96, 0.3)',
            marginBottom: '48px'
          }}>
            <h3 style={{
              fontSize: '18px',
              fontWeight: 700,
              color: 'var(--accent)',
              marginBottom: '12px'
            }}>
              How to Report Abuse
            </h3>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '16px' }}>
              If you witness or experience child abuse or exploitation on Squad:
            </p>
            <ul style={{ color: 'var(--text-secondary)', lineHeight: 2 }}>
              <li>• Use the in-app feedback mechanism (Feedback button on home screen)</li>
              <li>• Contact our safety team at thehustler.dev@gmail.com</li>
              <li>• Report to local authorities or the National Center for Missing & Exploited Children (NCMEC)</li>
            </ul>
          </div>

          <p style={{
            color: 'var(--text-secondary)',
            fontSize: '14px',
            textAlign: 'center'
          }}>
            For more information about child safety, visit <a href="https://support.google.com/googleplay/android-developer/answer/14585136" target="_blank" rel="noopener noreferrer" style={{ color: 'var(--accent)' }}>Google Play's Child Safety Standards Policy</a>
          </p>
        </div>
      </section>

      <Footer />
    </main>
  );
}
