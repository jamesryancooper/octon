---
title: Workspace Assistants
description: Specialized subagents that perform focused tasks for agents or humans.
---

# Workspace Assistants

Assistants are **specialized subagents** within the Harmony multi-agent architecture. They provide focused modularity for complex problems by operating with their own context, skills, and tools to complete scoped tasks assigned by agents or humans.

---

## What is an Assistant?

An assistant is a packaged specialist behavior that:

- Has a **specific mission** (review code, refactor, write docs)
- Accepts **invocation** via @mention or agent delegation
- Produces **structured output** in a defined format
- Operates under **boundaries** and knows when to escalate
- Can **use skills** to complete tasks

Assistants are **stateless subagents**—they inherit context from the calling agent or workspace, complete their focused task, and return results. They assist agents by handling specialized work that benefits from domain focus.

---

## Multi-Agent Hierarchy

Assistants fit into the Harmony multi-agent architecture as specialized subagents:

```
┌─────────────────────────────────────────────────────────────────┐
│  AGENT (Supervisor)                                             │
│  Planner, Builder, Verifier                                     │
│  • High autonomy, persistent state                              │
│  • Reasons, plans, delegates                                    │
│  • Commands missions                                            │
├─────────────────────────────────────────────────────────────────┤
│                    │ delegates to                               │
│                    ▼                                            │
│  ASSISTANT (Specialist Subagent)                                │
│  @reviewer, @refactor, @docs                                    │
│  • Focused autonomy, stateless                                  │
│  • Executes specialized tasks                                   │
│  • Uses skills, escalates to agents                             │
├─────────────────────────────────────────────────────────────────┤
│                    │ uses                                       │
│                    ▼                                            │
│  SKILLS (Capabilities)                                          │
│  refactor, synthesize, create-workspace                         │
│  • Composable I/O units                                         │
│  • Single-session execution                                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Assistants vs Agents

| Characteristic | Agent (Supervisor) | Assistant (Specialist) |
|----------------|-------------------|------------------------|
| **Role** | Supervisor | Subagent |
| **Autonomy** | High — reasons, plans, decides | Focused — executes assigned tasks |
| **Lifecycle** | Persistent across sessions | Stateless (inherits context) |
| **Scope** | Broad — orchestrates complex work | Narrow — scoped operations |
| **State** | Maintains context and memory | No persistent state |
| **Invocation** | Assigned to missions/workspaces | `@mention` or delegation |
| **Delegation** | Delegates **to** assistants | Escalates **to** agents/humans |
| **Skills** | Commands skills via missions | Uses skills directly |
| **Examples** | Planner, Builder, Verifier | Reviewer, Refactor, Docs |

**Key insight:** Agents think about *what* needs to be done and *who* should do it. Assistants focus on *how* to do their specific task well.

```mermaid
graph TB
    subgraph workspace [Workspace]
        human[Human]
        agent[Agent - Planner]
        
        subgraph assistants [Assistants]
            reviewer[Reviewer]
            refactor[Refactor]
            docs[Docs Writer]
        end
    end
    
    human -->|"@reviewer check this"| reviewer
    human -->|"@refactor extract method"| refactor
    agent -->|delegates subtask| reviewer
    agent -->|delegates subtask| refactor
    agent -->|delegates subtask| docs
```

---

## Directory Structure

```text
.harmony/agency/assistants/
├── registry.yml           # @mention mappings
├── README.md              # Usage guide
├── _template/             # Template for new assistants
│   └── assistant.md
├── reviewer/
│   └── assistant.md       # Reviewer spec
├── refactor/
│   └── assistant.md       # Refactor spec
└── docs/
    └── assistant.md       # Docs writer spec
```

---

## Registry Format

The `registry.yml` file maps @mentions to assistant definitions:

```yaml
schema_version: "1.0"
default: null  # Optional default assistant

assistants:
  - name: reviewer
    path: reviewer/
    aliases: ["@review", "@rev"]
    description: "Code review specialist for quality, style, and correctness."
    
  - name: refactor
    path: refactor/
    aliases: ["@refactor", "@ref"]
    description: "Refactoring specialist for code improvements."
```

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Assistant identifier |
| `path` | Yes | Directory containing `assistant.md` |
| `aliases` | Yes | @mention triggers (including primary) |
| `description` | Yes | One-line description |

---

## Assistant Specification Format

Each `assistant.md` follows this structure:

```markdown
---
title: "Assistant: [name]"
description: "[One-line description]"
access: agent
---

# Assistant: [name]

## Mission
[One sentence defining what this assistant does.]

## Invocation
- **Direct:** Human types `@[name] [task]` in chat
- **Delegated:** Agent delegates subtask to this assistant

## Operating Rules
1. [Rule 1]
2. [Rule 2]

## Output Format
[Structured output template]

## Boundaries
- Never [constraint 1]
- Prefer [preference 1]

## When to Escalate
- If [condition], escalate to [agent/human]
```

---

## Invocation Patterns

### Direct Invocation (Human)

User types in chat:
```text
@reviewer Check this PR for security issues
@refactor Extract the validation logic into a helper
@docs Improve the API documentation clarity
```

### Delegated Invocation (Agent)

An agent (e.g., Planner) delegates:
```text
Agent: "Delegating code review to @reviewer"
→ Reviewer assistant executes
→ Returns structured findings to agent
```

---

## @mention Router Spec

The @mention router follows these rules:

**Rule A — Turn-level selection:**
If a user message starts with `@assistant_name`, route the entire turn to that assistant.

**Rule B — Inline delegation:**
If `@assistant_name` appears mid-message, treat it as a subtask delegation.

**Rule C — Locality:**
Nearest `.harmony/agency/assistants/registry.yml` wins. Child workspaces can override parent assistants.

---

## When to Create an Assistant

| Scenario | Create Assistant? | Alternative |
|----------|-------------------|-------------|
| Repeated specialized task | Yes | — |
| Task needs consistent output format | Yes | — |
| Agent should be able to delegate | Yes | — |
| One-off task, no reuse | No | Just do it inline |
| Long-running orchestration | No | Create an Agent role |

---

## Example: Reviewer Assistant

```markdown
---
title: "Assistant: Reviewer"
description: "Code review specialist for quality, style, correctness, and security."
access: agent
---

# Assistant: Reviewer

## Mission
Review code changes for quality, style, correctness, and security issues.

## Invocation
- **Direct:** Human types `@reviewer [task]` or `@rev [task]`
- **Delegated:** Agent delegates review subtask

## Operating Rules
1. Focus on the specific code or changes provided
2. Prioritize issues by severity: security > correctness > style
3. Provide actionable feedback with specific line references
4. Suggest fixes, not just problems

## Output Format
### Review Summary
**Verdict:** [Approve / Request Changes / Needs Discussion]

### Findings
- **Critical:** [severity-tagged findings]
- **Important:** [severity-tagged findings]
- **Minor:** [severity-tagged findings]

### Suggested Patches
[Code blocks with fixes]

## Boundaries
- Never approve code with security vulnerabilities
- Stay within the scope of provided changes

## When to Escalate
- Architectural concerns → escalate to Planner
- Unclear requirements → request human clarification
```

---

## See Also

- [README.md](./README.md) — Canonical workspace structure
- [Missions](./missions.md) — Time-bounded sub-projects
- [Taxonomy](./taxonomy.md) — Artifact type classification
