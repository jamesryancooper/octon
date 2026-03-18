---
title: React Native Rules - Critical
description: Critical impact rendering and list-performance rules.
version: "1.0.1"
---

# Critical Rules

## 1. Core Rendering

**Impact: CRITICAL**

Fundamental React Native rendering rules. Violations cause
runtime crashes or broken UI.

### 1.1 Never Use && with Potentially Falsy Values

**Impact: CRITICAL (prevents production crash)**

Never use `{value && <Component />}` when `value` could be an empty string or

`0`. These are falsy but JSX-renderable—React Native will try to render them as

text outside a `<Text>` component, causing a hard crash in production.

**Incorrect: crashes if count is 0 or name is ""**

```tsx
function Profile({ name, count }: { name: string; count: number }) {
  return (
    <View>
      {name && <Text>{name}</Text>}
      {count && <Text>{count} items</Text>}
    </View>
  )
}
// If name="" or count=0, renders the falsy value → crash
```

**Correct: ternary with null**

```tsx
function Profile({ name, count }: { name: string; count: number }) {
  return (
    <View>
      {name ? <Text>{name}</Text> : null}
      {count ? <Text>{count} items</Text> : null}
    </View>
  )
}
```

**Correct: explicit boolean coercion**

```tsx
function Profile({ name, count }: { name: string; count: number }) {
  return (
    <View>
      {!!name && <Text>{name}</Text>}
      {!!count && <Text>{count} items</Text>}
    </View>
  )
}
```

**Best: early return**

```tsx
function Profile({ name, count }: { name: string; count: number }) {
  if (!name) return null

  return (
    <View>
      <Text>{name}</Text>
      {count > 0 ? <Text>{count} items</Text> : null}
    </View>
  )
}
```

Early returns are clearest. When using conditionals inline, prefer ternary or

explicit boolean checks.

**Lint rule:** Enable `react/jsx-no-leaked-render` from

[eslint-plugin-react](https://github.com/jsx-eslint/eslint-plugin-react/blob/master/docs/rules/jsx-no-leaked-render.md)

to catch this automatically.

### 1.2 Wrap Strings in Text Components

**Impact: CRITICAL (prevents runtime crash)**

Strings must be rendered inside `<Text>`. React Native crashes if a string is a

direct child of `<View>`.

**Incorrect: crashes**

```tsx
import { View } from 'react-native'

function Greeting({ name }: { name: string }) {
  return <View>Hello, {name}!</View>
}
// Error: Text strings must be rendered within a <Text> component.
```

**Correct:**

```tsx
import { View, Text } from 'react-native'

function Greeting({ name }: { name: string }) {
  return (
    <View>
      <Text>Hello, {name}!</Text>
    </View>
  )
}
```

---

## 2. List Performance

**Impact: HIGH**

Optimizing virtualized lists (FlatList, LegendList, FlashList)
for smooth scrolling and fast updates.

### 2.1 Avoid Inline Objects in renderItem

**Impact: HIGH (prevents unnecessary re-renders of memoized list items)**

Don't create new objects inside `renderItem` to pass as props. Inline objects

create new references on every render, breaking memoization. Pass primitive

values directly from `item` instead.

**Incorrect: inline object breaks memoization**

```tsx
function UserList({ users }: { users: User[] }) {
  return (
    <LegendList
      data={users}
      renderItem={({ item }) => (
        <UserRow
          // Bad: new object on every render
          user={{ id: item.id, name: item.name, avatar: item.avatar }}
        />
      )}
    />
  )
}
```

**Incorrect: inline style object**

```tsx
renderItem={({ item }) => (
  <UserRow
    name={item.name}
    // Bad: new style object on every render
    style={{ backgroundColor: item.isActive ? 'green' : 'gray' }}
  />
)}
```

**Correct: pass item directly or primitives**

```tsx
function UserList({ users }: { users: User[] }) {
  return (
    <LegendList
      data={users}
      renderItem={({ item }) => (
        // Good: pass the item directly
        <UserRow user={item} />
      )}
    />
  )
}
```

**Correct: pass primitives, derive inside child**

```tsx
renderItem={({ item }) => (
  <UserRow
    id={item.id}
    name={item.name}
    isActive={item.isActive}
  />
)}

const UserRow = memo(function UserRow({ id, name, isActive }: Props) {
  // Good: derive style inside memoized component
  const backgroundColor = isActive ? 'green' : 'gray'
  return <View style={[styles.row, { backgroundColor }]}>{/* ... */}</View>
})
```

**Correct: hoist static styles in module scope**

```tsx
const activeStyle = { backgroundColor: 'green' }
const inactiveStyle = { backgroundColor: 'gray' }

renderItem={({ item }) => (
  <UserRow
    name={item.name}
    // Good: stable references
    style={item.isActive ? activeStyle : inactiveStyle}
  />
)}
```

Passing primitives or stable references allows `memo()` to skip re-renders when

the actual values haven't changed.

**Note:** If you have the React Compiler enabled, it handles memoization

automatically and these manual optimizations become less critical.

### 2.2 Hoist callbacks to the root of lists

**Impact: MEDIUM (Fewer re-renders and faster lists)**

When passing callback functions to list items, create a single instance of the

callback at the root of the list. Items should then call it with a unique

identifier.

**Incorrect: creates a new callback on each render**

```typescript
return (
  <LegendList
    renderItem={({ item }) => {
      // bad: creates a new callback on each render
      const onPress = () => handlePress(item.id)
      return <Item key={item.id} item={item} onPress={onPress} />
    }}
  />
)
```

**Correct: a single function instance passed to each item**

```typescript
const onPress = useCallback(() => handlePress(item.id), [handlePress, item.id])

return (
  <LegendList
    renderItem={({ item }) => (
      <Item key={item.id} item={item} onPress={onPress} />
    )}
  />
)
```

Reference: [https://example.com](https://example.com)

### 2.3 Keep List Items Lightweight

**Impact: HIGH (reduces render time for visible items during scroll)**

List items should be as inexpensive as possible to render. Minimize hooks, avoid

queries, and limit React Context access. Virtualized lists render many items

during scroll—expensive items cause jank.

**Incorrect: heavy list item**

```tsx
function ProductRow({ id }: { id: string }) {
  // Bad: query inside list item
  const { data: product } = useQuery(['product', id], () => fetchProduct(id))
  // Bad: multiple context accesses
  const theme = useContext(ThemeContext)
  const user = useContext(UserContext)
  const cart = useContext(CartContext)
  // Bad: expensive computation
  const recommendations = useMemo(
    () => computeRecommendations(product),
    [product]
  )

  return <View>{/* ... */}</View>
}
```

**Correct: lightweight list item**

```tsx
function ProductRow({ name, price, imageUrl }: Props) {
  // Good: receives only primitives, minimal hooks
  return (
    <View>
      <Image source={{ uri: imageUrl }} />
      <Text>{name}</Text>
      <Text>{price}</Text>
    </View>
  )
}
```

**Move data fetching to parent:**

```tsx
// Parent fetches all data once
function ProductList() {
  const { data: products } = useQuery(['products'], fetchProducts)

  return (
    <LegendList
      data={products}
      renderItem={({ item }) => (
        <ProductRow name={item.name} price={item.price} imageUrl={item.image} />
      )}
    />
  )
}
```

**For shared values, use Zustand selectors instead of Context:**

```tsx
// Incorrect: Context causes re-render when any cart value changes
function ProductRow({ id, name }: Props) {
  const { items } = useContext(CartContext)
  const inCart = items.includes(id)
  // ...
}

// Correct: Zustand selector only re-renders when this specific value changes
function ProductRow({ id, name }: Props) {
  // use Set.has (created once at the root) instead of Array.includes()
  const inCart = useCartStore((s) => s.items.has(id))
  // ...
}
```

**Guidelines for list items:**

- No queries or data fetching

- No expensive computations (move to parent or memoize at parent level)

- Prefer Zustand selectors over React Context

- Minimize useState/useEffect hooks

- Pass pre-computed values as props

The goal: list items should be simple rendering functions that take props and

return JSX.

### 2.4 Optimize List Performance with Stable Object References

**Impact: CRITICAL (virtualization relies on reference stability)**

Don't map or filter data before passing to virtualized lists. Virtualization

relies on object reference stability to know what changed—new references cause

full re-renders of all visible items. Attempt to prevent frequent renders at the

list-parent level.

Where needed, use context selectors within list items.

**Incorrect: creates new object references on every keystroke**

```tsx
function DomainSearch() {
  const { keyword, setKeyword } = useKeywordZustandState()
  const { data: tlds } = useTlds()

  // Bad: creates new objects on every render, reparenting the entire list on every keystroke
  const domains = tlds.map((tld) => ({
    domain: `${keyword}.${tld.name}`,
    tld: tld.name,
    price: tld.price,
  }))

  return (
    <>
      <TextInput value={keyword} onChangeText={setKeyword} />
      <LegendList
        data={domains}
        renderItem={({ item }) => <DomainItem item={item} keyword={keyword} />}
      />
    </>
  )
}
```

**Correct: stable references, transform inside items**

```tsx
const renderItem = ({ item }) => <DomainItem tld={item} />

function DomainSearch() {
  const { data: tlds } = useTlds()

  return (
    <LegendList
      // good: as long as the data is stable, LegendList will not re-render the entire list
      data={tlds}
      renderItem={renderItem}
    />
  )
}

function DomainItem({ tld }: { tld: Tld }) {
  // good: transform within items, and don't pass the dynamic data as a prop
  // good: use a selector function from zustand to receive a stable string back
  const domain = useKeywordZustandState((s) => s.keyword + '.' + tld.name)
  return <Text>{domain}</Text>
}
```

**Updating parent array reference:**

```tsx
// good: creates a new array instance without mutating the inner objects
// good: parent array reference is unaffected by typing and updating "keyword"
const sortedTlds = tlds.toSorted((a, b) => a.name.localeCompare(b.name))

return <LegendList data={sortedTlds} renderItem={renderItem} />
```

Creating a new array instance can be okay, as long as its inner object

references are stable. For instance, if you sort a list of objects:

Even though this creates a new array instance `sortedTlds`, the inner object

references are stable.

**With zustand for dynamic data: avoids parent re-renders**

```tsx
function DomainItemFavoriteButton({ tld }: { tld: Tld }) {
  const isFavorited = useFavoritesStore((s) => s.favorites.has(tld.id))
  return <TldFavoriteButton isFavorited={isFavorited} />
}
```

Virtualization can now skip items that haven't changed when typing. Only visible

items (~20) re-render on keystroke, rather than the parent.

**Deriving state within list items based on parent data (avoids parent

re-renders):**

For components where the data is conditional based on the parent state, this

pattern is even more important. For example, if you are checking if an item is

favorited, toggling favorites only re-renders one component if the item itself

is in charge of accessing the state rather than the parent:

Note: if you're using the React Compiler, you can read React Context values

directly within list items. Although this is slightly slower than using a

Zustand selector in most cases, the effect may be negligible.

### 2.5 Pass Primitives to List Items for Memoization

**Impact: HIGH (enables effective memo() comparison)**

When possible, pass only primitive values (strings, numbers, booleans) as props

to list item components. Primitives enable shallow comparison in `memo()` to

work correctly, skipping re-renders when values haven't changed.

**Incorrect: object prop requires deep comparison**

```tsx
type User = { id: string; name: string; email: string; avatar: string }

const UserRow = memo(function UserRow({ user }: { user: User }) {
  // memo() compares user by reference, not value
  // If parent creates new user object, this re-renders even if data is same
  return <Text>{user.name}</Text>
})

renderItem={({ item }) => <UserRow user={item} />}
```

This can still be optimized, but it is harder to memoize properly.

**Correct: primitive props enable shallow comparison**

```tsx
const UserRow = memo(function UserRow({
  id,
  name,
  email,
}: {
  id: string
  name: string
  email: string
}) {
  // memo() compares each primitive directly
  // Re-renders only if id, name, or email actually changed
  return <Text>{name}</Text>
})

renderItem={({ item }) => (
  <UserRow id={item.id} name={item.name} email={item.email} />
)}
```

**Pass only what you need:**

```tsx
// Incorrect: passing entire item when you only need name
<UserRow user={item} />

// Correct: pass only the fields the component uses
<UserRow name={item.name} avatarUrl={item.avatar} />
```

**For callbacks, hoist or use item ID:**

```tsx
// Incorrect: inline function creates new reference
<UserRow name={item.name} onPress={() => handlePress(item.id)} />

// Correct: pass ID, handle in child
<UserRow id={item.id} name={item.name} />

const UserRow = memo(function UserRow({ id, name }: Props) {
  const handlePress = useCallback(() => {
    // use id here
  }, [id])
  return <Pressable onPress={handlePress}><Text>{name}</Text></Pressable>
})
```

Primitive props make memoization predictable and effective.

**Note:** If you have the React Compiler enabled, you do not need to use

`memo()` or `useCallback()`, but the object references still apply.

### 2.6 Use a List Virtualizer for Any List

**Impact: HIGH (reduced memory, faster mounts)**

Use a list virtualizer like LegendList or FlashList instead of ScrollView with

mapped children—even for short lists. Virtualizers only render visible items,

reducing memory usage and mount time. ScrollView renders all children upfront,

which gets expensive quickly.

**Incorrect: ScrollView renders all items at once**

```tsx
function Feed({ items }: { items: Item[] }) {
  return (
    <ScrollView>
      {items.map((item) => (
        <ItemCard key={item.id} item={item} />
      ))}
    </ScrollView>
  )
}
// 50 items = 50 components mounted, even if only 10 visible
```

**Correct: virtualizer renders only visible items**

```tsx
import { LegendList } from '@legendapp/list'

function Feed({ items }: { items: Item[] }) {
  return (
    <LegendList
      data={items}
      // if you aren't using React Compiler, wrap these with useCallback
      renderItem={({ item }) => <ItemCard item={item} />}
      keyExtractor={(item) => item.id}
      estimatedItemSize={80}
    />
  )
}
// Only ~10-15 visible items mounted at a time
```

**Alternative: FlashList**

```tsx
import { FlashList } from '@shopify/flash-list'

function Feed({ items }: { items: Item[] }) {
  return (
    <FlashList
      data={items}
      // if you aren't using React Compiler, wrap these with useCallback
      renderItem={({ item }) => <ItemCard item={item} />}
      keyExtractor={(item) => item.id}
    />
  )
}
```

Benefits apply to any screen with scrollable content—profiles, settings, feeds,

search results. Default to virtualization.

### 2.7 Use Compressed Images in Lists

**Impact: HIGH (faster load times, less memory)**

Always load compressed, appropriately-sized images in lists. Full-resolution

images consume excessive memory and cause scroll jank. Request thumbnails from

your server or use an image CDN with resize parameters.

**Incorrect: full-resolution images**

```tsx
function ProductItem({ product }: { product: Product }) {
  return (
    <View>
      {/* 4000x3000 image loaded for a 100x100 thumbnail */}
      <Image
        source={{ uri: product.imageUrl }}
        style={{ width: 100, height: 100 }}
      />
      <Text>{product.name}</Text>
    </View>
  )
}
```

**Correct: request appropriately-sized image**

```tsx
function ProductItem({ product }: { product: Product }) {
  // Request a 200x200 image (2x for retina)
  const thumbnailUrl = `${product.imageUrl}?w=200&h=200&fit=cover`

  return (
    <View>
      <Image
        source={{ uri: thumbnailUrl }}
        style={{ width: 100, height: 100 }}
        contentFit='cover'
      />
      <Text>{product.name}</Text>
    </View>
  )
}
```

Use an optimized image component with built-in caching and placeholder support,

such as `expo-image` or `SolitoImage` (which uses `expo-image` under the hood).

Request images at 2x the display size for retina screens.

### 2.8 Use Item Types for Heterogeneous Lists

**Impact: HIGH (efficient recycling, less layout thrashing)**

When a list has different item layouts (messages, images, headers, etc.), use a

`type` field on each item and provide `getItemType` to the list. This puts items

into separate recycling pools so a message component never gets recycled into an

image component.

[LegendList getItemType](https://legendapp.com/open-source/list/api/props/#getitemtype-v2)

**Incorrect: single component with conditionals**

```tsx
type Item = { id: string; text?: string; imageUrl?: string; isHeader?: boolean }

function ListItem({ item }: { item: Item }) {
  if (item.isHeader) {
    return <HeaderItem title={item.text} />
  }
  if (item.imageUrl) {
    return <ImageItem url={item.imageUrl} />
  }
  return <MessageItem text={item.text} />
}

function Feed({ items }: { items: Item[] }) {
  return (
    <LegendList
      data={items}
      renderItem={({ item }) => <ListItem item={item} />}
      recycleItems
    />
  )
}
```

**Correct: typed items with separate components**

```tsx
type HeaderItem = { id: string; type: 'header'; title: string }
type MessageItem = { id: string; type: 'message'; text: string }
type ImageItem = { id: string; type: 'image'; url: string }
type FeedItem = HeaderItem | MessageItem | ImageItem

function Feed({ items }: { items: FeedItem[] }) {
  return (
    <LegendList
      data={items}
      keyExtractor={(item) => item.id}
      getItemType={(item) => item.type}
      renderItem={({ item }) => {
        switch (item.type) {
          case 'header':
            return <SectionHeader title={item.title} />
          case 'message':
            return <MessageRow text={item.text} />
          case 'image':
            return <ImageRow url={item.url} />
        }
      }}
      recycleItems
    />
  )
}
```

**Why this matters:**

```tsx
<LegendList
  data={items}
  keyExtractor={(item) => item.id}
  getItemType={(item) => item.type}
  getEstimatedItemSize={(index, item, itemType) => {
    switch (itemType) {
      case 'header':
        return 48
      case 'message':
        return 72
      case 'image':
        return 300
      default:
        return 72
    }
  }}
  renderItem={({ item }) => {
    /* ... */
  }}
  recycleItems
/>
```

- **Recycling efficiency**: Items with the same type share a recycling pool

- **No layout thrashing**: A header never recycles into an image cell

- **Type safety**: TypeScript can narrow the item type in each branch

- **Better size estimation**: Use `getEstimatedItemSize` with `itemType` for

  accurate estimates per type

---

