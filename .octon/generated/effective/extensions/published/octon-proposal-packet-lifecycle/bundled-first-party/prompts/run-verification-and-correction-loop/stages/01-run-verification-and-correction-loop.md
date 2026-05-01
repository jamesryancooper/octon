# Run Verification And Correction Loop

Run the packet-specific verification prompt, emit stable findings, generate
targeted correction prompts for unresolved findings, apply corrections only
inside packet scope, and repeat verification. Stop only at a declared terminal
state and retain each pass as evidence.
