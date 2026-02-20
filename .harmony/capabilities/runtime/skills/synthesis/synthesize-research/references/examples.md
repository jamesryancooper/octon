---
examples:
  - input: "_ops/state/resources/synthesize-research/projects/auth-patterns/"
    invocation: "/synthesize-research _ops/state/resources/synthesize-research/projects/auth-patterns/"
    output: ".harmony/output/drafts/auth-patterns-synthesis.md"
    description: "Synthesize authentication pattern research"
  - input: "_ops/state/resources/synthesize-research/api-design/"
    invocation: "/synthesize-research _ops/state/resources/synthesize-research/api-design/"
    output: ".harmony/output/drafts/api-design-synthesis.md"
    description: "Consolidate API design research notes"
---

# Examples Reference

Complete worked examples demonstrating the synthesize-research skill.

---

## Example 1: Authentication Patterns Research

Synthesizing research on authentication patterns for a web application.

### Input

```bash
/synthesize-research projects/auth-patterns/
```

### Source Files

```
projects/auth-patterns/
├── project.md       # Research goal and context
├── jwt-research.md  # JWT token research
├── session-research.md  # Session-based auth research
└── findings.md      # Preliminary findings
```

### Expected Output

**Path:** `.harmony/output/drafts/auth-patterns-synthesis.md`

```markdown
# Research Synthesis: auth-patterns

**Generated:** 2025-01-12T10:31:00Z
**Source:** projects/auth-patterns/

## Executive Summary

The research compared JWT tokens and session-based authentication for the web application. JWT tokens offer stateless scalability but require careful handling of token revocation. Session-based auth provides simpler revocation but requires session storage infrastructure. For this application's scale, JWT with short expiry and refresh tokens is recommended.

## Key Themes

### Theme 1: Scalability Characteristics

**Insight:** JWT tokens scale horizontally without shared state, while sessions require distributed session storage.

**Evidence:**
- JWT validation is self-contained, requiring only the signing key
- Session validation requires a round-trip to session storage
- At 10K+ concurrent users, session storage becomes a bottleneck without Redis/Memcached

**Confidence:** High

### Theme 2: Security Trade-offs

**Insight:** Both approaches have security trade-offs; the choice depends on threat model priorities.

**Evidence:**
- JWTs cannot be revoked before expiry without a blocklist (adds state)
- Sessions can be immediately revoked by deleting from storage
- JWTs in localStorage are vulnerable to XSS; sessions in httpOnly cookies are not

**Confidence:** High

### Theme 3: Implementation Complexity

**Insight:** JWT implementation is more complex upfront but simpler to operate at scale.

**Evidence:**
- JWT requires refresh token flow, token rotation, and secure storage
- Sessions require sticky sessions or distributed storage
- JWT debugging is harder (base64 decoding, signature verification)

**Confidence:** Medium

### Theme 4: Mobile Client Considerations

**Insight:** JWT tokens are better suited for mobile clients due to stateless nature.

**Evidence:**
- Mobile apps can store tokens securely in keychain/keystore
- No need to manage cookies across different mobile platforms
- Offline-capable apps benefit from self-contained tokens

**Confidence:** Medium

## Contradictions & Resolutions

| Finding A | Finding B | Resolution |
|-----------|-----------|------------|
| "JWTs are more secure" (jwt-research.md) | "Sessions are more secure" (session-research.md) | Context-dependent: JWTs better for XSS-mitigated SPAs; sessions better when revocation is critical |

## Open Questions

1. What is the expected user concurrency at launch vs. 1 year?
2. Is immediate session revocation a hard requirement?
3. Will there be native mobile apps, or web-only?

## Sources Reviewed

- project.md
- jwt-research.md
- session-research.md
- findings.md
```

### Notes

- Four themes emerged from the research
- One contradiction was identified and contextualized
- Three open questions highlight gaps that need stakeholder input
- Confidence levels reflect evidence strength

---

## Example 2: API Design Research

Consolidating research notes on REST vs. GraphQL API design.

### Input

```bash
/synthesize-research _ops/state/resources/synthesize-research/api-design/
```

### Source Files

```markdown
_ops/state/resources/synthesize-research/api-design/
├── rest-notes.md
├── graphql-notes.md
├── performance-findings.md
└── team-feedback.md
```

### Expected Output

**Path:** `.harmony/output/drafts/api-design-synthesis.md`

```markdown
# Research Synthesis: api-design

**Generated:** 2025-01-14T14:22:00Z
**Source:** _ops/state/resources/synthesize-research/api-design/

## Executive Summary

Research compared REST and GraphQL for the platform API. REST offers simplicity and better caching, while GraphQL provides flexibility for varied client needs. Team has more REST experience, but GraphQL's type system appeals to frontend developers. Recommendation: Start with REST for v1, evaluate GraphQL for v2 based on client diversity.

## Key Themes

### Theme 1: Developer Experience

**Insight:** GraphQL offers better DX for frontend developers; REST is simpler for backend developers.

**Evidence:**
- GraphQL's type system provides auto-completion and documentation
- Frontend team prefers single endpoint with flexible queries
- Backend team is more familiar with REST patterns and tooling

**Confidence:** High

### Theme 2: Performance Characteristics

**Insight:** REST has better caching; GraphQL reduces over-fetching but has complexity overhead.

**Evidence:**
- REST endpoints can leverage HTTP caching headers effectively
- GraphQL queries are POST requests, harder to cache at HTTP layer
- GraphQL eliminates multiple round-trips for complex data needs
- Performance-findings.md shows 30% fewer requests with GraphQL for dashboard page

**Confidence:** High

### Theme 3: Versioning and Evolution

**Insight:** GraphQL handles schema evolution more gracefully than REST versioning.

**Evidence:**
- REST requires URL versioning or header-based versioning
- GraphQL schema can evolve with deprecation annotations
- Breaking changes are explicit in GraphQL schema

**Confidence:** Medium

## Contradictions & Resolutions

| Finding A | Finding B | Resolution |
|-----------|-----------|------------|
| "GraphQL is always faster" (graphql-notes.md) | "REST with proper caching outperforms GraphQL" (performance-findings.md) | Both true in different contexts: GraphQL faster for complex queries; REST faster for cacheable resources |

## Open Questions

1. How diverse will our client ecosystem be? (web, mobile, third-party)
2. What's the team's appetite for learning GraphQL?
3. Do we need real-time subscriptions?

## Sources Reviewed

- rest-notes.md
- graphql-notes.md
- performance-findings.md
- team-feedback.md
```

### Notes

- Three themes emerged from four source files
- One contradiction resolved with context
- Questions guide next steps in decision-making

---

## Example 3: Minimal Input (Edge Case)

Handling a folder with minimal research content.

### Input

```bash
/synthesize-research _ops/state/resources/synthesize-research/quick-notes/
```

### Source Files

```markdown
_ops/state/resources/synthesize-research/quick-notes/
└── notes.md  # Single file with brief notes
```

### Expected Output

**Path:** `.harmony/output/drafts/quick-notes-synthesis.md`

```markdown
# Research Synthesis: quick-notes

**Generated:** 2025-01-15T09:00:00Z
**Source:** _ops/state/resources/synthesize-research/quick-notes/

## Executive Summary

Limited research material available. Single source file contains preliminary observations on caching strategies. Findings are tentative and require additional research to validate.

## Key Themes

### Theme 1: Caching Approaches

**Insight:** Redis and Memcached are the primary candidates for distributed caching.

**Evidence:**
- Notes mention both as common choices
- No performance comparison data available

**Confidence:** Low

### Theme 2: Cache Invalidation

**Insight:** Cache invalidation is identified as a key challenge.

**Evidence:**
- Notes reference "hardest problem in computer science" quote
- No specific strategies documented

**Confidence:** Low

## Contradictions & Resolutions

None identified.

## Open Questions

1. What are the specific performance requirements?
2. What is the expected cache hit ratio?
3. How will cache invalidation be handled?
4. What is the data consistency requirement?

## Sources Reviewed

- notes.md
```

### Notes

- Only two themes could be identified from limited material
- Confidence is appropriately low throughout
- Open questions highlight significant research gaps
- Synthesis is honest about limitations
