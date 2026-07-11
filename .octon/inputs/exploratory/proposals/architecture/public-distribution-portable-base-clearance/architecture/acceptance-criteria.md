# Acceptance Criteria

## AC-01

A machine-readable component graph identifies the smallest dependency-closed base for the promised installation, bootstrap, execution, validation, update, and rollback workflows.

Objective minimality test: the selected closure equals the transitive
dependency closure of the declared entrypoint components recorded in
`.octon/framework/manifest.yml` — no selected component sits outside that
computed closure, and no component inside the selection is unreachable from a
declared entrypoint. `validate-portable-component-clearance.sh` fails on
either deviation.

## AC-02

Every reachable export path inherits or overrides explicit origin, AI-assistance, license, sensitivity, and publication-clearance fields, with zero unknown statuses.

## AC-03

Apache-2.0 and designated MIT-0 template coverage are mechanically mapped, and required third-party notices are included only when supported by recorded obligations.

## AC-04

Unresolved, restricted, quarantined, or excluded files cannot enter the selected closure directly or through dependencies.

## AC-05

A basic name-conflict search receipt and concise official-identity input exist, while unresolved plausible conflict blocks maintainer clearance.

The retained receipt must record: the exact queries run, the sources searched,
the search date, the results found, and the maintainer disposition for each
result. A blocking conflict is any active project, product, organization, or
registered mark using the same or a confusingly similar name in the software
tooling or agent-framework space whose result the maintainer has not
dispositioned as non-conflicting; any undispositioned plausible conflict
blocks clearance.

## Aggregate Gate

All criteria above must pass on the exact reviewed implementation revision.
A general statement that tests pass is insufficient; evidence must identify
the behavior, boundary, negative case, and retained receipt.

