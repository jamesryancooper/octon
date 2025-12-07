# GuardKit

Comprehensive AI output protection for the Harmony methodology. GuardKit validates AI-generated content before it's accepted, protecting against prompt injection, hallucinations, secret exposure, and unsafe code patterns.

## Interfaces

GuardKit provides three interfaces:

| Interface | Consumers | Use For |
|-----------|-----------|---------|
| **Programmatic API** (primary) | AI agents, services | Production traffic, automated checks |
| **HTTP Runner** | Python agents, microservices | Cross-language, distributed systems |
| **CLI** | Humans, CI/CD | Debugging, scripts, simple integrations |

## Programmatic API (Primary)

The programmatic API is the **source of truth** for GuardKit functionality.

### Quick Start

```typescript
import { GuardKit } from '@harmony/guardkit';

const guard = new GuardKit({
  projectRoot: process.cwd(),
  packageJson: require('./package.json'),
});

// Full guardrail check
const result = guard.check(aiOutput);

if (result.safe) {
  console.log('All checks passed');
} else {
  console.log('Issues found:', result.checks.filter(c => !c.passed));
}
```

### Configuration

```typescript
interface GuardKitConfig {
  /** Project root for file verification */
  projectRoot?: string;

  /** package.json content for import verification */
  packageJson?: Record<string, unknown>;

  /** Known files in the project */
  knownFiles?: string[];

  /** Known exports/functions in the project */
  knownExports?: string[];

  /** Enable prompt injection checks (default: true) */
  checkInjection?: boolean;

  /** Enable hallucination detection (default: true) */
  checkHallucinations?: boolean;

  /** Enable secret detection (default: true) */
  checkSecrets?: boolean;

  /** Enable PII detection (default: true) */
  checkPii?: boolean;

  /** Enable code safety checks (default: true) */
  checkCodeSafety?: boolean;

  /** Severity threshold for blocking: 'critical' | 'high' | 'medium' | 'low' */
  blockThreshold?: Severity;

  /** Enable run record generation (default: true) */
  enableRunRecords?: boolean;

  /** Directory to write run records */
  runsDir?: string;
}
```

### Methods

#### `check(content: string): GuardrailResult`

Run all enabled guardrail checks on content.

```typescript
const result = guard.check(aiOutput);

// Result structure
interface GuardrailResult {
  safe: boolean;           // No issues at or above threshold
  canProceed: boolean;     // No critical/high issues
  totalChecks: number;
  passedChecks: number;
  checks: GuardrailCheckResult[];
  summary: { critical: number; high: number; medium: number; low: number; info: number };
  timestamp: string;
}
```

#### `quickCheck(content: string): { safe: boolean; reason?: string }`

Fast preliminary check (less thorough, good for filtering):

```typescript
const quick = guard.quickCheck(input);
if (!quick.safe) {
  console.log('Blocked:', quick.reason);
}
```

#### `sanitizeInput(input: string, options?: SanitizeOptions): SanitizeResult`

Sanitize user input before including in prompts:

```typescript
const sanitized = guard.sanitizeInput(userInput, {
  escapeHtml: true,
  removeInjection: true,
  redactSecrets: true,
  maxLength: 10000,
});
```

#### `verifyImports(code: string): string[]`

Check if all imports exist in package.json:

```typescript
const missing = guard.verifyImports(generatedCode);
if (missing.length > 0) {
  console.log('Unknown packages:', missing);
}
```

#### `detectHallucinations(content: string): HallucinationCheckResult`

Detailed hallucination analysis:

```typescript
const hallucinations = guard.detectHallucinations(code);
if (hallucinations.detected) {
  console.log('Confidence:', hallucinations.confidence);
  console.log('Issues:', hallucinations.issues);
}
```

## HTTP Interface (Cross-Language)

For Python agents, microservices, or distributed systems:

```typescript
import { createHttpGuardRunner } from '@harmony/guardkit';

const guard = createHttpGuardRunner({
  baseUrl: 'http://guardkit-service:8081',
  timeoutMs: 30000,
  headers: { 'X-API-Key': process.env.GUARDKIT_API_KEY },
});

// Same interface as programmatic API
const result = await guard.check('AI content', {
  checkInjection: true,
  checkSecrets: true,
});

const sanitized = await guard.sanitize('User input');
const quick = await guard.quickCheck('Content');
```

### HTTP Protocol

The HTTP runner expects a service implementing:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/guard/check` | POST | Run full guardrail check |
| `/guard/sanitize` | POST | Sanitize content |
| `/guard/quick-check` | POST | Fast safety check |

## CLI (Debugging and CI/CD)

The CLI is a **thin wrapper** around the programmatic API for human debugging and CI/CD.

```bash
# Run full guardrail check on content
guardkit check "AI generated content to check"
guardkit check --file output.ts

# Sanitize user input
guardkit sanitize "User input with potential issues"

# Fast preliminary check
guardkit quick-check "Content to verify"

# Dry-run mode (default in local)
guardkit check --dry-run "Content"

# JSON output (matches programmatic API response structure)
guardkit check --format json "Content"

# With risk tier and stage
guardkit check --risk T3 --stage verify "Content"
```

### CLI Commands

| Command | Description |
|---------|-------------|
| `check` | Run all guardrail checks on content |
| `sanitize` | Sanitize content for safe use in prompts |
| `quick-check` | Fast safety check (less thorough) |

### CLI Options

| Option | Description |
|--------|-------------|
| `--file, -F` | Read content from file |
| `--project-root` | Project root for import verification |
| `--threshold` | Block threshold: critical\|high\|medium\|low |

Plus all [standard kit flags](../README.md#standard-cli-flags).

## What It Protects Against

### 1. Prompt Injection (Critical)

Detects attempts to manipulate AI behavior:

| Pattern | Severity | Description |
|---------|----------|-------------|
| `ignore_instructions` | Critical | "Ignore all previous instructions" |
| `jailbreak_attempt` | Critical | "You are now DAN" patterns |
| `system_prompt_leak` | High | Attempts to reveal system prompts |
| `command_injection` | High | Shell command patterns |

### 2. Hallucinations (High)

Identifies fake or non-existent code:

| Check | Severity | What It Detects |
|-------|----------|-----------------|
| Unknown imports | High | Packages not in package.json |
| Fake APIs | High | Non-existent browser/Node APIs |
| Suspicious helpers | Medium | Generic `utils/helpers` imports |
| TODO markers | Low | Incomplete code indicators |

### 3. Secret Exposure (Critical)

Catches leaked credentials:

| Pattern | Severity | Examples |
|---------|----------|----------|
| AWS keys | Critical | `AKIA...`, `aws_secret_access_key` |
| GitHub tokens | Critical | `ghp_...`, `github_pat_...` |
| JWT tokens | Critical | `eyJ...` (3-part base64) |
| Private keys | Critical | `-----BEGIN PRIVATE KEY-----` |

### 4. PII Detection (Medium)

Flags personally identifiable information:

| Type | Severity | Pattern |
|------|----------|---------|
| Email addresses | Medium | `user@domain.com` |
| Phone numbers | Medium | US/international formats |
| Social Security Numbers | High | `XXX-XX-XXXX` |
| Credit card numbers | High | 16-digit patterns |

### 5. Code Safety (Critical/High)

Catches dangerous code patterns:

| Pattern | Severity | Risk |
|---------|----------|------|
| `eval()` | Critical | Arbitrary code execution |
| `innerHTML` | High | XSS vulnerability |
| SQL concatenation | Critical | SQL injection |
| `dangerouslySetInnerHTML` | High | React XSS |

## Standalone Utilities

Import individual functions for targeted use:

```typescript
import {
  // Sanitization
  sanitize,
  sanitizeForPrompt,
  sanitizeOutput,
  containsInjection,
  containsSecrets,
  containsPii,

  // Detection
  detectHallucinations,
  checkCodeSafety,
  quickHallucinationCheck,
  verifyImports,

  // Patterns (for custom checks)
  INJECTION_PATTERNS,
  SECRET_PATTERNS,
  PII_PATTERNS,
  CODE_SAFETY_PATTERNS,
  matchesPatterns,
} from '@harmony/guardkit';
```

## Risk Tier Sensitivity

GuardKit adjusts sensitivity based on risk tier:

| Tier | Sensitivity | Use For |
|------|-------------|---------|
| T1 | Low | Trivial changes (typos, comments) |
| T2 | Medium | Standard features (default) |
| T3 | High | Security-sensitive, data, auth |

## Testing

```bash
# Run GuardKit tests
pnpm --filter @harmony/guardkit test
```

## See Also

- [AI Guardrails Guide](/docs/harmony/human/AI-GUARDRAILS.md) - Human-facing guardrails documentation
- [@harmony/kit-base](../kit-base/README.md) - Shared infrastructure
- [Harmony CLI](/packages/harmony-cli) - CLI integration

## License

Private — part of the Harmony monorepo.
