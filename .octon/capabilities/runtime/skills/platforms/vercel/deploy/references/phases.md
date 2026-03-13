---
title: Behavior Phases
description: Phase-by-phase instructions for the vercel-deploy skill.
---

# Behavior Phases

Detailed instructions for each phase of the Vercel deployment workflow.

## Phase 1: Pre-flight

**Goal:** Verify deployment prerequisites are met.

### Steps

1. Check `vercel` CLI is available: `vercel --version`
   - If not found: instruct user to run `npm i -g vercel` and stop
2. Check project is linked: look for `.vercel/project.json`
   - If not found: instruct user to run `vercel link` and stop
3. Read `vercel.json` if present for build/output configuration
4. Read `package.json` to identify framework and build script
5. Log pre-flight results

### Failure Handling

- CLI not installed: stop, report installation instructions
- Not authenticated: stop, instruct user to run `vercel login`
- Project not linked: stop, instruct user to run `vercel link`

## Phase 2: Build Verification

**Goal:** Check for obvious issues before deploying.

### Steps

1. Note the framework detected by Vercel (from `package.json` or `vercel.json`)
2. Check for common issues:
   - Missing `build` script in `package.json` (if framework requires one)
   - TypeScript config errors in `tsconfig.json`
   - Missing required environment variables (if `.env.example` exists)
3. Log build verification results

### Notes

- Do NOT run the build locally — Vercel handles this
- This phase is informational, not blocking (deploy may succeed even with warnings)

## Phase 3: Deploy

**Goal:** Execute the deployment.

### Steps

1. Determine deployment command:
   - Production: `vercel --prod`
   - Preview: `vercel`
2. Execute the command
3. Capture output, extracting:
   - Deployment URL
   - Project name
   - Build duration (if reported)
   - Any warnings or errors

### Error Handling

- Build failure: capture error output, report to user, do not retry
- Network failure: report error, suggest checking connection
- Permission error: report, suggest checking team/project access

## Phase 4: Report

**Goal:** Log results and report to user.

### Steps

1. Write execution log to `_ops/state/logs/vercel-deploy/{run_id}.md`:
   ```markdown
   # vercel-deploy — {run_id}

   - **Date:** YYYY-MM-DD HH:MM
   - **Environment:** production | preview
   - **Project:** {project_name}
   - **Framework:** {detected_framework}
   - **Deployment URL:** {url}
   - **Status:** success | failed
   - **Notes:** {any warnings or errors}
   ```
2. Update `_ops/state/logs/vercel-deploy/index.yml` and `_ops/state/logs/index.yml`
3. Report deployment URL and status to user
