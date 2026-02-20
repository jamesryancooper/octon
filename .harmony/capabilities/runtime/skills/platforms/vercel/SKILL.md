---
name: vercel
description: >
  Platform skill set for Vercel deployments. Provides context about
  the available skills, platform requirements, and deployment workflow.
user-invocable: false
skill_sets: [specialist]
capabilities: []
allowed-tools: Read Grep Glob
---

# Vercel Platform

Background context for Claude — not invoked directly. This skill set
targets projects deployed to **Vercel**. Claude should use this to guide
skill suggestions and platform assumptions.

## Platform Assumptions

These skills encode workflows for a specific deployment platform. They
apply when the project meets these conditions:

| Requirement     | Choice                                    |
|-----------------|-------------------------------------------|
| CLI             | Vercel CLI (`vercel`) installed globally  |
| Authentication  | `vercel login` completed                 |
| Project linking | `vercel link` completed (or first deploy)|
| Framework       | Any Vercel-supported framework           |
| Node.js         | Active LTS version                       |

### Supported Frameworks

Vercel auto-detects 40+ frameworks including Next.js, React, Vue/Nuxt,
Svelte/SvelteKit, Astro, Remix, Express, Fastify, and static HTML.

**When not to suggest these skills:** Projects deployed via Docker or
Kubernetes. Non-Node.js backends (Python, Go, Rust) unless they have a
separate frontend deployed to Vercel. Projects using other hosting
platforms exclusively (AWS Amplify, Cloudflare Pages, Netlify). Static
sites better served by simpler hosting (GitHub Pages, S3).

## Child Skills

| Skill | Purpose |
|-------|---------|
| `/vercel-deploy` | Package and deploy the project to Vercel using the CLI |

## Prerequisites

Before using deployment skills, ensure:

1. **Vercel CLI installed:** `npm i -g vercel`
2. **Authenticated:** `vercel login`
3. **Project linked:** `vercel link` (or the first deploy will prompt)

## Usage

The deploy skill is an **executor skill** — it runs a deployment workflow
and reports the result (deployment URL and status). It can be invoked
independently at any time.
