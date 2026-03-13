---
title: Parse — PDF → Markdown (Docling-powered)
description: Developer documentation for implementing and using Parse to convert PDFs into clean Markdown with tables and figures, aligned to Octon's AI Services Platform service conventions.
---

# Parse

Convert PDFs into clean, reviewable Markdown using Docling, with an optional tiny fallback via Microsoft's MarkItDown. Parse is a local‑first service that produces deterministic artifacts (`.md` files) suitable for downstream ingestion, indexing, and documentation workflows.

## Purpose

- Single‑purpose: Parse PDFs → Markdown (tables/figures preserved when possible).
- Deterministic and local‑first: Runs on a developer machine or CI without cloud dependencies.
- Produces artifacts under `docs_out/parsed/**` and a minimal run record for provenance and governance.

## When to Use

- Preparing PDFs for doc improvement (Doc), ingestion (Ingest), or indexing (Index).
- Converting vendor docs into Markdown for internal knowledge bases or RAG corpora.
- Pre‑processing artifacts for AI agent workflows that expect Markdown inputs.

## Octon Alignment

- Pillars: focus_through_absorbed_complexity, velocity_through_agentic_automation, trust_through_governed_determinism.
- Lifecycle stage: implement (feeds docs/ingest/index flows).
- Invariants:
  - Determinism: stable inputs → stable outputs; run record includes one‑line JSON summary.
  - Observability: emit standard run metadata; integrate with Observe where applicable.
  - Governance: use Guard redaction policy and typed outputs for CI gates.

### Service identity

| Field                | Value                                                                                                                 |
|----------------------|-----------------------------------------------------------------------------------------------------------------------|
| Service name         | `parse`                                                                                                            |
| Stage                | `implement`                                                                                                           |
| Required span        | `service.parse.run`                                                                                                  |
| Artifacts            | `docs_out/parsed/*.md`, `runs/**/parse-*.json`                                                                     |
| Contracts (normative)| `.octon/capabilities/runtime/services/retrieval/parse/schema/input.schema.json`, `.octon/capabilities/runtime/services/retrieval/parse/schema/output.schema.json` |

## Why Docling

- One‑liner PDF→MD via stable Python API/CLI; includes figures/tables where supported.
- Modern, active, MIT‑licensed; better table/layout handling than minimal tools.
- Aligns with local‑first Turborepo + CI patterns already used in Octon.

References:

- [Docling (Project Site)](https://docling-project.github.io/docling/usage/)
- [Docling (GitHub)](https://github.com/docling-project/docling)
- [Docling (PyPI)](https://pypi.org/project/docling/)
- [PyMuPDF tables reference (Artifex)](https://artifex.com/blog/extracting-tables-from-pdfs-with-pymupdf)

### Lightweight fallback: MarkItDown

- Tiny Python utility producing LLM‑friendly Markdown (headings/lists/tables/links).
- Use for “simple PDFs, minimal deps” or as an emergency fallback.
- [MarkItDown (GitHub)](https://github.com/microsoft/markitdown)

## Setup (Turborepo)

Directory layout:

```plaintext
/services/parse/
├── package.json
├── pyproject.toml
├── src/
│   └── parse/
│       └── cli.py
├── schema/
│   ├── input.schema.json
│   └── output.schema.json
└── runs/              # gitignored artifacts
```

`package.json` (wire a Python service into Turbo):

```json
{
  "name": "parse",
  "private": true,
  "scripts": {
    "service:run": "python -m parse.cli",
    "lint": "echo \"n/a\"",
    "typecheck": "echo \"n/a\"",
    "test": "pytest -q || true"
  }
}
```

`pyproject.toml` (Python 3.11+, Docling):

```toml
[project]
name = "parse"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = ["docling>=2.60", "pydantic>=2", "typer>=0.12", "rich>=13"]

[project.scripts]
parse = "parse.cli:app"
```

Turbo pipeline (excerpt):

```json
{
  "pipeline": {
    "service:run": { "cache": false },
    "lint": { "outputs": [] },
    "typecheck": { "outputs": [] },
    "test": { "outputs": ["runs/test/**"] }
  }
}
```

## CLI Usage

The CLI is intentionally minimal and deterministic. It converts a single file or a glob, writes Markdown to `docs_out/parsed`, and emits a tiny run record JSON file for provenance.

Example invocation (local):

```bash
cd .octon/capabilities/runtime/services/retrieval/parse
# install Python deps (pip or uv)
pip install -e .
# or: uv pip install -e .

# help
pnpm turbo run service:run --filter=parse -- --help

# parse a set of PDFs into Markdown
pnpm turbo run service:run --filter=parse -- "docs/**/*.pdf" --out "docs_out/parsed"
```

### CLI behavior

- Inputs:
  - `input` (positional): file path or glob (`"docs/**/*.pdf"`).
  - `--out` / `--out-dir`: output folder (default `docs_out/parsed`).
  - `--include-assets`: export figures to `assets/` where supported (default: true).
- Outputs:
  - Markdown files: `docs_out/parsed/<stem>.md`
  - Run record: `docs_out/parsed/<timestamp>-parse.json`
  - One‑line JSON summary to stdout (for agents/CI parsing)

## Contracts (Schemas)

Normative schema locations (create as the service matures):

- Inputs: `.octon/capabilities/runtime/services/retrieval/parse/schema/input.schema.json`
- Outputs: `.octon/capabilities/runtime/services/retrieval/parse/schema/output.schema.json`

Minimum output keys to include in the run record:

```json
{
  "runId": "2025-11-07T12-00-01Z-parse-9f2c",
  "service": { "name": "parse", "version": "0.1.0" },
  "artifacts": [
    { "path": "docs_out/parsed/example.md", "type": "markdown" }
  ],
  "status": "success",
  "summary": "Parsed 3 file(s) → docs_out/parsed",
  "telemetry": { "trace_id": "<optional>" },
  "stage": "implement"
}
```

## Determinism, Observability, Governance

- Determinism:
  - Stable inputs produce stable outputs; avoid time‑dependent content in files.
  - Print a one‑line JSON summary to stdout (`{"status":"success","summary":"..."}`).
- Observability:
  - Emit a parent lifecycle span `service.parse.run` (when integrated with Observe).
  - Include attributes: `service.name`, `service.version`, `run.id`, `stage`.
- Governance:
  - Apply Guard redaction rules at write/log boundaries; never serialize secrets/PII.
  - Fail‑closed posture in CI when schema validation or policy checks fail.

## Fallback: MarkItDown

For simple PDFs or emergency usage:

```bash
pip install markitdown
python - <<'PY'
from markitdown import MarkItDown
import sys, pathlib
src = pathlib.Path(sys.argv[1])
md = MarkItDown().convert(src).text_content
out = pathlib.Path("docs_out/parsed") / (src.stem + ".md")
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(md, encoding="utf-8")
print("wrote", out)
PY  path/to/file.pdf
```

Note: MarkItDown targets LLM‑readable Markdown rather than high‑fidelity typesetting. Prefer Docling for robust layout and tables.

## CI Recommendations

- Add a lightweight `service:run` job for preview branches to refresh parsed docs.
- Store artifacts under `docs_out/parsed` and link run records in PRs (Patch).
- For medium/high‑risk changes, include Eval/Policy gates that verify schema presence and redaction compliance.

## Troubleshooting

- Missing tables/figures:
  - Ensure you’re on a current Docling release; some PDFs require newer parsers.
- Encoding issues:
  - Force UTF‑8 writes; validate Markdown renders in your docs portal.
- Slow conversions:
  - Run locally and cache results with Cache (pure ops with explicit `cacheKey`).

## Security & Compliance Notes

- Never log or serialize secrets/PII. Apply Guard redaction policies.
- Treat run records as non‑sensitive; avoid embedding raw source content in JSON.
- Respect licensing for source PDFs; include license/provenance notes in PRs when appropriate.

## See Also

- Doc (docs improvement), Ingest (normalize), Index (build stores), Query (answers+evidence).
- Observe for OTel spans/logs; Policy/Eval for gates; Patch for PRs.
