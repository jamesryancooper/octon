# Changelog

All notable changes to `@harmony/prompts` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-15

### Added

#### Core Prompts
- **spec-from-intent** (v1.0.0): Generate specifications from natural language descriptions
  - Tiered output: T1 (minimal), T2 (standard), T3 (full STRIDE)
  - Examples for all three tiers
  - Validation checklist with automated and human checks

- **plan-from-spec** (v1.0.0): Create implementation plans from validated specs
  - Step-by-step ordered plans with dependencies
  - Architecture detection and file planning
  - Risk checkpoints for human review

- **code-from-plan** (v1.0.0): Generate code following plan steps
  - Step-by-step code generation
  - Hallucination detection rules
  - Pattern compliance checks

- **test-from-contract** (v1.0.0): Generate tests from OpenAPI contracts
  - Unit, contract, e2e, and golden test generation
  - Security-derived tests from STRIDE
  - Coverage tracking for acceptance criteria

- **threat-model-from-spec** (v1.0.0): Generate STRIDE threat analysis
  - T2 summary format
  - T3 full STRIDE with likelihood/impact ratings
  - OWASP ASVS v5 mapping

#### Infrastructure
- **catalog.yaml**: Central prompt registry with versioning
  - Model tier mapping (T1/T2/T3)
  - Quality gates configuration
  - Hallucination checks list

- **JSON Schemas**: Input/output validation for all prompts
  - Strict schema validation with AJV
  - Tiered output schemas (T1/T2/T3)

- **TypeScript Utilities**:
  - `PromptCatalog`: Load and query the prompt catalog
  - `PromptLoader`: Load prompts with templates and schemas
  - `PromptValidator`: Validate inputs/outputs against schemas
  - `GoldenTestManager`: Manage and run golden tests

- **Validation Tool**: `pnpm validate` to check all prompts

### Configuration
- Default temperature: 0.2 (low variance for determinism)
- Default max_tokens: 4096
- Model mapping:
  - T1: gpt-4o-mini
  - T2 draft: gpt-4o-mini
  - T2 final: gpt-4o
  - T3: gpt-4o

---

## Versioning Policy

### Prompt Versioning
Each prompt has its own version tracked in `catalog.yaml`:
- **Major (X.0.0)**: Breaking changes to input/output schemas
- **Minor (0.X.0)**: New optional fields or capabilities
- **Patch (0.0.X)**: Bug fixes, clarifications, example updates

### Package Versioning
The package version tracks overall library changes:
- **Major**: Breaking API changes to TypeScript utilities
- **Minor**: New prompts or significant utility features
- **Patch**: Bug fixes, documentation updates

---

## Migration Guide

### From Previous Prompts Structure
If migrating from the previous `packages/prompts/assessments/` structure:

1. Prompts are now under `core/` organized by workflow step
2. Manifests replaced by `catalog.yaml`
3. Use TypeScript utilities instead of direct file access:
   ```typescript
   // Old
   import { resolvePromptPath } from '@harmony/prompts';
   
   // New
   import { loadCatalog, PromptLoader } from '@harmony/prompts';
   const catalog = loadCatalog();
   const loader = new PromptLoader(catalog);
   const prompt = loader.load('spec-from-intent');
   ```

