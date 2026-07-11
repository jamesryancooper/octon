---
disclosure_status: externally-shareable-after-maintainer-review
authority_mode: non-authoritative
external_transmission_approved: false
---

# Repository And Storage Topology

## 1. Private Octon Workspace

**Sponsor decision:** The private workspace develops canonical
`.octon/framework/**` source and owns this repository's
`.octon/instance/**` authority.

It may retain broader private development material, but should reduce routine
tracking of high-churn state, raw evidence, generated output, logs, caches, and
host projections. It must not have the public distribution as a push target and
must never publish workspace history as public Octon.

## 2. Public Octon Distribution Repository

**Sponsor decision:** Public `octon` is separate, has synthetic history, and
is populated only from a validated `portable_dropin` tree.

It contains no live workspace or downstream instance, input, state, evidence,
generated, host-projection, or pack content. Public-repository-only files are
not installed into downstream projects.

## 3. Downstream Octon Project

**Sponsor decision:** A downstream repository commits:

- an exact `.octon/core.lock.yml`;
- its own repository authority;
- intentionally hosted durable project material;
- only classified receipts or artifacts required for real collaboration or
  governance.

It retrieves a verified release artifact and materializes core locally. Updates
preserve every project-owned path.

## 4. Machine-Local Or External Operational Storage

**Sponsor decision:** Runtime state, raw evidence, generated outputs, logs,
caches, and host projections are local by default. High-value local evidence
uses encrypted system backup plus a disconnected encrypted backup.

External object storage is optional and cannot be claimed unless a real object,
durable locator, access policy, and content digest exist.

## Non-Collapse Rule

These four surfaces have different owners, threat models, Git policies,
retention needs, and rollback behavior. A single repository policy cannot
safely replace the topology.

Sources: `SRC-009`, `SRC-010`, `SRC-011`, `SRC-014`,
`SRC-015`, and `SRC-018`.

