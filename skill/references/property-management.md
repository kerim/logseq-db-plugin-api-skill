# Property Value Iteration Patterns

## Critical Understanding

In Logseq DB graphs, properties are stored directly on block objects as **namespaced keys**, NOT in `block.properties` object.

## Property Storage Format

Properties are stored with namespaced keys directly on the block object:

**Key Format**:
- User properties: `:user.property/propertyname`
- Logseq properties: `:logseq.property/propertyname`
- Plugin properties: `:plugin.property.{plugin-id}/propertyname`

**Direct Access**:
```typescript
// Read property value directly from block object
const block = await logseq.Editor.getBlock(uuid)

// Access via namespaced key (if you know the exact key name)
const value = block[':user.property/myProperty']
```

**IMPORTANT**: The `block.properties` object is unreliable for reading property values. Always use direct key access or iteration.

## Iteration Pattern for Unknown Property Names

When you don't know the exact property name or need to find properties dynamically:

```typescript
/**
 * Find and read property values by iterating over block object keys
 * Useful when property names are unknown or vary
 */
function findPropertyValue(block: BlockEntity, criteria: (key: string, value: any) => boolean): any | null {
  const blockObj = block as Record<string, any>

  for (const [key, value] of Object.entries(blockObj)) {
    // Skip non-property keys (properties start with ':')
    if (!key.startsWith(':')) continue

    // Skip non-user properties if needed
    if (!key.includes('property')) continue

    // Skip Logseq metadata properties
    if (key === ':logseq.property/created-by-ref') continue
    if (key === ':logseq.property/ls-type') continue

    // Apply custom criteria
    if (criteria(key, value)) {
      return value
    }
  }

  return null
}
```

## Type-Based Property Detection

**Real-world example**: Finding checkbox properties dynamically (from logseq-checklist plugin)

```typescript
/**
 * Gets the checkbox property value from a block
 * Finds any boolean-type property (checkbox properties are boolean)
 *
 * Source: logseq-checklist v1.0.0
 */
function getCheckboxValue(block: BlockEntity): boolean | null {
  // In Logseq DB, properties are stored directly on the block object with namespaced keys
  // Format: ':user.property/propertyname' or ':logseq.property/propertyname'
  // NOT in block.properties!

  const blockObj = block as Record<string, any>

  // Look for properties directly on the block object
  // Properties have keys starting with ':' and containing 'property'
  for (const [key, value] of Object.entries(blockObj)) {
    // Skip non-property keys
    if (!key.startsWith(':')) continue
    if (!key.includes('property')) continue
    if (key === ':logseq.property/created-by-ref') continue // Skip metadata

    // Check if it's a boolean value (checkbox properties are boolean)
    if (typeof value === 'boolean') {
      return value
    }
  }

  return null
}
```

## Type Detection Patterns

Different property types can be detected by their value types:

```typescript
function analyzeBlockProperties(block: BlockEntity): void {
  const blockObj = block as Record<string, any>

  for (const [key, value] of Object.entries(blockObj)) {
    if (!key.startsWith(':')) continue
    if (!key.includes('property')) continue

    // Type-based detection
    if (typeof value === 'boolean') {
      console.log(`Checkbox property: ${key} = ${value}`)
    } else if (typeof value === 'number') {
      console.log(`Number/DateTime property: ${key} = ${value}`)
    } else if (typeof value === 'string') {
      console.log(`String/URL property: ${key} = ${value}`)
    } else if (Array.isArray(value)) {
      console.log(`Multi-value property: ${key} = [${value.join(', ')}]`)
    } else if (typeof value === 'object' && value !== null) {
      console.log(`Entity reference property: ${key} = (entity)`)
    }
  }
}
```

## Common Use Cases

### 1. Finding Properties When Name is Unknown

```typescript
// Find first string property containing "title"
const titleValue = findPropertyValue(block, (key, value) =>
  key.includes('title') && typeof value === 'string'
)
```

### 2. Reading All User-Defined Properties

```typescript
function getUserProperties(block: BlockEntity): Record<string, any> {
  const blockObj = block as Record<string, any>
  const userProps: Record<string, any> = {}

  for (const [key, value] of Object.entries(blockObj)) {
    if (key.startsWith(':user.property/')) {
      const propName = key.replace(':user.property/', '')
      userProps[propName] = value
    }
  }

  return userProps
}
```

### 3. Filtering Blocks by Property Value Type

```typescript
async function findBlocksWithCheckboxes(parentUuid: string): Promise<BlockEntity[]> {
  const parent = await logseq.Editor.getBlock(parentUuid, { includeChildren: true })
  if (!parent?.children) return []

  const blocksWithCheckbox: BlockEntity[] = []

  function traverse(block: BlockEntity) {
    const hasCheckbox = getCheckboxValue(block) !== null
    if (hasCheckbox) {
      blocksWithCheckbox.push(block)
    }

    if (block.children && Array.isArray(block.children)) {
      for (const child of block.children) {
        if (typeof child === 'object' && 'uuid' in child) {
          traverse(child as BlockEntity)
        }
      }
    }
  }

  traverse(parent)
  return blocksWithCheckbox
}
```

## Performance Considerations

⚡ **Iteration vs Direct Access**:
- **Direct access**: `block[':user.property/name']` - Instant, O(1)
- **Iteration**: `Object.entries(block)` - Slower, O(n) where n = number of block keys
- **Recommendation**: Use direct access when property name is known, iteration only when necessary

⚡ **Optimization Strategy**:
```typescript
// Good: Direct access when name is known
const title = block[':user.property/title']

// Good: Cache iteration results if checking multiple properties
const propCache = new Map<string, any>()
for (const [key, value] of Object.entries(blockObj)) {
  if (key.startsWith(':user.property/')) {
    propCache.set(key, value)
  }
}

// Avoid: Iterating for every property read in a loop
for (const block of blocks) {
  // This is inefficient if done repeatedly
  Object.entries(block).forEach(([k, v]) => { ... })
}
```

## Critical Insights

🎯 **Why `block.properties` is unreliable**:
- API returns properties object but values are often undefined
- Actual property values stored in namespaced keys on block object
- `block.properties` mainly useful for checking if property exists, not reading values

🎯 **Metadata properties to skip**:
- `:logseq.property/created-by-ref` - Internal reference tracking
- `:logseq.property/ls-type` - Block type metadata
- `:block/*` keys - Internal block metadata
- `:db/*` keys - Database internal keys

🎯 **Multi-value properties**:
- Stored as arrays when cardinality is 'many'
- Example: `:user.property/tags = ['tag1', 'tag2', 'tag3']`
- Check with `Array.isArray(value)` before iteration

## Source Reference

These patterns are production-tested in:
- **logseq-checklist plugin v1.0.0**: `getCheckboxValue()` function
- GitHub: [https://github.com/kerim/logseq-checklist](https://github.com/kerim/logseq-checklist)
- File: `src/progress.ts` lines 57-79
