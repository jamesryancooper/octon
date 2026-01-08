# Tool Recommendations

| Category            | Must-Have                        | Should-Have                                   | Consider                                            | Avoid                                          |
| ------------------- | -------------------------------- | --------------------------------------------- | --------------------------------------------------- | ---------------------------------------------- |
| Schema validation   | **Zod**                          | TypeScript typegen helpers                    | JSON Schema export tooling                          | Ad-hoc regex parsing                           |
| Markdown processing | `remark`/`unified` + frontmatter | Markdown directives (for restricted includes) | Markdoc for constrained tags/transclusion           | "MDX everywhere" for agent-authored prose      |
| Build-time index    | **SQLite + better-sqlite3**      | Incremental build cache                       | libSQL/Turso/Cloudflare D1 (only if runtime needed) | "Every framework parses content itself"        |
| Search              | Pagefind                         | FTS5 in SQLite                                | Orama (vector/hybrid)                               | Hosted search SaaS by default                  |
| Optional GUI        | None                             | GitHub web editor + PR previews               | Keystatic / Decap for SMEs                          | Custom GUI (scope creep) ; full CMS by default |

Notes:

- "Contentlayer maintenance status uncertain" is explicitly flagged as an Avoid in v1.
