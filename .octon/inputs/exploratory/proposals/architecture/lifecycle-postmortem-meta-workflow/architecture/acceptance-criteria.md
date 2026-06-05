# Acceptance Criteria

- The workflow contract exists under the meta workflow root.
- The workflow stages are local assets referenced by the workflow contract.
- The runtime command path binds `--run-id` and rejects empty or unsafe ids.
- The workflow reads retained control and evidence refs rather than generated
  summaries or chat memory.
- The workflow writes only retained postmortem evidence.
- The workflow refuses to mutate lifecycle journals, runtime state, closeout
  dispositions, proposal manifests, support targets, generated outputs, or
  authority artifacts.
- Missing required evidence produces a blocked or low-confidence postmortem
  rather than inferred facts.
- The workflow output layout is compatible with the validator child.
