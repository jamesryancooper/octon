# Evidence Plan

## Evidence that must exist before closure

### Instruction-layer evidence
- one enriched instruction-layer manifest example or fixture
- proof that capability pack refs / class refs / budget refs are populated when relevant
- proof that source digests and precedence stack remain present

### Execution-envelope evidence
- one request / grant / receipt chain showing normalized pack/class/envelope semantics
- proof that repo-shell class receipt reasons remain coherent
- proof that raw payload refs are emitted when envelope policy requires offload

### Validation evidence
- output from `validate-instruction-layer-manifest-depth.sh`
- output from `validate-capability-envelope-normalization.sh`
- CI logs from two consecutive clean passes

## Evidence location posture

This packet does not create a new evidence family. It expects evidence to remain under existing retained evidence practice, with candidate artifacts under:
- existing run evidence / receipt roots
- existing control-execution evidence roots
- existing validation evidence practices

## Evidence that must never be treated as truth

- proposal packet files
- generated summaries
- chat history
- CI annotations alone without retained underlying artifacts
