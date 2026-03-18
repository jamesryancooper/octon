# Plan Invariants

1. Plan output includes a canonical `plan` object.
2. Every plan step has a stable step identifier.
3. Dependencies reference declared step ids only.
4. Invalid graph structures fail closed.
