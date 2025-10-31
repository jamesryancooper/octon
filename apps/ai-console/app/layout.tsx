import '@harmony/ui-kit/dist/ui.css';

import React from 'react';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Harmony AI Console',
  description: 'Internal console for AI completions and embeddings'
};

export default function RootLayout({
  children
}: {
  children: React.ReactNode;
}): React.ReactElement {
  return (
    <html lang="en" suppressHydrationWarning>
      <body
        style={{
          minHeight: '100vh',
          backgroundColor: 'rgb(var(--background))',
          color: 'rgb(var(--foreground))',
          fontFamily:
            "Inter, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
          WebkitFontSmoothing: 'antialiased',
          MozOsxFontSmoothing: 'grayscale'
        }}
      >
        <div style={{ padding: '2rem 1.5rem', maxWidth: '72rem', margin: '0 auto' }}>{children}</div>
      </body>
    </html>
  );
}


