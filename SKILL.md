---
name: logseq-db-plugin-api
version: 1.8.0
description: Essential knowledge for developing Logseq plugins for DB (database) graphs. Use this skill when creating or debugging Logseq plugins that work with DB graphs. Covers complete API reference from LSPlugin.ts including tag/class management (with CORRECTED method names - addBlockTag/removeBlockTag), property handling (complete upsertProperty signature with cardinality, hide, public options), icon management, tag inheritance, comprehensive type definitions, proper Vite bundling setup, event-driven updates with DB.onChanged, multi-layered tag detection, property value iteration, and production-tested plugin architecture patterns.
---

# Logseq DB Plugin API Development

## Overview

This skill provides comprehensive knowledge for developing Logseq plugins specifically for **DB (database) graphs**. It builds on the foundational DB graph concepts and focuses on the **plugin API capabilities** that enable programmatic manipulation of DB graphs.

**CRITICAL**: Plugins for Logseq DB graphs require different approaches than plugins for markdown-based graphs. The API has evolved significantly to support DB-specific features like classes, typed properties, and direct EDN import.

**Keywords**: logseq plugin development, logseq db api, plugin api, createTag, addTag, property management, EDN import, class creation, @logseq/libs

## When to Use This Skill

Invoke this skill whenever:
- Developing a new Logseq plugin for DB graphs
- Debugging plugin API calls that aren't working as expected
- Need to understand new tag/class management APIs
- Working with properties programmatically
- Implementing import workflows (from Zotero, external sources, etc.)
- Migrating a markdown-based plugin to DB graphs

## Prerequisites

**Required Knowledge**:
- Basic understanding of Logseq DB graphs (see `logseq-db-knowledge` skill)
- TypeScript/JavaScript development
- npm/pnpm package management
- Basic Datalog query concepts

**Recommended Reading**:
- `/Users/niyaro/Documents/Code/Logseq/logseq-db-knowledge/SKILL.md` - DB graph fundamentals
- https://plugins-doc.logseq.com/ - Original plugin documentation

---

## Key Differences: DB vs. Markdown Plugins

### Data Model

**Markdown Plugins**:
- Work with files and text blocks
- Properties in frontmatter (YAML/EDN)
- Tags as simple text markers
- Page references through markdown links

**DB Plugins**:
- Work with nodes (pages/blocks) in database
- Properties as typed database entities
- Tags as classes with schemas
- Page references through database relationships

### Property Handling

**Markdown**:
```typescript
// Properties set via text manipulation
await logseq.Editor.upsertBlockProperty(blockUuid, 'author', 'Jane Doe')
```

**DB**:
```typescript
// Properties set during creation with type validation
await logseq.Editor.createPage('My Page', {
  tags: ['zot'],
  author: 'Jane Doe',      // text/string property
  year: 2023,              // number property (requires upsertProperty first - see below)
  title: 'My Article'      // default/text property
})
// Note: Properties go at top level, NOT wrapped in properties:{}
// Note: For number properties, define type with upsertProperty FIRST
```

### Tag System

**Markdown**:
- Tags are simple text (`#tag`)
- No schema or structure
- No inheritance

**DB**:
- Tags are classes with properties
- Support inheritance (Extends)
- Define structure for all tagged nodes
- Plugins can create tags programmatically

### Import Approaches

**Markdown**:
- Create page files
- Write markdown content
- Properties in frontmatter

**DB**:
- **Option 1**: Property API (always available in plugins)
- **Option 2**: EDN import (NEW! Available as of recent commits)
- **Option 3**: Template auto-apply + property API

---

## Project Setup & Bundling

**CRITICAL**: Proper bundling is essential for plugin performance. Plugins must be bundled into a single optimized file for fast loading.

### Why Bundling Matters

**Without proper bundling**:
- Slow plugin load times (TypeScript compilation overhead)
- Multiple file requests
- No minification
- Poor user experience

**With Vite bundling**:
- Fast plugin loading (single minified file)
- Optimized code with tree-shaking
- Watch mode for development
- Production-ready builds

### Recommended Setup: Vite + vite-plugin-logseq

**Use Vite as your bundler** - it's the fastest and most reliable option for Logseq plugins.

#### package.json

```json
{
  "name": "my-logseq-plugin",
  "version": "0.1.0",
  "description": "My Logseq DB plugin",
  "main": "dist/index.js",
  "scripts": {
    "build": "vite build",
    "dev": "vite build --watch",
    "clean": "rm -rf dist"
  },
  "keywords": ["logseq", "plugin"],
  "author": "Your Name",
  "license": "MIT",
  "dependencies": {
    "@logseq/libs": "^0.2.8"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.3.0",
    "vite": "^7.2.2",
    "vite-plugin-logseq": "^1.1.2"
  },
  "logseq": {
    "id": "my-plugin-id",
    "title": "My Plugin Title",
    "description": "What my plugin does",
    "main": "dist/index.html"
  }
}
```

**Key Points**:
- `@logseq/libs`: Use `^0.2.8` or later for full DB support
- `vite-plugin-logseq`: Essential for Logseq plugin bundling
- `main` in `logseq` config: Must point to `dist/index.html` (not `.js`)
- Scripts: Use `vite build` for production, `vite build --watch` for dev

#### vite.config.ts

```typescript
import { defineConfig } from 'vite'
import logseqDevPlugin from 'vite-plugin-logseq'

export default defineConfig({
  plugins: [logseqDevPlugin()],
  build: {
    target: 'esnext',
    minify: 'esbuild'
  }
})
```

**What this does**:
- `logseqDevPlugin()`: Handles Logseq plugin packaging
- `target: 'esnext'`: Modern JavaScript (Logseq supports it)
- `minify: 'esbuild'`: Fast minification

#### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "node",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "strict": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"]
}
```

#### Project Structure

```
my-plugin/
├── src/
│   └── index.ts          # Your plugin code
├── dist/                 # Build output (gitignored)
├── package.json
├── tsconfig.json
├── vite.config.ts
├── .gitignore
└── README.md
```

**.gitignore**:
```
node_modules/
dist/
*.log
.DS_Store
```

### Build Workflow

#### Initial Setup

```bash
# Install dependencies
npm install

# Build plugin
npm run build
```

#### Development Workflow

```bash
# Start watch mode (rebuilds on file changes)
npm run dev
```

**In Logseq**:
1. Settings → Plugins → Load unpacked plugin
2. Select your plugin directory
3. Logseq will detect changes and auto-reload

#### Production Build

```bash
# Clean previous build
npm run clean

# Build optimized version
npm run build
```

### Common Issues

#### Issue: Plugin loads slowly

**Cause**: Not using Vite bundling (using raw TypeScript)

**Solution**: Set up Vite as shown above

#### Issue: `dist/index.html` not found

**Cause**: Wrong `main` path in `package.json` logseq config

**Solution**: Change `"main": "dist/index.js"` → `"main": "dist/index.html"`

#### Issue: Build fails with module errors

**Cause**: Missing `vite-plugin-logseq`

**Solution**:
```bash
npm install --save-dev vite-plugin-logseq
```

#### Issue: Plugin doesn't reload in dev mode

**Cause**: Logseq not detecting file changes

**Solution**:
1. Unload and reload plugin manually in Logseq
2. Check that `npm run dev` is running
3. Verify `dist/` directory is being updated

### Version Requirements

**Minimum versions for DB plugins**:
- `@logseq/libs`: `^0.2.8` (for full DB API support)
- `typescript`: `^5.0.0`
- `vite`: `^7.0.0`
- `vite-plugin-logseq`: `^1.1.0`

### Example: Complete Setup

See working example at:
- `/Users/niyaro/Documents/Code/Logseq/logseq-tag-schema-poc/`
- Demonstrates proper Vite bundling
- Fast loading times
- Clean development workflow

---

## Core API Capabilities for DB Graphs

### Type Definitions Reference

Understanding the core types is essential for working with the Logseq plugin API.

#### Block & Page Identity Types

```typescript
// Block identity - UUID string or object with uuid property
type BlockIdentity = BlockUUID | Pick<BlockEntity, 'uuid'>
type BlockUUID = string

// Page identity - page name string or block identity
type PageIdentity = BlockPageName | BlockIdentity
type BlockPageName = string
```

#### BlockEntity Interface

Complete structure of a block in Logseq DB:

```typescript
interface BlockEntity {
  // Core identifiers
  id: number                      // Database entity ID
  uuid: string                    // Block UUID (permanent identifier)

  // Content
  content: string                 // DEPRECATED - use title instead
  title: string                   // Block text content
  fullTitle: string               // Content with block references resolved to text

  // Relationships
  parent: { id: number }          // Parent block reference
  page: { id: number }            // Owner page reference
  file?: { id: number }           // Associated file reference

  // Properties & metadata
  properties?: Record<string, any>  // Block properties
  order: string                     // Fractional ordering string
  format: 'markdown' | 'org'        // Content format
  marker?: string                   // Task marker (TODO, DONE, etc.)

  // Timestamps
  createdAt: number               // Creation timestamp
  updatedAt: number               // Last update timestamp

  // UI state
  'collapsed?': boolean           // Collapse state
  level?: number                  // Indentation level

  // Other optional fields
  ident?: string                  // For property blocks
  anchor?: string                 // Anchor link
  children?: Array<BlockEntity | BlockUUIDTuple>  // Child blocks

  [key: string]: unknown          // Additional dynamic properties
}
```

#### PageEntity Interface

Complete structure of a page in Logseq DB:

```typescript
interface PageEntity {
  // Core identifiers
  id: number                      // Database entity ID
  uuid: string                    // Page UUID (permanent identifier)
  name: string                    // Page name (lowercase, unique)
  originalName: string            // Original case-sensitive name

  // Type & classification
  type: 'page' | 'journal' | 'whiteboard' | 'class' | 'property' | 'hidden'
  ident?: string                  // Class identifier (e.g., ":logseq.class/Task")

  // Content & format
  title?: string                  // Display title
  format: 'markdown' | 'org'      // Content format

  // Properties
  properties?: Record<string, any>  // Page properties

  // Journal-specific
  'journal?': boolean             // Is this a journal page?
  journalDay?: number             // Journal date (YYYYMMDD format)

  // Relationships
  namespace?: { id: number }      // Parent namespace
  file?: { id: number }           // Associated file
  children?: Array<PageEntity>    // Sub-pages (namespaces)

  // Timestamps
  createdAt: number               // Creation timestamp
  updatedAt: number               // Last update timestamp

  [key: string]: unknown          // Additional dynamic properties
}
```

#### IBatchBlock Interface

Structure for batch block creation:

```typescript
interface IBatchBlock {
  content: string                           // Block text content
  properties?: Record<string, any>          // NOTE: NOT supported in DB graphs!
  children?: Array<IBatchBlock>             // Nested child blocks
}
```

**IMPORTANT**: In DB graphs, properties cannot be set via `IBatchBlock`. Set properties separately after block creation.

#### Entity ID Reference

```typescript
type EntityID = number                    // Database entity ID
type IEntityID = { id: EntityID; [key: string]: any }  // Entity reference object
```

#### Other Common Types

```typescript
// Block UUID tuple format
type BlockUUIDTuple = ['uuid', BlockUUID]

// Transaction data (from DB.onChanged)
type IDatom = [
  e: number,        // Entity ID
  a: string,        // Attribute name
  v: any,           // Value
  t: number,        // Transaction ID
  added: boolean    // true if added, false if retracted
]
```

### Page Management

#### createPage - Enhanced for DB Graphs

Create pages with tags, properties, and custom UUIDs in a single operation.

```typescript
// CRITICAL: Properties go at TOP LEVEL, not wrapped in properties:{}

// Basic page creation with properties
const page = await logseq.Editor.createPage(
  'Research Paper Title',
  {
    tags: ['zot'],
    author: 'Jane Doe',
    year: '2023',  // Use string to avoid NUMBER property issues
    DOI: 'https://doi.org/10.1234/example',
    collections: ['Reading List', 'Dissertation']  // multi-value
  }
)

// Create page with custom UUID (useful for external ID mapping)
const page = await logseq.Editor.createPage(
  'My Page',
  {
    customUUID: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    source: 'external-system'
  }
)

// ❌ WRONG - Do NOT wrap in properties:{}
const page = await logseq.Editor.createPage('My Page', {
  tags: ['zot'],
  properties: {  // DON'T DO THIS!
    author: 'Jane Doe'
  }
})
// This creates a single property called "properties" with JSON value
```

**Property Type Handling**:
- `string` → Text property
- `number` → Number property
- `'YYYY-MM-DD'` → Date property (links to journal)
- `'http://...'` or `'https://...'` → URL property (clickable)
- `string[]` → Multi-value text property
- `boolean` → Checkbox property

**Empty Properties**: Properties with empty/null values are automatically hidden in DB graphs. No need to conditionally set them.

#### Page Utility Methods

Additional page management methods from LSPlugin.ts:

```typescript
// Rename a page
await logseq.Editor.renamePage('Old Page Name', 'New Page Name')

// Create a journal page
const journalPage = await logseq.Editor.createJournalPage('2024-12-25')
// Or with Date object
const journalPage = await logseq.Editor.createJournalPage(new Date())

// Get all pages in the graph
const allPages = await logseq.Editor.getAllPages()
// Returns: PageEntity[] | null

// Get all pages with optional repo filter
const repoPages = await logseq.Editor.getAllPages('my-repo-name')

// Delete a page
await logseq.Editor.deletePage('Page Name')
```

**Use Cases**:
- **renamePage**: Bulk page reorganization, fixing typos, standardizing names
- **createJournalPage**: Programmatic journal creation for specific dates
- **getAllPages**: Building page selection UIs, graph analysis, search features
- **deletePage**: Cleanup operations, removing temporary pages

### Block Management

#### prependBlockInPage - NEW!

Insert blocks at the beginning of a page (added in commit 025e2e70d).

```typescript
// Prepend a block at the start of a page
await logseq.Editor.prependBlockInPage(
  pageNameOrUuid,
  '## Summary\nThis is the first block'
)

// Compare with existing appendBlockInPage
await logseq.Editor.appendBlockInPage(
  pageNameOrUuid,
  '## References\nThis is the last block'
)
```

#### insertBatchBlock - Nested Structures

Create complex nested block structures efficiently.

```typescript
// Create nested blocks (e.g., for notes, annotations)
const blocks = [
  {
    content: '## Annotations',
    children: [
      {
        content: 'Highlight on page 5',
        properties: { page: 5, color: 'yellow' }
      },
      {
        content: 'Comment on page 12',
        properties: { page: 12, type: 'comment' }
      }
    ]
  },
  {
    content: '## Notes',
    children: [
      { content: 'Key insight about methodology' }
    ]
  }
]

// Insert under a page or block
await logseq.Editor.insertBatchBlock(
  targetBlockUuid,
  blocks,
  { sibling: false }  // false = children, true = siblings
)
```

---

## Tag/Class Management (NEW API!)

Recent commits have added powerful tag/class management capabilities specifically for DB graphs.

### createTag - Create Class Pages

Create tag pages programmatically (added in commit 51fbc705d, enhanced in bd4b022a0).

```typescript
// Basic tag creation
const tag = await logseq.Editor.createTag('zot')

// Create tag with custom UUID (useful for plugin namespacing)
const tag = await logseq.Editor.createTag('zot', {
  uuid: 'plugin-namespace-zot-tag'
})

// Check result
if (tag) {
  console.log(`Created tag: ${tag.name}`)
} else {
  console.log('Tag already exists or creation failed')
}
```

**Validation Rules**:
- Tag name cannot be blank
- Tag name cannot contain forward slashes
- Tag name must be a string

**Plugin Namespace Support** (commit 0a54e807b):

Plugins can create classes with custom namespace identifiers:

```typescript
// Use plugin-specific namespace for classes
const pluginClass = await logseq.Editor.createTag('my-plugin-data', {
  // Plugin classes use format: plugin.class.id/class-name
  'class-ident-namespace': 'my-plugin-id'
})
```

### addBlockTag / removeBlockTag - Tag Association

Add or remove tags from blocks (added in commit 51fbc705d).

```typescript
// Add tag to a block
await logseq.Editor.addBlockTag(blockUuid, 'zot')

// Remove tag from a block
await logseq.Editor.removeBlockTag(blockUuid, 'zot')

// Can also add tags during creation
await logseq.Editor.createPage('Item Name', {
  tags: ['zot', 'imported', 'unread']
})
```

### getTag / getTagObjects - Retrieve Tag Info

Query tag information (enhanced in commit 0a54e807b).

```typescript
// Get tag by name, UUID, or ident
const tag = await logseq.Editor.getTag('zot')
const tag = await logseq.Editor.getTag(tagUuid)
const tag = await logseq.Editor.getTag(':logseq.class/Task')

// Get all objects with a tag (including inherited via subclasses)
const zotItems = await logseq.Editor.getTagObjects('zot')
```

**PageEntity with ident**:

The `PageEntity` interface now includes `ident` property for direct access to class identifiers:

```typescript
interface PageEntity {
  uuid: string
  name: string
  originalName: string
  properties?: Record<string, any>
  ident?: string  // e.g., ":logseq.class/Task" or ":plugin.class.id/custom"
}
```

### Multi-Layered Tag Detection for Reliability

**CRITICAL DISCOVERY**: When detecting tags via plugin API, `block.properties.tags` is unreliable (often `undefined`).

**Problem**: Simple property checks fail:

```typescript
// ❌ UNRELIABLE - often returns undefined
const tags = block.properties?.tags
if (tags?.includes('mytag')) {
  // This rarely works!
}
```

**Solution**: Three-tier detection approach for maximum reliability.

**Pattern from logseq-checklist v1.0.0**:

```typescript
/**
 * Reliably check if a block has a specific tag
 * Combines three detection methods for maximum reliability
 */
async function hasTag(block: BlockEntity, tagName: string): Promise<boolean> {
  // Tier 1: Fast content-based check (fastest, works if tag in content)
  // Catches ~80% of cases instantly with minimal API calls
  const content = block.content || block.title || ''
  if (content.includes(`#${tagName}`)) {
    return true
  }

  // Tier 2: Datascript query (most reliable, always works)
  // Authoritative check using database query
  const query = `
  [:find (pull ?b [*])
   :where
   [?b :block/tags ?t]
   [?t :block/title "${tagName}"]]
  `

  const results = await logseq.DB.datascriptQuery(query)
  if (results && results.length > 0) {
    const found = results.find(r => r[0]?.uuid === block.uuid)
    if (found) {
      return true
    }
  }

  // Tier 3: Fallback to properties (rarely works but doesn't hurt)
  // Safety net for edge cases
  const tags = block.properties?.tags
  if (tags) {
    return Array.isArray(tags) ? tags.includes(tagName) : tags === tagName
  }

  return false
}
```

**Why each tier matters:**

**Tier 1 (Content check)**:
- ⚡ **Fastest**: No async calls, simple string search
- ✅ **Catches majority**: Works when tag appears in block text
- ⏱️ **Immediate**: Zero latency
- 📊 **Hit rate**: ~80% of cases

**Tier 2 (Datascript query)**:
- 🎯 **Authoritative**: Database is source of truth
- ✅ **Always works**: Reliable even when content doesn't include tag text
- 🔍 **Handles edge cases**: Tags added programmatically, inherited tags
- 📊 **Hit rate**: 100% of actual tagged blocks

**Tier 3 (Properties fallback)**:
- 🛡️ **Safety net**: Costs nothing to check
- ⚠️ **Rarely works**: `block.properties.tags` often undefined
- 📊 **Hit rate**: <5%, but harmless to include

**Performance characteristics:**

```typescript
// Typical case (tag in content): ~0.1ms
const hasTag1 = await hasTag(block, 'mytag')  // Tier 1 success

// Tag not in content (programmatically added): ~5-10ms
const hasTag2 = await hasTag(block, 'imported')  // Tier 2 success

// Overall: Fast path for common case, reliable fallback for edge cases
```

**Real-world usage:**

```typescript
// Finding parent blocks with specific tags
async function findParentWithTag(
  blockUuid: string,
  tagName: string
): Promise<string | null> {
  let currentBlock = await logseq.Editor.getBlock(blockUuid)
  let iterations = 0
  const maxIterations = 10  // Safety limit

  while (currentBlock && iterations < maxIterations) {
    iterations++

    // Use multi-layered detection
    if (await hasTag(currentBlock, tagName)) {
      return currentBlock.uuid
    }

    // Move up to parent
    if (currentBlock.parent?.id) {
      currentBlock = await logseq.Editor.getBlock(currentBlock.parent.id)
    } else {
      break
    }
  }

  return null
}

// Filtering children by tag
async function getChildrenWithTag(
  parentUuid: string,
  tagName: string
): Promise<BlockEntity[]> {
  const parent = await logseq.Editor.getBlock(parentUuid, {
    includeChildren: true
  })

  if (!parent?.children) {
    return []
  }

  const tagged: BlockEntity[] = []

  for (const child of parent.children) {
    if (typeof child === 'object' && 'uuid' in child) {
      const childBlock = child as BlockEntity
      if (await hasTag(childBlock, tagName)) {
        tagged.push(childBlock)
      }
    }
  }

  return tagged
}
```

**When to use this pattern:**
- ✅ Finding parent blocks with specific tags
- ✅ Filtering children by tag
- ✅ Any conditional logic based on tag presence
- ✅ Validating tag-based workflows
- ✅ Building tag-aware navigation

**When you can skip it:**
- ❌ You already have the block from a datascript query that filtered by tag
- ❌ You're working with `getTagObjects()` results (already filtered)
- ❌ Performance is absolutely critical and you can tolerate false negatives

**Production validation:**

This pattern is used in [logseq-checklist v1.0.0](https://github.com/kerim/logseq-checklist) to detect:
- `#checklist` blocks (parent containers)
- `#checkbox` blocks (child items to count)

**Results**:
- ✅ Zero false negatives
- ✅ Works with rapid editing
- ✅ Handles programmatic tag assignment
- ✅ No performance issues (processes 20+ blocks instantly)

**Source**: Discovered through production debugging, validated in real-world plugin use.

### tag-add-property / tag-remove-property - Define Tag Properties

Add properties to tags to create class schemas (added in commit 7f4d8ad22).

**IMPORTANT**: The documented APIs below may not be fully exposed in the plugin context. See **Parent Frame API** below for the confirmed working method.

#### Option 1: Kebab-case API (name-based only)

```typescript
// Add property to a tag (defines it for all tagged nodes)
await logseq.API['tag-add-property']('zot', 'author')
await logseq.API['tag-add-property']('zot', 'year')
await logseq.API['tag-add-property']('zot', 'DOI')

// Remove property from tag
await logseq.API['tag-remove-property']('zot', 'unwanted-property')
```

**Note**: `logseq.API` may be undefined in plugin context. See Parent Frame API below.

#### Option 2: CamelCase API (accepts UUIDs or names)

```typescript
// Add property to tag using UUID or name
await logseq.Editor.addTagProperty('zot', 'author')
await logseq.Editor.addTagProperty(tagUuid, propertyUuid)
await logseq.Editor.addTagProperty(tagUuid, 'author')

// Remove property from tag using UUID or name
await logseq.Editor.removeTagProperty('zot', 'unwanted-property')
await logseq.Editor.removeTagProperty(tagUuid, propertyUuid)
```

**Note**: `logseq.Editor.addTagProperty` may not be available in all SDK versions.

#### **Parent Frame API** (Confirmed Working)

Plugins run in an iframe, and the tag property API is available in the parent frame context:

```typescript
// Access parent frame API
// @ts-ignore
const parentLogseq = (window as any).parent?.logseq

if (!parentLogseq?.api?.add_tag_property) {
  throw new Error('parent.logseq.api.add_tag_property not available')
}

// Add property to tag (snake_case method names)
await parentLogseq.api.add_tag_property(tagUuid, 'author')
await parentLogseq.api.add_tag_property(tagUuid, 'title')
await parentLogseq.api.add_tag_property(tagUuid, 'publisher')

// Remove property from tag
await parentLogseq.api.remove_tag_property(tagUuid, 'unwanted-property')
```

**Parent Frame API Signature**:
- **Method**: `parent.logseq.api.add_tag_property(tagUuid, propertyName)`
- **Parameters**:
  - `tagUuid` (string) - UUID of the tag to add property to
  - `propertyName` (string) - Name of the property (NOT UUID)
- **Naming**: Snake_case (`add_tag_property`, not `addTagProperty`)
- **Context**: Must be called from `parent.logseq.api`, not `logseq.API` or `logseq.Editor`

**Why Parent Frame?**
- Plugins run in an iframe sandbox
- `window.logseq.api` is undefined in plugin context
- `parent.logseq.api` accesses the parent frame's Logseq API
- Some APIs (like tag property management) are only exposed in parent frame

**Property Namespacing**:

Plugin-created properties are automatically namespaced in the database:
- Format: `:plugin.property.{plugin-id}/{property-name}`
- Example: `:plugin.property.my-plugin/title`
- This prevents conflicts between plugins
- Built-in properties use `:logseq.property/{property-name}`

**Entity Reference Behavior**:

When you read pages with `getPage()`, properties are stored as **entity references** (database IDs), not direct values:

```typescript
const page = await logseq.Editor.getPage(pageUuid)

// Properties appear as entity IDs:
console.log(page[':plugin.property.my-plugin/title'])  // → 189
console.log(page[':plugin.property.my-plugin/author'])  // → 190
```

The numbers (189, 190) are entity IDs. The actual values are stored in those entity records in the database.

**Reading Actual Property Values**:

To get dereferenced property values, use Datalog queries instead of `getPage()`:

```typescript
// Query to get actual property values
const query = `
{:query [:find (pull ?b [:block/uuid
                         :plugin.property.my-plugin/title
                         :plugin.property.my-plugin/author])
         :where
         [?b :block/uuid "${pageUuid}"]]}`

const results = await logseq.DB.datascriptQuery(query)
const page = results[0]?.[0]

console.log(page[':plugin.property.my-plugin/title'])  // → "Actual Title"
console.log(page[':plugin.property.my-plugin/author'])  // → "John Doe"
```

**Key Points**:
- `getPage()` returns entity references
- Datalog queries with proper pull patterns dereference entities
- Use namespaced keys (`:plugin.property.{id}/{name}`) in queries

**When to use UUIDs**:
- Working with dynamically created properties
- Need to reference specific property entities
- Building generic class management tools
- Programmatically managing tag schemas

**Critical Requirement: Property Initialization**

Properties **MUST exist in the database** before adding them to a tag schema.

**Error when property doesn't exist**:
```
"Not a valid property"
```

**Solution**: Create properties first by using them on a temporary page:

```typescript
// Step 1: Create temp page with properties to initialize them
const tempPage = await logseq.Editor.createPage(
  `temp-property-init-${Date.now()}`,
  {
    title: 'temp',
    author: 'temp',
    publisher: 'temp'
  },
  { redirect: false }
)

// Step 2: Delete temp page (properties persist in database)
await logseq.Editor.deletePage(tempPage.name)

// Step 3: NOW properties can be added to tag schema
const parentLogseq = (window as any).parent?.logseq
await parentLogseq.api.add_tag_property(tagUuid, 'title')
await parentLogseq.api.add_tag_property(tagUuid, 'author')
await parentLogseq.api.add_tag_property(tagUuid, 'publisher')
```

**Why this works**: Properties are created when first used on a page. Deleting the page doesn't delete the property definition from the database.

**Important Notes**:
- Cannot add/remove private built-in properties
- Tag must be a class (created via createTag or manually)
- Property must exist in database (create via temp page first)
- Both API styles work identically, choose based on your use case

**Complete Tag Setup Pattern (Recommended)**:

```typescript
async function setupZoteroTag() {
  // 1. Create tag
  const zotTag = await logseq.Editor.createTag('zot')

  if (!zotTag) {
    console.error('Failed to create #zot tag')
    return
  }

  // 2. Define properties list
  const properties = [
    'zoteroKey',      // unique identifier
    'citeKey',        // citation key
    'itemType',       // article, book, etc.
    'title',
    'author1', 'author2', 'author3', 'authorsEtAl',
    'year',           // Note: NUMBER properties have limitations (see below)
    'DOI',
    'url',
    'collections',    // multi-value
    'tags'            // Zotero tags (multi-value)
  ]

  // 3. Initialize properties with temp page
  const propertyInit: Record<string, any> = {}
  for (const prop of properties) {
    propertyInit[prop] = 'temp'  // Use TEXT for all to avoid NUMBER issues
  }

  const tempPage = await logseq.Editor.createPage(
    `temp-init-${Date.now()}`,
    propertyInit,
    { redirect: false }
  )

  await logseq.Editor.deletePage(tempPage.name)
  console.log('✅ Properties initialized')

  // 4. Add properties to tag schema using parent frame API
  const parentLogseq = (window as any).parent?.logseq

  if (!parentLogseq?.api?.add_tag_property) {
    console.error('❌ parent.logseq.api.add_tag_property not available')
    return
  }

  for (const prop of properties) {
    try {
      await parentLogseq.api.add_tag_property(zotTag.uuid, prop)
      console.log(`✅ Added property: ${prop}`)
    } catch (err: any) {
      console.error(`❌ Failed to add property ${prop}:`, err.message)
    }
  }

  console.log('✅ #zot tag configured with properties')
}
```

### Block Icons - setBlockIcon / removeBlockIcon

Set or remove icons for blocks (added to TypeScript definitions, available in recent versions).

**Icon Types**:
- **emoji**: Use emoji names from [emoji-mart](https://learn.missiveapp.com/open/emoji-mart)
- **tabler-icon**: Use icon names from [Tabler Icons](https://tabler.io/icons)

```typescript
// Set emoji icon
await logseq.Editor.setBlockIcon(blockId, 'emoji', 'smile')
await logseq.Editor.setBlockIcon(blockId, 'emoji', 'star')

// Set tabler icon
await logseq.Editor.setBlockIcon(blockId, 'tabler-icon', 'calendar')
await logseq.Editor.setBlockIcon(blockId, 'tabler-icon', 'book')

// Remove block icon
await logseq.Editor.removeBlockIcon(blockId)
```

**Use Cases**:
- Visual categorization of blocks
- Custom block types (tasks, notes, warnings)
- Plugin-specific markers
- Enhanced visual organization

**Example - Set Icon Based on Block Type**:
```typescript
async function setIconByType(blockId: string, itemType: string) {
  const iconMap: Record<string, [string, string]> = {
    'book': ['tabler-icon', 'book'],
    'article': ['tabler-icon', 'file-text'],
    'video': ['emoji', 'movie_camera'],
    'podcast': ['emoji', 'microphone']
  }

  const icon = iconMap[itemType]
  if (icon) {
    await logseq.Editor.setBlockIcon(blockId, icon[0] as any, icon[1])
  }
}
```

### Tag Inheritance - addTagExtends / removeTagExtends

Create tag hierarchies where child tags inherit properties from parent tags (added to TypeScript definitions).

```typescript
// Create a parent-child relationship between tags
await logseq.Editor.addTagExtends(childTagId, parentTagId)

// Example: Create inheritance hierarchy
const mediaTag = await logseq.Editor.createTag('media')
const videoTag = await logseq.Editor.createTag('video')
const movieTag = await logseq.Editor.createTag('movie')

// Set up inheritance: movie extends video extends media
await logseq.Editor.addTagExtends(videoTag.uuid, mediaTag.uuid)
await logseq.Editor.addTagExtends(movieTag.uuid, videoTag.uuid)

// Remove inheritance relationship
await logseq.Editor.removeTagExtends(movieTag.uuid, videoTag.uuid)
```

**How Inheritance Works**:
- Child tags inherit all properties defined on parent tags
- Objects tagged with child tags appear in parent tag queries
- Allows creating taxonomies and categorization hierarchies
- Multiple inheritance is supported (tag can extend multiple parents)

**Use Cases**:
- Content taxonomies (Document → Article → Research Paper)
- Item categorization (Media → Video → Tutorial)
- Permission hierarchies
- Shared property schemas across related tags

**Example - Content Taxonomy**:
```typescript
// Create hierarchy: Document → Article → Research Paper → Published Paper
const docTag = await logseq.Editor.createTag('document')
const articleTag = await logseq.Editor.createTag('article')
const researchTag = await logseq.Editor.createTag('research-paper')
const publishedTag = await logseq.Editor.createTag('published-paper')

await logseq.Editor.addTagExtends(articleTag.uuid, docTag.uuid)
await logseq.Editor.addTagExtends(researchTag.uuid, articleTag.uuid)
await logseq.Editor.addTagExtends(publishedTag.uuid, researchTag.uuid)

// Define properties on parent tag
const parentLogseq = (window as any).parent?.logseq
await parentLogseq.api.add_tag_property(docTag.uuid, 'title')
await parentLogseq.api.add_tag_property(docTag.uuid, 'author')

// All child tags automatically inherit these properties!
```

### Utility Methods - getAllTags / getAllProperties

Retrieve all tags or properties from the graph.

```typescript
// Get all tags in the graph
const allTags = await logseq.Editor.getAllTags()
// Returns: PageEntity[] | null

// Get all properties in the graph
const allProperties = await logseq.Editor.getAllProperties()
// Returns: PageEntity[] | null

// Example: List all tag names
const tags = await logseq.Editor.getAllTags()
if (tags) {
  const tagNames = tags.map(tag => tag.name)
  console.log('Available tags:', tagNames)
}

// Example: List all property names
const props = await logseq.Editor.getAllProperties()
if (props) {
  const propNames = props.map(prop => prop.name)
  console.log('Available properties:', propNames)
}
```

**Use Cases**:
- Building tag/property selection UIs
- Validation (check if tag/property exists before using)
- Auto-completion features
- Plugin configuration interfaces
- Graph analysis and statistics

---

## Property Management

### Setting Properties During Creation

**Best Practice**: Set properties during page/block creation for atomic operations.

```typescript
// All properties set in one operation
// IMPORTANT: Properties go at top level, NOT in properties:{}
await logseq.Editor.createPage('Paper Title', {
  tags: ['zot'],
  zoteroKey: 'ABC123',
  itemType: 'journalArticle',
  title: 'Research on Topic',
  author1: 'Jane Doe',
  author2: 'John Smith',
  authorsEtAl: 'Additional authors...',
  year: '2023',  // Use string to avoid NUMBER issues
  DOI: 'https://doi.org/10.1234/example',
  collections: ['Reading List', 'Methodology'],  // array
  tags: ['qualitative', 'case-study'],           // array (Zotero tags, not Logseq tags)
  url: 'https://example.com/paper',
  abstract: 'Long text...'
})
```

### Updating Properties

#### upsertBlockProperty - Single Property

```typescript
// Update single property
await logseq.Editor.upsertBlockProperty(
  blockUuid,
  'status',
  'Done'
)

// Set multi-value property
await logseq.Editor.upsertBlockProperty(
  blockUuid,
  'tags',
  ['tag1', 'tag2', 'tag3']
)
```

#### set-block-properties! - Multiple Properties

Update multiple properties with reset control (enhanced in commit 94a2d9c28).

```typescript
// Set multiple properties
await logseq.API['db-based-save-block-properties!'](
  blockUuid,
  {
    author: 'New Author',
    year: 2024,
    tags: ['updated', 'revised']
  }
)

// Reset/remove properties with new option
await logseq.API['db-based-save-block-properties!'](
  blockUuid,
  {
    author: 'New Author',
    tags: null  // Remove this property
  },
  { 'reset-property-values': true }  // Enable property removal
)
```

**Property Reset Behavior**:
- Without `reset-property-values`: `null` values ignored
- With `reset-property-values: true`: `null` values remove the property

#### Property Utility Methods

Additional property management methods from LSPlugin.ts:

```typescript
// Get a property entity by key
const prop = await logseq.Editor.getProperty('propertyName')
// Returns: BlockEntity | null

// Remove a property entity (deletes the property definition)
await logseq.Editor.removeProperty('propertyName')

// Get all properties of a specific page
const pageProps = await logseq.Editor.getPageProperties(pageUuid)
// Returns: Record<string, any> | null

// Get all properties of a specific block
const blockProps = await logseq.Editor.getBlockProperties(blockUuid)
// Returns: Record<string, any> | null

// Get a single property value from a block
const value = await logseq.Editor.getBlockProperty(blockUuid, 'propertyName')
// Returns: BlockEntity | unknown

// Remove a property from a block
await logseq.Editor.removeBlockProperty(blockUuid, 'propertyName')
```

**Use Cases**:
- **getProperty**: Check if a property exists before creating/using it
- **removeProperty**: Clean up unused property definitions
- **getPageProperties**: Retrieve all properties for validation or display
- **getBlockProperties**: Access all block metadata
- **getBlockProperty**: Read specific property value
- **removeBlockProperty**: Clean up individual property values

**Example - Validate Property Exists**:
```typescript
async function ensurePropertyExists(propertyName: string) {
  const prop = await logseq.Editor.getProperty(propertyName)

  if (!prop) {
    // Property doesn't exist, create it
    await logseq.Editor.upsertProperty(propertyName, {
      type: 'default'
    })
    console.log(`Created property: ${propertyName}`)
  }
}
```

### Reading Property Values from Block Objects

**CRITICAL Understanding**: In Logseq DB graphs, properties are stored directly on block objects as **namespaced keys**, NOT in `block.properties` object.

#### Property Storage Format

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

#### Iteration Pattern for Unknown Property Names

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

#### Type-Based Property Detection

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

#### Type Detection Patterns

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

#### Common Use Cases

**1. Finding properties when name is unknown**:
```typescript
// Find first string property containing "title"
const titleValue = findPropertyValue(block, (key, value) =>
  key.includes('title') && typeof value === 'string'
)
```

**2. Reading all user-defined properties**:
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

**3. Filtering blocks by property value type**:
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

#### Performance Considerations

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

#### Critical Insights

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

#### Source Reference

These patterns are production-tested in:
- **logseq-checklist plugin v1.0.0**: `getCheckboxValue()` function
- GitHub: [https://github.com/kerim/logseq-checklist](https://github.com/kerim/logseq-checklist)
- File: `src/progress.ts` lines 57-79

### Property Types & Validation

**Type Inference**:
- Logseq infers property types from values
- Once set, type is generally enforced
- Use correct type to avoid validation errors

**Property Value Formats** (100% success rate):

| Type | Example Value | Status | Notes |
|------|---------------|--------|-------|
| Text/Default | `"Jane Doe"` | ✅ Confirmed | Default type, allows any text. Stored as entity reference. |
| String | `"Jane Doe"` | ✅ Confirmed | Explicit text type. Stored as direct value. |
| Number | `2023` | ✅ Confirmed | Requires `upsertProperty` first. Stored as entity reference. |
| DateTime | `Date.now()` | ✅ Confirmed | Milliseconds timestamp. Stored as direct numeric value. |
| Checkbox | `true` or `false` | ✅ Confirmed | Boolean value. Stored as direct boolean value. |
| URL | `"https://..."` | ✅ Confirmed | Plain URL string. Stored as entity reference. |
| Node | `"Page Name"` | ✅ Confirmed | Page name string (not UUID). Stored as entity reference. |
| Date | `journalPage.id` | ✅ **SOLVED** | Journal page entity ID (number). See DATE Properties section below. |
| Multi-value | `["a", "b", "c"]` | ⚠️ Partial | Arrays work for text, unclear for other types |

**Property Type Definition with `upsertProperty`** ✅

**SOLVED** (as of 2025-11-18): You can now explicitly define property types using `logseq.Editor.upsertProperty`!

**API Signature**:
```typescript
await logseq.Editor.upsertProperty(
  key: string,
  schema?: Partial<{
    type: 'default' | 'string' | 'number' | 'date' | 'datetime' | 'checkbox' | 'url' | 'node' | 'json',
    cardinality: 'one' | 'many',  // Single value or multi-value
    hide: boolean,                 // Hide from UI
    public: boolean                // Public visibility
  }>,
  opts?: { name?: string }        // Optional display name
) => Promise<IEntityID>
```

**Parameters**:
- **key** (string): Property name/key
- **schema** (optional object):
  - **type**: Property data type (see below)
  - **cardinality**: `'one'` for single value, `'many'` for multi-value (default: `'one'`)
  - **hide**: Hide property from UI (default: `false`)
  - **public**: Property is public (default: `false`)
- **opts** (optional object):
  - **name**: Display name for the property (different from key)

**Return**: `Promise<IEntityID>` - Returns entity reference to the created/updated property

**Valid Property Types**:
- `'default'` - Default text type (stored as entity reference)
- `'string'` - Explicit text type (stored as direct value)
- `'number'` - Number type (stored as entity reference) ✅
- `'date'` - Date type (journal page reference)
- `'datetime'` - DateTime type (milliseconds timestamp)
- `'checkbox'` - Boolean/checkbox type (stored as direct value)
- `'url'` - URL type (stored as entity reference)
- `'node'` - Node/page reference type (stored as entity reference)
- `'json'` - JSON type

**IMPORTANT**: `'text'` is INVALID - use `'default'` or `'string'` instead.

**NUMBER Properties - SOLVED** ✅

**Problem (OLD)**: Numbers were interpreted as entity ID references, causing errors.

**Solution (NEW)**: Define property type BEFORE using it!

```typescript
// Step 1: Define property type FIRST
await logseq.Editor.upsertProperty('year', { type: 'number' })

// Step 2: Now you can use NUMBER values
const page = await logseq.Editor.createPage('Research Paper', {
  year: 2025  // ✅ Works! Stored as actual number
})
```

**Why This Works**:
- Without type definition: Numbers interpreted as entity references → ERROR
- With type definition: Logseq knows it's a value, not a reference → SUCCESS

**Complete Working Example** (ALL 8 types confirmed):
```typescript
// 1. Define all property types FIRST
await logseq.Editor.upsertProperty('myString', { type: 'string' })
await logseq.Editor.upsertProperty('myNumber', { type: 'number' })
await logseq.Editor.upsertProperty('myDateTime', { type: 'datetime' })
await logseq.Editor.upsertProperty('myCheckbox', { type: 'checkbox' })
await logseq.Editor.upsertProperty('myUrl', { type: 'url' })
await logseq.Editor.upsertProperty('myNode', { type: 'node' })
await logseq.Editor.upsertProperty('myDefault', { type: 'default' })
await logseq.Editor.upsertProperty('myDate', { type: 'date' })  // ← DATE type!

// 2. Create journal page for date property
const journalPage = await logseq.Editor.createPage('2024-12-25', {}, { redirect: false })

// 3. Create pages with properly typed properties (ALL 8 types!)
const page = await logseq.Editor.createPage('Test Page', {
  myString: 'Plain text value',                    // ✅ String
  myNumber: 2025,                                   // ✅ Number
  myDateTime: Date.now(),                           // ✅ Milliseconds timestamp
  myCheckbox: true,                                 // ✅ Boolean
  myUrl: 'https://example.com',                     // ✅ URL string
  myNode: 'Referenced Page Name',                   // ✅ Page name
  myDefault: 'Text content',                        // ✅ Plain text
  myDate: journalPage.id                            // ✅ Date (journal page ID!)
})
```

**Advanced `upsertProperty` Usage**:

```typescript
// Multi-value property (can store arrays)
await logseq.Editor.upsertProperty('tags', {
  type: 'default',
  cardinality: 'many'  // Allows multiple values
})

// Hidden property (not shown in UI by default)
await logseq.Editor.upsertProperty('internalId', {
  type: 'string',
  hide: true
})

// Property with custom display name
await logseq.Editor.upsertProperty('createdAt', {
  type: 'datetime'
}, {
  name: 'Created At'  // Display name shown in UI
})

// Public multi-value property
await logseq.Editor.upsertProperty('collaborators', {
  type: 'node',
  cardinality: 'many',
  public: true
})
```

**Critical Discoveries**:

1. **Namespaced Property Keys**: Plugin properties are stored with namespaced keys:
   - Format: `:plugin.property.{plugin-id}/{property-name}`
   - Example: `:plugin.property.my-plugin/myString`
   - Must use namespaced key when reading back with `getPage()`

2. **Entity References vs Direct Values**: Some property types store entity IDs, others store actual values:
   - **Direct values**: `string`, `boolean` (checkbox), `number` (datetime timestamps)
   - **Entity references**: `default`, `number`, `url`, `node`
   - When you read entity reference types, you get entity ID numbers, not the actual values
   - To get actual values, need Datalog queries with proper pull patterns (see Property Value Dereferencing section)

**DATE Properties - SOLVED** ✅

**Problem**: Date properties require a special value format - journal page entity IDs.

**Solution** (as of 2025-11-18):

Date properties work with **journal page entity ID (number)**, not date strings or timestamps.

```typescript
// Step 1: Define the date property type
await logseq.Editor.upsertProperty('eventDate', { type: 'date' })

// Step 2: Create or get a journal page using ISO date format (YYYY-MM-DD)
const journalPage = await logseq.Editor.createPage('2024-12-25', {}, { redirect: false })
// This automatically creates a page with journalDay property (20241225)

// Step 3: Use the journal page's ID (entity number) as the date property value
const eventPage = await logseq.Editor.createPage('Christmas Party', {
  eventDate: journalPage.id  // ← Use .id property (e.g., 298)
})
```

**Key Points**:
- **CORRECT format**: `journalPage.id` (entity number like 298)
  - ✅ Works perfectly with NO warnings
  - ✅ Value is properly stored and can be read back
- **WRONG formats**: `journalPage.uuid` or `journalPage.name`
  - ⚠️ Trigger "should be a journal date" warnings
  - ❌ Property value shows as `undefined` when read back

**Journal Page Creation**:
- Use ISO date format: `createPage('YYYY-MM-DD')`
- Logseq automatically adds `journalDay` property (YYYYMMDD integer)
- Returns page with `.id` (entity number), `.uuid`, `.name` properties

**Best Practice**:
Define property types during plugin initialization, before creating any pages:

```typescript
async function main() {
  // Initialize property types (ALL 8 types now working!)
  const propertyTypes = {
    title: 'default',         // Text with entity reference
    author: 'string',         // Direct string value
    year: 'number',           // Number with entity reference
    dateModified: 'datetime', // Date.now() milliseconds
    isPublic: 'checkbox',     // Boolean true/false
    url: 'url',               // Plain URL string with entity reference
    relatedPage: 'node',      // Page name with entity reference
    eventDate: 'date'         // ✅ Date (journal page ID!)
  }

  for (const [name, type] of Object.entries(propertyTypes)) {
    await logseq.Editor.upsertProperty(name, { type })
  }

  // Now safe to use ALL 8 property types throughout plugin lifecycle
}

logseq.ready(main)
```

**References**:
- POC: `/Users/niyaro/Documents/Code/Logseq API/old POCs/logseq-property-type-poc` (v0.0.12 - types 1-7)
- POC: `/Users/niyaro/Documents/Code/Logseq API/active POCs/logseq-journal-date-property-poc` (v0.0.2 - date type)
- FUTURE-RESEARCH.md: Questions #2 (NUMBER properties) ✅ SOLVED and #3 (Property types) ✅ FULLY SOLVED (100%)
- LEARNINGS.md: Complete property value format reference and findings

### Reserved Property Names

**Avoid these built-in property names**:
- `created` - Reserved by Logseq
- `modified` - Reserved by Logseq
- `created-at` - Use `dateAdded` instead
- `updated-at` - Use `dateModified` instead

**Safe Alternatives**:
- `dateAdded` ✅
- `dateModified` ✅
- `addedOn` ✅
- `lastUpdated` ✅

---

## EDN Import Support (NEW!)

Recent commits have added support for importing EDN data structures directly via the plugin API.

### What is EDN Import?

EDN (Extensible Data Notation) is Logseq's native data format. Importing via EDN allows you to:
- Create complex nested structures atomically
- Set properties with precise control
- Define relationships between nodes
- Import entire graph structures at once

### EDN Import API

**IMPORTANT**: Based on the migration plan research, EDN import may not be fully available in the plugin API yet. The proven approach is **Property API + Template auto-apply**.

**Recommended Pattern** (works in all versions):

```typescript
// 1. Create page with properties via API
const page = await logseq.Editor.createPage('Item Name', {
  tags: ['zot'],
  properties: {
    zoteroKey: 'ABC123',
    title: 'Paper Title',
    author1: 'Jane Doe',
    // ... all properties
  }
})

// 2. Let template auto-apply (if configured)
//    Template with: "Apply template to tags: #zot"

// 3. Populate template sections with content
const pageBlocks = await logseq.Editor.getPageBlocksTree(page.uuid)

// Find template sections (e.g., "Annotations", "Notes")
const annotationsBlock = pageBlocks.find(b =>
  b.content.includes('## Annotations')
)

if (annotationsBlock) {
  // Insert annotations as children
  await logseq.Editor.insertBatchBlock(
    annotationsBlock.uuid,
    annotationBlocks,
    { sibling: false }
  )
}
```

### Template Auto-Apply Pattern

**Setup**: Create a template that automatically applies to tagged pages.

```typescript
// 1. Create template page
const template = await logseq.Editor.createPage(
  'Zotero Item Template',
  {
    tags: ['Template'],
    properties: {
      'template-name': 'Zotero Item',
      'Apply template to tags': '#zot'  // Auto-apply to all #zot pages
    }
  }
)

// 2. Add template structure
await logseq.Editor.appendBlockInPage(template.uuid, '## Annotations')
await logseq.Editor.appendBlockInPage(template.uuid, '## Notes')
await logseq.Editor.appendBlockInPage(template.uuid, '## Reading Notes')

// 3. Now all pages created with #zot tag will auto-apply this template!
```

---

## Query & Database Operations

### datascriptQuery - Querying DB Graphs

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

### Common Query Patterns

#### Find All Tagged Items

```typescript
const query = `
{:query [:find (pull ?b [*])
         :where
         [?b :block/tags ?t]
         [?t :block/title "zot"]]}
`
```

#### Find Items by Property Value

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

#### Find Items in Collection (Multi-value Property)

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

#### Extract Specific Property Only

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

### Caching Query Results

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

### get-class-objects - Get All Tagged Items

Alternative to Datalog queries for simple tag-based retrieval (mentioned in migration plan).

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

---

## Event-Driven Updates with DB.onChanged

### Overview

The `DB.onChanged` hook enables plugins to respond to database changes in real-time. This is essential for plugins that need to maintain derived state (like progress indicators, aggregations, or computed properties) based on user edits.

**Use cases:**
- Auto-updating progress indicators when checkboxes toggle
- Maintaining aggregated statistics across tagged items
- Triggering workflows based on property changes
- Keeping caches synchronized with the database

**Source**: Patterns validated in [logseq-checklist v1.0.0](https://github.com/kerim/logseq-checklist) production plugin.

### Event Structure

`DB.onChanged` receives a change object with this structure:

```typescript
interface ChangeData {
  blocks: BlockEntity[]              // Changed blocks (full entities)
  deletedAssets: string[]            // Deleted asset UUIDs
  deletedBlockUuids: string[]        // Deleted block UUIDs
  txData: IDatom[]                   // Transaction datoms (detailed changes)
  txMeta: { [key: string]: any }     // Transaction metadata
}

// IDatom format: [entityId, attribute, value, txId, added]
type IDatom = [number, string, any, number, boolean]
```

**Setup in plugin:**

```typescript
async function main() {
  if (logseq.DB?.onChanged) {
    logseq.DB.onChanged((changeData) => {
      handleDatabaseChanges(changeData)
    })
  } else {
    logseq.UI.showMsg(
      'DB.onChanged not available - automatic updates disabled',
      'warning'
    )
  }
}

logseq.ready(main).catch(console.error)
```

### Filtering Transaction Datoms

**Pattern**: Extract specific changes from `txData` array by matching attribute patterns.

```typescript
async function handleDatabaseChanges(changeData: any): Promise<void> {
  // Extract txData array from change object
  const txData = changeData?.txData

  if (!txData || !Array.isArray(txData)) {
    return
  }

  // Filter for property changes matching a pattern
  const propertyChanges = []
  for (const datom of txData) {
    const [entityId, attribute, value, txId, added] = datom

    // Match property changes (attributes containing "property")
    if (attribute.includes('property')) {
      propertyChanges.push(datom)
    }
  }

  if (propertyChanges.length === 0) {
    return
  }

  // Process each property change
  for (const datom of propertyChanges) {
    const [entityId] = datom

    // Convert entity ID to block
    const block = await logseq.Editor.getBlock(entityId)
    if (block) {
      // Handle the change
      await processBlockChange(block)
    }
  }
}
```

**Common attribute patterns:**
- `:user.property/{name}` - User-defined properties
- `:logseq.property/{name}` - System properties
- `:block/title` - Block content changes
- `:block/tags` - Tag assignments

### Debouncing Updates

**Problem**: Rapid changes (e.g., toggling multiple checkboxes) trigger excessive updates, causing UI lag.

**Solution**: Debounce updates with Set-based deduplication.

```typescript
// Debouncing state
const pendingUpdates = new Set<string>()  // Set of block UUIDs to update
let updateTimer: NodeJS.Timeout | null = null

/**
 * Schedule an update with 300ms debouncing
 */
function scheduleUpdate(blockUuid: string): void {
  pendingUpdates.add(blockUuid)  // Deduplicates automatically

  if (updateTimer) {
    clearTimeout(updateTimer)
  }

  updateTimer = setTimeout(async () => {
    // Batch process all pending updates
    for (const uuid of pendingUpdates) {
      await updateBlock(uuid)
    }
    pendingUpdates.clear()
  }, 300)  // 300ms debounce window
}
```

**Why this works:**
- **Set deduplication**: Multiple changes to same block = single update
- **Timer reset**: Rapid changes extend debounce window
- **Batch processing**: All updates happen together after changes settle
- **300ms sweet spot**: Long enough to batch, short enough to feel instant

### Complete Example: Checkbox Change Tracking

Real implementation from logseq-checklist plugin - tracks checkbox changes and updates parent progress indicators.

```typescript
import { IDatom, BlockEntity } from './types'

/**
 * Debouncing state
 */
const pendingUpdates = new Set<string>()
let updateTimer: NodeJS.Timeout | null = null

/**
 * Check if datom represents a checkbox property change
 */
function isCheckboxChange(datom: IDatom): boolean {
  const [, attribute] = datom

  // Match properties containing "property" (checkbox properties are boolean properties)
  return attribute.includes('property')
}

/**
 * Find parent block with #checklist tag
 */
async function findParentChecklist(blockUuid: string): Promise<string | null> {
  let currentBlock = await logseq.Editor.getBlock(blockUuid)
  let iterations = 0
  const maxIterations = 10  // Safety limit

  while (currentBlock && iterations < maxIterations) {
    iterations++

    // Check if current block has #checklist tag
    const query = `
    [:find (pull ?b [*])
     :where
     [?b :block/tags ?t]
     [?t :block/title "checklist"]]
    `

    const results = await logseq.DB.datascriptQuery(query)
    const hasTag = results?.some(r => r[0]?.uuid === currentBlock.uuid)

    if (hasTag) {
      return currentBlock.uuid
    }

    // Move up to parent
    if (currentBlock.parent?.id) {
      currentBlock = await logseq.Editor.getBlock(currentBlock.parent.id)
    } else {
      break
    }
  }

  return null
}

/**
 * Schedule update with debouncing
 */
function scheduleUpdate(checklistUuid: string): void {
  pendingUpdates.add(checklistUuid)

  if (updateTimer) {
    clearTimeout(updateTimer)
  }

  updateTimer = setTimeout(async () => {
    for (const uuid of pendingUpdates) {
      await updateChecklistProgress(uuid)
    }
    pendingUpdates.clear()
  }, 300)
}

/**
 * Handle database changes
 */
async function handleDatabaseChanges(changeData: any): Promise<void> {
  try {
    const txData = changeData?.txData

    if (!txData || !Array.isArray(txData)) {
      return
    }

    // Filter for checkbox changes
    const checkboxChanges = txData.filter(isCheckboxChange)

    if (checkboxChanges.length === 0) {
      return
    }

    // For each checkbox change, find and update parent checklist
    for (const datom of checkboxChanges) {
      const [entityId] = datom

      const block = await logseq.Editor.getBlock(entityId)
      if (block) {
        const checklistUuid = await findParentChecklist(block.uuid)
        if (checklistUuid) {
          scheduleUpdate(checklistUuid)  // Debounced update
        }
      }
    }
  } catch (error) {
    console.error('Error handling database changes:', error)
  }
}

/**
 * Setup in plugin initialization
 */
async function main() {
  if (logseq.DB?.onChanged) {
    logseq.DB.onChanged(handleDatabaseChanges)
  }
}

logseq.ready(main).catch(console.error)
```

**This pattern demonstrates:**
- Event structure parsing
- Datom filtering by attribute pattern
- Parent block traversal with tag detection
- Debounced batch updates
- Error handling throughout

**Production results:**
- Handles rapid checkbox toggles smoothly
- No UI lag even with 20+ checkboxes
- Efficient: Only updates affected checklists
- Reliable: Updates always reflect current state

---

## Development Features

### devEntry Support (NEW!)

Separate entry points for development and production (added in commit 501230b0d).

**package.json**:

```json
{
  "name": "my-logseq-plugin",
  "version": "1.0.0",
  "main": "dist/index.js",
  "logseq": {
    "id": "my-plugin",
    "entry": "dist/index.js",
    "devEntry": "src/index.ts"
  }
}
```

**Benefits**:
- Use TypeScript directly in dev mode (with ts-node or similar)
- Different bundling for dev vs. prod
- Faster development iteration
- Keep production build optimized

**How it works**:
- In development mode: Logseq loads `devEntry`
- In production mode: Logseq loads `entry`
- If `devEntry` not specified: falls back to `entry`

### API Discovery in Console

**How to discover undocumented APIs**: Many Logseq plugin APIs are not fully documented. You can explore available APIs using the browser console.

**Key Insight**: The Logseq console runs in the **parent frame**, not the plugin iframe. This means you can test APIs directly in the console that may need `parent.logseq.api` in your plugin code.

#### Discovering Available Methods

```javascript
// In Logseq console (DevTools → Console)

// List all API methods containing 'tag'
Object.keys(logseq.api).filter(k => k.includes('tag'))
// Output: ['add_tag_property', 'remove_tag_property', 'create_tag', ...]

// List all API methods containing 'property'
Object.keys(logseq.api).filter(k => k.includes('property'))

// List all available APIs
Object.keys(logseq.api).sort()

// Check method signature (if available)
console.log(logseq.api.add_tag_property.toString())
```

#### Testing APIs Directly

Before implementing in your plugin, test APIs in the console:

```javascript
// Get a tag UUID first
const tag = await logseq.Editor.getTag('zot')
console.log('Tag UUID:', tag.uuid)

// Test adding a property to the tag
await logseq.api.add_tag_property(tag.uuid, 'testProperty')
// If it works, you'll see the property added to the tag schema

// Test removing it
await logseq.api.remove_tag_property(tag.uuid, 'testProperty')
```

#### Translating Console Commands to Plugin Code

**In Console** (parent frame):
```javascript
await logseq.api.add_tag_property(tagUuid, 'author')
```

**In Plugin** (iframe context):
```typescript
// @ts-ignore
const parentLogseq = (window as any).parent?.logseq
await parentLogseq.api.add_tag_property(tagUuid, 'author')
```

#### Discovering Property Namespaces

```javascript
// Get a page and inspect its properties
const page = await logseq.Editor.getCurrentPage()
console.log('Page properties:', Object.keys(page))

// Look for property keys with namespaces
// Example: ":plugin.property.my-plugin/title"
//          ":logseq.property/created-at"
```

#### Common Discovery Patterns

```javascript
// 1. Find all 'Editor' methods
Object.keys(logseq.Editor)

// 2. Find all 'DB' methods
Object.keys(logseq.DB)

// 3. Find all 'API' methods (snake_case style)
Object.keys(logseq.API)

// 4. Search by keyword
const keyword = 'block'
[
  ...Object.keys(logseq.Editor).filter(k => k.includes(keyword)),
  ...Object.keys(logseq.DB).filter(k => k.includes(keyword)),
  ...Object.keys(logseq.API).filter(k => k.includes(keyword))
]
```

**Best Practice**: Always test new or undocumented APIs in the console before writing plugin code. This helps you understand the correct parameters and return values.

---

## Practical Plugin Patterns

### Pattern 1: Tag Schema Setup on Install

Create and configure tags when plugin is first installed.

```typescript
// On plugin load
async function initializePlugin() {
  // Check if setup already done
  const settings = logseq.settings
  if (settings?.setupComplete) {
    return
  }

  try {
    // Create #zot tag
    const tag = await logseq.Editor.createTag('zot')

    if (!tag) {
      throw new Error('Tag already exists or creation failed')
    }

    // Define properties
    const properties = [
      'zoteroKey', 'citeKey', 'itemType',
      'title', 'author1', 'author2', 'author3', 'authorsEtAl',
      'year', 'DOI', 'url', 'publicationTitle',
      'collections', 'tags'
    ]

    for (const prop of properties) {
      await logseq.API['tag-add-property']('zot', prop)
    }

    // Create template
    await createZotTemplate()

    // Mark setup complete
    logseq.updateSettings({ setupComplete: true })

    logseq.UI.showMsg('✅ Zotero plugin setup complete!', 'success')
  } catch (error) {
    logseq.UI.showMsg(`❌ Setup failed: ${error.message}`, 'error')
  }
}

async function createZotTemplate() {
  const template = await logseq.Editor.createPage(
    'Zotero Item Template',
    {
      tags: ['Template'],
      properties: {
        'template-name': 'Zotero Item',
        'Apply template to tags': '#zot'
      }
    }
  )

  await logseq.Editor.appendBlockInPage(template.uuid, '## Annotations')
  await logseq.Editor.appendBlockInPage(template.uuid, '## Notes')
  await logseq.Editor.appendBlockInPage(template.uuid, '## Reading Notes')
}

// Register initialization
logseq.ready(initializePlugin)
```

### Pattern 2: Import Workflow with Properties

Import external data (e.g., from Zotero) into Logseq DB.

```typescript
interface ZoteroItem {
  key: string
  itemType: string
  title: string
  creators: Array<{ firstName: string; lastName: string; creatorType: string }>
  date: string
  DOI?: string
  url?: string
  collections: Array<{ name: string }>
  tags: Array<{ tag: string }>
  abstractNote?: string
  notes: Array<{ note: string }>  // HTML content
}

async function importZoteroItem(item: ZoteroItem) {
  // 1. Check if already imported
  const existing = await findItemByZoteroKey(item.key)
  if (existing) {
    console.log('Item already imported')
    return
  }

  // 2. Process creators
  const authors = item.creators
    .filter(c => c.creatorType === 'author')
    .map(c => `${c.firstName} ${c.lastName}`.trim())

  const properties: Record<string, any> = {
    zoteroKey: item.key,
    itemType: item.itemType,
    title: item.title,
    year: parseInt(item.date?.substring(0, 4) || '0'),
    collections: item.collections.map(c => c.name),
    tags: item.tags.map(t => t.tag)
  }

  // Add authors (first 3 + overflow)
  if (authors.length > 0) properties.author1 = authors[0]
  if (authors.length > 1) properties.author2 = authors[1]
  if (authors.length > 2) properties.author3 = authors[2]
  if (authors.length > 3) properties.authorsEtAl = authors.slice(3).join(', ')

  // Add optional fields
  if (item.DOI) properties.DOI = `https://doi.org/${item.DOI}`
  if (item.url) properties.url = item.url
  if (item.abstractNote) properties.abstract = item.abstractNote

  // 3. Create page with properties
  const page = await logseq.Editor.createPage(
    item.title,
    {
      tags: ['zot'],
      properties
    }
  )

  // 4. Add notes as blocks (if template not used)
  if (item.notes.length > 0) {
    const noteBlocks = item.notes.map(note => ({
      content: parseHTMLToMarkdown(note.note)
    }))

    await logseq.Editor.insertBatchBlock(
      page.uuid,
      noteBlocks,
      { sibling: false }
    )
  }

  return page
}

async function findItemByZoteroKey(key: string) {
  const query = `
  {:query [:find (pull ?b [*])
           :where
           [?b :logseq.property/zoteroKey "${key}"]]}
  `

  const results = await logseq.DB.datascriptQuery(query)
  return results.length > 0 ? results[0][0] : null
}

function parseHTMLToMarkdown(html: string): string {
  // Implement HTML to Markdown conversion
  // Keep existing parser from markdown plugin
  return html  // Simplified
}
```

### Pattern 3: Query and Display in UI

Query items and display results in plugin UI.

```typescript
async function searchZoteroItems(searchText: string) {
  // Query by title (case-insensitive)
  const query = `
  {:query [:find (pull ?b [*])
           :where
           [?b :block/tags ?t]
           [?t :block/title "zot"]
           [?b :logseq.property/title ?title]
           [(clojure.string/lower-case ?title) ?lowerTitle]
           [(clojure.string/includes? ?lowerTitle "${searchText.toLowerCase()}")]]}
  `

  const results = await logseq.DB.datascriptQuery(query)
  const items = results.map(r => r[0])

  // Display in UI
  displaySearchResults(items)
}

function displaySearchResults(items: any[]) {
  const html = items.map(item => {
    const props = item.properties || {}
    return `
      <div class="zot-item">
        <h3>${props.title || 'Untitled'}</h3>
        <p>${props.author1 || 'Unknown'} (${props.year || 'n.d.'})</p>
        <button onclick="window.openItem('${item.uuid}')">Open</button>
      </div>
    `
  }).join('')

  logseq.provideUI({
    key: 'search-results',
    template: `<div class="zot-search-results">${html}</div>`
  })
}

// Make function available to UI
window.openItem = async (uuid: string) => {
  await logseq.Editor.scrollToBlockInPage(uuid)
}
```

---

## Plugin Architecture Patterns

Best practices for organizing production-quality Logseq plugins based on real-world implementations.

### File Organization

**Recommended structure** for maintainable plugins:

```
logseq-plugin/
├── src/
│   ├── index.ts         # Plugin initialization & entry point
│   ├── events.ts        # Event handlers (DB.onChanged, user interactions)
│   ├── logic.ts         # Core business logic (pure functions)
│   ├── settings.ts      # Settings schema and accessors
│   └── types.ts         # TypeScript interfaces and types
├── dist/                # Build output (auto-generated)
├── package.json         # Dependencies & metadata
├── tsconfig.json        # TypeScript configuration
└── vite.config.ts       # Build configuration
```

**Separation of Concerns**:

1. **index.ts** - Entry point only
   - Plugin initialization
   - Register event listeners
   - Bootstrap logic
   - Minimal code, delegates to other modules

2. **events.ts** - I/O and side effects
   - DB.onChanged handlers
   - User interaction handlers
   - Debouncing and throttling
   - Calls pure functions from logic.ts

3. **logic.ts** - Pure business logic
   - No I/O operations
   - No Logseq API calls
   - Testable pure functions
   - Takes data in, returns data out

4. **settings.ts** - Configuration
   - Settings schema definition
   - Settings accessors
   - Default values
   - Validation logic

5. **types.ts** - Type definitions
   - TypeScript interfaces
   - Type aliases
   - Constants
   - Re-exports from @logseq/libs

### Settings Registration

Use Logseq's built-in settings schema system for user configuration.

#### Settings Schema Definition

**Example from logseq-checklist**:

```typescript
// settings.ts
import { SettingSchemaDesc } from '@logseq/libs/dist/LSPlugin.user'
import { PluginSettings, DEFAULT_SETTINGS } from './types'

/**
 * Register settings using Logseq's built-in settings schema
 */
export function registerSettings(): void {
  try {
    const settings: SettingSchemaDesc[] = [
      {
        key: 'checklistTag',
        type: 'string',
        title: 'Checklist Tag',
        description: 'Tag used to identify checklist blocks (without # prefix)',
        default: DEFAULT_SETTINGS.checklistTag,
      },
      {
        key: 'checkboxTag',
        type: 'string',
        title: 'Checkbox Tag',
        description: 'Tag used to identify checkbox blocks (without # prefix)',
        default: DEFAULT_SETTINGS.checkboxTag,
      }
    ]

    logseq.useSettingsSchema(settings)
  } catch (error) {
    console.error('Error registering settings schema:', error)
  }
}

/**
 * Get current plugin settings with defaults
 * Uses Logseq's built-in settings system
 */
export function getSettings(): PluginSettings {
  try {
    // Logseq automatically provides settings via logseq.settings
    if (logseq.settings) {
      return {
        checklistTag: logseq.settings?.checklistTag || DEFAULT_SETTINGS.checklistTag,
        checkboxTag: logseq.settings?.checkboxTag || DEFAULT_SETTINGS.checkboxTag,
      }
    }

    // Fallback to defaults if settings not available
    return DEFAULT_SETTINGS
  } catch (error) {
    console.error('Error loading settings:', error)
    return DEFAULT_SETTINGS
  }
}
```

```typescript
// types.ts
export interface PluginSettings {
  checklistTag: string
  checkboxTag: string
}

export const DEFAULT_SETTINGS: PluginSettings = {
  checklistTag: 'checklist',
  checkboxTag: 'checkbox'
}
```

#### Settings Schema Types

Available setting types in `SettingSchemaDesc`:

```typescript
type SettingSchemaDesc = {
  key: string                    // Setting identifier
  type: 'string' | 'number' | 'boolean' | 'enum' | 'heading'
  title: string                  // Display name in UI
  description: string            // Help text
  default: any                   // Default value

  // For 'enum' type only:
  enumChoices?: string[]         // Available options
  enumPicker?: 'select' | 'radio'  // UI control type
}
```

**Example with all types**:

```typescript
const settings: SettingSchemaDesc[] = [
  {
    key: 'generalSettings',
    type: 'heading',
    title: 'General Settings',
    description: 'Basic configuration options',
    default: null
  },
  {
    key: 'tagName',
    type: 'string',
    title: 'Tag Name',
    description: 'Tag to monitor for changes',
    default: 'mytag'
  },
  {
    key: 'debounceMs',
    type: 'number',
    title: 'Debounce Delay (ms)',
    description: 'Delay before processing changes',
    default: 300
  },
  {
    key: 'enabled',
    type: 'boolean',
    title: 'Enable Plugin',
    description: 'Toggle plugin functionality',
    default: true
  },
  {
    key: 'displayMode',
    type: 'enum',
    title: 'Display Mode',
    description: 'How to show progress indicators',
    default: 'inline',
    enumChoices: ['inline', 'prefix', 'suffix'],
    enumPicker: 'select'
  }
]
```

#### Accessing Settings

Settings are available via `logseq.settings` object:

```typescript
// Anywhere in your plugin code
const settings = getSettings()  // Use accessor function for type safety

// Or direct access
const tagName = logseq.settings?.tagName || 'default'
```

### Error Handling

**Production-ready error handling pattern**:

```typescript
// index.ts - Main initialization
async function main() {
  try {
    // 1. Register settings first
    registerSettings()

    // 2. Initialize features with error handling
    if (logseq.DB?.onChanged) {
      logseq.DB.onChanged((txData) => {
        handleDatabaseChanges(txData)
      })
    } else {
      // Graceful degradation - inform user
      logseq.UI.showMsg(
        'Plugin: Automatic updates not available in this Logseq version',
        'warning'
      )
    }

    // 3. Register UI commands/buttons if needed
    // ...

  } catch (error) {
    // Log to console for debugging
    console.error('Error initializing plugin:', error)

    // Show user-friendly error message
    logseq.UI.showMsg('Plugin initialization failed', 'error')
  }
}

// Bootstrap with error handling
logseq.ready(main).catch(console.error)
```

**Error handling in event handlers**:

```typescript
// events.ts
export function handleDatabaseChanges(changeData: any): void {
  try {
    // Extract datoms
    const txData = changeData?.txData || []

    // Process changes
    for (const datom of txData) {
      // ... processing logic
    }
  } catch (error) {
    // Log but don't crash the plugin
    console.error('Error handling database changes:', error)
    // Don't show UI messages for every event - too noisy
  }
}
```

**Best Practices**:
- ✅ Wrap initialization in try/catch
- ✅ Log errors to console.error (users can see in DevTools)
- ✅ Show UI messages for critical failures only
- ✅ Provide graceful degradation when features unavailable
- ✅ Don't show UI errors on every event (causes UI spam)
- ✅ Include context in error messages ("Error in X")

### TypeScript Configuration

**Recommended tsconfig.json** for Logseq plugins:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ES2020",
    "lib": ["ES2020", "DOM"],
    "moduleResolution": "node",
    "esModuleInterop": true,
    "strict": true,
    "skipLibCheck": true,
    "resolveJsonModule": true,
    "outDir": "dist",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### Build Configuration (Vite)

**Recommended vite.config.ts** using vite-plugin-logseq:

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

**package.json scripts**:

```json
{
  "scripts": {
    "build": "vite build",
    "dev": "vite build --watch"
  },
  "dependencies": {
    "@logseq/libs": "^0.2.8"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.3.0",
    "vite": "^7.2.2",
    "vite-plugin-logseq": "^1.1.2"
  }
}
```

### Complete Mini-Plugin Example

**Full working plugin demonstrating all patterns** (based on logseq-checklist architecture):

```typescript
// ===== types.ts =====
import { BlockEntity } from '@logseq/libs/dist/LSPlugin'

export type IDatom = [
  e: number,        // Entity ID
  a: string,        // Attribute name
  v: any,           // Value
  t: number,        // Transaction ID
  added: boolean    // true if added, false if retracted
]

export interface PluginSettings {
  monitorTag: string
  updateDelay: number
}

export const DEFAULT_SETTINGS: PluginSettings = {
  monitorTag: 'monitor',
  updateDelay: 300
}

export type { BlockEntity }

// ===== settings.ts =====
import { SettingSchemaDesc } from '@logseq/libs/dist/LSPlugin.user'
import { PluginSettings, DEFAULT_SETTINGS } from './types'

export function registerSettings(): void {
  try {
    const settings: SettingSchemaDesc[] = [
      {
        key: 'monitorTag',
        type: 'string',
        title: 'Monitor Tag',
        description: 'Tag to monitor for changes',
        default: DEFAULT_SETTINGS.monitorTag,
      },
      {
        key: 'updateDelay',
        type: 'number',
        title: 'Update Delay (ms)',
        description: 'Debounce delay for updates',
        default: DEFAULT_SETTINGS.updateDelay,
      }
    ]

    logseq.useSettingsSchema(settings)
  } catch (error) {
    console.error('Error registering settings:', error)
  }
}

export function getSettings(): PluginSettings {
  try {
    if (logseq.settings) {
      return {
        monitorTag: logseq.settings?.monitorTag || DEFAULT_SETTINGS.monitorTag,
        updateDelay: logseq.settings?.updateDelay || DEFAULT_SETTINGS.updateDelay,
      }
    }
    return DEFAULT_SETTINGS
  } catch (error) {
    console.error('Error loading settings:', error)
    return DEFAULT_SETTINGS
  }
}

// ===== logic.ts =====
import { BlockEntity } from './types'

/**
 * Pure business logic - no I/O, fully testable
 */
export function processBlock(block: BlockEntity): string {
  const content = block.content || ''
  // ... your logic here
  return content
}

// ===== events.ts =====
import { IDatom } from './types'
import { getSettings } from './settings'
import { processBlock } from './logic'

const pendingUpdates = new Set<string>()
let updateTimer: NodeJS.Timeout | null = null

export function handleDatabaseChanges(changeData: any): void {
  try {
    const txData: IDatom[] = changeData?.txData || []

    // Filter for property changes
    for (const datom of txData) {
      const [entityId, attribute, value, txId, added] = datom

      // Only process specific property changes
      if (attribute && attribute.includes(':user.property/')) {
        scheduleUpdate(String(entityId))
      }
    }
  } catch (error) {
    console.error('Error handling database changes:', error)
  }
}

function scheduleUpdate(blockUuid: string): void {
  const settings = getSettings()

  pendingUpdates.add(blockUuid)

  if (updateTimer) {
    clearTimeout(updateTimer)
  }

  updateTimer = setTimeout(async () => {
    for (const uuid of pendingUpdates) {
      await updateBlock(uuid)
    }
    pendingUpdates.clear()
  }, settings.updateDelay)
}

async function updateBlock(uuid: string): Promise<void> {
  try {
    const block = await logseq.Editor.getBlock(uuid)
    if (!block) return

    const newContent = processBlock(block)
    await logseq.Editor.updateBlock(block.uuid, newContent)
  } catch (error) {
    console.error('Error updating block:', error)
  }
}

// ===== index.ts =====
import '@logseq/libs'
import { handleDatabaseChanges } from './events'
import { registerSettings } from './settings'

async function main() {
  try {
    // 1. Register settings
    registerSettings()

    // 2. Setup DB listener
    if (logseq.DB?.onChanged) {
      logseq.DB.onChanged((txData) => {
        handleDatabaseChanges(txData)
      })
    } else {
      logseq.UI.showMsg(
        'Plugin: DB.onChanged not available',
        'warning'
      )
    }

    console.log('Plugin initialized successfully')
  } catch (error) {
    console.error('Error initializing plugin:', error)
    logseq.UI.showMsg('Plugin initialization failed', 'error')
  }
}

logseq.ready(main).catch(console.error)
```

### Testing Strategy

**Recommended approach** for plugin development:

1. **Manual Testing**:
   - Load plugin with "Load unpacked plugin"
   - Open DevTools Console (Cmd/Ctrl+Shift+I)
   - Monitor console.log and console.error output
   - Test with small test graph

2. **Debug Logging**:
   ```typescript
   const DEBUG = true  // Set to false for production

   function debug(...args: any[]) {
     if (DEBUG) {
       console.log('[Plugin]', ...args)
     }
   }

   debug('Processing block:', block.uuid)
   ```

3. **Error Boundaries**:
   - Wrap all async operations in try/catch
   - Log errors with context
   - Continue operation when possible

4. **Performance Monitoring**:
   ```typescript
   const start = performance.now()
   // ... operation
   const elapsed = performance.now() - start
   console.log(`Operation took ${elapsed.toFixed(2)}ms`)
   ```

### Deployment Checklist

Before releasing a plugin:

- [ ] **Version number** updated in package.json
- [ ] **CHANGELOG.md** updated with changes
- [ ] **README.md** includes installation and usage instructions
- [ ] **Build succeeds** with `pnpm run build`
- [ ] **Test in fresh graph** with sample data
- [ ] **DevTools console** shows no errors
- [ ] **Settings work** and have sensible defaults
- [ ] **Error messages** are user-friendly
- [ ] **Source maps** included for debugging (sourcemap: true)
- [ ] **GitHub release** created with dist/ folder as zip
- [ ] **LICENSE** file included (e.g., MIT)

### Source Reference

These patterns are production-tested in:
- **logseq-checklist plugin v1.0.0**: Complete working implementation
- GitHub: [https://github.com/kerim/logseq-checklist](https://github.com/kerim/logseq-checklist)
- Files: All source files demonstrate these patterns
- Lines of code: ~350 total (clean, maintainable architecture)

**Key Achievements**:
- ✅ Zero configuration required
- ✅ Automatic real-time updates
- ✅ Debounced performance optimization
- ✅ Comprehensive error handling
- ✅ User-configurable settings
- ✅ Clean separation of concerns

---

## Common Pitfalls & Solutions

### Pitfall 1: Tag Creation Validation Errors

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

### Pitfall 2: Property Name Conflicts

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

### Pitfall 3: Query Tag Matching Issues

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

### Pitfall 4: Multi-value Property Querying

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

### Pitfall 5: Date Property Formatting

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

### Pitfall 6: Property Auto-hide Assumptions

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

### Pitfall 7: Property Value Dereferencing

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

### Pitfall 8: Wrong Tag Method Names

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

---

## Version Compatibility

### Minimum Versions

**Logseq**:
- DB graph support: Logseq 0.10.0+
- Full DB API: Logseq 0.11.0+
- Latest features (custom UUID, tag management): Logseq 0.11.0+

**@logseq/libs**:
- **Minimum for DB graphs**: `^0.3.0` (required for DB compatibility)
- Basic DB support: `^0.0.17` (limited features)
- Tag management APIs: `^0.2.4`
- Full new APIs: `^0.2.8`

**Check in package.json**:

```json
{
  "dependencies": {
    "@logseq/libs": "^0.2.8"
  },
  "engines": {
    "logseq": ">=0.11.0"
  }
}
```

### Feature Availability by Version

| Feature | @logseq/libs Version | Commit |
|---------|---------------------|--------|
| `createPage` with properties | 0.0.17+ | - |
| `createTag` | 0.2.4+ | 51fbc705d |
| `addTag` / `removeTag` | 0.2.4+ | 51fbc705d |
| `tag-add-property` / `tag-remove-property` | 0.2.5+ | 7f4d8ad22 |
| `devEntry` support | 0.2.6+ | 501230b0d |
| Custom UUID for pages | 0.2.6+ | 28bc28ecd |
| Custom UUID for tags | 0.2.7+ | bd4b022a0 |
| `prependBlockInPage` | 0.2.7+ | 025e2e70d |
| Plugin class namespaces | 0.2.8+ | 0a54e807b |
| `reset-property-values` option | 0.2.8+ | 94a2d9c28 |

### Checking Versions Programmatically

```typescript
// Check Logseq version
const logseqVersion = await logseq.App.getInfo('version')
console.log(`Logseq version: ${logseqVersion}`)

// Check if feature available
const hasCreateTag = typeof logseq.Editor.createTag === 'function'
if (!hasCreateTag) {
  logseq.UI.showMsg(
    '❌ This plugin requires Logseq 0.11.0+ with @logseq/libs 0.2.4+',
    'error'
  )
}
```

---

## Related Resources

### Skills
- **logseq-db-knowledge** - Essential DB graph concepts (nodes, properties, tags, queries)
- **logseq-cli** - Working with Logseq via CLI (queries, exports)

### Documentation
- Official plugin docs: https://plugins-doc.logseq.com/
- Logseq DB guide: https://docs.logseq.com (DB sections)
- @logseq/libs API reference: https://github.com/logseq/logseq/tree/master/libs/src

### Example Projects

- **logseq-tag-schema-poc**: `/Users/niyaro/Documents/Code/Logseq/logseq-tag-schema-poc/`
  - **Working demonstration of tag schema API**
  - Confirms `parent.logseq.api.add_tag_property()` works
  - Documents property initialization requirement
  - Shows entity reference behavior
  - Includes comprehensive future research questions
  - GitHub: https://github.com/kerim/logseq-tag-schema-poc

- **logseq-zot-db-plugin**: `/Users/niyaro/Documents/Code/Logseq-Zotero Integration/logseq-zot-db-plugin/`
  - Real-world example of Zotero integration
  - Uses tag schemas, property API, template auto-apply
  - Demonstrates import workflows

- **Migration Plan**: `/Users/niyaro/Documents/Code/Logseq-Zotero Integration/logseq-zotero-db-migration-plan.md`
  - Detailed analysis of MD → DB migration
  - Decision rationale for tag strategies
  - Property design patterns

### Commits (Latest API Additions)
1. 0a54e807b - Plugin class namespaces, enhanced tag APIs
2. 51fbc705d - createTag, addTag, removeTag
3. 7f4d8ad22 - tag-add-property, tag-remove-property
4. 501230b0d - devEntry support
5. 28bc28ecd - Custom UUID for pages
6. bd4b022a0 - Custom UUID for tags
7. 94a2d9c28 - reset-property-values option
8. 025e2e70d - prependBlockInPage export

---

## Quick Reference: Key APIs

### Page/Block Creation
```typescript
// Create page
logseq.Editor.createPage(name, { tags, properties, customUUID })

// Create tag
logseq.Editor.createTag(name, { uuid })

// Insert blocks
logseq.Editor.insertBatchBlock(uuid, blocks, opts)
logseq.Editor.appendBlockInPage(uuid, content)
logseq.Editor.prependBlockInPage(uuid, content)
```

### Tag Management
```typescript
// Create/retrieve tags
logseq.Editor.createTag(name, { uuid })
logseq.Editor.getTag(nameOrUuidOrIdent)
logseq.Editor.getTagObjects(nameOrIdent)
logseq.Editor.getAllTags()

// Associate tags with blocks
logseq.Editor.addBlockTag(blockUuid, tagName)
logseq.Editor.removeBlockTag(blockUuid, tagName)

// Tag inheritance
logseq.Editor.addTagExtends(childTagId, parentTagId)
logseq.Editor.removeTagExtends(childTagId, parentTagId)

// Block icons
logseq.Editor.setBlockIcon(blockId, iconType, iconName)
logseq.Editor.removeBlockIcon(blockId)

// Define tag properties (name-based)
logseq.API['tag-add-property'](tagName, propName)
logseq.API['tag-remove-property'](tagName, propName)

// Define tag properties (UUID or name-based)
logseq.Editor.addTagProperty(tagId, propertyIdOrName)
logseq.Editor.removeTagProperty(tagId, propertyIdOrName)
```

### Property Management
```typescript
// Set single property
logseq.Editor.upsertBlockProperty(uuid, key, value)

// Set multiple properties
logseq.API['db-based-save-block-properties!'](uuid, props, opts)
```

### Queries
```typescript
// Datalog query
logseq.DB.datascriptQuery(queryString)

// Get tagged objects
logseq.API['get-class-objects'](tagName)
```

---

## Summary

This skill provides the essential knowledge for building Logseq plugins that work with DB graphs:

✅ **Key Differences**: Understand how DB plugins differ from markdown plugins
✅ **Tag/Class APIs**: Create and manage tags programmatically with the new APIs
✅ **Property Handling**: Set typed properties during creation and updates
✅ **Import Patterns**: Use Property API + templates for robust imports
✅ **Querying**: Write Datalog queries specific to DB graphs
✅ **Pitfall Avoidance**: Know the common mistakes and how to avoid them

**Remember**: DB graph plugins require different approaches than markdown plugins. Always use `:block/title` for tag matching, set properties during creation, and leverage the new tag management APIs for robust plugin development.

For foundational DB graph concepts, see the `logseq-db-knowledge` skill. For practical examples, explore the `logseq-zot-db-plugin` project.
