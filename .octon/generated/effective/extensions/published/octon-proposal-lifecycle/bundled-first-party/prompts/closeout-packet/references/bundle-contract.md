# Bundle Contract

Closeout is a gated lifecycle route. It must fail closed on failing required
checks, unresolved review conversations, unintended staging, missing evidence,
or unsafe proposal registry regeneration.

For `status: implemented` packets, closeout uses the baseline proposal-review
gate to verify preserved accepted review evidence. The strict implementation
authorization gate is pre-implementation/promotion authority and is not a
successful closeout prerequisite after a packet has already reached
`implemented`.
