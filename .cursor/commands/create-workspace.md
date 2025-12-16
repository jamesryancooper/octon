# Create Workspace `/create-workspace`

Scaffold a new `.workspace` directory in a target location, customized to the directory's context.

## Usage

```
/create-workspace @path/to/target/directory
```

## Instructions

1. **Validate target**
   - Confirm the user included exactly one `@Files` or `@Folders` reference pointing to a directory
   - Verify the target directory exists (offer to create if not)
   - Check if `.workspace/` already exists (ask to confirm before overwriting)

2. **Analyze directory context**
   - List contents: `ls -la <target>`
   - Identify directory type:
     | Indicators | Type |
     |------------|------|
     | `package.json`, `src/`, `*.ts/js` | Code (Node/JS) |
     | `pyproject.toml`, `*.py` | Code (Python) |
     | `*.md`, `docs/` | Documentation |
     | `*.yaml`, `*.json`, `Dockerfile` | Config/Infrastructure |
     | Mixed | Hybrid |
   - Read `README.md` if present for context
   - Check for existing conventions (`.eslintrc`, `.prettierrc`, `.editorconfig`)
   - Note any test files, CI configs, or build scripts

3. **Gather context from user**
   
   Ask these questions (can skip if obvious from analysis):
   
   - **Scope:** "What is this directory for?" (1-2 sentences)
   - **In-scope work:** "What types of work happen here?"
   - **Out-of-scope:** "What should NOT be done here?" (belongs elsewhere)
   - **Quality checks:** "What must be verified before work is complete?"
   - **Setup requirements:** "Any prerequisites to work here?" (deps, env vars, build)

4. **Create directory structure**
   ```
   .workspace/
   ├── START.md
   ├── scope.md
   ├── conventions.md
   ├── progress/
   │   ├── log.md
   │   └── tasks.json
   └── checklists/
       └── done.md
   ```

5. **Customize templates based on context**

   | File | Customize With |
   |------|----------------|
   | `scope.md` | User's scope description, in/out of scope answers |
   | `conventions.md` | Detected naming patterns, file types |
   | `done.md` | User's quality checks, detected test/lint configs |
   | `START.md` | Setup requirements, key entry points found |
   | `tasks.json` | Initial tasks based on directory state |
   | `log.md` | Creation context and initial analysis |

6. **Populate customized content**

   **scope.md:**
   - Replace `{{SCOPE_DESCRIPTION}}` with user's scope
   - Fill "In Scope" with work types
   - Fill "Out of Scope" with boundaries
   - Add "Adjacent Areas" if sibling directories exist

   **conventions.md:**
   - Match file naming to detected patterns
   - Adjust document structure for content type
   - Add domain-specific style notes

   **done.md:**
   - Add detected quality gates (tests, lint, build)
   - Include user's quality checks
   - Add domain-specific verification steps

   **START.md:**
   - Add setup prerequisites if any
   - Point to key files/entry points
   - Customize "When Stuck" for domain

   **tasks.json:**
   - Add context-appropriate initial tasks:
     | Directory State | Initial Tasks |
     |-----------------|---------------|
     | Empty/new | "Define structure", "Create initial content" |
     | Has code | "Document current state", "Identify priorities" |
     | Has docs | "Audit existing content", "Identify gaps" |

7. **Verify and summarize**
   - List all created files
   - Show customizations made
   - Suggest next steps: "Run boot sequence in START.md"

> Reference: `.workspace/workflows/create-workspace.md` for detailed workflow
