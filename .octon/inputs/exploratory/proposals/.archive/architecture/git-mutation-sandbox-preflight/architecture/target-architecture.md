# Target Architecture

Closeout routes diagnose permission-sensitive git mutations before attempting
or retrying them. Diagnostics identify the operation class, expected authority
route, likely sandbox or host permission blocker, and the owning rerun path.

Diagnostics do not authorize mutation. They only make blocked git operations
observable and routeable through the correct approval or retry surface.
