# Proposed Entry-Artifact Edits

_Status: In-review proposal packet artifact_


## Linked root README opening — companion proposed replacement

This wording is retained for a linked repo-local companion proposal. It is not
an active promotion target in this octon-internal packet.

```markdown
# Octon

**Put agents to work without putting them in charge.**

Octon turns agent-assisted software work into deterministic, governed workflows with authorization, evidence, replay, rollback, and human intervention built in.

Technically, Octon is a **Constitutional Engineering Harness** whose core runtime is best understood as a **Governed Workflow Runtime** for consequential software work. It compiles the execution harness for each admitted workflow and allows agents to participate only as bounded, evidenced activity nodes.
```

## Linked README clarification paragraph

```markdown
Octon does not make agents inherently trustworthy. It makes agent-assisted work more trustworthy by keeping workflow state, authorization, capability admission, context assembly, evidence, rollback, and closeout under deterministic Octon-owned surfaces.
```

## Linked root AGENTS adapter proposed replacement

This wording is retained for a linked repo-local companion proposal.

```markdown
# `.octon` Ingress Adapter

## Behavioral Contract

Enable reliable workflow participation by bounded agents inside Octon-governed execution boundaries. Workflow state owns control flow. Agents do not.

Canonical internal ingress lives at `/.octon/instance/ingress/AGENTS.md`.
```

## `.octon/README.md` proposed addition

```markdown
Octon's core runtime is best understood as a Governed Workflow Runtime: workflow state, run contracts, authorization, evidence, replay, rollback, and closeout own execution control. Agents participate only as bounded, evidenced activity nodes inside admitted execution harnesses.
```

## Ingress proposed addition

```markdown
Before planning or implementation, bind the workflow/run surface first. Agents may summarize, classify, draft, review, repair, or recommend, but they must not own workflow state, authorize effects, mutate control truth, admit connectors, or close work.
```

## Durable coordination note

```markdown
Durable Objects or similar durable coordination systems may be evaluated in future packets as live coordination adapters. They must never become Octon authority, control truth, retained evidence, permission, or closeout truth.
```
