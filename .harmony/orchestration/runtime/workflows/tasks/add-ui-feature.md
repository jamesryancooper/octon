---
name: "add-ui-feature"
description: "Step-by-step guide to adding a new UI feature with AI assistance."
---

# Add Ui Feature

_Generated projection from canonical pipeline `add-ui-feature`._

## Usage

```text
/add-ui-feature
```

## Target

This projection wraps the canonical pipeline `add-ui-feature` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/tasks/add-ui-feature`.

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.


# Task: Add a UI Feature

This guide walks you through adding a new UI feature using Harmony's AI-assisted workflow.

---

## Quick Version

```bash
harmony spec "user profile page showing avatar, name, and bio"
# AI generates spec with wireframe description
harmony build
# AI writes components, styles, tests
# You review in preview, approve PR
```

**Your time: 20-30 minutes**

---

## Step-by-Step

### 1. Describe What You Want

```bash
harmony spec "user profile page showing avatar, name, bio, and edit button"
```

Be specific about:
- What the user sees
- Key interactions
- Where it fits in the app

### 2. AI Generates the Spec

AI creates a spec with UI details:

```
Generating spec...

Spec Summary:
┌─────────────────────────────────────────────────────────────────┐
│ Feature: User Profile Page                                      │
│ Route: /profile/:id                                             │
│                                                                 │
│ Layout:                                                         │
│   ┌─────────────────────────────────────┐                       │
│   │  [Avatar]                           │                       │
│   │  Name                               │                       │
│   │  Bio text here...                   │                       │
│   │                        [Edit Button]│                       │
│   └─────────────────────────────────────┘                       │
│                                                                 │
│ Components:                                                     │
│   - UserProfilePage (route component)                           │
│   - UserAvatar (reusable)                                       │
│   - EditProfileButton                                           │
│                                                                 │
│ Data:                                                           │
│   - Fetches from GET /api/users/:id                             │
│   - Shows loading state                                         │
│   - Handles 404 (user not found)                                │
│                                                                 │
│ Tier: T2 (new feature)                                          │
│ Flag: feature.user-profile-page                                 │
└─────────────────────────────────────────────────────────────────┘

Does this look right? [Y/n/edit]
```

**Your review:**
- Does the layout match your vision?
- Are the components reasonable?
- Missing any states (loading, error)?

### 3. AI Builds the Feature

```bash
harmony build
```

AI generates:
- React components (following project patterns)
- CSS/Tailwind styles
- Loading and error states
- Unit tests
- Accessibility basics (ARIA labels, keyboard nav)
- Route configuration

```
Building user-profile-page...

Files created:
- src/app/profile/[id]/page.tsx
- src/components/UserAvatar.tsx
- src/components/EditProfileButton.tsx
- src/components/__tests__/UserAvatar.test.tsx
- src/components/__tests__/EditProfileButton.test.tsx

Tests:
- 6 unit tests (all passing)
- Accessibility check (passing)

Creating PR #145...
Deploying to preview...

Ready for review:
- PR: https://github.com/your-repo/pull/145
- Preview: https://preview-145.vercel.app/profile/demo-user
```

### 4. Review in Preview

This is where UI features differ from API changes—**you should actually look at it**.

```bash
# Open preview
harmony preview "#145"
```

Check:
- [ ] Does it look right?
- [ ] Does it work on mobile?
- [ ] Do interactions feel good?
- [ ] Loading state appropriate?
- [ ] Error state makes sense?

### 5. Request Changes (If Needed)

```bash
# Visual tweak
harmony refine "#145" --context "make the avatar larger, center the bio text"

# Functional change
harmony refine "#145" --context "add a back button in the header"

# AI updates the PR
```

### 6. Approve and Ship

Once it looks good:

1. Approve the PR
2. After merge: `harmony ship user-profile-page`
3. Enable flag: `harmony flag enable feature.user-profile-page --scope internal`
4. Check in production
5. Full rollout: `harmony flag enable feature.user-profile-page`

---

## Common UI Patterns

### Form Feature

```bash
harmony spec "settings form with name, email, notification preferences and save button"
```

AI will add:
- Form validation
- Submit handling
- Success/error feedback
- Dirty state tracking

### List/Table Feature

```bash
harmony spec "orders table with columns: date, items, total, status - with sorting and pagination"
```

AI will add:
- Column headers
- Sort indicators
- Pagination controls
- Empty state
- Loading skeleton

### Modal/Dialog

```bash
harmony spec "confirmation dialog when user clicks delete account"
```

AI will add:
- Focus trap
- Escape to close
- Backdrop click handling
- Proper ARIA roles

### Dashboard/Stats

```bash
harmony spec "dashboard showing total users, active sessions, and revenue chart"
```

AI will add:
- Stat cards
- Chart component
- Data fetching
- Refresh capability

---

## Styling Guidance

### Following Project Patterns

AI automatically follows your project's styling approach:
- Tailwind CSS (if present)
- CSS Modules
- Styled-components
- etc.

### Requesting Specific Styles

```bash
# Specific styling
harmony spec "dark-themed card component with rounded corners and subtle shadow"

# Match existing
harmony spec "user card matching the style of ProductCard component"

# Reference design system
harmony spec "profile page using our design system tokens"
```

### Responsive Requirements

```bash
harmony spec "profile page - stack vertically on mobile, side-by-side on desktop"
```

AI generates responsive styles by default, but you can be explicit.

---

## Accessibility

AI includes basic accessibility by default:
- Semantic HTML
- ARIA labels where needed
- Keyboard navigation
- Color contrast (follows design system)

### Requesting Enhanced Accessibility

```bash
harmony spec "form with full screen reader support and aria-live regions for errors"
```

### Checking Accessibility

```bash
# Run accessibility audit
harmony audit a11y "#145"
```

---

## Modifying After Build

### Visual Changes

```bash
harmony refine "#145" --context "change button color to blue, add more padding"
```

### Layout Changes

```bash
harmony refine "#145" --context "move edit button to top right corner"
```

### Add New Element

```bash
harmony refine "#145" --context "add a 'share profile' button below the bio"
```

### Remove Element

```bash
harmony refine "#145" --context "remove the edit button, not needed for MVP"
```

---

## Testing UI Features

### AI-Generated Tests

AI creates:
- Component render tests
- Interaction tests (clicks, form fills)
- Snapshot tests (optional)
- Accessibility tests

### Manual Testing

Always check in preview:
1. Happy path works
2. Loading state looks good
3. Error states handled
4. Mobile responsive
5. Browser back/forward works

### Request Additional Tests

```bash
harmony refine "#145" --context "add tests for keyboard navigation"
```

---

## What AI Does (Behind the Scenes)

1. **Component Design**: Determines component hierarchy and data flow
2. **Code Generation**: Creates React components following project patterns
3. **Styling**: Applies styles using project's approach (Tailwind, CSS modules, etc.)
4. **State Management**: Handles loading, error, and success states
5. **Data Fetching**: Connects to APIs using project's data fetching pattern
6. **Testing**: Creates unit and integration tests
7. **Accessibility**: Adds semantic HTML, ARIA attributes, keyboard support
8. **Route Setup**: Configures routing (Next.js, React Router, etc.)

---

## Tips

### Be Visual in Descriptions

```bash
# Good - describes what user sees
harmony spec "card showing product image on left, title and price on right, add to cart button below"

# Less useful - too abstract
harmony spec "product display component"
```

### Mention Interactions

```bash
harmony spec "dropdown menu that opens on click, closes on outside click or escape"
```

### Reference Existing Components

```bash
harmony spec "profile page using our existing Card, Button, and Avatar components"
```

### Specify States

```bash
harmony spec "comment form with disabled state while submitting, success message after"
```

---

## Troubleshooting

### Doesn't Look Right

```bash
# Be specific about what's wrong
harmony refine "#145" --context "the spacing is too tight, needs more whitespace between sections"
```

### Component Structure Wrong

```bash
# Ask AI to explain
harmony explain "#145" --aspect "component structure"

# Suggest alternative
harmony refine "#145" --context "split UserProfile into smaller components: ProfileHeader, ProfileBio, ProfileActions"
```

### Styling Conflicts

```bash
# Diagnose
harmony diagnose "#145" --focus "styling"

# AI identifies and fixes conflicts
```

### Tests Failing

```bash
# See what's failing
harmony test --pr "#145"

# Usually AI can self-fix
harmony fix-tests "#145"
```

---

## Next Steps

- [Add an API endpoint](./add-api-endpoint.md) (for backend data)
- [Handle a security issue](./handle-security-issue.md)
- Back to [DAILY-FLOW.md](/.harmony/agency/practices/daily-flow.md)

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical pipeline `add-ui-feature` |

