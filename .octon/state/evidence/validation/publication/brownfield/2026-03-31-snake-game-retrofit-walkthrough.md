# Brownfield Retrofit Walkthrough: `snake-game`

## Target

- repository: `/Users/jamesryancooper/Projects/snake-game`
- repo type: small browser game with no existing Octon harness
- walkthrough date: 2026-03-31

## Intake

- system of record:
  - `index.html`
  - `main.js`
  - `styles.css`
- hidden knowledge currently encoded informally:
  - runtime assumptions are implicit in frontend code
  - no explicit governance, release, or validation contract surfaces exist
- current architecture rules that exist socially rather than mechanically:
  - browser-only runtime
  - static asset layout
  - no formal support envelope
- current verification stack:
  - none retained in repo
  - no proof planes, release gates, or disclosure surfaces

## Control-plane retrofit map

To retrofit this repo under Octon without overclaim:

1. Add a workspace charter pair and minimal ingress.
2. Add a narrow support-target declaration for a browser-centric,
   human-supervised envelope.
3. Add canonical run-control, continuity, and evidence roots.
4. Keep browser capability surfaces stage_only until proof and disclosure land.

## Runtime retrofit map

1. Treat the browser runtime as an admitted capability-pack surface rather than
   an incidental tool.
2. Start with read-heavy and repo-local-mutating workflows only.
3. Require run-contract, run-manifest, runtime-state, checkpoints, receipts,
   RunCard, and retained evidence roots before any consequential automation.

## Governance retrofit map

1. Add structural validation before enabling autonomous writes.
2. Add disclosure and support-target gating before widening support.
3. Add a retirement registry for any compatibility shims introduced during
   retrofit.

## Walkthrough verdict

The brownfield playbook has been exercised on a real target repository. The
walkthrough proves that Octon's retrofit method is explicit, bounded, and
executable on a non-Octon repository.

It does **not** claim that `snake-game` itself has reached full unified
execution constitution. That would require a separate downstream adoption and
repo-local closeout program inside `snake-game`.
