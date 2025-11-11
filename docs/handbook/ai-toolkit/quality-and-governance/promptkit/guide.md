# PromptKit — Templates & Prompt Conventions

- **Purpose:** Centralizes prompts, roles, variables, and prompt tests to add repeatable, AI-powered prompting aligned to Harmony contracts.
- **Responsibilities:** defining templates/partials, validating variables, supporting variants/A-B strategies, handling environment overrides, packaging test fixtures.
- **Harmony alignment:** advances consistent contracts and interoperability across AI-powered kits; exposes validation hooks for safe, reviewable prompt outputs.
- **Integrates with:** Dockit (doc prompts), DevKit (code prompts), PlanKit (LLM prompts), ScaffoldKit (templating).
- **I/O:** reads `prompts/**` (YAML/JSON/MD templates, roles, variables); emits `prompts_out/**` compiled prompts and `prompt_tests/**` fixtures.
- **Wins:** Reproducible, testable prompts with clear ownership and fast iteration.
- **Common Qs:** *Programmatic prompts?* Yes—partials and functions via templating. *Per-env variants?* Yes—validated overrides with defaults. *A/B?* Yes—variant selectors with fallback.
- **Implementation Choices (opinionated):**
  - jinja2: flexible prompt templating with partials/filters.
  - pydantic v2: typed prompt/variable contracts with strict validation.
  - ruamel.yaml: robust YAML read/write for template metadata.
