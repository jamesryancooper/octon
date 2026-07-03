# Target Architecture

Receipt writers should distinguish new proof from repeated equivalent proof.

The target architecture can include:

- content-addressed full logs;
- compact latest pointers;
- bounded per-run or per-producer indexes;
- digest verification;
- explicit retained evidence references;
- refusal when compact summaries cannot retrieve full proof.

Receipt compaction may treat two receipts as equivalent only when command or
publisher identity, semantic input digests, effective source digests,
validator or publisher version, environment-relevant options, result, output
digest, retained proof digest, and evidence obligation are identical.
