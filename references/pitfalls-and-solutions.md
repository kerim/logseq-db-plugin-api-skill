# Common Pitfalls & Solutions

## Pitfall 1: Tag Creation Validation Errors

**Problem**: `createTag()` fails silently or returns null.

**Causes**:
- Tag name is blank
- Tag name contains forward slashes
- Tag name is not a string
- Tag already exists

**Solution**:

```typescript
async function safeCreateTag(tagName: string) {
  // Validate input
  if (!tagName || typeof tagName !== 'string') {
    throw new Error('Tag name must be a non-empty string')
  }

  if (tagName.includes('/')) {
    throw new Error('Tag name cannot contain forward slashes')
  }

  // Try to create
  const tag = await logseq.Editor.createTag(tagName)

  if (!tag) {
    // Check if already exists
    const existing = await logseq.Editor.getTag(tagName)
    if (existing) {
      console.log(`Tag #${tagName} already exists`)
      return existing
    } else {
      throw new Error(`Failed to create tag #${tagName}`)
    }
  }

  return tag
}
```

## Pitfall 2: Property Name Conflicts

**Problem**: Properties not appearing or causing errors.

**Cause**: Using reserved property names like `created`, `modified`.

**Solution**: Use alternative names.

```typescript
// ❌ DON'T
properties: {
  created: new Date().toISOString(),
  modified: new Date().toISOString()
}

// ✅ DO
properties: {
  dateAdded: new Date().toISOString().split('T')[0],    // YYYY-MM-DD
  dateModified: new Date().toISOString().split('T')[0]
}
```

## Pitfall 3: Query Tag Matching Issues

**Problem**: Query returns no results even though tagged items exist.

**Cause**: Using `:db/ident` for custom tags instead of `:block/title`.

**Solution**: Always use `:block/title` for tag matching in queries.

```clojure
;; ❌ WRONG - :db/ident only works for built-in tags
{:query [:find (pull ?b [*])
         :where
         [?b :block/tags ?t]
         [?t :db/ident :logseq.class/zot]]}  ;; zot is custom!

;; ✅ CORRECT - :block/title works for all tags
{:query [:find (pull ?b [*])
         :where
         [?b :block/tags ?t]
         [?t :block/title "zot"]]}
```

## Pitfall 4: Multi-value Property Querying

**Problem**: Can't query multi-value properties properly.

**Solution**: Use `contains?` for arrays.

```clojure
;; ❌ WRONG - Direct equality doesn't work for arrays
{:query [:find (pull ?b [*])
         :where
         [?b :logseq.property/collections "Reading List"]]}

;; ✅ CORRECT - Use contains? for multi-value
{:query [:find (pull ?b [*])
         :where
         [?b :logseq.property/collections ?coll]
         [(contains? ?coll "Reading List")]]}
```

## Pitfall 5: Date Property Formatting

**Problem**: Date properties not recognized or linking incorrectly.

**Cause**: Wrong date format.

**Solution**: Use `YYYY-MM-DD` format for dates.

```typescript
// ❌ WRONG formats
properties: {
  date: '2023/05/15',           // Wrong separator
  date: '05-15-2023',           // Wrong order
  date: '2023-05-15T10:30:00',  // Use dateTime if you need time
}

// ✅ CORRECT
properties: {
  date: '2023-05-15',           // Date only
  dateTime: '2023-05-15T10:30:00',  // Date + time
}
```

## Pitfall 6: Property Auto-hide Assumptions

**Problem**: Expecting properties to be set even when empty.

**Reality**: In DB graphs, empty properties are automatically hidden.

**Best Practice**: Set all possible properties, even if empty. They'll auto-hide.

```typescript
// Don't conditionally set properties - just set them all!
properties: {
  title: item.title || '',           // Empty string is fine
  author1: authors[0] || '',         // Will hide if empty
  author2: authors[1] || '',         // Will hide if empty
  DOI: item.DOI || '',               // Will hide if empty
  year: item.year || 0,              // Will hide if 0
  collections: item.collections || []  // Will hide if empty array
}
```

## Pitfall 7: Property Value Dereferencing

**Problem**: `getPage()` returns entity IDs instead of actual values.

**Example**:
```typescript
const page = await logseq.Editor.getPage(pageUuid)
console.log(page[':plugin.property.my-plugin/title'])  // → 189 (entity ID!)
```

**Cause**: Properties are stored as entity references in Logseq DB.

**Solution**: Use Datalog queries with proper pull patterns to dereference.

```typescript
// ❌ WRONG - Using getPage()
const page = await logseq.Editor.getPage(pageUuid)
const title = page.properties?.title  // undefined or entity ID

// ✅ CORRECT - Using Datalog query
const query = `
{:query [:find (pull ?b [:block/uuid
                         :plugin.property.my-plugin/title])
         :where
         [?b :block/uuid "${pageUuid}"]]}`

const results = await logseq.DB.datascriptQuery(query)
const page = results[0]?.[0]
const title = page[':plugin.property.my-plugin/title']  // "Actual Title"
```

**Reference**: See [logseq-tag-schema-poc](https://github.com/kerim/logseq-tag-schema-poc) for detailed examples.

## Pitfall 8: Wrong Tag Method Names

**Problem**: Code using `addTag()` or `removeTag()` throws "method not found" or "function is not defined" errors.

**Example Error**:
```
TypeError: logseq.Editor.addTag is not a function
```

**Cause**: Incorrect method names from outdated documentation or incorrect assumptions.

**Solution**: Use the correct method names from LSPlugin.ts:

```typescript
// ❌ WRONG - These methods don't exist
await logseq.Editor.addTag(blockUuid, 'myTag')
await logseq.Editor.removeTag(blockUuid, 'myTag')

// ✅ CORRECT - Use Block prefix
await logseq.Editor.addBlockTag(blockUuid, 'myTag')
await logseq.Editor.removeBlockTag(blockUuid, 'myTag')
```

**Why This Matters**:
- The API uses `addBlockTag` and `removeBlockTag` (with "Block" in the name)
- This distinguishes them from other tag operations like `addTagProperty` or `addTagExtends`
- Using the wrong name will cause runtime errors that break your plugin

**Quick Fix**:
If you have existing code using the wrong names, do a find-and-replace:
- Find: `logseq.Editor.addTag(`
- Replace: `logseq.Editor.addBlockTag(`

- Find: `logseq.Editor.removeTag(`
- Replace: `logseq.Editor.removeBlockTag(`
