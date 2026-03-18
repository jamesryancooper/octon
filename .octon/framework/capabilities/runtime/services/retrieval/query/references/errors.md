# Query Errors

| Error Code | Exit Code | Category | Notes |
|---|---|---|---|
| `InputValidationError` | `5` | structural | Request payload does not satisfy input schema. |
| `UnsupportedCommandError` | `5` | structural | Command is not `ask`, `retrieve`, or `explain`. |
| `UnsupportedSignalError` | `5` | structural | Signal is outside `keyword`, `semantic`, `graph`. |
| `SnapshotNotFoundError` | `6` | dependency | Snapshot path or ID does not resolve. |
| `MissingSignalArtifactError` | `6` | dependency | Required signal artifact is missing from snapshot. |
| `SemanticScoringUnavailableError` | `6` | dependency | Semantic scoring could not run for this request. |
| `CitationAssemblyError` | `4` | semantic | Candidate/citation/evidence join failed. |
| `NativeInvariantViolation` | `4` | policy | Core contract contains non-native config surface. |
| `ProviderTermLeakError` | `4` | policy | Provider-specific terms leaked outside adapter paths. |
