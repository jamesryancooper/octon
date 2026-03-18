---
title: React Native Rules - Low
description: Lower impact dependency and ecosystem rules.
version: "1.0.1"
---

# Low Impact Rules

## 11. Monorepo

**Impact: LOW**

Dependency management and native module configuration in
monorepos.

### 11.1 Install Native Dependencies in App Directory

**Impact: CRITICAL (required for autolinking to work)**

In a monorepo, packages with native code must be installed in the native app's

directory directly. Autolinking only scans the app's `node_modules`—it won't

find native dependencies installed in other packages.

**Incorrect: native dep in shared package only**

```typescript
packages/
  ui/
    package.json  # has react-native-reanimated
  app/
    package.json  # missing react-native-reanimated
```

Autolinking fails—native code not linked.

**Correct: native dep in app directory**

```json
// packages/app/package.json
{
  "dependencies": {
    "react-native-reanimated": "3.16.1"
  }
}
```

Even if the shared package uses the native dependency, the app must also list it

for autolinking to detect and link the native code.

### 11.2 Use Single Dependency Versions Across Monorepo

**Impact: MEDIUM (avoids duplicate bundles, version conflicts)**

Use a single version of each dependency across all packages in your monorepo.

Prefer exact versions over ranges. Multiple versions cause duplicate code in

bundles, runtime conflicts, and inconsistent behavior across packages.

Use a tool like syncpack to enforce this. As a last resort, use yarn resolutions

or npm overrides.

**Incorrect: version ranges, multiple versions**

```json
// packages/app/package.json
{
  "dependencies": {
    "react-native-reanimated": "^3.0.0"
  }
}

// packages/ui/package.json
{
  "dependencies": {
    "react-native-reanimated": "^3.5.0"
  }
}
```

**Correct: exact versions, single source of truth**

```json
// package.json (root)
{
  "pnpm": {
    "overrides": {
      "react-native-reanimated": "3.16.1"
    }
  }
}

// packages/app/package.json
{
  "dependencies": {
    "react-native-reanimated": "3.16.1"
  }
}

// packages/ui/package.json
{
  "dependencies": {
    "react-native-reanimated": "3.16.1"
  }
}
```

Use your package manager's override/resolution feature to enforce versions at

the root. When adding dependencies, specify exact versions without `^` or `~`.

---

## 12. Third-Party Dependencies

**Impact: LOW**

Wrapping and re-exporting third-party dependencies for
maintainability.

### 12.1 Import from Design System Folder

**Impact: LOW (enables global changes and easy refactoring)**

Re-export dependencies from a design system folder. App code imports from there,

not directly from packages. This enables global changes and easy refactoring.

**Incorrect: imports directly from package**

```tsx
import { View, Text } from 'react-native'
import { Button } from '@ui/button'

function Profile() {
  return (
    <View>
      <Text>Hello</Text>
      <Button>Save</Button>
    </View>
  )
}
```

**Correct: imports from design system**

```tsx
import { View } from '@/components/view'
import { Text } from '@/components/text'
import { Button } from '@/components/button'

function Profile() {
  return (
    <View>
      <Text>Hello</Text>
      <Button>Save</Button>
    </View>
  )
}
```

Start by simply re-exporting. Customize later without changing app code.

---

## 13. JavaScript

**Impact: LOW**

Micro-optimizations like hoisting expensive object creation.

### 13.1 Hoist Intl Formatter Creation

**Impact: LOW-MEDIUM (avoids expensive object recreation)**

Don't create `Intl.DateTimeFormat`, `Intl.NumberFormat`, or

`Intl.RelativeTimeFormat` inside render or loops. These are expensive to

instantiate. Hoist to module scope when the locale/options are static.

**Incorrect: new formatter every render**

```tsx
function Price({ amount }: { amount: number }) {
  const formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  })
  return <Text>{formatter.format(amount)}</Text>
}
```

**Correct: hoisted to module scope**

```tsx
const currencyFormatter = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
})

function Price({ amount }: { amount: number }) {
  return <Text>{currencyFormatter.format(amount)}</Text>
}
```

**For dynamic locales, memoize:**

```tsx
const dateFormatter = useMemo(
  () => new Intl.DateTimeFormat(locale, { dateStyle: 'medium' }),
  [locale]
)
```

**Common formatters to hoist:**

```tsx
// Module-level formatters
const dateFormatter = new Intl.DateTimeFormat('en-US', { dateStyle: 'medium' })
const timeFormatter = new Intl.DateTimeFormat('en-US', { timeStyle: 'short' })
const percentFormatter = new Intl.NumberFormat('en-US', { style: 'percent' })
const relativeFormatter = new Intl.RelativeTimeFormat('en-US', {
  numeric: 'auto',
})
```

Creating `Intl` objects is significantly more expensive than `RegExp` or plain

objects—each instantiation parses locale data and builds internal lookup tables.

---

## 14. Fonts

**Impact: LOW**

Native font loading for improved performance.

### 14.1 Load fonts natively at build time

**Impact: LOW (fonts available at launch, no async loading)**

Use the `expo-font` config plugin to embed fonts at build time instead of

`useFonts` or `Font.loadAsync`. Embedded fonts are more efficient.

[Expo Font Documentation](https://docs.expo.dev/versions/latest/sdk/font/)

**Incorrect: async font loading**

```tsx
import { useFonts } from 'expo-font'
import { Text, View } from 'react-native'

function App() {
  const [fontsLoaded] = useFonts({
    'Geist-Bold': require('./assets/fonts/Geist-Bold.otf'),
  })

  if (!fontsLoaded) {
    return null
  }

  return (
    <View>
      <Text style={{ fontFamily: 'Geist-Bold' }}>Hello</Text>
    </View>
  )
}
```

**Correct: config plugin, fonts embedded at build**

```tsx
import { Text, View } from 'react-native'

function App() {
  // No loading state needed—font is already available
  return (
    <View>
      <Text style={{ fontFamily: 'Geist-Bold' }}>Hello</Text>
    </View>
  )
}
```

After adding fonts to the config plugin, run `npx expo prebuild` and rebuild the

native app.

---

