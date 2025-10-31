import React from 'react';
import { getFlagSnapshot } from '../../lib/flags';

export default function StatusPage(): React.ReactElement {
  const flags = getFlagSnapshot();

  return (
    <main className="grid gap-6">
      <h1 className="text-2xl font-semibold tracking-tight">System Status</h1>
      <section className="rounded-[var(--radius-md)] border border-black/10 bg-white p-4 shadow-sm">
        <h2 className="text-lg font-medium">Flags</h2>
        <ul className="mt-3 grid gap-2 text-sm text-black/70">
          {Object.entries(flags).map(([k, v]) => (
            <li key={k} className="flex items-center justify-between gap-4 rounded bg-black/5 px-3 py-2">
              <code className="font-mono text-xs uppercase tracking-wide text-black/60">{k}</code>
              <span className="font-semibold text-black">{String(v)}</span>
            </li>
          ))}
        </ul>
      </section>
    </main>
  );
}


