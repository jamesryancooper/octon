# Source Artifact

## Preferred Hardening Design To Promote

The preferred fix for prompt evolution hardening is:

1. add an authored prompt-set contract inside the pack
2. add a validator and publisher for the prompt set
3. publish an effective prompt bundle rather than relying on raw Markdown reads
4. make `alignment_mode=auto` fail closed when prompt freshness is stale or
   alignment fails
5. record prompt provenance in every run
6. ideally reuse the native prompt compilation service for deterministic prompt
   bundle rendering and hashing

This packet turns that design into a concrete Octon architecture change.
