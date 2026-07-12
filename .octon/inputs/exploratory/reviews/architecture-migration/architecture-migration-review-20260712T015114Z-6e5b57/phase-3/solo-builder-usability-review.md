# Solo-Builder Usability Review

## Target experience

The operator should experience:

1. one guided setup that enrolls broker/verifier identities in the OS
   keychain without secret copying;
2. automatic project detection and creation of one minimal Workspace Project;
3. one opinionated inferred Project Profile;
4. a normal prompt that becomes a mission without profile/route/evidence
   questions;
5. automatic isolated candidate execution and Class selection;
6. automatic brokered no-PR Class B publication or automatic PR escalation;
7. concise outcome, source/target, validation, rollback, and any required
   intervention;
8. progressive evidence expansion and a small mission inbox;
9. automatic restart/reconciliation after interruption;
10. doctor and repair commands that describe operator actions, not internal
    state-machine jargon.

## Current friction

- Safe Start requires engagement/profile/plan/arm concepts before ordinary
  execution.
- The public command surface exposes many governance and federation concepts.
- Codex preflight can surface writable user-state database mechanics.
- Project identity is a singleton absolute-path profile.
- Publication route policy considers direct-main first and expects detailed
  closeout artifacts.
- Evidence retention is large and not automatically bounded.
- Broker, credential enrollment, mission inbox, and integrated repair do not
  yet exist.

## Burden budgets and tests

| Budget | Target | Required measurement |
|---|---|---|
| Clean setup | 15 minutes or less | Fresh supported macOS machine, no manual secret copy |
| Repository onboarding | 5 minutes or less | Existing GitHub repo to first safe Class A mission |
| Routine Class A prompts | Zero | Representative edit/test/doc tasks |
| Admitted routine Class B prompts | Zero | Isolated branch to verified no-PR landing |
| Completion output | One concise screen | User study with evidence collapsed |
| Failure recovery | Automatic or one actionable choice | Broker/provider/model/disk/restart matrix |
| Monthly administration | 15 minutes or less | 30-day dogfood including key and retention health |
| Profile selection | None in normal use | Mixed project fixtures with deterministic inference |

## Complexity that should stay invisible

SQLite transactions, evidence outboxes, verifier signatures, revocation
generations, operation attempts, sandbox profiles, Git sanitization, and
checkpoint compaction are essential internals but should not become routine
operator concepts. The inbox should say what happened, what is safe, and what
action is needed.

## Verdict

The migration can meet the solo-builder target if WG-12 treats these budgets
as release gates. Current repository evidence does not prove them.

