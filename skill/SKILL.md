---
name: logseq-db-plugin-api
version: 2.1.0
description: Build Logseq DB graph plugins: core APIs, DB.onChanged events, tag detection, property iteration, Datalog queries with tag inheritance, production-tested patterns from logseq-checklist v1.0.0.
dependencies: Logseq>=0.11.0, @logseq/libs>=0.3.0, Node.js>=18, vite, vite-plugin-logseq
---

# Logseq DB Plugin API Skill

Comprehensive guidance for building Logseq plugins for **DB (database) graphs**, with production-tested patterns from real-world plugins.

## Overview

This skill provides essential knowledge for building Logseq plugins that work with the new DB graph architecture. It covers:

- **Core APIs**: Tag/class management, property handling, block operations
- **Production Patterns**: Event-driven updates, tag detection, property iteration
- **Plugin Architecture**: File organization, settings, error handling, testing
- **Common Pitfalls**: Validation errors, query issues, property dereferencing

All patterns are validated through production use in [logseq-checklist v1.0.0](https://github.com/kerim/logseq-checklist).

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

## Reference Files

The skill provides detailed documentation in modular reference files:

### Production Patterns (Load These First)

**[Event Handling](./references/event-handling.md)** - DB.onChanged patterns
Database change detection, datom filtering, debouncing strategies. Essential for plugins that maintain derived state.

**Search for**: `DB.onChanged`, `debouncing`, `transaction datoms`

**[Tag Detection](./references/tag-detection.md)** - Reliable multi-layered detection
Three-tier approach (content → datascript → properties) for maximum reliability when `block.properties.tags` fails.

**Search for**: `hasTag`, `block.properties.tags undefined`, `multi-layered`

**[Property Management](./references/property-management.md)** - Reading property values
Iteration patterns for unknown property names, type-based detection, namespaced key access.

**Search for**: `property iteration`, `namespaced keys`, `:user.property/`

**[Plugin Architecture](./references/plugin-architecture.md)** - Best practices
File organization, settings registration, error handling, testing strategy, deployment checklist.

**Search for**: `file organization`, `settings schema`, `production patterns`

### API Reference

**[Core APIs](./references/core-apis.md)** - Essential methods
Tag/class management, page/block creation, property operations, icons, utilities.

**Search for**: `createTag`, `addBlockTag`, `upsertProperty`, `createPage`

**[Queries and Database](./references/queries-and-database.md)** - Datalog patterns
Query syntax, common patterns, caching strategies, tag inheritance with or-join, :block/title vs :block/name.

**Search for**: `datascriptQuery`, `datalog`, `caching`, `query patterns`, `or-join`, `tag inheritance`, `:logseq.property.class/extends`

### Troubleshooting

**[Common Pitfalls](./references/pitfalls-and-solutions.md)** - Errors and fixes
Tag creation errors, property conflicts, query issues, method name mistakes.

**Search for**: `validation errors`, `query returns no results`, `addTag not a function`

## Quick Start

### 1. Project Setup

```bash
# Create plugin directory
mkdir my-logseq-plugin
cd my-logseq-plugin

# Initialize project
pnpm init
pnpm add @logseq/libs
pnpm add -D typescript vite vite-plugin-logseq @types/node

# Create src/ directory
mkdir src
```

### 2. Essential Files

**src/index.ts** - Entry point:
```typescript
import '@logseq/libs'

async function main() {
  console.log('Plugin loaded')

  // Register settings, initialize features
}

logseq.ready(main).catch(console.error)
```

**vite.config.ts** - Build configuration:
```typescript
import { defineConfig } from 'vite'
import logseqDevPlugin from 'vite-plugin-logseq'

export default defineConfig({
  plugins: [logseqDevPlugin()],
  build: {
    target: 'esnext',
    minify: 'esbuild',
    sourcemap: true
  }
})
```

**package.json** - Metadata and scripts:
```json
{
  "name": "my-logseq-plugin",
  "version": "0.0.1",
  "main": "dist/index.js",
  "scripts": {
    "build": "vite build",
    "dev": "vite build --watch"
  },
  "logseq": {
    "id": "my-logseq-plugin",
    "title": "My Logseq Plugin",
    "main": "dist/index.html"
  }
}
```

### 3. Development Workflow

```bash
# Development mode (watch for changes)
pnpm run dev

# Load plugin in Logseq:
# Settings → Plugins → Load unpacked plugin → Select plugin directory

# Production build
pnpm run build

# Create release
# Zip the entire plugin directory and upload to GitHub releases
```

## Core Concepts

### Property Storage

In DB graphs, properties are stored as **namespaced keys** on block objects:

```typescript
const block = await logseq.Editor.getBlock(uuid)

// Direct access (if you know the name)
const value = block[':user.property/myProperty']

// Iteration (if name unknown)
for (const [key, value] of Object.entries(block)) {
  if (key.startsWith(':user.property/')) {
    // Found a user property
  }
}
```

**CRITICAL**: `block.properties.tags` and `block.properties[name]` are often unreliable. Use direct key access or iteration instead.

### Tag Detection

Simple property checks fail. Use multi-layered detection:

```typescript
// Tier 1: Content check (fast)
if (block.content.includes('#mytag')) return true

// Tier 2: Datascript query (reliable)
const query = `[:find (pull ?b [*])
                :where [?b :block/tags ?t] [?t :block/title "mytag"]]`
const results = await logseq.DB.datascriptQuery(query)
// Check if block.uuid in results

// Tier 3: Properties fallback (rarely works)
if (block.properties?.tags?.includes('mytag')) return true
```

See [references/tag-detection.md](./references/tag-detection.md) for complete implementation.

### Event-Driven Updates

For plugins that maintain derived state (progress indicators, aggregations):

```typescript
if (logseq.DB?.onChanged) {
  logseq.DB.onChanged((changeData) => {
    const { txData } = changeData

    // Filter for relevant changes
    for (const [entityId, attribute, value, txId, added] of txData) {
      if (attribute.includes('property')) {
        scheduleUpdate(entityId)  // Debounced
      }
    }
  })
}
```

See [references/event-handling.md](./references/event-handling.md) for debouncing strategies and complete examples.

### Property Type Definition

Always define property types before using them:

```typescript
// During plugin initialization
await logseq.Editor.upsertProperty('title', { type: 'string' })
await logseq.Editor.upsertProperty('year', { type: 'number' })
await logseq.Editor.upsertProperty('published', { type: 'checkbox' })
await logseq.Editor.upsertProperty('modifiedAt', { type: 'datetime' })

// Now safe to use throughout plugin
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
// 1. Create tag (if doesn't exist)
const tag = await logseq.Editor.createTag('zot')

// 2. Define properties FIRST
await logseq.Editor.upsertProperty('title', { type: 'string' })
await logseq.Editor.upsertProperty('author', { type: 'string' })
await logseq.Editor.upsertProperty('year', { type: 'number' })

// 3. Add properties to tag schema (using parent frame API)
const parentLogseq = (window as any).parent?.logseq
await parentLogseq.api.add_tag_property(tag.uuid, 'title')
await parentLogseq.api.add_tag_property(tag.uuid, 'author')
await parentLogseq.api.add_tag_property(tag.uuid, 'year')

// 4. Create page with tag and properties
await logseq.Editor.createPage('My Item', {
  tags: ['zot'],      // Assign tag
  title: 'Paper Title',
  author: 'Jane Doe',
  year: 2024
})
```

### Querying Tagged Items

```typescript
// Find all items with #zot tag
const query = `
{:query [:find (pull ?b [*])
         :where
         [?b :block/tags ?t]
         [?t :block/title "zot"]]}
`

const results = await logseq.DB.datascriptQuery(query)
const items = results.map(r => r[0])

// Filter by property value
const query = `
{:query [:find (pull ?b [*])
         :where
         [?b :block/tags ?t]
         [?t :block/title "zot"]
         [?b :logseq.property/year 2024]]}
`
```

**Querying Tag Hierarchies**:

```typescript
// Find items with #task OR any tag that extends #task (e.g., #shopping, #feedback)
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

const results = await logseq.DB.datascriptQuery(query)
const allTasks = results.map(r => r[0])
```

See [references/queries-and-database.md](./references/queries-and-database.md) for advanced patterns including tag inheritance, or-join usage, and query context differences.

### Responding to Database Changes

```typescript
import { IDatom } from './types'

const pendingUpdates = new Set<string>()
let updateTimer: NodeJS.Timeout | null = null

function handleDatabaseChanges(changeData: any): void {
  const txData: IDatom[] = changeData?.txData || []

  for (const [entityId, attribute, value, txId, added] of txData) {
    if (attribute.includes('property')) {
      // Schedule debounced update
      pendingUpdates.add(String(entityId))

      if (updateTimer) clearTimeout(updateTimer)
      updateTimer = setTimeout(async () => {
        for (const id of pendingUpdates) {
          await updateBlock(id)
        }
        pendingUpdates.clear()
      }, 300)
    }
  }
}
```

See [references/event-handling.md](./references/event-handling.md) for complete implementation.

## Architecture Recommendations

Follow production-tested patterns:

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

See [references/plugin-architecture.md](./references/plugin-architecture.md) for complete guidance including error handling, testing, and deployment.

## Common Mistakes to Avoid

1. **Wrong method names**: Use `addBlockTag()` not `addTag()`
2. **Property access**: Don't rely on `block.properties.tags` - iterate namespaced keys
3. **Query syntax**: Use `:block/title` not `:db/ident` for custom tags
4. **Type definition**: Define property types before using them
5. **Reserved names**: Avoid `created`, `modified` - use `dateAdded`, `dateModified`
6. **Date format**: Use `YYYY-MM-DD` for date properties
7. **Entity references**: Use Datalog queries to dereference, not `getPage()`

See [references/pitfalls-and-solutions.md](./references/pitfalls-and-solutions.md) for detailed solutions.

## Version Requirements

- **Logseq**: 0.11.0+ (for full DB graph support)
- **@logseq/libs**: 0.3.0+ (minimum for DB graphs), 0.2.8+ recommended
- **Graph type**: Database graphs only (not markdown/file-based graphs)

## Related Resources

- **logseq-checklist plugin**: Production reference implementation
  - GitHub: https://github.com/kerim/logseq-checklist
  - All patterns in this skill validated through this plugin

- **Official Plugin Docs**: https://plugins-doc.logseq.com/

- **Logseq DB Knowledge Skill**: Foundational DB concepts (use alongside this skill)

## Getting Help

When encountering issues:

1. **Check Common Pitfalls**: Load [references/pitfalls-and-solutions.md](./references/pitfalls-and-solutions.md)
2. **Search Reference Files**: Use grep patterns listed above
3. **Check logseq-checklist source**: Real working implementation
4. **DevTools Console**: Open Console (Cmd/Ctrl+Shift+I) to see error messages
5. **Check API definitions**: LSPlugin.ts in @logseq/libs

## Summary

For DB graph plugin development:

1. **Load references as needed** - Each covers specific functionality
2. **Follow production patterns** - All validated in logseq-checklist v1.0.0
3. **Define types first** - Properties, settings, interfaces
4. **Use correct APIs** - `addBlockTag()`, namespaced keys, Datalog queries
5. **Handle errors** - Try/catch, graceful degradation, user feedback
6. **Test thoroughly** - DevTools Console, fresh graph, edge cases

The modular structure keeps information organized and context-efficient. Load reference files as needed for specific tasks.
