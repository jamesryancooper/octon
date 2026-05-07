# Bundle Matrix

| Bundle | Primary Input | Primary Output | Default Validators |
| --- | --- | --- | --- |
| `source-to-architecture-packet` | one source artifact | architecture packet | proposal + architecture |
| `architecture-revision-packet` | one source artifact | architecture revision packet | proposal + architecture |
| `constitutional-challenge-packet` | proposal packet, source artifact, or explicit kernel conflicts | policy challenge packet | proposal + policy |
| `source-to-policy-packet` | one source artifact | policy packet | proposal + policy |
| `source-to-migration-packet` | one source artifact | migration packet | proposal + migration |
| `multi-source-synthesis-packet` | multiple source artifacts | architecture packet | proposal + architecture |
| `packet-refresh-and-supersession` | existing packet | refreshed or superseding packet | packet-kind-specific |
| `packet-to-implementation` | existing packet | implementation + closeout result | packet-kind-specific + repo/runtime checks |
| `subsystem-targeted-integration` | one source artifact + subsystem scope | architecture packet | proposal + architecture |
| `repo-internal-concept-mining` | repo-native artifacts | architecture packet | proposal + architecture |
