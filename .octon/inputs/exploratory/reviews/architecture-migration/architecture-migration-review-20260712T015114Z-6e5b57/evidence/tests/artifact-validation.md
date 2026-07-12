# Artifact Validation Receipt

Review completion validation was run against the unique review directory.

- YAML: all 19 YAML files parsed successfully with Ruby Psych.
- JSONL: all 34 command-log records parsed successfully with jq.
- Decision coverage: 24 unique IDs, FD-001 through FD-024.
- Material finding schema: 14 findings contained every required field; every
  evidence classification was in the allowed vocabulary.
- Proposal map: 14 unique workgroups; each has dependencies, entry criteria,
  exit criteria, rollback, and proof.
- Recommendations: 13 of 13 cite evidence.
- Target claims: 11 of 11 map to required proof and a promotion gate.
- Required artifact tree: 42 of 42 required artifacts existed and were
  non-empty before evidence extras and the integrity index.
- Citation validation: 46 distinct repository paths and 72 unique path-line
  citations resolved and their first cited line was within file bounds.
- Mermaid: Mermaid CLI was unavailable. Both files passed basic flowchart
  header, balanced bracket, and balanced quote validation.
- Sibling review consultation: none.
- Final verdict: READY_FOR_PROPOSAL_PROGRAM.

The checksum index covers every review artifact except itself. Final write-scope
and checksum verification are recorded by the last command-log entries and
were run after the review content was frozen.
