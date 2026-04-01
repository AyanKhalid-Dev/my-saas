import "./globals.css";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Karobar OS",
  description: "Simple Business Operating System for Pakistani retailers"
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
