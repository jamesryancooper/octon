# Verification scenarios (manual)

These scenarios correspond to the verification table in the implementation brief.

> Notes:
> - The CLI binary is `harmony` (kernel crate). For development, use `.harmony/runtime/run ...` which falls back to `cargo run`.
> - The stdio protocol uses **stdout**. Logs go to **stderr**.

## 1) Hello handshake (valid)

Command:

```bash
.harmony/runtime/run serve-stdio
```

Then send on stdin:

```json
{"type":"hello","protocol":"harmony-stdio-v1","client":{"name":"test","version":"0"}}
```

Expected stdout (one line):

```json
{"type":"hello","protocol":"harmony-stdio-v1","kernel":{"version":"<semver>","os":"<os>","arch":"<arch>"}}
```

## 2) Hello handshake (wrong protocol)

Send:

```json
{"type":"hello","protocol":"wrong","client":{"name":"test","version":"0"}}
```

Expected stdout:

```json
{"type":"error","error":{"code":"PROTOCOL_UNSUPPORTED","message":"unsupported or missing protocol (expected harmony-stdio-v1)","details":{...}}}
```

## 3) KV put → get → del → get

Start stdio server (`serve-stdio`) and after hello, send:

```json
{"id":"1","type":"request","method":"tool.invoke","params":{"category":"interfaces","service":"kv","op":"put","input":{"key":"a","value":"1"}}}
{"id":"2","type":"request","method":"tool.invoke","params":{"category":"interfaces","service":"kv","op":"get","input":{"key":"a"}}}
{"id":"3","type":"request","method":"tool.invoke","params":{"category":"interfaces","service":"kv","op":"del","input":{"key":"a"}}}
{"id":"4","type":"request","method":"tool.invoke","params":{"category":"interfaces","service":"kv","op":"get","input":{"key":"a"}}}
```

Expected responses (order is usually preserved but not guaranteed due to concurrency):

- id=1 result `{ "ok": true }`
- id=2 result `{ "value": "1" }`
- id=3 result `{ "ok": true }`
- id=4 result `{ "value": null }`

## 4) Unknown service

```json
{"id":"x","type":"request","method":"tool.invoke","params":{"category":"interfaces","service":"nope","op":"get","input":{}}}
```

Expected response:

```json
{"id":"x","type":"response","ok":false,"error":{"code":"UNKNOWN_SERVICE",...}}
```

## 5) Unknown op on valid service

```json
{"id":"x","type":"request","method":"tool.invoke","params":{"category":"interfaces","service":"kv","op":"nope","input":{}}}
```

Expected:

```json
{"id":"x","type":"response","ok":false,"error":{"code":"UNKNOWN_OPERATION",...}}
```

## 6) Input fails schema validation

Missing required `key`:

```json
{"id":"x","type":"request","method":"tool.invoke","params":{"category":"interfaces","service":"kv","op":"get","input":{}}}
```

Expected:

```json
{"id":"x","type":"response","ok":false,"error":{"code":"INVALID_INPUT",...}}
```

## 7) Service requests ungrantable capability

Edit policy file `.harmony/runtime/config/policy.yml` to remove `storage.local` from `interfaces/kv`, then invoke `kv.get`.

Expected:

```json
{"id":"x","type":"response","ok":false,"error":{"code":"CAPABILITY_DENIED",...}}
```

## 8) Service exceeds timeout

Set `limits.timeout_ms` in a service.json to a very small value (e.g. 1ms) and implement a busy loop in the guest.

Expected:

```json
{"id":"x","type":"response","ok":false,"error":{"code":"TIMEOUT",...}}
```

## 9) Cancellation

Send a long-running request id=long, then send:

```json
{"id":"c1","type":"request","method":"cancel","params":{"id":"long"}}
```

Expected:

- Response for `c1` acknowledging cancellation (implementation choice).
- Final response for `long` with `error.code = "CANCELLED"`.

## 10) Studio command discoverability and help

Command:

```bash
.harmony/runtime/run --help
```

Expected:

- command list includes `studio`

Then:

```bash
.harmony/runtime/run studio --help
```

Expected:

- help includes `Launch Harmony Studio desktop UI`
