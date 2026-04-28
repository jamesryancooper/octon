# Architecture Evaluation

## Why v2 is highest leverage after v1

v1 makes Octon safe to start. It compiles repo orientation and objective shaping into a governed Work Package and first run-contract candidate. But drop-in governed autonomy requires safe continuation across multiple runs. v2 supplies the missing mission-continuation runtime.

## Current constraints

- Run lifecycle is strong but run-local.
- Mission schemas exist but do not implement queueing, continuation, stop conditions, or closeout.
- Action Slice exists but is not yet a Mission Queue control system.
- Budget and breaker schemas exist but are not wrapped into an operator-visible Autonomy Window.
- Decision Requests need mission-aware blocking/resolution semantics.
- Connector posture needs operation-level contracts before safe live admission.
- CLI is run-first and lacks mission continuation commands.

## Why these primitives

- Autonomy Window makes lease/budget/breakers understandable.
- Mission Runner prevents an unsafe infinite agent loop.
- Mission Queue makes next work bounded and inspectable.
- Action Slice provides bounded compile-to-run work units.
- Continuation Decision makes post-run state explicit and evidenced.
- Mission Run Ledger indexes mission runs without replacing run journals.
- Mission Evidence Profile defines mission-level proof depth.
- Mission-Aware Decision Request provides a unified human intervention path.
- Limited Connector Admission creates future MCP/tool hooks without widening support prematurely.

## No rival control plane

Mission Queue is control state, not authority. Continuation Decision records post-run outcomes, not authorization. Mission Run Ledger indexes run refs, not run truth. Generated mission status is a projection only. Connector operations map into existing capability packs and material-effect classes.
