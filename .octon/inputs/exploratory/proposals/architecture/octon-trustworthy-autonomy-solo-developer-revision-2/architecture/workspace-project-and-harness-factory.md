# Workspace Project and Governed Harness Factory

## Decision Summary

Workspace Project and Governed Harness Factory are compilation mechanisms, not
authorization mechanisms.

- Workspace Project gives a repository or monorepo durable project identity,
  explicit boundaries, relationships, discovery rules, and a versioned Project
  Profile.
- The Policy Compiler alone classifies effect/risk and intersects governing
  policy, project, support, budget, credential, and host limits into an exact
  Harness Compilation Plan.
- Governed Harness Factory structurally locks source inputs and compiles that
  exact plan, context, validation, rollback, and host controls into one
  immutable Effective Harness Manifest without policy discretion.
- The Policy Compiler verifies plan conformance and seals a Compiled
  Authorization Input; the canonical authority engine receives it and the
  exact manifest digest. Only that engine may issue a GrantBundle and sign a
  typed capability issuance request; only capability-ledger `register_issue`
  may expose the registered effect reference.
- The launch broker and effect broker submit those capabilities to the
  capability ledger, validate its authenticated reservation lease, and request
  ledger-owned consume/outbox transitions; the evidence store independently
  commits attempt start before adapter invocation.

Neither a Project, Profile, compiled manifest, context pack, support tuple,
mission, delegation contract, or Run Contract mints authority.

## Workspace Project

### Purpose

A Workspace Project is the durable identity and boundary description for one
logical engineering project inside a repository. It solves the singleton
Project Profile limitation without creating nested Octon control planes.

It provides:

- stable identity independent of filesystem location;
- explicit owned roots, exclusions, and nested-project relationships;
- deterministic project discovery and selection;
- versioned project facts and freshness;
- monorepo and cross-project dependency behavior;
- inputs for policy, context, validation, sandbox, and harness compilation.

### Canonical Placement

Recommended authored configuration:

~~~text
.octon/instance/locality/projects/
  registry.yml
  <project-storage-key>/
    project.yml
    revisions/
      <revision>.yml
    profiles/
      <revision>.yml
~~~

The registry maps each logical `project_id` URI to a path-safe,
case-normalized opaque `project_storage_key` (for example a base32 digest).
The storage key contains no `/`, `\`, `:`, dot-segment, or platform-reserved
name and is the only identifier interpolated into local paths. `project.yml`
is a small active-pointer document containing `project_id`,
`project_storage_key`,
`active_revision`, `active_revision_ref`, `active_revision_digest`,
`active_profile_revision`, `active_profile_ref`,
`active_profile_digest`, and lifecycle
status. The boundary/relationship document shown below is stored at
`revisions/<revision>.yml` and is immutable after publication. Updating the
active pointer and registry is one brokered transaction; it never rewrites or
deletes a revision still referenced by a run, receipt, or retention rule.

Recommended retained facts:

~~~text
.octon/state/evidence/project-profiles/
  <project-storage-key>/
    <revision>/
      source-facts.yml
      discovery-receipt.yml
      repair-receipt.yml
~~~

Optional generated operator views remain under generated/cognition and are
derived-only.

### Target Schema

~~~yaml
schema_version: workspace-project-v1
project_id: project://<repository-id>/<opaque-project-id>
project_storage_key: <path-safe-opaque-key>
revision: 3
predecessor_revision_ref: .octon/instance/locality/projects/<project-storage-key>/revisions/2.yml
predecessor_revision_digest: sha256:<digest>
display_name: api

repository:
  repository_id: repo://<provider-or-local-stable-id>
  repository_lineage_id: repo-lineage://<opaque-lineage-id>
  identity_source: provider-node-id
  canonical_remote_identity: github://<provider-repository-node-id>
  local_adoption_ref: null
  repository_root_marker_ref: .git
  repository_root_marker_digest: sha256:<digest>

boundaries:
  roots:
    - packages/api
  excludes:
    - packages/api/generated/vendor
  path_format: normalized-repo-relative-posix
  overlap_policy: explicit-nesting-deepest-root-wins
  write_ownership: exclusive
  external_paths: forbidden
  canonical_control_roots:
    - .octon/instance
    - .octon/state
  boundary_revision_digest: sha256:<digest>

relationships:
  monorepo_id: monorepo://<repository-id>
  parent_project_id: project://<repository-id>/<parent-id>
  dependencies:
    - project_id: project://<repository-id>/<dependency-id>
      access: read_only
      version_binding: exact-revision

discovery:
  markers:
    - packages/api/Cargo.toml
  selection_priority: 100
  cwd_selection_allowed: true

authority_boundary:
  authorizes_execution: false
  mints_grants: false
  mints_capabilities: false
  widens_scope: false
  requires_authority_engine_intersection: true

published_at: <rfc3339>
~~~

The production JSON Schema should set additionalProperties to false for every
security-relevant object. Explicit extension fields may be admitted through a
versioned namespaced extensions object, not arbitrary properties.

`project.yml` atomically pairs independent immutable revisions:

~~~yaml
schema_version: workspace-project-active-pointer-v1
project_id: project://<repository-id>/<opaque-project-id>
project_storage_key: <path-safe-opaque-key>
active_revision: 3
active_revision_ref: .octon/instance/locality/projects/<project-storage-key>/revisions/3.yml
active_revision_digest: sha256:<digest>
active_profile_revision: 8
active_profile_ref: .octon/instance/locality/projects/<project-storage-key>/profiles/8.yml
active_profile_digest: sha256:<digest>
lifecycle_status: active
pointer_epoch: 11
previous_pointer_digest: sha256:<digest>
transition_receipt_ref: <canonical-broker/evidence-ref>
transition_receipt_digest: sha256:<digest>
updated_by_identity: <authenticated-store-caller>
~~~

The separately versioned Project Profile projection contains its own
`source_fact_manifest_ref`/digest, `freshness_state`, `checked_at`,
`invalidation_keys`, tool/validation/ownership/risk facts, and the immutable
Workspace Project revision ref/digest whose boundary it observes. A run
snapshots the exact pointer epoch and both revision/digest pairs.

Workspace Project trust relies on an authenticated protected revision/pointer
store, immutable digest/predecessor chains, and broker/evidence transition
receipts—not on an undeclared project-file signing key. The store rejects a
revision rewrite, missing predecessor, pointer digest mismatch, or transition
without the exact typed capability and receipt binding.

Lifecycle status is owned only by `project.yml` and the registry active
pointer. Immutable project and profile revision documents record
`published_at`; they are never relabeled
`stale`, `suspended`, `blocked`, or `retired`. A lifecycle transition updates
the pointer/registry and may publish a successor revision, while old runs retain
the original revision digest.

### Durable Identity

Project identity must not be a directory path:

- project_id is an opaque stable ID generated when the project is adopted;
- repository_id uses a provider-stable repository identifier when available;
- a local-only repository receives a generated repository instance UUID stored
  in Git local configuration and a host adoption registry outside tracked
  repository content; the authored revision records only its digest-bound
  reference;
- a pure filesystem move preserves project and boundary revision because
  boundaries are repository-relative; it refreshes only adoption locator,
  discovery receipt, and Project Profile machine facts unless an authored
  repo-relative boundary actually changed;
- a fork receives a new repository identity even if paths and history match;
- provider transfer or remote rename preserves identity when the provider's
  stable repository ID remains the same;
- every run binds repository ID, project ID, immutable project-revision ref and
  digest, profile digest, boundary digest, and source SHA.

Local-only adoption uses this deterministic protocol:

1. Read `octon.repository-instance-id` from Git local configuration. Normal Git
   clone does not copy this value.
2. If present, accept it only when the destination host registry already owns
   the matching claim or a signed move-transfer receipt from the prior host is
   consumed. A preexisting but unclaimed ID is ambiguous and cannot select a
   project or inherit authority.
3. If absent, allocate a new UUID and atomically claim it in the per-user host
   adoption registry before writing Git local configuration.
4. A directory move on the same host preserves the local Git configuration and
   registry claim, so the instance ID survives without boundary-revision churn.
5. A normal clone receives a new instance ID. Copied authored project records
   become non-authoritative lineage candidates until new project revisions are
   brokered for that repository ID.
6. A raw filesystem copy that duplicates the local ID conflicts with the
   existing host-registry claim and blocks selection until the operator marks
   one path as the move or adopts the copy as a new instance.
   On another host, the copied ID remains blocked until a signed move-transfer
   receipt is provided or a new ID is adopted.
7. `repository_lineage_id` may relate clones or forks for discovery, but it
   never permits reuse of scope, grants, capabilities, profiles, or durable
   targets across repository IDs.

The host adoption registry is locality state, not authority. Deleting or
copying it cannot grant access; ambiguity blocks project selection and retains
the candidate work.

### Lifecycle States

~~~text
discovered
  -> profile_pending
  -> active

active
  -> stale
  -> repairing
  -> active

active | stale
  -> suspended
  -> active

any non-retired state
  -> blocked

blocked
  -> repairing
  -> suspended
  -> active

active | suspended | blocked
  -> retired
~~~

State meanings:

- **discovered:** marker evidence exists, but no durable project revision is
  active.
- **profile_pending:** identity and boundary candidate exist; facts are being
  compiled.
- **active:** boundary and Project Profile are current and may be used as
  narrowing inputs.
- **stale:** one or more declared invalidation keys changed.
- **repairing:** a new candidate profile revision is being generated and
  validated.
- **suspended:** project selection and new durable transitions are disabled,
  while retained evidence remains.
- **blocked:** boundary conflict, missing ownership, unverifiable identity, or
  unsafe repair prevents use. It may leave only after a signed repair or
  conflict-resolution receipt proves the affected identity/boundary current;
  unrelated projects and candidate work remain selectable.
- **retired:** immutable historical identity; it cannot be selected for a new
  run.

Project lifecycle transitions are canonical-state effects. Narrowing and
factual transitions may be automatically brokered under Class B policy.
Boundary widening, protected-zone relaxation, new egress, new credentials, or
trust-policy changes require the Class C route.

### Boundary Representation

Boundaries use normalized repository-relative POSIX paths:

- roots are inclusive;
- excludes subtract from roots;
- symlink resolution occurs before comparison;
- path traversal, alternate casing, junctions, mount aliases, and external
  targets fail closed;
- a root does not imply authority over canonical Octon control/evidence roots;
- write ownership is exclusive unless a specific shared-generated-root contract
  defines a deterministic single writer;
- run scope is the intersection of Run Contract scope, Workspace Project
  boundary, policy, support admission, and host enforcement limits.

The Project boundary can only narrow a request. It never makes a path writable
by itself.

### Project Profile Relationship

Workspace Project and Project Profile have distinct roles:

- Workspace Project owns identity, logical boundary, and relationships.
  `project.yml` owns lifecycle and atomically selects one active project
  revision plus one active profile revision.
- Project Profile records evidence-backed project facts: toolchains, build/test
  commands, CI posture, protected zones, ownership hints, dependency facts,
  validation strategy, rollback constraints, and known risks.
- Profile revisions are immutable.
- The active pointer pairs one project revision/digest with one profile
  revision/digest. A machine-fact repair or same-host move may publish and
  select a new profile revision while leaving the immutable project revision
  and boundary digest unchanged.
- A run binds the pointer epoch and both selected digests and does not silently
  follow a later revision.

The Project Profile is authoritative configuration/fact input inside the
repository's precedence model, but it is not execution authorization.

### Monorepo and Nested-Project Behavior

One repository has one Octon control root. Nested logical projects do not
install descendant .octon roots.

Selection and ownership rules:

1. The deepest explicit active project root owns a single matched path.
2. Parent membership never grants child-project write access.
3. A task whose declared write set belongs to one project selects that project.
4. A task whose declared write set spans projects becomes an explicit
   multi-project run.
5. A multi-project run binds every involved project revision and receives only
   the intersection of their policies.
6. Parallel runs may read shared dependencies but may not write an overlapping
   owned path.
7. Ambiguous overlap blocks the affected path or transition, not unrelated
   candidate work.
8. Generated roots shared by projects require a declared owner, deterministic
   compiler, and conflict policy.

### Cross-Project Dependencies

Dependency edges are explicit and directional:

- read_only: dependency may be read through a pinned snapshot;
- build_input: dependency may be mounted read-only and used by builds;
- test_fixture: dependency may be copied into disposable test state;
- explicit_multi_project_write: write requires a multi-project Run Contract and
  authority decision.

Defaults:

- an undeclared dependency is inaccessible;
- a dependency edge does not authorize traversal or mutation;
- cross-repository dependencies use separate repository/project identities and
  source snapshots;
- remote dependency fetching is brokered and digest-bound;
- no project can widen another project's boundary;
- a durable cross-project effect binds every affected exact SHA/revision.

### Discovery and Selection

Discovery produces non-authoritative candidates from:

- current working directory;
- repository markers and build manifests;
- changed/touched path sets;
- explicit operator project ID;
- retained project registry;
- dependency manifests.

Deterministic selection order:

1. An explicit project ID supplied by the operator or governing request.
2. The deepest active project containing the current working directory.
3. The single active project owning the complete declared path set.
4. Otherwise one operator selection request with the minimal conflicting set.

Discovery never creates permission. Creating a durable project revision is a
brokered canonical-state effect.

### Stale-Profile Detection and Repair

Each Project Profile declares a complete source-fact manifest and invalidation
keys. Harness compilation performs a cheap digest check.

Repair behavior:

- a changed non-boundary fact marks the profile stale;
- candidate work may continue under the still-safe pinned envelope;
- the affected durable transition waits for reconciliation;
- the profiler emits a new immutable candidate revision;
- factual or narrowing changes within the current boundary may be automatically
  promoted by the broker;
- root expansion, new external dependency, new credential/egress need,
  protected-zone relaxation, or trust change requires Class C approval;
- old runs retain their pinned revision and may not silently acquire the new
  scope;
- boundary shrink or revocation immediately narrows or terminates affected
  access.

The denial must identify the changed invalidation key and the shortest repair
command. It must not stop unrelated projects.

### Workspace Project Non-Authority Invariants

Workspace Project and Project Profile may:

- identify and classify a project;
- compile and narrow requested scope;
- select context, validation, sandbox, and rollback inputs;
- inform policy and support matching.

They may not:

- authorize execution;
- mint a GrantBundle or effect capability;
- widen a Run Contract, mission, delegation, support tuple, or capability pack;
- make a discovered path readable or writable;
- authorize cross-project access;
- activate a profile, policy, runtime, or trust-root change by themselves;
- turn a generated projection into authority.

## Governed Harness Factory

### Purpose

The Governed Harness Factory locks structural source inputs and compiles the
Policy Compiler's exact Harness Compilation Plan into one immutable,
digest-addressed Effective Harness Manifest. It gives the authority engine and
launch broker a complete, concrete envelope to evaluate and enforce without
letting the factory reinterpret policy.

It does not make the authorization decision.

### Input Classes

#### Governing Inputs

- Run Contract and digest;
- workspace-charter and mission/delegation bindings;
- policy versions and active revocations;
- support tuple and capability-pack admissions;
- required approvals or exception leases;
- evidence and rollback obligations.

#### Project Inputs

- repository identity and exact source SHA;
- Workspace Project ID, revision, and boundary digest;
- Project Profile revision and source-fact digest;
- multi-project dependency bindings.

#### Runtime and Trust Inputs

- authority-engine, broker, launcher, signer, and verifier identities, versions,
  and digests;
- executor and host adapter identities;
- sandbox enforcement profile and conformance proof;
- installation/update trust anchors.

#### Capability and Effect Inputs

- admitted tool/capability schemas;
- requested effect classes;
- egress destinations/methods;
- opaque credential-handle classes;
- broker endpoints and provider installations.

#### Context Inputs

- context-pack receipt and digest;
- prompt, skill, extension, and route-bundle handles;
- freshness and omission metadata;
- model-visible source manifest.

#### Assurance Inputs

- validation plan and exact commands;
- evidence profile;
- rollback/compensation plan;
- expected postconditions;
- fault-injection requirements.

#### Untrusted Inputs

- user request text;
- candidate target manifests;
- agent/model plans and summaries;
- raw proposal or generated material.

Untrusted inputs may be classified and digested, but they cannot override a
governing input or mint authority.

### Compilation Stages

~~~text
1. Factory ingests inputs and labels source/trust classes
2. Factory validates schemas, digests, freshness, and structural precedence
3. Factory resolves descriptive repository, Project, Profile, source, dependency, tool, and context facts
4. Factory emits deterministic HarnessInputLock with requested paths/actions; it makes no effect/risk decision
5. Policy Compiler classifies Class A/B/C consequence, resolves policy/support/budget/credential limits, and emits exact HarnessCompilationPlan
6. Factory verifies the plan and compiles concrete context, validation, evidence, rollback, executor, sandbox, process, network, and broker controls without discretion
7. Factory emits immutable Effective Harness Manifest plus separate compilation receipt
8. Policy Compiler verifies manifest-to-plan conformance and seals CompiledAuthorizationInput binding both digests
9. Submit ExecutionRequest and CompiledAuthorizationInput to canonical authority
10. Receive GrantBundle; authority issuer signs ExecutorLaunch request; ledger register_issue returns registered capability reference
11. Launch broker requests verification/reservation, installs/validates controls, requests consume/outbox, supplies AttemptLivenessBundle, obtains evidence-store AttemptStartReceipt and sole ledger AttemptLinkAck, then consumes the invocation guard to launch
12. Effect broker applies the same reserve/consume/liveness/attempt-start/link/guard protocol to later typed durable-effect capabilities
~~~

Stages 1–8 are non-authorizing compilation. The Policy Compiler is the sole
owner of normative effect/risk classification, policy/support intersection,
and Harness Compilation Plan. The Factory is the sole owner of structural
input locking, concrete manifest canonicalization, and deterministic
plan-to-controls compilation. It must reject a plan it cannot implement exactly
rather than relax it. The Policy Compiler's final conformance step is the only
route to CompiledAuthorizationInput. Neither component authorizes launch or
effects.

### Effective Harness Manifest Schema

~~~yaml
schema_version: effective-harness-manifest-v1
harness_id: harness://<run-id>/<identity-digest>
run_id: <run-id>
harness_identity_digest: sha256:<digest-of-input-lock-plan-and-compiler-tuple>
harness_input_lock_digest: sha256:<digest>
harness_compilation_plan_digest: sha256:<digest>

compiler:
  identity: octon-harness-compiler
  version: <version>
  binary_digest: sha256:<digest>

inputs:
  - ref: <canonical-or-evidence-ref>
    digest: sha256:<digest>
    class: governing
    freshness: current

bindings:
  run_contract_ref: <ref>
  run_contract_digest: sha256:<digest>
  repository_id: repo://<id>
  source_sha: <git-sha>
  workspace_projects:
    - project_id: project://<id>
      project_storage_key: <path-safe-opaque-key>
      repository_id: repo://<id>
      source_kind: git-sha
      exact_source_sha: <git-sha>
      source_snapshot_digest: sha256:<digest>
      revision: 3
      project_revision_ref: .octon/instance/locality/projects/<project-storage-key>/revisions/3.yml
      project_digest: sha256:<digest>
      profile_digest: sha256:<digest>
      boundary_digest: sha256:<digest>
      requested_scope_id: project-scope://<run-id>/<project-id>
  support_tuple_ref: <ref>
  support_tuple_digest: sha256:<digest>
  policy_version: <version>
  runtime_version: <version>
  revocation_epoch: <epoch>

candidate_envelope:
  workspace_kind: disposable-clone
  workspace_id: candidate://<run-id>
  base_sha: <git-sha>
  project_scopes:
    - scope_id: project-scope://<run-id>/<project-id>
      project_id: project://<id>
      project_revision: 3
      read_roots:
        - <normalized-root>
      write_roots:
        - <normalized-root>
      dependency_mounts:
        - dependency_project_id: project://<dependency-id>
          dependency_repository_id: repo://<dependency-repository-id>
          revision: 7
          exact_source_sha: <git-sha-or-null-for-non-git-snapshot>
          source_snapshot_digest: sha256:<digest>
          mount_path: <normalized-candidate-relative-path>
          access: read_only
  denied_roots:
    - <normalized-root>
  temporary_roots:
    - <run-owned-temp-root>
  process_profile: <profile-id>
  network:
    default: deny
    direct_egress: false
  git:
    separate_database: true
    remotes_present: false
    canonical_refs_writable: false
  ambient_credentials: false
  child_process_inherits_envelope: true

broker_envelope:
  endpoint_identity: broker://<id>
  requested_project_effects:
    - scope_id: project-scope://<run-id>/<project-id>
      project_id: project://<id>
      requested_effect_classes:
        - <typed-effect-class>
      repository_targets:
        - repo://<id>/<exact-ref-or-canonical-root>
      provider_targets:
        - <provider-installation-and-object-id>
      credential_handle_classes:
        - <opaque-class>
  raw_credentials_model_visible: false

executor:
  parent_executor_id: executor://<parent-id>
  requested_child_id: child://<run-id>/<child-id>
  delegation:
    kind: root-or-child
    parent_run_id: <run-id-or-null>
    parent_grant_ref: <canonical-ref-or-null>
    parent_grant_digest: <sha256-or-null>
    delegation_contract_ref: <canonical-ref>
    delegation_contract_digest: sha256:<digest>
    requested_depth: <non-negative-integer>
    max_depth: <non-negative-integer>
  adapter_id: <adapter-id>
  executable_identity: <identity>
  executable_digest: sha256:<digest>
  normalized_argv:
    - <argument>
  working_scope_id: project-scope://<run-id>/<project-id>
  working_directory: <normalized-path-within-working-scope>
  environment:
    inherit_parent: false
    allowed_names:
      - <name>
    values_digest: sha256:<digest>
  timeout_ms: <positive-integer>
  cancellation_grace_ms: <positive-integer>
  max_descendants: <non-negative-integer>
  resources:
    cpu_millis: <positive-integer>
    memory_bytes: <positive-integer>
    writable_bytes: <positive-integer>
    process_count: <positive-integer>
  budget:
    token_limit: <positive-integer>
    wall_time_ms: <positive-integer>
    broker_call_limit: <non-negative-integer>
  operation_descriptor_digest: sha256:<digest>
  model_identity: <model-id>

context:
  context_pack_ref: <ref>
  context_pack_digest: sha256:<digest>
  model_visible_context_digest: sha256:<digest>
  omissions_ref: <ref>
  omissions_digest: sha256:<digest>

validation_plan:
  ref: <ref>
  digest: sha256:<digest>

evidence_plan:
  trusted_sink_ref: <ref>
  trusted_sink_digest: sha256:<digest>
  candidate_log_class: untrusted-source
  journal_anchor_policy_ref: <ref>
  journal_anchor_policy_digest: sha256:<digest>

rollback:
  posture_ref: <ref>
  digest: sha256:<digest>

freshness:
  input_lock_digest: sha256:<digest>
  not_before: <rfc3339-derived-from-input-validity>
  expires_at: <rfc3339>
  invalidation_keys:
    - <ref-or-epoch>

authorization_boundary:
  manifest_authorizes_execution: false
  manifest_mints_grants: false
  manifest_mints_capabilities: false
~~~

The schema should be strict. Security-relevant arrays are sorted and
deduplicated before canonical serialization. The manifest digest is computed
over one specified serialization. It contains only deterministic normalized
inputs and derived values. The separate compilation receipt contains the
unique build ID, compiler-run identity, `compiled_at` observation, timings, and
the resulting manifest digest; those observational fields are not part of the
manifest digest.

Every security-relevant `*_ref` must have an adjacent `*_digest` and must
appear exactly once with the same digest in the canonical `inputs`
ref-to-digest map. The map is exhaustive for governing, validation, context,
support, evidence-sink/anchor, rollback, project/profile, delegation, and
policy references. Schema/conformance validation rejects an unbound,
duplicate, differently digested, or unclassified reference.

`harness_identity_digest` is the digest of the canonical tuple
`(run_id, harness_input_lock_digest, harness_compilation_plan_digest,
compiler.identity, compiler.version, compiler.binary_digest)`. It excludes the
`harness_id` and `harness_identity_digest` fields themselves, so two manifests
compiled from a different plan or compiler cannot share an identity.

The `ExecutionRequest` is constructed only after the manifest digest exists.
No ExecutionRequest or binding-request digest appears inside the manifest, so
there is no self-reference. The later authority-owned binding artifact binds
the request digest, manifest digest, grant digest, and ledger-registered
capability.
The factory does not mint `operation_lineage_id`, attempt generation, or the
canonical idempotency key. The authority engine derives them from the
canonical operation descriptor plus target semantics, rejects lineage/key
collisions or substitution, and records them only in that later binding
artifact and ledger-registered capability.

### Freshness and Digest Binding

The manifest is immutable. Its freshness is the intersection of all inputs:

- Run Contract and project revision;
- policy, support, capability, and runtime versions;
- context-pack receipt;
- approval/exception expiry;
- credential lease;
- verifier release;
- revocation epoch;
- source SHA.

The earliest expiry wins. Any input digest change invalidates the cached
manifest.

The authority engine receives:

- ExecutionRequest digest;
- Run Contract digest;
- Harness Input Lock and Harness Compilation Plan digests;
- Effective Harness Manifest digest;
- repository/project/source bindings;
- policy/support/runtime versions.

An allow GrantBundle repeats the exact harness digest. A separate authority-owned
harness binding artifact records:

- ExecutionRequest identity and digest;
- GrantBundle identity and digest;
- harness identity and digest;
- ledger-registered ExecutorLaunch capability identity/digest;
- canonical operation-lineage ID, attempt generation, idempotency key, and any
  predecessor/supersession record;
- separately evaluated granted project envelopes and their exact
  project-revision/scope digests;
- expiry and revocation epoch.

The manifest is never edited to add authority after issuance.

For a multi-project run, the authority engine evaluates every
`requested_scope_id` separately and records one narrowed project envelope per
project in the single canonical decision. A durable capability binds exactly
one project envelope and exact target, except for an explicitly typed
multi-project atomic effect that names every envelope. No flattened union of
project roots, provider targets, or credential classes is authorized.

### Authority-Binding Point

The only binding point is the canonical authority decision after compilation:

~~~text
Effective Harness Manifest
  + Harness Compilation Plan
  -> Policy Compiler conformance
  -> CompiledAuthorizationInput + ExecutionRequest
  -> authorize_execution
  -> allow GrantBundle
  -> sign typed ExecutorLaunch issuance request
  -> capability-ledger register_issue
  -> registered AuthorizedEffect<ExecutorLaunch> reference
  -> launch-broker reservation request
  -> capability-ledger atomic verification/reservation
  -> launch-broker authenticated-lease validation/private guard
  -> control installation and validation
  -> irreversible consume-intent commit
  -> evidence-store outbox import
  -> durable attempt_started record
  -> capability-ledger one-time attempt link
  -> broker-private AttemptInvocationGuard
  -> exact process spawn
~~~

The factory cannot:

- call the launcher directly;
- manufacture an authority_ref;
- accept a self-declared unattended mode as authorization;
- widen scope after the GrantBundle;
- sign/register/expose a child capability;
- convert validation success into permission.

### Host-Control Installation

The factory emits an unprivileged installation plan. A pinned launch broker
outside the repository:

1. validates the manifest/request bindings and submits the canonical
   GrantBundle/ExecutorLaunch reference to the capability ledger;
2. validates the ledger's authenticated reservation lease and constructs a
   broker-private non-cloneable guard;
3. verifies its own and the broker's pinned identities;
4. creates or opens the run-owned candidate workspace;
5. installs filesystem, process, signal, network, IPC, and credential controls;
6. exposes only an authenticated broker endpoint;
7. removes or masks provider CLIs, credential agents, cloud metadata, Docker or
   container-admin sockets, and canonical Git write paths;
8. requests irreversible consume-intent/outbox commit from the capability
   ledger after every launch precondition is ready;
9. requests idempotent outbox import and durable `attempt_started` from the
   evidence store;
10. submits the `AttemptStartReceipt` to the capability ledger and obtains the
    sole `AttemptLinkAck`;
11. constructs/consumes `AttemptInvocationGuard<ExecutorLaunch>` and launches
    the model process as a contained process-tree root;
12. attests to the installed control set and observed outcome.

Repository scripts, hooks, generated files, and model-visible configuration may
describe the requested plan but cannot replace the installed launcher, broker,
signer, verifier, or host enforcement profile.

### Disposable Execution Semantics

- The source snapshot is exact-SHA and immutable.
- The candidate workspace and Git database are run-owned.
- No remote is configured for the model process.
- Local commits and candidate refs are permitted.
- Candidate evidence is untrusted until observed or attested by a trusted
  component.
- Durable promotion accepts an exact candidate commit/tree and never relies on a
  model-supplied claim about its contents.
- Broker/provider outage preserves the candidate and permits unrelated Class A
  work.
- Garbage collection requires a preservation, promotion, or explicit discard
  receipt.

### Child-Agent Semantics

A delegated or child agent never inherits ambient authority.

Two process forms are distinct:

1. **Enumerated non-agent subprocess:** a compiler, test, or tool subprocess
   already admitted by the parent launch's process profile may run in the same
   sandbox. It receives no child-agent identity, broker identity, grant, or new
   effect capability.
2. **Delegated child agent:** the parent requests a separate child harness whose
   project scope, context, budget, lifetime, and requested effect classes are
   strict subsets. The authority engine executes
   `authorize_execution(ChildExecutionRequest)` with the parent grant
   ID/digest and subset proof and issues a fresh child-scoped `GrantBundle`.
   The authority issuer signs the child's distinct `ExecutorLaunch` and later
   typed issuance requests only from that child grant; ledger `register_issue`
   alone activates/exposes the capability references.

Rules:

- a delegation proof is evidence of requested/derived scope, not authority;
- child-agent launch always follows issuer signature, ledger
  registration/reservation/consume, evidence-store/ledger attempt gating, and
  launch-adapter invocation-guard consumption for a typed request derived from
  the fresh child grant;
- child broker requests bind child run ID, harness digest, and delegation
  lineage;
- the parent grant/capabilities are never passed to or accepted from the child;
- a child cannot extend lifetime, create grandchildren beyond policy, add
  projects, add egress, gain credentials, or activate Class C effects;
- parent cancellation or revocation cascades to child grants and descendants;
  child revocation remains independently addressable;
- child results are candidate inputs until independently integrated and
  validated;
- no child can write canonical control/evidence roots directly.

### Revocation

Revocation may target:

- run;
- harness;
- executor/child lineage;
- project revision;
- capability or effect class;
- credential handle;
- broker/provider identity;
- verifier/runtime release.

On revocation:

1. Broker rejects new operations at or after the revocation epoch.
2. Launcher terminates affected process trees.
3. In-flight operations enter reconciliation rather than blind retry.
4. Credential leases and broker sessions are invalidated.
5. Candidate state is preserved.
6. Trusted revocation and termination evidence is retained.

The agent cannot refresh or replace its own harness after revocation.

### Retirement

Retirement sequence:

1. stop accepting new child or broker requests;
2. revoke launch/effect leases;
3. terminate the process tree;
4. reconcile in-flight external operations;
5. capture final candidate tree/commit and preservation disposition;
6. seal trusted receipts and journal anchor;
7. remove credential handles, IPC endpoints, mounts, and temporary policy;
8. garbage-collect workspace only after retention criteria pass.

Retirement is idempotent. A crash between steps resumes from trusted retained
state.

### Required Evidence

Retain:

- input classification and canonical source manifest;
- compilation-stage timings and result;
- Effective Harness Manifest and digest;
- authority binding, GrantBundle, and ExecutorLaunch issuance/consumption;
- sandbox/host-control installation attestation;
- process identity and termination receipt;
- child derivation/launch lineage;
- broker capability verification, effect, and external postcondition receipts;
- revocation and reconciliation records;
- final candidate digest and preservation/promotion/discard receipt;
- retirement and cleanup result.

The effect or launch broker records facts it observed in the canonical evidence
store. The separate evidence signer reads and signs those normalized committed
facts; it never signs an effect description merely supplied by the model.

## Acceptance Tests

Workspace Project acceptance:

- project identity survives a directory move;
- fork and provider-transfer scenarios follow the identity rules;
- deepest-root selection is deterministic;
- nested parent does not gain child writes;
- a multi-project run binds every project revision;
- overlapping concurrent writes deny only the overlap;
- stale non-boundary facts auto-repair without operator interruption;
- boundary widening requires the Class C route;
- generated views and Project Profiles cannot mint authority.

Harness Factory acceptance:

- changing any bound input invalidates the manifest;
- manifest mutation after grant denies launch;
- wrong source SHA, project revision, policy version, revocation epoch, or
  verifier version denies;
- replayed or concurrently consumed ExecutorLaunch capability denies;
- launch broker installs the exact declared host controls;
- agent and children cannot access canonical roots, ambient credentials,
  unrestricted network, or provider CLIs;
- derived child scope cannot exceed parent scope;
- broker outage preserves candidate state;
- retirement is crash-recoverable and does not discard unpreserved work.
