# Executive Summary

## Verdict

READY_FOR_PROPOSAL_PROGRAM

Octon is ready to create a formal migration proposal program, but it is not
ready for privileged implementation, autonomous Class B publication, or
trust-root automation.

The repository already has a substantial reusable core: typed effects,
canonical authorization validation, lifecycle records, exact-ref publication
checks, provider ruleset guardrails, context packing, extension publication,
hash-linked evidence, and promotion non-authority contracts. A rewrite would
discard valuable work.

Four current facts prevent trustworthy autonomy:

1. lifecycle and child process launch does not consume canonical one-shot
   ExecutorLaunch authority;
2. candidates inherit host user/environment context and share canonical Git
   state;
3. GitHub privileged automation executes candidate code with a write-capable
   token, while required verification is also candidate-controlled; and
4. token/journal/effect state is file-backed and not atomically concurrency or
   crash safe.

Two additional correctness issues require the first proposal packet: scope
matching can widen by reverse prefix, and proof metadata can claim referenced
tests were executed without invoking them.

The smallest safe migration is one local SQLite/WAL store, one local broker,
one structural launch guard, one native credentialless candidate boundary,
one sanitized Git adapter, and one independent exact-SHA verifier. Existing
files become projections; current exact-ref logic moves behind the trusted
boundary; no second control plane is added.

The immediate containment packet must disable candidate-controlled privileged
provider writes and autonomous direct-main, narrow support claims, and complete
physical writer/launch inventories. Until the brokered path is proven, the
bridge is manual/protected PR only.

Six operator decisions remain, but none blocks creation of the proposal
program. They concern provider credential form, signing-key custody, trust-root
inventory, optional remote worker timing, evidence retention budgets, and
advanced CLI disposition. Each can be closed inside its owning packet before
that packet exits design.

