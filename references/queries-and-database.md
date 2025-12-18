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

## Advanced Query Patterns

### Tag Inheritance with or-join

**Problem**: In Logseq DB, tags can extend other tags (e.g., `#shopping` extends `#task`). Simple queries only find items directly tagged, missing items with child tags.

**Solution**: Use `or-join` to query both direct tags AND tags that extend the parent tag.

**The `:logseq.property.class/extends` Attribute**:
- Tags store their parent relationships in `:logseq.property.class/extends`
- Value is an entity reference: `[{:db/id 140}]` where `140` is the parent tag's ID
- Use Datalog to traverse this relationship

**Working Pattern**:

```typescript
// Find all tasks (direct #task OR any tag that extends #task)
const query = `
{:query [:find (pull ?b [*])
         :where
         (or-join [?b]
           ;; Branch 1: Blocks directly tagged with #task
           (and [?b :block/tags ?t]
                [?t :block/title "task"])
           ;; Branch 2: Blocks tagged with tags that extend #task
           (and [?b :block/tags ?child]
                [?child :logseq.property.class/extends ?parent]
                [?parent :block/title "task"]))]}
`

const results = await logseq.DB.datascriptQuery(query)
const allTasks = results.map(r => r[0])
```

**This finds**:
- Items tagged with `#task` directly
- Items tagged with `#shopping`, `#feedback`, `#question`, etc. (any tag extending `#task`)

**Combining with Filters**:

```typescript
// Find TODO tasks with priority (including child tags)
const query = `
{:query [:find (pull ?b [*])
         :where
         (or-join [?b]
           (and [?b :block/tags ?t]
                [?t :block/title "task"])
           (and [?b :block/tags ?child]
                [?child :logseq.property.class/extends ?parent]
                [?parent :block/title "task"]))
         [?b :logseq.property/status ?s]
         [?s :block/title "Todo"]
         [?b :logseq.property/priority ?p]]}
`
```

**Why `or-join` is Required**:

Standard `or` clauses require all branches to have identical free variables. This fails:

```clojure
;; ❌ WRONG - Variable mismatch error
(or
  (and [?b :block/tags ?t] [?t :block/title "task"])
  (and [?b :block/tags ?child] [?child :logseq.property.class/extends ?parent] [?parent :block/title "task"]))

;; Error: All clauses in 'or' must use same set of free vars,
;; had [#{?b ?t} #{?b ?child ?parent}]
```

**Fix with `or-join`**:

```clojure
;; ✅ CORRECT - Explicitly declare ?b must unify
(or-join [?b]
  (and [?b :block/tags ?t] [?t :block/title "task"])
  (and [?b :block/tags ?child] [?child :logseq.property.class/extends ?parent] [?parent :block/title "task"]))
```

The `[?b]` explicitly states "only `?b` must be the same across branches."

**Setting Up Tag Inheritance**:

See [core-apis.md](./core-apis.md#tag-inheritance) for how to create tag hierarchies with `addTagExtends()`.

### `:block/title` vs `:block/name` for Tags

Tags have two attributes for their name:

| Attribute | Format | Use Case | Example |
|-----------|--------|----------|---------|
| `:block/title` | Display name (case-sensitive) | Queries, display | `"Task"` |
| `:block/name` | Normalized (lowercase) | Internal ID, CLI queries | `"task"` |

**In Queries**:

```clojure
;; ✅ RECOMMENDED - Use :block/title (matches display)
[?t :block/title "Task"]

;; Also works - Use :block/name (normalized)
[?t :block/name "task"]
```

**When to use each**:
- **`:block/title`**: Use in plugin queries and app query blocks (matches what users see)
- **`:block/name`**: Use for case-insensitive matching or when you have normalized input
- **This documentation**: Uses `:block/title` throughout for consistency

**Why both exist**:
- `:block/title` preserves user's capitalization
- `:block/name` enables case-insensitive lookups and URL-safe identifiers

### Query Context: Plugin vs App vs CLI

The same Datalog syntax works across different contexts:

**In Plugin Code**:
```typescript
const query = `{:query [:find (pull ?b [*]) :where ...]}`
const results = await logseq.DB.datascriptQuery(query)
```

**In Logseq App Query Blocks**:
```clojure
{:query [:find (pull ?b [*])
         :where
         [?b :block/tags ?t]
         [?t :block/title "task"]]}
```

**In CLI**:
```bash
logseq query "[:find (pull ?b [*]) :where [?b :block/tags ?t] [?t :block/title \"task\"]]" -g "graph-name"
```

**Key Differences**:
- **Syntax**: Same Datalog, different string wrapping
- **Format**: CLI can use bare vectors `[:find ...]`, others need `{:query [...]}`
- **Execution**: Same database, same results

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
