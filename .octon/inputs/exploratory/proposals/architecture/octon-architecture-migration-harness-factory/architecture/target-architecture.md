# Target Architecture

## Decision

Implement FD-020 by extending the existing task-harness, route, resolver,
context, and lifecycle-executor primitives into one canonical per-run Harness
Factory. Implement only the generic executor-adapter and component-conformance
portion of FD-023. Compilation is a pure non-authoritative transformation;
provider execution remains subordinate to existing authority, mission,
evidence, recovery, and effect owners.

## Canonical Compilation Boundary

The Factory accepts one already-admitted compile request containing exact
identities, immutable refs, digests, and schemas. It performs no repository or
provider effect and cannot infer a grant. Its single output transaction is:

1. validate the compile request and every referenced source;
2. enumerate the closed direct/transitive input graph;
3. apply the declared precedence and narrowing rules;
4. normalize values and paths without reading undeclared ambient state;
5. serialize one effective Harness manifest canonically;
6. emit an ordered source manifest and deterministic compile receipt; and
7. return their exact digests to the existing authorization/launch path.

The compiler fails closed on missing, extra, ambiguous, duplicated, stale,
unversioned, digest-mismatched, schema-invalid, cyclic, or widening sources.
It does not launch, schedule, approve, repair, recover, verify, or publish.

## Complete Input Graph

Every compile contains these families and every transitive source they cite:

| Family | Required binding | Owner consumed |
| --- | --- | --- |
| Project | Workspace Project ID, immutable revision ref/digest, Profile ref/digest, whitelisted fields | RP-10 |
| Mission | Mission identity, charter/control roots, objective/scope, current admitted state | Existing mission owners |
| Run | Run Contract identity/version/digest, one-shot guard/authorization refs, attempt identity | RP-01 and runtime contracts |
| Policy | Exact applicable policy identities, versions/digests, classification and routing results | Existing policy/authority owners |
| Extension | Exact admitted generation, capability declarations, compatibility and source digests | Existing extension owner, later RP-12 hardening |
| Context | Ordered context-pack sources, trust class, truncation/budget outcome, source digests | Existing context owners |
| Model | Generic adapter identity/version/schema/conformance refs and selected model constraints | RP-11 generic seam plus policy owner selection |
| Tool | Exact tool/capability route handles, declared limits, isolation binding | Existing capability routing and RP-02 boundary |
| Validation | Required validators, schemas, acceptance identities, and expected evidence classes | Existing assurance/mission owners |
| Evidence | Evidence profile, destinations, required receipts, retention/capacity bindings | Existing evidence owner |
| Rollback | Rollback posture/ref/digest, cancel/retire expectations, safe-state identifier | Existing recovery owner, later RP-08 specialization |

An input that is inherited, generated, defaulted, or reached through another
record is still represented as an explicit source node with identity, role,
schema version, immutable ref, digest, and parent edge. Optional inputs carry an
explicit absent disposition; absence is itself deterministic and cannot cause
an ambient fallback.

## Precedence and Narrowing

The versioned precedence table is compiled data, not implicit code behavior:

1. constitutional prohibitions and canonical authority/guard decision;
2. Run Contract and admitted mission boundaries;
3. Workspace Project/Profile and candidate-isolation boundaries;
4. applicable policy, support, and capability-route decisions;
5. exact admitted extension generation and provider-adapter constraints;
6. context, tool, validation, evidence, and rollback requirements; and
7. operator-facing/default presentation values that do not affect authority.

Lower layers may only preserve or narrow higher layers. Conflicting identities,
attempted widening, incomparable scopes, or an undeclared default deny compile.
No generated route bundle, effective manifest, receipt, provider response, or
operator-facing setting may outrank its canonical source.

## Canonical Representation

The canonical serializer is schema-versioned and includes:

- UTF-8 with one defined newline convention and no locale-dependent output;
- lexicographically sorted object keys and a schema-declared order for lists;
- normalized repository-relative paths with traversal, alias, symlink, case,
  and external-path rules validated before serialization;
- normalized integer, boolean, enum, duration, and digest encodings;
- explicit `null`/absent semantics only where the schema declares them;
- no map iteration order, wall clock, random value, process ID, hostname,
  current directory, environment default, or provider discovery in digested
  bytes; and
- compiler identity containing implementation version, schema set digest, and
  precedence-table digest.

The effective manifest and ordered source manifest are byte-identical across
two compiles of identical inputs. The compile receipt's identity-bearing body
is deterministic; a separately classified observational envelope may record
time without changing the compiled identity.

## Source Manifest and Compile Receipt

The source manifest records the closed input graph in canonical order:

- run, project, mission, and compile-request identities;
- every source role, canonical path/ref, schema/version, content digest, and
  parent edge;
- optional-absence and narrowing dispositions;
- compiler, normalization, and precedence identities; and
- source-manifest root digest.

The compile receipt binds that root digest to the effective manifest digest,
schema-validation result, compile-request digest, compiler identity, and exact
authorization/guard binding expected at launch. A receipt with an unknown
source, unverified transitive reference, or different compiler identity is not
launchable.

## Selected Encoding, Graph, and Digest Mechanisms

All digested compiler documents use RFC 8785 JCS JSON over UTF-8 NFC strings,
strict schemas, no unknown fields, and SHA-256. Each digest has a fixed domain
prefix `octon:rp11:<document-kind>:v1\0` before the JCS bytes; source-node,
source-graph, effective-manifest, compiler-identity, compile-request, and
receipt-body domains are distinct. Lists whose order is semantically supplied
retain that validated order. Set-like lists sort by their schema-declared key.

The closed source graph is a DAG. Nodes are unique by `(source_role,
canonical_id, immutable_ref, schema_id, schema_version, content_digest)`;
edges are unique by `(parent_node_key, child_node_key, edge_role)`. A Kahn
topological sort selects zero-indegree nodes by precedence rank, source role
enum, canonical ID, immutable ref, and digest. Duplicate keys with different
bytes, cycles, missing parents, undeclared optional absence, or a second valid
ordering deny compilation. Repository paths are root-relative POSIX NFC paths
opened from the canonical root with no-follow traversal; pre/post `fstat`
identity and byte digest must agree. Non-file sources require an immutable
owner ref and exact retained bytes. The compiler reads no source not already
named by the admitted compile request.

The deterministic receipt body binds the compile-request, compiler/schema-set/
precedence, source-graph, effective-manifest, project/mission/run/attempt,
adapter, isolation, and RP-01 guard-template digests. `recorded_at`, host,
process, and observation fields live only in a non-digested evidence envelope.
The mechanisms and dependency digests are recorded in
`resources/harness-compiler-adapter-design-and-dependency-receipt.yml`.

## Authorization and Immediate Spawn Binding

RP-11 adds binding fields and a pre-spawn revalidation call to the existing
RP-01 interface; it does not define authority predicates. The authorization
record binds:

- repository/project/mission/run/attempt identities;
- compiler identity and source-manifest digest;
- effective Harness manifest digest;
- generic adapter identity/version; and
- one-shot guard identity, expiry, and consumption state already owned by
  RP-01.

Immediately before spawning the provider process/session, the launch path
re-resolves no discretionary input. It reads the retained immutable sources,
revalidates their exact digests and adapter declaration, compares the compiled
bytes, and atomically consumes the one-shot guard for that binding. Any change
between compile, authorization, and spawn denies and requires a fresh compile
and authorization. There is no authorized-but-later-recompiled window.

The implementation holds verified no-follow source handles through the final
comparison when the source type permits it; otherwise it reopens only the
exact immutable owner ref and verifies identity plus bytes. Under the RP-01
serialized final-guard transaction it compares every receipt binding and
consumes the one-shot guard. No repository, policy, adapter, environment, or
provider discovery occurs between successful consumption and the same lexical
path's `spawn`. A crash or spawn error after consumption records
`consumed-no-confirmed-spawn`, never reuses the guard, and requires a fresh
attempt. A lost spawn response is `UNKNOWN` and routes to RP-08 reconciliation;
RP-11 does not claim cross-process atomicity or retry the launch.

## Generic Executor Adapter

`lifecycle_executor::adapter` becomes the only provider dispatch seam. A
strict adapter registry resolves an exact adapter identity/version/schema
digest; provider names in user input or a match statement cannot dispatch.
The generic trait exposes six typed operations:

| Operation | Required behavior | Must not do |
| --- | --- | --- |
| `prepare` | Validate exact Harness/authorization binding, provider capability declarations, isolation target, and operation identity; return a non-authoritative prepared handle. | Reclassify, grant, schedule, or mutate canonical inputs. |
| `launch` | Consume the prepared handle exactly once and start the provider operation under the already-consumed one-shot guard. | Recompile, select another adapter, widen scope, or fall back direct. |
| `observe` | Return provider-neutral operation state and immutable provider observation refs. | Declare mission success, verification, publication, or recovery. |
| `cancel` | Request bounded cancellation and report acknowledged, terminal, unknown, or unsupported status truthfully. | Hide an unknown outcome or invent completion. |
| `usage` | Return typed measured/estimated/unsupported dimensions with provenance. | Turn measurement into authority or claim unsupported hard enforcement. |
| `retire` | Release/revoke the adapter-owned prepared/session handle and report residual state. | Delete canonical mission/candidate/evidence data or perform RP-08 recovery. |

Every method is idempotent where observation permits, carries operation and
adapter identity, and produces typed results that canonical owners interpret.
The adapter owns provider protocol translation only. It is not a scheduler,
policy engine, verifier, publisher, evidence authority, recovery controller,
or child runtime.

Every adapter operation carries `(run_id, attempt_id, adapter_id,
adapter_version, prepared_handle_id, operation_id, idempotency_key)`. The
prepared handle is the domain-separated digest of the exact receipt and
adapter declaration, is single-attempt/single-adapter, expires after 60
seconds unless the Run Contract is stricter, and contains no grant. Its
monotonic states are `prepared -> launch-attempting -> running -> terminal ->
retired`; failure before launch is `prepare-failed`, and an unconfirmed launch
is `unknown`, which is terminal for RP-11 retry purposes. Duplicate calls with
the same key return the retained outcome; a different key or parameters for an
existing operation deny. Prepare and launch acknowledgement each have a
30-second ceiling, observe has a 10-second call ceiling, cancel acknowledgement
has 10 seconds, and retire has 30 seconds. A timeout never implies provider
termination. Usage dimensions are monotonic observations with measured,
estimated, or unsupported provenance. Cancel, unknown, and retirement failure
never authorize relaunch, adapter switching, or evidence deletion.

The RP-01 census identifies four current candidate-launch seams: kernel
pipeline, kernel workflow stage, lifecycle provider, and lifecycle workflow
leaf. RP-11 routes their admitted model/host execution through the same strict
registry/trait while RP-01 retains the final consuming guard in each lexical
spawn path. `authorization.rs` runtime admission is a non-candidate control
subprocess and remains outside adapter dispatch. The remaining RP-01 closed-
world utility partition likewise stays governed by its owning effect boundary.
Static fitness fails any candidate spawn lacking both the RP-01 guard and an
RP-11 registry-resolved prepared handle; dynamic tests exercise all four seams.

## Implementation and Specialization Split

- `codex.rs` supplies one real primary-provider implementation for the
  supported primary path.
- `mock.rs` supplies multiple fake conformance fixtures, including success,
  failure, timeout, cancellation race, malformed usage, and retirement
  failure. Fake adapters are tests, never live providers.
- `auto.rs` may resolve an already-admitted adapter identity before registry
  lookup but cannot inspect names and dispatch providers itself.
- `claude.rs` is either removed from live routing or converted to an inactive
  implementation. It cannot be called a live secondary until a separate
  support claim admits it with current proof.
- RP-06 owns verifier/publication translation; RP-08 owns effect/recovery
  translation; RP-13 owns child identity, limits, and provider-child mapping.
  These owners consume the generic seam without redefining it.
- RP-14 independently reproduces integrated authority, mission, evidence,
  effect, recovery, and provider-equivalence outcomes for PO-FD-023 promotion.

## Source-of-Truth and Writer Rules

| Data | Canonical or planned owner | Writer rule |
| --- | --- | --- |
| Input authority/policy/project/mission/run sources | Existing canonical owners and RP dependencies | Unchanged; Factory reads immutable exact refs only |
| Harness/source/receipt schemas and compiler | RP-11 durable contract/code entries | Versioned authored changes through canonical route |
| Effective manifest and source manifest instances | RP-11 deterministic compiler | Rebuildable projection, immutable for an authorized attempt |
| Compile receipt | RP-11 evidence producer | Append/retain through evidence owner; not authority |
| Authorization decision and one-shot guard | RP-01 | RP-11 only supplies/validates bound digests |
| Adapter schemas, registry entry, trait, primary/fake conformance | RP-11 | Exact entries/symbols only |
| Provider observations/usage | Adapter evidence output | Non-authoritative typed records |
| Verifier/publication, effect/recovery, child semantics | RP-06/RP-08/RP-13 | Not written by RP-11 |

Generated effective manifests and route bundles are never promotion authority.
Shared registries are updated only for exact RP-11 entries in the trusted
integration lane.

## Availability and Degraded Operation

If any required source, digest, schema, compiler identity, adapter declaration,
or immediate-spawn binding is unavailable or mismatched, new affected launches
fail closed. Candidate work and immutable inputs remain preserved; unrelated
runs remain available. An unobservable provider outcome is reported as unknown
to the existing reconciler. No legacy direct-provider or second-runtime
fallback exists.

## Unsupported Remainder

This target does not support arbitrary provider plugins, live secondary
providers without separate admission, manual provider/route choice, dynamic
policy creation, speculative input discovery, provider-defined mission
semantics, provider-specific verification/publication/recovery/effect logic,
child delegation, persistent agents, or another scheduler/control plane.
