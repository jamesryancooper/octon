# Implementation Plan

1. Extend or add validators for the mechanism index non-authority banner.
2. Add path/class checks for `state/control/**`, `state/evidence/**`,
   generated-effective, generated operator read models, raw inputs, and
   compatibility surfaces.
3. Add product feature catalog checks preserving navigation-only posture.
4. Add lifecycle interaction receipt checks proving receipts do not authorize
   target action.
5. Add proposal-program checks preventing parent evidence from satisfying child
   receipts.
6. Add retired-term checks for `Lifecycle Autopilot` outside compatibility or
   historical notes.
7. Add tests with positive and negative fixtures.
