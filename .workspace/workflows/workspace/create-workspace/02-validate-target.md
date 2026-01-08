# Step 2: Validate Target

## Actions

1. Confirm exactly one directory reference was provided
2. Verify target directory exists (offer to create if not)
3. Check if `.workspace/` already exists at target
   - If exists: ask to confirm before overwriting
4. Ask: **"Will an agent work here across multiple sessions, with domain-specific constraints?"**
   - **No** → Suggest a README instead; workspace is overkill
   - **Yes** → Proceed to next step

