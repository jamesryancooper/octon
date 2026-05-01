# Generate Program Correction Prompt

Create a bounded correction prompt for one program finding. Preserve finding
ownership as parent, child, child-group, or cross-packet dependency. Do not let
parent correction override child `proposal.yml`, subtype manifests, acceptance
criteria, validation verdicts, or promotion targets.
