# Lab

`framework/lab/**` is Octon's authored lab surface for behavioral proof,
replay, scenario design, shadow-run method, and adversarial discovery.

The lab is distinct from ordinary assurance:

- assurance owns the proof-plane contracts and gating posture
- lab owns the authored scenario, replay, and experiment surfaces that feed
  behavioral proof

Wave 4 remediation also adds:

- a lab catalog for reusable scenario and benchmark disclosure assets
- reusable writers for HarnessCards and evaluator-backed benchmark claims

The authored lab surface explicitly covers:

- scenario proof
- replay and shadow exercises
- fault rehearsals
- adversarial experiments

Primary authored domains:

- `scenarios/`
- `replay/`
- `shadow/`
- `faults/`
- `probes/`

Retained lab evidence lives under `/.octon/state/evidence/lab/**`.
