import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Squad | India's #1 Social Group Planner",
  description: "From 'Kaha Jaaye?' to 'It's Happening!' - Poll on dates, lock in venues, and split bills with your inner circle. Built for India.",
  keywords: ["group planning", "social planner", "india app", "bill split", "whatsapp groups", "kaha jaaye", "squad app"],
  openGraph: {
    title: "Squad | Group Hangout Planner",
    description: "The dedicated tool to close the planning loop in your friend groups.",
    url: "https://squad.app",
    siteName: "Squad",
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
      },
    ],
    locale: "en_IN",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <link rel="icon" href="/favicon.png" sizes="any" />
      </head>
      <body>
        {children}
      </body>
    </html>
  );
}
