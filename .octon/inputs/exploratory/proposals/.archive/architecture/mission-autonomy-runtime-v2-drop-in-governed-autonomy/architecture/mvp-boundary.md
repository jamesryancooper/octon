# MVP Boundary

## In scope

- One active Engagement.
- One active Mission per Engagement.
- One active Work Package.
- One active Autonomy Window.
- One active run at a time.
- Mission Queue.
- Action Slices.
- Continuation Decisions.
- Mission Run Ledger.
- Mission-aware Decision Requests.
- Budget enforcement.
- Circuit-breaker enforcement.
- Lease enforcement.
- Mission-level closeout.
- Repo-local governed runs.
- Stage-only connector admission hooks only; live connector admission is blocked in v2 MVP.

## Out of scope

- Multiple concurrent missions.
- Broad MCP marketplace.
- Arbitrary effectful API connectors.
- Browser-driving autonomy.
- Deployment automation.
- Credential provisioning.
- Multi-repo autonomy.
- Autonomous governance amendments.
- Destructive irreversible external operations.
- Fully unattended unconstrained long-horizon mission running.

## Success statement

v2 MVP succeeds when Octon can take a v1 Work Package, open a bounded mission, execute multiple repo-local governed runs one at a time through existing run lifecycle/authorization paths, emit Continuation Decisions, pause/escalate when gates fail, and close the mission with retained evidence and continuity.
