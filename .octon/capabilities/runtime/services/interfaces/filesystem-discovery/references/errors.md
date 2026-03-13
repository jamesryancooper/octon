# Filesystem Discovery Errors

| Error Code | Category | Notes |
|---|---|---|
| `ERR_FILESYSTEM_INTERFACES_INPUT_INVALID` | `validation` | Input payload failed schema validation. |
| `ERR_FILESYSTEM_INTERFACES_PATH_INVALID` | `policy` | Path is invalid or outside allowed workspace scope. |
| `ERR_FILESYSTEM_INTERFACES_NOT_FOUND` | `not-found` | Requested file, node, or snapshot does not exist. |
| `ERR_FILESYSTEM_INTERFACES_LIMIT_EXCEEDED` | `resource` | Time, file, or byte safety bounds were exceeded. |
| `ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID` | `integrity` | Snapshot artifacts are missing or malformed. |
| `ERR_FILESYSTEM_INTERFACES_FORMAT_UNSUPPORTED` | `compatibility` | Snapshot artifact format is not supported by this runtime version. |
| `ERR_FILESYSTEM_INTERFACES_LOCKED` | `resource` | Snapshot build lock is held by another in-progress writer. |
| `ERR_FILESYSTEM_INTERFACES_OPERATION_UNSUPPORTED` | `validation` | Operation is outside the declared service contract. |
| `ERR_FILESYSTEM_INTERFACES_INTERNAL` | `internal` | Internal execution failure. |

Canonical source: `.octon/capabilities/runtime/services/interfaces/filesystem-discovery/contracts/errors.yml`.
