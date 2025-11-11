'use client';

import React from 'react';
import { Button } from '@harmony/ui';

import generateEmbedding from '../../actions/generate-embedding.action';

type FormState =
  | { pending: false; dimension?: number; error?: string }
  | { pending: true; dimension?: number; error?: string };

export default function EmbeddingsPage(): React.ReactElement {
  const [state, formAction] = React.useActionState(
    async (prev: FormState, formData: FormData): Promise<FormState> => {
      const input = String(formData.get('input') || '');
      const model = String(formData.get('model') || '');

      const res = await generateEmbedding({
        input,
        model: model || undefined
      });

      if (!res.ok) {
        return { pending: false, error: res.error };
      }

      const dimension = Array.isArray(res.data.embedding) ? res.data.embedding.length : 0;
      return { pending: false, dimension };
    },
    { pending: false }
  );

  return (
    <main className="grid max-w-3xl gap-6">
      <h1 className="text-2xl font-semibold tracking-tight">Embeddings</h1>
      <form action={formAction} className="grid gap-4">
        <textarea
          name="input"
          rows={6}
          placeholder="Text to embed..."
          required
          className="w-full rounded-[var(--radius-md)] border border-black/10 bg-white p-4 shadow-sm focus:border-black focus:outline-none"
        />
        <input
          name="model"
          placeholder="Model (optional)"
          className="max-w-sm rounded-[var(--radius-md)] border border-black/10 bg-white px-3 py-2 shadow-sm focus:border-black focus:outline-none"
        />
        <Button type="submit" disabled={state.pending} className="justify-self-start">
          {state.pending ? 'Embedding…' : 'Generate Embedding'}
        </Button>
      </form>
      {state.error && <p className="text-red-600">{state.error}</p>}
      {typeof state.dimension === 'number' && !state.pending && (
        <section className="rounded-[var(--radius-md)] border border-black/10 bg-white p-4 shadow-sm">
          <h2 className="text-lg font-medium">Embedding</h2>
          <p className="text-sm text-black/70">Vector dimension: {state.dimension}</p>
        </section>
      )}
    </main>
  );
}


