'use client';

import React from 'react';
import { Button } from '@harmony/ui';

import generateCompletion from '../../actions/generate-completion.action';

type FormState =
  | { pending: false; result?: string; tokens?: number; error?: string }
  | { pending: true; result?: string; tokens?: number; error?: string };

export default function CompletionsPage(): React.ReactElement {
  const [state, formAction] = React.useActionState(
    async (prev: FormState, formData: FormData): Promise<FormState> => {
      const prompt = String(formData.get('prompt') || '');
      const model = String(formData.get('model') || '');
      const temperature = Number(formData.get('temperature') || NaN);
      const maxTokens = Number(formData.get('maxTokens') || NaN);

      const res = await generateCompletion({
        prompt,
        model: model || undefined,
        temperature: Number.isFinite(temperature) ? temperature : undefined,
        maxTokens: Number.isFinite(maxTokens) ? maxTokens : undefined
      });

      if (!res.ok) {
        return { pending: false, error: res.error };
      }

      return {
        pending: false,
        result: res.data.output,
        tokens: res.data.totalTokens
      };
    },
    { pending: false }
  );

  return (
    <main className="grid max-w-3xl gap-6">
      <h1 className="text-2xl font-semibold tracking-tight">Completions</h1>
      <form action={formAction} className="grid gap-4">
        <textarea
          name="prompt"
          rows={6}
          placeholder="Enter a prompt..."
          required
          className="w-full rounded-[var(--radius-md)] border border-black/10 bg-white p-4 shadow-sm focus:border-black focus:outline-none"
        />
        <div className="grid gap-3 md:grid-cols-3">
          <input
            name="model"
            placeholder="Model (optional)"
            className="rounded-[var(--radius-md)] border border-black/10 bg-white px-3 py-2 shadow-sm focus:border-black focus:outline-none"
          />
          <input
            name="temperature"
            type="number"
            step={0.1}
            min={0}
            max={2}
            placeholder="0.7"
            className="rounded-[var(--radius-md)] border border-black/10 bg-white px-3 py-2 shadow-sm focus:border-black focus:outline-none"
          />
          <input
            name="maxTokens"
            type="number"
            min={1}
            max={8192}
            placeholder="512"
            className="rounded-[var(--radius-md)] border border-black/10 bg-white px-3 py-2 shadow-sm focus:border-black focus:outline-none"
          />
        </div>
        <Button type="submit" disabled={state.pending} className="justify-self-start">
          {state.pending ? 'Generating…' : 'Generate'}
        </Button>
      </form>
      {state.error && <p className="text-red-600">{state.error}</p>}
      {state.result && (
        <section className="grid gap-3 rounded-[var(--radius-md)] border border-black/10 bg-white p-4 shadow-sm">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-medium">Output</h2>
            {!!state.tokens && <span className="text-sm text-black/60">Tokens: {state.tokens}</span>}
          </div>
          <pre className="whitespace-pre-wrap text-sm text-black/80">{state.result}</pre>
        </section>
      )}
    </main>
  );
}


