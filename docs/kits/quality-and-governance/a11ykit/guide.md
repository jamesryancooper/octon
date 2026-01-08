# A11yKit — Accessibility Checks (WCAG)

- **Purpose:** Automated WCAG audits for UI and docs, producing machine‑readable evidence for gated delivery.
- **Responsibilities:** scanning rendered pages via test flows, checking ARIA/landmarks/contrast/focus, annotating failing nodes with hints, emitting JSON/HTML reports, tracking documented exceptions.
- **Harmony alignment:** Advances Evidence‑First and Safe‑by‑Default by standardizing a11y contracts and emitting governance‑ready artifacts.
- **Integrates with:** TestKit (drives UI flows), PatchKit (PR checks/summaries), UIkit (surfaces issues).
- **I/O:** inputs: UI flows/preview URLs; outputs: axe JSON reports, HTML summaries, PR check annotations.
- **Wins:** Prevents a11y regressions with low overhead and audit‑ready evidence.

- **Implementation Choices (opinionated):**
  - axe-core: primary WCAG rules engine with broad, reliable coverage.
  - @axe-core/playwright: runs axe within Playwright-driven UI flows provided by TestKit.
  - pa11y-ci: fast URL-level scans for docs/previews outside full test runs.
