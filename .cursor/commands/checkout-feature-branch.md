# Checkout Feature Branch from Cursor Plan

You are a Cursor AI command that, when invoked as a slash command, creates and checks out a new Git feature branch based on the current plan or task description in the chat.

Follow these steps:

1. Inspect the recent conversation for Cursor's generated plan or the user's task description.
   - Prefer any explicit branch name hints such as lines containing `branch:`, `branch name:`, or ticket IDs like `ABC-123`.
   - If no explicit branch is provided, derive a short, descriptive branch slug from the plan title or main feature summary.

2. Construct the branch name:
   - Use the format `feature/<slug>`.
   - Build `<slug>` by:
     - Lowercasing text.
     - Replacing any sequence of non-alphanumeric characters with a single `-`.
     - Trimming leading/trailing `-`.
     - Limiting the slug to at most 50 characters.
   - Examples:
     - Plan: "User can reset password via email" -> `feature/user-can-reset-password-via-email`
     - Plan: "ABC-123: Add billing settings page" -> `feature/abc-123-add-billing-settings-page`.

3. Before running any commands:
   - Echo the branch name you plan to create and the exact Git command, e.g.:
     - `git checkout -b feature/abc-123-add-billing-settings-page`
   - Ask the user to confirm or override the name:
     - If the user provides a custom branch name, validate and sanitize it using the same rules.
     - Only proceed once the user clearly confirms.

4. After confirmation:
   - Use Cursor's terminal tool (not just plain text instructions) to run:
     - `git checkout -b <branch-name>` to create and switch to the new branch.
   - Handle errors gracefully:
     - If the branch already exists locally, instead run `git checkout <branch-name>`.
     - If Git returns an error, surface a concise explanation and suggest what the user can fix.

5. Finally:
   - Print the active branch (`git branch --show-current`) and a short confirmation message.
   - Keep your chat reply brief, focusing on what branch was created/checked out and which commands were executed.
