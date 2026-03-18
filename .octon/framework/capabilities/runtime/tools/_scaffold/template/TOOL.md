---
name: {{tool-id}}
description: >
  What this tool does, when to use it, what it returns.
interface_type: shell
version: "1.0.0"
metadata:
  author: "{{author}}"
  created: "YYYY-MM-DD"
  updated: "YYYY-MM-DD"
input_schema: schema/input.schema.json
output_schema: schema/output.schema.json
requires:
  runtime: [bash]
  commands: []
timeout_ms: 30000
sandbox: process
---

# {{tool-id}}

Describe invocation contract, error behavior, and output guarantees.
