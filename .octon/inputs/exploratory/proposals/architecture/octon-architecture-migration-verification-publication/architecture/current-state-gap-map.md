# Current-State Gap Map

## Preservable Primitives

- Existing exact-ref and source-SHA validation concepts.
- Required-check and ruleset integration.
- Runtime authorized-effect and protected-CI request boundaries.
- Protected PR as a safe publication lane.
- Current Git helper evidence of source, target, ancestry, and post-state.
- Provider adapter manifests and conformance vocabulary.

Preservation is not a completion claim.

## Material Gaps

| Gap | Current evidence | Required RP-06 change |
| --- | --- | --- |
| Candidate-controlled verifier | Required check producers execute candidate repository code | Move verdict code and policy outside candidate control |
| Ambiguous check identity | Context name can appear under different events/producers | Authenticate verifier identity/version and full tuple |
| Coupled verification/effect plane | Candidate workflows or provider identities can combine decision and mutation | Separate verifier/check identity from publisher/effect identity |
| Route policy spread | Current direct-main, branch-no-PR, and branch-PR rules do not implement one frozen A/B/C predicate | Publish one immutable typed policy and digest |
| Invalid-authority escalation risk | Blocked routes can be mistaken for PR predicates | Deny invalid authority; PR only for valid policy-selected review |
| Provider worker authority | Current writer workflows can act from candidate code | Optional worker consumes exact broker authority and owns no state/policy |
| Projection source missing | .github workflow files are live owners, with no accepted .octon generator found | Establish authored .octon source/generator before projection changes |
| Provider evidence staleness | Rules, Apps, permissions, contexts, and secrets are point-in-time | Refresh at implementation and promotion |

## Findings

- RF-007: candidate-influenced provider effect planes require containment and
  replacement.
- RF-009: publication must consume RP-05 atomic target-pre binding.
- RF-010: candidate-controlled verifier and ambiguous check identity contradict
  automatic landing.
- RF-024: generic provider/Harness completion claims remain unproved; RP-06
  owns only its specialization.

## Baseline Drift

The reconciliation baseline is c5b1f5760c78ff521cca6b054e4e8fef5300505b.
Creation ran at d78ee8b42cb3a39557bbe39b66cb5d156946172a.
No intervening change touched the RP-06 source families inspected, including
engine runtime, execution roles, product contracts, assurance runtime,
instance governance, or GitHub workflows. Reconciled assumptions remain
applicable.

## Removed Or Demoted

- Candidate-head verification and effect code leave the supported automatic
  path.
- Context-name-only trust is demoted to display/projection metadata.
- Autonomous direct-main remains unreachable.
- Invalid authority cannot be converted into a PR effect.
- Provider dashboards, labels, comments, and checks remain non-authoritative.
- Current workflow files become derived projections or retire only after an
  accepted .octon source/generator and proof exist.
