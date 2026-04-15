# Implementation Plan

1. Define the effective metadata shape and placement under the generated
   effective extension family.
2. Update the extension publisher to emit structured skill registry metadata
   from pack-local registry fragments.
3. Extend extension publication validation to enforce the new output.
4. Update capability routing publication if needed so extension skill metadata
   comes from the effective surface rather than raw pack rereads.
5. Add or update tests proving the new metadata is emitted and consumed.
