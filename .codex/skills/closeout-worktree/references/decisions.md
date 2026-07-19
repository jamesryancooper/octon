# Decisions

- Unambiguous candidates are classified and preserved; they are not delegated.
- Ambiguous, unsafe, protected, or foreign candidates remain preserved with a
  candidate-keyed blocker.
- Omitted/default targets resolve to `preserved`, not `cleaned`.
- Publication, landing, sync, cleanup, branch deletion, and Git/GitHub requests
  stop with `RP00_CONTAINMENT_PUBLICATION_DISABLED`.
- RP-06/RP-08 may be named as later owners but are not invoked.
