# Pricing Reference

Extracted from `packages/kits/costkit/src/pricing.ts`.

## Primary Models (USD per 1M tokens)

| Model | Provider | Input | Output |
|---|---|---:|---:|
| `gpt-4o` | openai | 2.50 | 10.00 |
| `gpt-4o-mini` | openai | 0.15 | 0.60 |
| `o3-mini` | openai | 1.10 | 4.40 |
| `claude-sonnet` | anthropic | 3.00 | 15.00 |
| `claude-haiku` | anthropic | 0.80 | 4.00 |
| `gemini-2.0-flash` | google | 0.10 | 0.40 |
| `mistral-large` | mistral | 2.00 | 6.00 |
| `mistral-small` | mistral | 0.20 | 0.60 |

The shell implementation uses this subset for portable estimation and falls back to a conservative default (`gpt-4o-mini`) for unknown model ids.
