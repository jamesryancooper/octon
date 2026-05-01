# Proposal Packet Closeout

Run the `closeout-proposal-packet` bundle. Refuse closeout when validation,
evidence, staging, PR checks, review conversations, archive state, or branch
sync gates are not satisfied. Red required checks start remediation rather than
status-only waiting, and final closeout is not complete until PR, merge,
branch-cleanup, and origin-sync gates are satisfied or explicitly blocked.
