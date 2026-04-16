---
name: logseq-db-plugin-api
version: 2.2.0
description: Essential knowledge for developing Logseq plugins for DB (database) graphs. Layered: (1) authoritative upstream docs mirrored from logseq/logseq master, (2) production-tested patterns from logseq-checklist v1.0.0, (3) related skills (Datascript schema, Electron debugging). Covers core APIs, event-driven updates, multi-layered tag detection, property iteration, advanced query patterns.
---

# Logseq DB Plugin API Skill

Comprehensive guidance for building Logseq plugins for **DB (database) graphs**, organized into three layers: authoritative upstream documentation, production-tested patterns, and related sibling skills.

## Overview

This skill provides essential knowledge for building Logseq plugins that work with the new DB graph architecture. It covers:

- **Core APIs**: Tag/class management, property handling, block operations
- **Production Patterns**: Event-driven updates, tag detection, property iteration
- **Plugin Architecture**: File organization, settings, error handling, testing
- **Common Pitfalls**: Validation errors, query issues, property dereferencing

## When to Use This Skill

Use this skill when developing Logseq plugins that:

- Work with **DB graphs** (not markdown graphs)
- Need to create/manage tags and properties programmatically
- Respond to database changes in real-time (DB.onChanged)
- Query the graph database with Datalog
- Handle complex tag detection or property iteration
- Require production-ready architecture patterns

## Key Differences: DB vs. Markdown Plugins

| Aspect | Markdown Graphs | DB Graphs |
|--------|----------------|-----------|
| **Data Storage** | Files (.md) | Database (SQLite) |
| **Properties** | YAML frontmatter | Typed database entities |
| **Tags** | Simple text markers | Classes with schemas |
| **Queries** | File-based attributes | Datalog / Database relationships |
| **Property Access** | Text parsing | Namespaced keys (`:user.property/name`) |

## Prerequisites

- **Logseq**: 0.11.0+ (for full DB graph support)
- **@logseq/libs**: 0.3.0+ (minimum for DB graphs)
- **Node.js**: 18+ recommended
- **Build tools**: Vite + vite-plugin-logseq

## Layer 1: Authoritative Upstream Docs

**Precedence**: Layer 1 is authoritative ground truth for API contracts. Layer 2 adds production-validated context and patterns not covered by official docs. When they conflict, **Layer 1 wins on API facts**; **Layer 2 wins on real-world pitfalls** (things that work on paper but fail in practice).

**Source**: mirrored verbatim from [logseq/logseq `libs/development-notes/`](https://github.com/logseq/logseq/tree/master/libs/development-notes) via `scripts/sync-logseq-docs.sh`. Each file carries a footer recording upstream commit SHA and fetch timestamp. License: AGPL-3.0 (see [`references/logseq-official/LICENSE`](./references/logseq-official/LICENSE)).

| File | Covers |
|------|--------|
| [`references/logseq-official/AGENTS.md`](./references/logseq-official/AGENTS.md) | AI-agent development guide — SDK repo structure, core patterns, conventions |
| [`references/logseq-official/starter_guide.md`](./references/logseq-official/starter_guide.md) | Plugin setup walkthrough: Node/TypeScript install, Logseq dev environment, hello world |
| [`references/logseq-official/db_properties_skill.md`](./references/logseq-official/db_properties_skill.md) | DB properties SDK reference — schema definition, tags-as-classes, property operations |
| [`references/logseq-official/db_properties_guide.md`](./references/logseq-official/db_properties_guide.md) | File graph vs DB graph properties — text vs typed entities, SDK API differences |
| [`references/logseq-official/db_query_guide.md`](./references/logseq-official/db_query_guide.md) | Datascript query guide — `logseq.DB.q`, `datascriptQuery`, parameterized Datalog |
| [`references/logseq-official/db_tag_property_idents_notes.md`](./references/logseq-official/db_tag_property_idents_notes.md) | Ident system — namespace conventions (`:logseq.property/`, `:plugin.property.*`), when idents apply |
| [`references/logseq-official/experiments_api_guide.md`](./references/logseq-official/experiments_api_guide.md) | `logseq.Experiments` — React integration, custom renderers, script loading, ClojureScript interop |

**Refresh**: `bash scripts/sync-logseq-docs.sh` from repo root. Idempotent — no-op if upstream HEAD matches `.last-synced-sha`.

## Layer 2: Production Patterns

Battle-tested code from real-world plugin development. All patterns validated through [logseq-checklist v1.0.0](https://github.com/kerim/logseq-checklist).

### Unique contributions (not in official docs)

**[Tag Detection](./references/tag-detection.md)** — Reliable multi-layered detection
Three-tier approach (content → datascript → properties) for maximum reliability when `block.properties.tags` fails.

**Search for**: `hasTag`, `block.properties.tags undefined`, `multi-layered`

**[Pitfalls & Solutions](./references/pitfalls-and-solutions.md)** — Errors and fixes discovered in production
Tag creation validation, property conflicts, query syntax mistakes, `or-join` variable mismatches, method-name errors.

**Search for**: `validation errors`, `query returns no results`, `addTag not a function`

### Supplementary (may overlap with Layer 1 — cross-linked where relevant)

**[Event Handling](./references/event-handling.md)** — DB.onChanged patterns
Database change detection, datom filtering, debouncing strategies. Essential for plugins that maintain derived state.

**Search for**: `DB.onChanged`, `debouncing`, `transaction datoms`

**[Property Management](./references/property-management.md)** — Reading property values
Iteration patterns for unknown property names, type-based detection, namespaced key access.

**Search for**: `property iteration`, `namespaced keys`, `:user.property/`

**[Core APIs](./references/core-apis.md)** — Essential methods
Tag/class management, page/block creation, property operations, icons, utilities.

**Search for**: `createTag`, `addBlockTag`, `upsertProperty`, `createPage`

**[Queries and Database](./references/queries-and-database.md)** — Datalog patterns
Query syntax, common patterns, caching strategies, tag inheritance with `or-join`, `:block/title` vs `:block/name`.

**Search for**: `datascriptQuery`, `datalog`, `caching`, `or-join`, `tag inheritance`

**[Plugin Architecture](./references/plugin-architecture.md)** — Best practices
File organization, settings registration, error handling, testing strategy, deployment checklist.

**Search for**: `file organization`, `settings schema`, `production patterns`

## Layer 3: Related Skills

For specialized concerns, defer to sibling skills with their own activation triggers:

| Skill | Use for |
|-------|---------|
| **`logseq-schema`** (RCmerci) | Authoritative Datascript schema reference when writing Datalog queries — covers entity attributes, relationships, cardinality. Install from [github.com/RCmerci/skills](https://github.com/RCmerci/skills). |
| **`logseq-electron-debug`** (RCmerci) | Chrome DevTools against a running Logseq app — useful when debugging your plugin's runtime behavior. Install from [github.com/RCmerci/skills](https://github.com/RCmerci/skills). |
| **`logseq-db-knowledge`** | Foundational DB graph concepts — use alongside this skill for understanding why DB graphs work the way they do. |
| **`logseq-cli-skill`** | Logseq CLI usage — Datalog queries run from shell, useful for bulk operations outside plugins. |

## Quick Start

### 1. Project Setup

```bash
mkdir my-logseq-plugin
cd my-logseq-plugin
pnpm init
pnpm add @logseq/libs
pnpm add -D typescript vite vite-plugin-logseq @types/node
mkdir src
```

### 2. Essential Files

**src/index.ts** — Entry point:
```typescript
import '@logseq/libs'

async function main() {
  console.log('Plugin loaded')
  // Register settings, initialize features
}

logseq.ready(main).catch(console.error)
```

**vite.config.ts**:
```typescript
import { defineConfig } from 'vite'
import logseqDevPlugin from 'vite-plugin-logseq'

export default defineConfig({
  plugins: [logseqDevPlugin()],
  build: { target: 'esnext', minify: 'esbuild', sourcemap: true }
})
```

**package.json**:
```json
{
  "name": "my-logseq-plugin",
  "version": "0.0.1",
  "main": "dist/index.js",
  "scripts": { "build": "vite build", "dev": "vite build --watch" },
  "logseq": { "id": "my-logseq-plugin", "title": "My Logseq Plugin", "main": "dist/index.html" }
}
```

### 3. Development Workflow

```bash
pnpm run dev              # Watch mode
pnpm run build            # Production build
# Load plugin: Settings → Plugins → Load unpacked plugin
```

## Core Concepts

### Property Storage

Properties in DB graphs are stored as **namespaced keys** on block objects:

```typescript
const block = await logseq.Editor.getBlock(uuid)

// Direct access
const value = block[':user.property/myProperty']

// Iteration (if name unknown)
for (const [key, value] of Object.entries(block)) {
  if (key.startsWith(':user.property/')) { /* ... */ }
}
```

**CRITICAL**: `block.properties.tags` and `block.properties[name]` are often unreliable. Use direct key access or iteration instead.

### Tag Detection

Simple property checks fail. Use multi-layered detection — see [references/tag-detection.md](./references/tag-detection.md) for the full pattern.

```typescript
// Tier 1: Content check (fast)
if (block.content.includes('#mytag')) return true

// Tier 2: Datascript query (reliable)
const results = await logseq.DB.datascriptQuery(
  `[:find (pull ?b [*]) :where [?b :block/tags ?t] [?t :block/title "mytag"]]`
)

// Tier 3: Properties fallback (rarely works)
if (block.properties?.tags?.includes('mytag')) return true
```

### Event-Driven Updates

For plugins that maintain derived state:

```typescript
if (logseq.DB?.onChanged) {
  logseq.DB.onChanged((changeData) => {
    const { txData } = changeData
    for (const [entityId, attribute, value, txId, added] of txData) {
      if (attribute.includes('property')) scheduleUpdate(entityId)
    }
  })
}
```

See [references/event-handling.md](./references/event-handling.md) for debouncing strategies.

### Property Type Definition

Always define property types before using them:

```typescript
await logseq.Editor.upsertProperty('title', { type: 'string' })
await logseq.Editor.upsertProperty('year', { type: 'number' })
await logseq.Editor.upsertProperty('published', { type: 'checkbox' })
await logseq.Editor.upsertProperty('modifiedAt', { type: 'datetime' })

await logseq.Editor.createPage('Item', {
  title: 'My Item',
  year: 2024,
  published: true,
  modifiedAt: Date.now()
})
```

## Essential Workflows

### Creating Tagged Pages with Properties

```typescript
// 1. Create tag
const tag = await logseq.Editor.createTag('zot')

// 2. Define properties FIRST
await logseq.Editor.upsertProperty('title', { type: 'string' })
await logseq.Editor.upsertProperty('author', { type: 'string' })
await logseq.Editor.upsertProperty('year', { type: 'number' })

// 3. Add properties to tag schema (parent frame API)
const parentLogseq = (window as any).parent?.logseq
await parentLogseq.api.add_tag_property(tag.uuid, 'title')
await parentLogseq.api.add_tag_property(tag.uuid, 'author')
await parentLogseq.api.add_tag_property(tag.uuid, 'year')

// 4. Create page with tag and properties
await logseq.Editor.createPage('My Item', {
  tags: ['zot'],
  title: 'Paper Title',
  author: 'Jane Doe',
  year: 2024
})
```

### Querying Tagged Items

```typescript
const query = `
{:query [:find (pull ?b [*])
         :where
         [?b :block/tags ?t]
         [?t :block/title "zot"]]}
`
const results = await logseq.DB.datascriptQuery(query)
```

**Tag Hierarchies** (items tagged with `#task` OR any tag extending `#task`):

```typescript
const query = `
{:query [:find (pull ?b [*])
         :where
         (or-join [?b]
           (and [?b :block/tags ?t]
                [?t :block/title "task"])
           (and [?b :block/tags ?child]
                [?child :logseq.property.class/extends ?parent]
                [?parent :block/title "task"]))]}
`
```

See [references/queries-and-database.md](./references/queries-and-database.md) for advanced patterns.

### Responding to Database Changes

```typescript
const pendingUpdates = new Set<string>()
let updateTimer: NodeJS.Timeout | null = null

function handleDatabaseChanges(changeData: any): void {
  const txData = changeData?.txData || []
  for (const [entityId, attribute, value, txId, added] of txData) {
    if (attribute.includes('property')) {
      pendingUpdates.add(String(entityId))
      if (updateTimer) clearTimeout(updateTimer)
      updateTimer = setTimeout(async () => {
        for (const id of pendingUpdates) await updateBlock(id)
        pendingUpdates.clear()
      }, 300)
    }
  }
}
```

## Architecture Recommendations

**File Structure**:
```
src/
├── index.ts         # Entry point, initialization
├── events.ts        # DB.onChanged handlers, debouncing
├── logic.ts         # Pure business logic (testable)
├── settings.ts      # Settings schema and accessors
└── types.ts         # TypeScript interfaces
```

**Settings Registration**:
```typescript
import { SettingSchemaDesc } from '@logseq/libs/dist/LSPlugin.user'

const settings: SettingSchemaDesc[] = [
  {
    key: 'tagName',
    type: 'string',
    title: 'Tag Name',
    description: 'Tag to monitor',
    default: 'mytag'
  }
]

logseq.useSettingsSchema(settings)
```

See [references/plugin-architecture.md](./references/plugin-architecture.md) for error handling, testing, and deployment.

## Common Mistakes to Avoid

1. **Wrong method names**: Use `addBlockTag()` not `addTag()`
2. **Property access**: Don't rely on `block.properties.tags` — iterate namespaced keys
3. **Query syntax**: Use `:block/title` not `:db/ident` for custom tags
4. **Type definition**: Define property types before using them
5. **Reserved names**: Avoid `created`, `modified` — use `dateAdded`, `dateModified`
6. **Date format**: Use `YYYY-MM-DD` for date properties
7. **Entity references**: Use Datalog queries to dereference, not `getPage()`

See [references/pitfalls-and-solutions.md](./references/pitfalls-and-solutions.md) for detailed solutions.

## Version Requirements

- **Logseq**: 0.11.0+ (for full DB graph support)
- **@logseq/libs**: 0.3.0+ (minimum for DB graphs), 0.2.8+ recommended
- **Graph type**: Database graphs only (not markdown/file-based graphs)

## Getting Help

When encountering issues:

1. **Check Layer 1 first** — official upstream docs are authoritative for API contracts
2. **Check Common Pitfalls** ([references/pitfalls-and-solutions.md](./references/pitfalls-and-solutions.md)) — production-observed gotchas not in official docs
3. **Search Reference Files** — grep patterns listed above
4. **Check logseq-checklist source** — real working implementation
5. **DevTools Console** — Cmd/Ctrl+Shift+I for runtime errors
6. **Invoke `logseq-electron-debug` skill** (RCmerci) — for debugging Logseq itself

## Summary

Three layers, in order of priority:

1. **Layer 1 — Official upstream docs** (ground truth for API contracts)
2. **Layer 2 — Production patterns** (tag-detection + pitfalls are unique contributions; others supplement Layer 1)
3. **Layer 3 — Related skills** (logseq-schema, logseq-electron-debug, logseq-db-knowledge, logseq-cli-skill)

Load the files you need for the current task. Layer 1 answers "what does the API do"; Layer 2 answers "what breaks in practice"; Layer 3 answers adjacent concerns that deserve their own skill activation.
