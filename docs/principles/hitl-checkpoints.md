---
title: Human-in-the-Loop Checkpoints
description: Agents propose, humans approve. Material changes require human review before taking effect.
pillar: Trust, Direction
status: Active
---

# Human-in-the-Loop Checkpoints

> Agents propose, humans approve. Material changes require human review before taking effect.

## What This Means

Human-in-the-Loop (HITL) is a governance principle: AI agents can analyze, plan, draft, and suggest, but humans make final decisions on material changes. This creates a collaborative model where:

- Agents handle the cognitive heavy lifting
- Humans provide judgment, context, and approval
- Neither operates entirely autonomously on consequential decisions

The standard loop is: **Plan → Diff → Explain → Test → Human Approval → Apply**

## Why It Matters

### Pillar Alignment: Trust through Governed Determinism

The Trust pillar promises "agents are bounded" and "mistakes are reversible." HITL checkpoints ensure:

- **Bounded agents**: Agents cannot make material changes without approval
- **Transparency**: Humans see what will change before it happens
- **Accountability**: A human approved each consequential action
- **Recoverability**: Humans can catch mistakes before they're applied

### Pillar Alignment: Direction through Validated Discovery

The Direction pillar ensures "every feature is validated before investment." HITL extends this to agent work:

- Agent proposals are validated before execution
- Human judgment filters out misaligned suggestions
- The feedback loop teaches agents what humans value

### The Autonomy Spectrum

Not all agent actions require the same level of oversight:

| Autonomy Level | Human Involvement | Example |
|---------------|-------------------|---------|
| Full autonomy | None | Read files, search code |
| Notify | Informed after | Log entries, status updates |
| Soft checkpoint | Can interrupt | Long-running analysis |
| Hard checkpoint | Must approve | File edits, commits, deploys |
| Prohibited | Cannot do | Delete files, push to main |

HITL checkpoints typically apply to "hard checkpoint" actions.

## In Practice

### The Standard Agent Loop

```
1. PLAN    Agent analyzes task, proposes approach
              ↓
2. DIFF    Agent shows exactly what will change
              ↓
3. EXPLAIN Agent explains why these changes
              ↓
4. TEST    Agent runs tests, shows results
              ↓
5. REVIEW  Human reviews plan, diff, explanation, tests
              ↓
6. APPROVE Human approves or requests changes
              ↓
7. APPLY   Agent applies approved changes
```

### ✅ Do

**Show diffs before applying:**

```typescript
// Good: Preview before action
async function editFile(path: string, changes: Change[]) {
  const diff = generateDiff(path, changes);
  
  const approved = await requestApproval({
    type: 'file_edit',
    path,
    diff,
    explanation: describeChanges(changes)
  });
  
  if (approved) {
    await applyChanges(path, changes);
  }
}
```

**Explain the reasoning:**

```markdown
## Proposed Changes

### What
- Add input validation to `createUser` function
- Add error handling for invalid email format

### Why
- Current code accepts any string as email
- This could cause downstream failures in email service
- Validation at boundary prevents invalid data propagation

### Diff
```diff
+ import { isValidEmail } from './validation';
+
  function createUser(email: string) {
+   if (!isValidEmail(email)) {
+     throw new ValidationError('Invalid email format');
+   }
    // ...
  }
```

### Tests
- ✅ Valid email accepted
- ✅ Invalid email rejected with clear error
- ✅ Existing tests still pass
```

**Batch related changes:**

```typescript
// Good: Group related changes for single approval
const changeset = {
  description: 'Add user validation',
  changes: [
    { file: 'src/validation.ts', action: 'create', content: '...' },
    { file: 'src/user.ts', action: 'edit', diff: '...' },
    { file: 'src/user.test.ts', action: 'edit', diff: '...' }
  ],
  tests: { passed: 5, failed: 0 }
};

await requestApproval(changeset);
```

**Respect protected resources:**

```yaml
# Agent policy
protected_resources:
  branches:
    - main
    - production
  files:
    - .env*
    - secrets/**
    - CODEOWNERS
  actions:
    - force_push
    - delete_branch
    - modify_ci
```

```typescript
// Good: Hard stop on protected resources
async function gitPush(branch: string) {
  if (PROTECTED_BRANCHES.includes(branch)) {
    throw new PolicyError(
      `Cannot push to protected branch: ${branch}. ` +
      `Please create a PR for human review.`
    );
  }
  await git.push(branch);
}
```

**Create PRs, don't merge them:**

```typescript
// Good: Agent creates PR, human merges
async function submitChanges(changes: Changeset) {
  const branch = `agent/${changes.id}`;
  
  await git.checkout('-b', branch);
  await applyChanges(changes);
  await git.commit(changes.message);
  await git.push('-u', 'origin', branch);
  
  const pr = await github.createPullRequest({
    title: changes.title,
    body: formatPRBody(changes),
    head: branch,
    base: 'main',
    draft: true  // Explicit: not ready to merge
  });
  
  return { pr, message: 'PR created for review' };
  // Human reviews and merges
}
```

### ❌ Don't

**Don't self-approve:**

```typescript
// Bad: Agent approves its own changes
await git.commit('Fix bug');
await git.push('main');  // Direct push without review

// Bad: Agent merges its own PR
await github.mergePullRequest(pr.number);
```

**Don't hide the full scope:**

```typescript
// Bad: Partial diff
await requestApproval({
  summary: 'Minor refactor',
  // Hides that 50 files are changing!
});

// Good: Full transparency
await requestApproval({
  summary: 'Refactor validation layer',
  filesChanged: 50,
  linesAdded: 1200,
  linesRemoved: 800,
  fullDiff: diff  // Complete diff available
});
```

**Don't bypass with batching tricks:**

```typescript
// Bad: Split to avoid scrutiny
for (const change of dangerousChanges) {
  await requestApproval(change);  // Each looks small
}

// Good: Show the full picture
await requestApproval({
  changes: dangerousChanges,
  totalImpact: summarizeImpact(dangerousChanges)
});
```

**Don't push to protected branches:**

```typescript
// Bad: Direct push
await git.push('main');
await git.push('production');

// Good: PR workflow
await createPullRequest({ base: 'main', ... });
```

## Implementation Patterns

### Approval Request Schema

```typescript
interface ApprovalRequest {
  // Identity
  id: string;
  skill_id: string;
  trace_id: string;
  
  // What
  action_type: 'file_edit' | 'file_create' | 'commit' | 'pr' | 'deploy';
  resources: string[];
  diff?: string;
  
  // Why
  explanation: string;
  reasoning?: string;
  
  // Evidence
  tests?: { passed: number; failed: number; };
  lint?: { errors: number; warnings: number; };
  
  // Risk
  risk_level: 'low' | 'medium' | 'high';
  reversible: boolean;
  
  // Timeout
  expires_at?: string;
}
```

### Checkpoint Placement

```
Task Start
    │
    ├── Read files ──────────── No checkpoint (read-only)
    ├── Search code ─────────── No checkpoint (read-only)
    ├── Analyze ─────────────── No checkpoint (internal)
    │
    ├── Generate plan ───────── Soft checkpoint (can interrupt)
    │
    ├── Proposed edits ──────── HARD CHECKPOINT (must approve)
    ├── Run tests ───────────── No checkpoint (verification)
    │
    ├── Apply edits ─────────── HARD CHECKPOINT (after tests)
    ├── Commit ──────────────── HARD CHECKPOINT
    ├── Create PR ───────────── HARD CHECKPOINT
    │
    └── Merge PR ────────────── PROHIBITED (human only)
```

### Async Approval Flow

For long-running or batch operations:

```typescript
async function batchProcess(items: Item[]) {
  // Phase 1: Plan all changes
  const plans = await Promise.all(
    items.map(item => agent.plan(item))
  );
  
  // Phase 2: Request batch approval
  const approval = await requestBatchApproval({
    plans,
    totalChanges: plans.flatMap(p => p.changes),
    estimatedTime: calculateTime(plans)
  });
  
  if (!approval.approved) {
    return { status: 'rejected', reason: approval.reason };
  }
  
  // Phase 3: Execute approved plans
  for (const plan of plans) {
    await agent.execute(plan);
    await notifyProgress(plan);
  }
  
  return { status: 'completed' };
}
```

### Emergency Override

For incident response, elevated permissions with audit:

```typescript
async function emergencyFix(fix: Fix, justification: string) {
  // Requires explicit emergency flag
  if (!context.emergencyMode) {
    throw new Error('Emergency mode not enabled');
  }
  
  // Full audit trail
  await audit.log({
    type: 'emergency_override',
    fix,
    justification,
    approver: context.humanApprover,
    timestamp: Date.now()
  });
  
  // Apply with enhanced logging
  await applyWithAudit(fix);
  
  // Require post-incident review
  await createPostIncidentReview(fix);
}
```

## Relationship to Other Principles

| Principle | Relationship |
|-----------|--------------|
| Deny by Default | HITL is the approval mechanism for elevated permissions |
| Reversibility | Even approved changes should be reversible |
| Determinism | Approval decisions are logged and traceable |
| No Silent Apply | HITL enforces the "no silent apply" agentic principle |

## Calibrating Checkpoint Sensitivity

### Too Many Checkpoints
Signs:
- Approval fatigue leads to rubber-stamping
- Workflow is slower than manual work
- Low-risk actions require approval

Fix: Reduce checkpoint scope to material changes only.

### Too Few Checkpoints
Signs:
- Unexpected changes appear in codebase
- "How did this get merged?"
- Agents make consequential decisions alone

Fix: Add checkpoints for all material changes.

### Right Balance
- Read operations: No checkpoint
- Analysis and planning: Soft checkpoint (interruptible)
- File modifications: Hard checkpoint
- Commits and PRs: Hard checkpoint
- Merges and deploys: Human only

## Related Documentation

- [Trust Pillar](../pillars/trust.md) — Bounded agents, human oversight
- [Direction Pillar](../pillars/direction.md) — Validated decisions
- [Deny by Default](./deny-by-default.md) — Permission elevation
- [Agentic Principles](../principles.md#agentic-principles) — Full agent governance model
- [No Silent Apply](./agentic/no-silent-apply.md) — Plan-diff-explain-test loop
