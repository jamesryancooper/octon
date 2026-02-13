---
title: Deny by Default
description: Agents and systems have no permissions until explicitly granted. Security through explicit allowlists, not blocklists.
pillar: Trust
status: Active
---

# Deny by Default

> Agents and systems have no permissions until explicitly granted. Start with zero access; add only what's needed.

## What This Means

Deny by default is a security principle: rather than allowing everything and blocking specific threats (blocklist), allow nothing and explicitly permit specific actions (allowlist).

In Harmony, this applies especially to AI agents:
- Agents cannot access tools until granted
- Agents cannot write files outside designated paths
- Agents cannot perform destructive actions without explicit permission
- Skills operate within bounded capability sets

This is the principle of least privilege applied systematically.

## Why It Matters

### Pillar Alignment: Trust through Governed Determinism

The Trust pillar promises "agents are bounded, security is enforced." Deny by default delivers this by:

- **Limiting blast radius**: Misbehaving agents can only affect what they're permitted to affect
- **Enabling audit**: All permitted actions are explicitly listed and traceable
- **Preventing accidents**: Dangerous operations require conscious enablement

### Defense in Depth

Deny by default works with other security layers:

```
Layer 1: Deny by default (agent can't even try)
Layer 2: Validation (input is checked if permitted)
Layer 3: Sandboxing (execution is isolated)
Layer 4: Audit (all actions are logged)
```

If any layer fails, the others provide protection.

### The Agent Safety Problem

AI agents can be surprisingly creative in achieving goals. Without explicit boundaries:
- An agent asked to "clean up the codebase" might delete important files
- An agent asked to "improve performance" might remove safety checks
- An agent given shell access might run dangerous commands

Deny by default ensures agents operate within intended boundaries regardless of how goals are interpreted.

## In Practice

### The Three-Tier Permission Model

Harmony skills operate under a three-tier permission model:

| Tier | Description | Example |
|------|-------------|---------|
| Allowed | Explicitly permitted actions | Write to `.harmony/capabilities/skills/outputs/` |
| Requires Approval | Permitted with human confirmation | Modify source files |
| Denied | Never permitted | Delete files, access secrets, network calls |

### ✅ Do

**Define explicit output paths:**

```yaml
# .harmony/capabilities/skills/registry.yml
skills:
  - id: code-analyzer
    outputs:
      allowed:
        - .harmony/capabilities/skills/outputs/code-analyzer/**
      requires_approval:
        - src/**/*.ts  # Can suggest edits, human approves
      denied:
        - .env*
        - secrets/**
        - node_modules/**
```

**Validate paths before operations:**

```typescript
// Good: Explicit path validation
function validateOutputPath(path: string, allowedPaths: string[]): boolean {
  const resolved = resolve(path);
  return allowedPaths.some(allowed => 
    resolved.startsWith(resolve(allowed))
  );
}

async function writeOutput(path: string, content: string) {
  if (!validateOutputPath(path, skill.outputs.allowed)) {
    throw new SecurityError(`Path not in allowed list: ${path}`);
  }
  await fs.writeFile(path, content);
}
```

**Use capability-based tool access:**

```yaml
# skill definition
tools:
  allowed:
    - read_file
    - write_output
    - grep
  denied:
    - shell          # Too broad
    - delete_file    # Destructive
    - network_fetch  # External access
```

**Log all permission checks:**

```typescript
// Good: Audit trail for permission decisions
function checkPermission(action: string, resource: string): boolean {
  const allowed = policy.isAllowed(action, resource);
  
  audit.log({
    timestamp: Date.now(),
    action,
    resource,
    allowed,
    skill_id: currentSkill.id,
    trace_id: context.traceId
  });
  
  return allowed;
}
```

**Fail closed on ambiguity:**

```typescript
// Good: Deny when uncertain
function resolvePermission(action: string): Permission {
  const explicit = policy.getExplicit(action);
  
  if (explicit === undefined) {
    // No explicit permission = denied
    return Permission.DENIED;
  }
  
  return explicit;
}
```

### ❌ Don't

**Don't use blocklists for security:**

```yaml
# Bad: Blocklist approach (will miss threats)
tools:
  blocked:
    - rm
    - delete
    - drop
  # Everything else allowed — dangerous!

# Good: Allowlist approach
tools:
  allowed:
    - read
    - write_output
    - search
  # Everything else denied by default
```

**Don't grant broad permissions:**

```yaml
# Bad: Overly permissive
outputs:
  allowed:
    - "**/*"  # Can write anywhere!

# Good: Specific, minimal permissions
outputs:
  allowed:
    - .harmony/capabilities/skills/outputs/this-skill/**
```

**Don't trust agent-provided paths:**

```typescript
// Bad: Agent controls path
async function saveResult(agentProvidedPath: string, content: string) {
  await fs.writeFile(agentProvidedPath, content);  // Path injection!
}

// Good: Agent provides key, system controls path
async function saveResult(resultKey: string, content: string) {
  const safePath = join(OUTPUTS_DIR, sanitize(resultKey));
  await fs.writeFile(safePath, content);
}
```

**Don't fail open:**

```typescript
// Bad: Fail open
async function executeAction(action: Action) {
  try {
    const allowed = await checkPermission(action);
    if (!allowed) throw new Error('Denied');
  } catch (e) {
    // Permission check failed, proceed anyway — dangerous!
    console.warn('Permission check failed, allowing');
  }
  await action.execute();
}

// Good: Fail closed
async function executeAction(action: Action) {
  let allowed = false;
  try {
    allowed = await checkPermission(action);
  } catch (e) {
    // Permission check failed = denied
    audit.log({ action, error: e, decision: 'denied' });
    throw new SecurityError('Permission check failed');
  }
  
  if (!allowed) {
    throw new SecurityError('Action not permitted');
  }
  
  await action.execute();
}
```

## Implementation Patterns

### Skill Permission Schema

```yaml
# SKILL.md frontmatter
permissions:
  files:
    read:
      - src/**/*.ts
      - docs/**/*.md
    write:
      - .harmony/capabilities/skills/outputs/{{skill_id}}/**
    deny:
      - .env*
      - secrets/**
      - "**/*.key"
  
  tools:
    allowed:
      - read_file
      - write_output
      - grep
      - glob
    requires_approval:
      - edit_file
    denied:
      - shell
      - delete
      - network
  
  resources:
    cpu_seconds: 60
    memory_mb: 512
    output_size_mb: 10
```

### Hierarchical Scope Validation

```typescript
// Harness hierarchy determines write permissions
function canWrite(harness: Harness, targetPath: string): boolean {
  const target = resolve(targetPath);
  const harnessRoot = resolve(harness.path);

  // Can write within own harness
  if (target.startsWith(harnessRoot)) {
    return true;
  }

  // Can write to descendant harnesses
  if (isDescendant(harness, targetPath)) {
    return true;
  }
  
  // Cannot write to ancestors or siblings
  return false;
}
```

### Human-in-the-Loop for Elevated Permissions

```typescript
async function executeWithApproval(action: Action): Promise<void> {
  const permission = policy.getPermission(action);
  
  switch (permission) {
    case 'allowed':
      await action.execute();
      break;
      
    case 'requires_approval':
      const approved = await requestHumanApproval({
        action: action.describe(),
        risk: action.riskLevel,
        reversible: action.isReversible
      });
      
      if (approved) {
        await action.execute();
      } else {
        throw new Error('Human denied action');
      }
      break;
      
    case 'denied':
    default:
      throw new SecurityError('Action not permitted');
  }
}
```

### Sandbox Enforcement

```typescript
// Runtime sandbox for skill execution
const sandbox = createSandbox({
  filesystem: {
    read: skill.permissions.files.read,
    write: skill.permissions.files.write,
    // Everything else blocked at syscall level
  },
  network: false,  // No network by default
  subprocess: false,  // No shell by default
  resourceLimits: skill.permissions.resources
});

await sandbox.execute(skill.entrypoint);
```

## Relationship to Other Principles

| Principle | Relationship |
|-----------|--------------|
| Locality | Scope boundaries naturally limit permissions |
| HITL Checkpoints | Elevated permissions require human approval |
| Reversibility | Even permitted actions should be reversible |
| Determinism | Predictable permission decisions |

## Exceptions

Broader permissions may be granted when:

- **Interactive sessions**: Human is actively reviewing agent actions
- **Trusted automation**: Well-tested, versioned automation pipelines
- **Recovery operations**: Incident response may need elevated access

For these cases:
1. Require explicit opt-in per session
2. Log all elevated actions
3. Time-box elevated permissions
4. Review audit logs post-session

## Anti-Pattern: Implicit Trust

The primary failure mode of ignoring deny-by-default is **implicit trust** — assuming agents will behave well without enforcement.

Signs of implicit trust:
- "The agent knows not to delete important files"
- Broad `**/*` permissions in configurations
- No permission checks in skill implementations
- Missing audit logs for agent actions

Prevention:
- Start with zero permissions, add explicitly
- Validate every path and action
- Log every permission decision
- Review agent audit trails regularly

## Related Documentation

- [Trust Pillar](../pillars/trust.md) — Bounded agents, enforced security
- [HITL Checkpoints](./hitl-checkpoints.md) — Human approval for elevated actions
- [Skills Specification](../architecture/harness/skills/specification.md) — Permission model details
- [Agentic Principles](../principles.md#agentic-principles) — Full agent governance model
