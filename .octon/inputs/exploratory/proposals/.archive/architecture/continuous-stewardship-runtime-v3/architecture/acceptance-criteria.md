# Acceptance Criteria

The proposal is implemented only when all criteria below are met.

## Architecture Criteria

- Stewardship Program, Epoch, Trigger, Admission Decision, Idle Decision,
  Renewal Decision, Stewardship Ledger, Evidence Profile, and
  Stewardship-Aware Decision Request are defined in canonical contracts or
  practice standards.
- Campaign relationship is documented and campaign deferment remains the default.
- Stewardship hierarchy is explicit:
  `Stewardship Program -> Stewardship Epoch -> optional Campaign -> Mission -> Action Slice -> Run Contract -> Governed Run`.

## Runtime Criteria

- `octon steward` CLI surface exists with MVP commands.
- No stewardship command directly executes material work.
- Human-objective and scheduled-review triggers can be normalized.
- Admission Decisions are emitted before handoff to mission surfaces.
- Idle Decisions are emitted when no admissible work exists.
- Renewal Decisions are emitted at epoch close.
- Handoff to v2 Mission Runner is explicit and governed.

## Safety Criteria

- No work occurs outside an active epoch.
- No trigger authorizes work by itself.
- No admission decision authorizes material execution.
- No campaign launches workflows or owns runs.
- No generated projection is consumed as authority.
- No input proposal path is used as runtime or policy source.
- All material execution continues to require v2/run authorization.

## Evidence Criteria

- Program, epoch, trigger, admission, idle, renewal, ledger, mission handoff, and
  closeout evidence roots exist and are populated by the implementation.
- Stewardship Ledger indexes mission/run evidence but does not replace mission or
  run evidence.
- Closure evidence includes rollback/compensation posture, replay/disclosure
  status, continuity updates, and no unresolved blocking Decision Requests.

## MVP Criteria

- One active Stewardship Program per repo/workspace.
- One active epoch per program.
- Scheduled-review and human-objective triggers supported.
- Campaigns remain deferred unless promotion criteria are separately met.
- No infinite agent loop is introduced.
