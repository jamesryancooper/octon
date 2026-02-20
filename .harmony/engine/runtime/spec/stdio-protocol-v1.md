# Harmony NDJSON stdio protocol (v1)

> **Normative:** This file defines the v1 session-mode stdio protocol used by the Harmony kernel.

## 4.1 Transport

- UTF-8 text
- One JSON object per line (`\n` or `\r\n`)
- Max line length: kernel-configurable (default 1 MiB)

## 4.2 Version negotiation

First message from client MUST be:

```json
{"type":"hello","protocol":"harmony-stdio-v1","client":{"name":"<string>","version":"<string>"}}
```

Kernel responds:

```json
{"type":"hello","protocol":"harmony-stdio-v1","kernel":{"version":"<string>","os":"<string>","arch":"<string>"}}
```

If protocol mismatch, kernel responds with:

```json
{"type":"error","error":{"code":"PROTOCOL_UNSUPPORTED","message":"..."}}
```

## 4.3 Message shapes

All subsequent messages MUST include `id` for request/response/event correlation.

### Request

```json
{
  "id": "1",
  "type": "request",
  "method": "tool.invoke",
  "params": {
    "service": "kv",
    "category": "interfaces",
    "op": "get",
    "input": { "key": "x" }
  },
  "meta": {
    "trace_id": "optional",
    "deadline_ms": 30000
  }
}
```

### Response

```json
{
  "id": "1",
  "type": "response",
  "ok": true,
  "result": { "value": "..." }
}
```

### Error response

```json
{
  "id": "1",
  "type": "response",
  "ok": false,
  "error": {
    "code": "CAPABILITY_DENIED",
    "message": "storage.local not granted",
    "details": { "capability": "storage.local" }
  }
}
```

### Events (streaming ops only)

```json
{"id":"9","type":"event","event":"chunk","data":{...}}
{"id":"9","type":"event","event":"done"}
```

## 4.4 Cancellation

Client may cancel an in-flight request:

```json
{"type":"request","id":"cancel-1","method":"cancel","params":{"id":"9"}}
```

Kernel MUST best-effort cancel and then emit:

- a final response for `id:"9"` with `ok:false` and `code:"CANCELLED"` (or `ok:true` if already finished).

## 4.5 Standard error codes (v1)

- `PROTOCOL_UNSUPPORTED`
- `MALFORMED_JSON`
- `REQUEST_TOO_LARGE`
- `UNKNOWN_METHOD`
- `UNKNOWN_SERVICE`
- `UNKNOWN_OPERATION`
- `INVALID_INPUT`
- `CAPABILITY_DENIED`
- `TIMEOUT`
- `SERVICE_TRAP`
- `INTERNAL`
- `CANCELLED`
