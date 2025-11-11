import React from 'react';
import Link from 'next/link';
import { Button } from '@harmony/ui';

export default function HomePage(): React.ReactElement {
  return (
    <main className="mx-auto grid max-w-3xl gap-6">
      <header className="grid gap-3">
        <h1 className="text-3xl font-semibold tracking-tight">Harmony AI Console</h1>
        <p className="text-base text-black/70">
          Explore internal tools for generating completions, embeddings, and monitoring system
          status.
        </p>
      </header>
      <section className="grid gap-3 sm:grid-cols-2">
        <Button asChild variant="default" size="lg">
          <Link href="/completions">Completions Playground</Link>
        </Button>
        <Button asChild variant="outline" size="lg">
          <Link href="/embeddings">Embeddings Playground</Link>
        </Button>
        <Button asChild variant="ghost" size="lg" className="sm:col-span-2 justify-start">
          <Link href="/status">System Status</Link>
        </Button>
      </section>
    </main>
  );
}


