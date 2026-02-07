---
title: ARE Loop - Tooling & Automation
description: Tool recommendations, AI prompts, and CI/CD integration
scope: shared
owner: engineering
version: 2.6.0
status: active
lastReviewed: 2025-12-11
related:
  - ./00-are-overview.md
tags:
  - documentation
  - methodology
  - tooling
  - automation
---

# ARE Loop - Tooling & Automation

This prompt covers tool recommendations for each phase, AI-assisted documentation prompts, and CI/CD integration patterns.

---

## Tool Selection Matrix

| Need | Recommended Tools | When to Use |
|------|-------------------|-------------|
| **Editing** | VS Code + Markdown, Google Docs, Notion, Confluence | Always |
| **Version Control** | Git | Always (track all changes) |
| **Readability Analysis** | Hemingway Editor, readable.io, CLI tools (textstat) | Analyze + Evaluate phases |
| **Link Checking** | markdown-link-check, Linkinator | Analyze + Refine phases |
| **Linting** | markdownlint, Vale, alex (inclusive language) | All phases |
| **Ideation/Brainstorming** | Miro, FigJam, paper/whiteboard | Refine phase (ideation) |
| **User Testing** | Maze, UserTesting, informal Zoom sessions | Evaluate phase |
| **Analytics** | Google Analytics, Plausible, PostHog | Analyze + Evaluate phases |
| **AI Assistance** | Claude, ChatGPT, Grammarly | Refine phase (drafting, editing) |
| **Surveys** | Google Forms, Typeform, Tally | Analyze + Evaluate phases |

---

## AI-Assisted Documentation Prompts

Use these prompts with AI assistants (Claude, ChatGPT, etc.) during each phase:

### Gap Analysis Prompt (Analyze Phase)

```
Review this documentation and identify gaps in: accuracy, completeness, 
readability, and usability. Prioritize issues by impact. Format as a 
numbered list with severity (High/Medium/Low).

[Paste document content]
```

### Ideation Prompt (Refine Phase)

```
Given these documentation gaps: [list gaps], suggest 3-5 solutions for each. 
Rate each solution by effort (1-5) and impact (1-5). Recommend the best 
option with rationale.
```

### Refinement Prompt (Refine Phase)

```
Rewrite this section to improve [specific criterion]. Maintain the existing 
tone and style. Target Flesch reading score of 65+. Preserve all technical 
accuracy.

[Paste section content]
```

### Evaluation Prompt (Evaluate Phase)

```
Compare these two versions of documentation. Identify improvements in: 
clarity, completeness, accuracy, and usability. Provide specific examples 
and estimate percentage improvement.

VERSION 1:
[Paste original]

VERSION 2:
[Paste revised]
```

### Terminology Consistency Prompt (Document Sets)

```
Review these documents for terminology consistency. Identify any terms that 
are used inconsistently (different spelling, capitalization, or synonyms). 
Suggest a preferred term for each inconsistency.

[Paste document excerpts or list of terms]
```

### Anti-Pattern Identification Prompt (Analyze Phase)

```
This document teaches [topic]. What are common mistakes readers might make 
when following this guidance? What anti-patterns should be explicitly 
documented? What "don't do this" guidance is missing?

[Paste document content]
```

---

## Automated Checks

### Readability Check Script (Python)

```python
#!/usr/bin/env python3
"""Check readability scores for documentation files."""

import sys
import textstat
from pathlib import Path

def check_readability(file_path: str, min_score: float = 60.0) -> bool:
    """Check if file meets minimum Flesch reading ease score."""
    content = Path(file_path).read_text()
    score = textstat.flesch_reading_ease(content)
    grade = textstat.flesch_kincaid_grade(content)
    
    print(f"{file_path}:")
    print(f"  Flesch Reading Ease: {score:.1f} (target: ≥{min_score})")
    print(f"  Flesch-Kincaid Grade: {grade:.1f}")
    
    return score >= min_score

if __name__ == "__main__":
    min_score = float(sys.argv[2]) if len(sys.argv) > 2 else 60.0
    files = list(Path(sys.argv[1]).rglob("*.md"))
    
    results = [check_readability(str(f), min_score) for f in files]
    sys.exit(0 if all(results) else 1)
```

### Link Check Command

```bash
# Using markdown-link-check
npx markdown-link-check docs/**/*.md --config .markdown-link-check.json

# Using Linkinator
npx linkinator docs/ --recurse --skip "^(?!http)"
```

### Markdown Lint Command

```bash
# Using markdownlint-cli
npx markdownlint-cli2 "docs/**/*.md"

# Check for inclusive language
npx alex docs/
```

---

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/docs-quality.yml
name: Documentation Quality

on:
  pull_request:
    paths:
      - 'docs/**'
      - '*.md'

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Lint Markdown
        uses: DavidAnson/markdownlint-cli2-action@v14
        
      - name: Check Links
        uses: lycheeverse/lychee-action@v1
        with:
          args: --verbose --no-progress 'docs/**/*.md'
          
      - name: Readability Score
        run: |
          pip install textstat
          python scripts/check-readability.py docs/ --min-score 60
          
      - name: Inclusive Language
        uses: get-alex/alex@v1
```

### Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.37.0
    hooks:
      - id: markdownlint
        args: ['--fix']
        
  - repo: https://github.com/tcort/markdown-link-check
    rev: v3.11.2
    hooks:
      - id: markdown-link-check
        args: ['--config', '.markdown-link-check.json']
```

### Markdown Link Check Config

```json
{
  "ignorePatterns": [
    { "pattern": "^http://localhost" }
  ],
  "replacementPatterns": [
    { "pattern": "^/", "replacement": "{{BASEURL}}/" }
  ],
  "httpHeaders": [
    {
      "urls": ["https://github.com"],
      "headers": {
        "Accept-Encoding": "zstd, br, gzip, deflate"
      }
    }
  ],
  "timeout": "20s",
  "retryOn429": true,
  "retryCount": 3,
  "fallbackRetryDelay": "30s"
}
```

---

## Measurement Tools

### Analytics Integration

```javascript
// Track documentation engagement (example with Plausible)
document.addEventListener('DOMContentLoaded', function() {
  // Track time on page
  let startTime = Date.now();
  
  window.addEventListener('beforeunload', function() {
    let timeSpent = Math.round((Date.now() - startTime) / 1000);
    plausible('Doc Engagement', {
      props: {
        page: window.location.pathname,
        timeSpent: timeSpent
      }
    });
  });
  
  // Track scroll depth
  let maxScroll = 0;
  window.addEventListener('scroll', function() {
    let scrollPercent = Math.round(
      (window.scrollY / (document.body.scrollHeight - window.innerHeight)) * 100
    );
    maxScroll = Math.max(maxScroll, scrollPercent);
  });
});
```

### User Feedback Widget

```html
<!-- Simple feedback widget -->
<div class="doc-feedback">
  <p>Was this page helpful?</p>
  <button onclick="sendFeedback('yes')">👍 Yes</button>
  <button onclick="sendFeedback('no')">👎 No</button>
</div>

<script>
function sendFeedback(value) {
  // Send to analytics or feedback system
  plausible('Doc Feedback', {
    props: {
      page: window.location.pathname,
      helpful: value
    }
  });
}
</script>
```

---

## Tool Selection by Phase

### Analyze Phase Tools

| Task | Tool | Purpose |
|------|------|---------|
| Read document | VS Code, web browser | Initial review |
| Check readability | Hemingway, textstat | Flesch score |
| Check links | markdown-link-check | Find broken links |
| Gather feedback | Google Forms, Typeform | User data collection |
| Review analytics | GA, Plausible | Usage patterns |

### Refine Phase Tools

| Task | Tool | Purpose |
|------|------|---------|
| Brainstorm | Miro, FigJam | Generate ideas |
| Research | Web browser | Benchmark review |
| Edit | VS Code | Make changes |
| Lint | markdownlint | Style consistency |
| AI assist | Claude, ChatGPT | Drafting, rewrites |

### Evaluate Phase Tools

| Task | Tool | Purpose |
|------|------|---------|
| Measure readability | textstat | Before/after comparison |
| User testing | Maze, Zoom | Task completion |
| Collect feedback | Forms, Slack | Qualitative data |
| Compare versions | diff, VS Code | Change review |

---

## Recommended Minimum Toolset

For teams just starting with ARE Loop:

| Category | Tool | Cost | Setup Time |
|----------|------|------|------------|
| Editing | VS Code + Markdown | Free | 5 min |
| Version Control | Git/GitHub | Free | Already have |
| Linting | markdownlint | Free | 10 min |
| Links | markdown-link-check | Free | 5 min |
| Readability | Hemingway Editor | Free (web) | 0 min |
| Feedback | Google Forms | Free | 15 min |

**Total setup time**: ~35 minutes

---

*Tools should support the methodology, not replace it. Start simple and add tooling as needed.*
