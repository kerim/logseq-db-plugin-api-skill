# Query & Database Operations

## datascriptQuery - Querying DB Graphs

Use Datalog queries to find nodes by tags, properties, or content.

**Query Format for DB Graphs**:

```clojure
{:query [:find (pull ?b [*])
         :where
         [?b :block/tags ?t]
         [?t :block/title "zot"]]}
```

**Execute from Plugin**:

```typescript
// Query all items with #zot tag
const query = `
{:query [:find (pull ?b [*])
         :where
         [?b :block/tags ?t]
         [?t :block/title "zot"]]}
`

const results = await logseq.DB.datascriptQuery(query)
// results is array of tuples: [[item1], [item2], ...]

// Extract items
const items = results.map(r => r[0])
```

## Common Query Patterns

### Find All Tagged Items

```typescript
const query = `
{:query [:find (pull ?b [*])
         :where
         [?b :block/tags ?t]
         [?t :block/title "zot"]]}
`
```

### Find Items by Property Value

```typescript
// Find journal articles
const query = `
{:query [:find (pull ?b [*])
         :where
         [?b :block/tags ?t]
         [?t :block/title "zot"]
         [?b :logseq.property/itemType "journalArticle"]]}
`

// Find items by author (requires text matching)
const query = `
{:query [:find (pull ?b [*])
         :where
         [?b :block/tags ?t]
         [?t :block/title "zot"]
         [?b :logseq.property/author1 ?author]
         [(clojure.string/includes? ?author "Jane Doe")]]}
`
```

### Find Items in Collection (Multi-value Property)

```typescript
const query = `
{:query [:find (pull ?b [*])
         :where
         [?b :block/tags ?t]
         [?t :block/title "zot"]
         [?b :logseq.property/collections ?coll]
         [(contains? ?coll "Reading List")]]}
`
```

### Extract Specific Property Only

```typescript
// Just get zoteroKeys (for tracking)
const query = `
{:query [:find ?key
         :where
         [?b :block/tags ?t]
         [?t :block/title "zot"]
         [?b :logseq.property/zoteroKey ?key]]}
`

const results = await logseq.DB.datascriptQuery(query)
const zoteroKeys = results.flat()  // ['ABC123', 'DEF456', ...]
```

## Caching Query Results

**Pattern**: Cache results to avoid repeated expensive queries.

```typescript
class ZoteroTracker {
  private cachedKeys: Set<string> = new Set()

  async refreshCache() {
    const query = `
    {:query [:find ?key
             :where
             [?b :block/tags ?t]
             [?t :block/title "zot"]
             [?b :logseq.property/zoteroKey ?key]]}
    `

    const results = await logseq.DB.datascriptQuery(query)
    this.cachedKeys = new Set(results.flat())
  }

  isInGraph(zoteroKey: string): boolean {
    return this.cachedKeys.has(zoteroKey)
  }

  async afterImport() {
    // Refresh cache after new items added
    await this.refreshCache()
  }
}

// Usage
const tracker = new ZoteroTracker()
await tracker.refreshCache()

if (tracker.isInGraph('ABC123')) {
  console.log('Item already in graph')
}
```

## get-class-objects - Get All Tagged Items

Alternative to Datalog queries for simple tag-based retrieval.

```typescript
// Get all objects with #zot tag (including subclasses)
const zotItems = await logseq.API['get-class-objects']('zot')

// Returns array of block entities with the tag
```

**When to use**:
- Simple tag-based retrieval
- No complex filtering needed
- Want to include items tagged with subclasses

**When to use Datalog instead**:
- Need to filter by property values
- Complex multi-condition queries
- Need to join multiple entities
