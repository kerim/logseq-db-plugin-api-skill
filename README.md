# Logseq DB Plugin API Skill

**Version**: 1.6.0
**Updated**: 2025-11-18

A comprehensive Claude Code skill for developing Logseq plugins specifically for **DB (database) graphs**.

## Overview

This skill provides essential knowledge for building Logseq plugins that work with the new DB graph architecture. It covers the latest plugin API features including tag/class management, property handling (with **ALL 8 property types confirmed working - 100% success rate!**), EDN import capabilities, proper Vite bundling setup, and best practices for DB-specific development.

**Target Audience**: Developers building plugins for Logseq DB graphs using Claude Code.

## What's New in v1.6.0

### Property Value Formats - 100% SOLVED! ✅

**COMPLETE BREAKTHROUGH**: All 8 property types now have confirmed working value formats!

- ✅ **string**: Plain string values → `"text"`
- ✅ **number**: Integer/float values → `2025`
- ✅ **datetime**: Milliseconds timestamp → `Date.now()`
- ✅ **checkbox**: Boolean values → `true` / `false`
- ✅ **url**: Plain URL strings → `"https://..."`
- ✅ **node**: Page name strings → `"Page Name"`
- ✅ **default**: Plain text → `"text"`
- ✅ **date**: Journal page entity ID → `journalPage.id` **← NEWLY SOLVED!**

### Date Property Solution 🎉

**The Missing Piece**: Date properties require journal page entity IDs!

```typescript
// 1. Define date property type
await logseq.Editor.upsertProperty('eventDate', { type: 'date' })

// 2. Create journal page with ISO date format
const journalPage = await logseq.Editor.createPage('2024-12-25', {}, { redirect: false })

// 3. Use journal page ID as date value
const event = await logseq.Editor.createPage('Christmas Party', {
  eventDate: journalPage.id  // ← Entity ID like 298
})
```

**Key Points**:
- ✅ Use `journalPage.id` (entity number) - works perfectly, NO warnings
- ❌ Don't use `journalPage.uuid` or `journalPage.name` - trigger validation warnings

### Critical Discoveries

1. **Namespaced Property Keys**: Plugin properties stored as `:plugin.property.{plugin-id}/{name}`
2. **Entity References vs Direct Values**: Some types store entity IDs, others store actual values
3. **Complete Working Examples**: Full code showing ALL 8 working property types
4. **Date Properties**: Require journal page entity references (newly discovered!)

### What's Changed

- **100% success rate**: Updated from 87.5% (7/8) to 100% (8/8)
- Property types table: Added DATE type with `journalPage.id` format
- `upsertProperty` examples: Now include all 8 types including date
- Best practices: Updated to include date property initialization
- Removed "Known Limitations" section about unsolvable date properties

See [CHANGELOG.md](CHANGELOG.md) for complete v1.6.0 details.

## Previous Updates

### v1.4.0 - Property Type Definition API

### New: Project Setup & Bundling Section 🚀

- **Complete Vite bundling guide**: Proper setup for fast plugin loading
- **vite-plugin-logseq**: Essential bundler configuration
- **Development workflow**: Watch mode, hot reloading, production builds
- **Common bundling issues**: Solutions for slow loading, build errors
- **Performance optimization**: Minification, tree-shaking, single file output

**Why this matters**: Without proper bundling, plugins load slowly and provide poor user experience. This update ensures you set up Vite correctly from the start.

### Previous Updates (v1.1.0)

### Confirmed Working APIs ✅
- **Tag Schema Definition**: Documented working `parent.logseq.api.add_tag_property()` API
- **Property Initialization**: Proven temp page pattern for creating properties before schema definition
- **Entity References**: Complete explanation of how properties are stored as database entities
- **Property Dereferencing**: Datalog query patterns for reading actual property values

### New Documentation
- **Working POC**: Reference to [logseq-tag-schema-poc](https://github.com/kerim/logseq-tag-schema-poc)
- **Property Namespacing**: How plugin properties are auto-namespaced
- **Common Pitfall #7**: Property value dereferencing issues and solutions
- **SDK Requirements**: Updated minimum version to 0.3.0+ for DB graphs

See [CHANGELOG.md](CHANGELOG.md) for complete details.

## What's Different in DB Graphs?

Logseq DB graphs use a fundamentally different data model than markdown-based graphs:

| Aspect | Markdown Graphs | DB Graphs |
|--------|----------------|-----------|
| **Data Storage** | Files (.md) | Database (SQLite) |
| **Properties** | YAML frontmatter | Typed database entities |
| **Tags** | Simple text markers | Classes with schemas |
| **Pages** | Unique by name | Unique by name + tag |
| **Queries** | File-based attributes | Database relationships |

## Key Features Covered

### New API Capabilities (2024-2025)

This skill documents the latest Logseq plugin API features added in recent commits:

- **Tag/Class Management**: `createTag`, `addTag`, `removeTag`, `tag-add-property`, `tag-remove-property`
- **Custom UUIDs**: Support for custom identifiers on pages and tags
- **Plugin Namespaces**: Create plugin-specific class namespaces
- **Property Control**: Enhanced property management with `reset-property-values` option
- **Block Operations**: New `prependBlockInPage` method
- **Development Features**: `devEntry` support for separate dev/prod builds

### Core Topics

1. **Project Setup & Bundling** 🆕
   - Vite configuration for fast plugin loading
   - vite-plugin-logseq setup
   - Development vs. production builds
   - Common bundling issues and solutions

2. **Page & Block Management**
   - Creating pages with tags, properties, and custom UUIDs
   - Inserting nested block structures
   - Batch operations

3. **Tag/Class System**
   - Creating tags programmatically
   - Defining tag schemas (properties)
   - Plugin-specific namespaces
   - Tag association and removal

4. **Property Management**
   - Setting typed properties during creation
   - Multi-value properties
   - Reserved property names to avoid
   - Property auto-hide behavior

5. **Import Workflows**
   - Property API approach (recommended)
   - Template auto-apply pattern
   - EDN import considerations

6. **Queries & Database**
   - Datalog queries for DB graphs
   - Tag-based retrieval
   - Property filtering
   - Result caching patterns

7. **Common Pitfalls**
   - Tag creation validation
   - Property name conflicts
   - Query syntax issues
   - Multi-value property handling

## Installation

### For Claude Code Users

1. **Clone or download this repository:**
   ```bash
   cd ~/Documents/Code
   git clone https://github.com/kerim/logseq-db-plugin-api-skill.git
   ```

2. **Install to Claude Code skills directory:**
   ```bash
   cp -r logseq-db-plugin-api-skill ~/.claude/skills/
   ```

3. **Restart Claude Code** to load the skill.

4. **Verify installation:**
   ```bash
   claude --list-skills | grep logseq-db-plugin-api
   ```

### Manual Installation

Copy the `SKILL.md` file to your Claude Code skills directory:

```bash
mkdir -p ~/.claude/skills/logseq-db-plugin-api
cp SKILL.md ~/.claude/skills/logseq-db-plugin-api/
```

## Usage

### In Claude Code

The skill will automatically activate when you:
- Ask about Logseq plugin development
- Work with Logseq DB graph plugins
- Mention tag management, property handling, or EDN import
- Debug plugin API issues

### Explicit Invocation

You can explicitly invoke the skill in your prompts:

```
Use the logseq-db-plugin-api skill to help me create a Zotero import plugin for Logseq DB graphs.
```

### Example Queries

**Creating a tag schema:**
```
How do I programmatically create a #zotero tag with properties for title, author, and year?
```

**Import workflow:**
```
What's the best approach for importing external data into Logseq DB graphs? Should I use EDN or the property API?
```

**Debugging queries:**
```
My query for items with #zot tag returns nothing. What am I doing wrong?
```

## Quick Start Example

Here's a minimal plugin that creates a tag with properties:

```typescript
import '@logseq/libs'

async function setupPlugin() {
  // 1. Create #mydata tag
  const tag = await logseq.Editor.createTag('mydata')

  if (!tag) {
    console.error('Tag creation failed')
    return
  }

  // 2. Initialize properties (required before adding to schema)
  const tempPage = await logseq.Editor.createPage(
    `temp-init-${Date.now()}`,
    {
      title: 'temp',
      source: 'temp',
      date: 'temp'
    },
    { redirect: false }
  )

  await logseq.Editor.deletePage(tempPage.name)
  console.log('✅ Properties initialized')

  // 3. Add properties to tag schema (using parent frame API)
  // @ts-ignore
  const parentLogseq = (window as any).parent?.logseq

  if (!parentLogseq?.api?.add_tag_property) {
    console.error('parent.logseq.api.add_tag_property not available')
    return
  }

  await parentLogseq.api.add_tag_property(tag.uuid, 'title')
  await parentLogseq.api.add_tag_property(tag.uuid, 'source')
  await parentLogseq.api.add_tag_property(tag.uuid, 'date')

  console.log('✅ Tag schema defined')

  // 4. Create a page using the tag (properties at top level!)
  await logseq.Editor.createPage('Example Item', {
    tags: ['mydata'],
    title: 'My First Item',
    source: 'External API',
    date: '2024-01-15'
  })

  console.log('✅ Plugin setup complete!')
}

logseq.ready(setupPlugin).catch(console.error)
```

**Key Points**:
- Properties must exist before adding to schema (step 2)
- Use `parent.logseq.api.add_tag_property()` from parent frame
- Properties go at top level in `createPage()`, NOT wrapped in `properties:{}`

## Version Requirements

- **Logseq**: 0.11.0+ (for full DB graph support)
- **@logseq/libs**: **0.3.0+** (minimum for DB graph compatibility)
  - 0.2.4+ for tag management APIs
  - 0.2.8+ for full feature set
- **Node.js**: 18+ recommended
- **Claude Code**: Latest version

## What's Included

- **SKILL.md**: Complete skill documentation with:
  - Comprehensive API reference
  - Code examples and patterns
  - Common pitfalls and solutions
  - Query examples
  - Version compatibility guide

## Differences from Markdown Plugin Development

If you're coming from markdown-based Logseq plugin development, here are the key differences:

### Property Setting

**Markdown approach:**
```typescript
// Text manipulation, frontmatter
await logseq.Editor.upsertBlockProperty(uuid, 'author', 'Jane Doe')
```

**DB approach:**
```typescript
// Typed properties, set during creation
await logseq.Editor.createPage('Title', {
  properties: {
    author: 'Jane Doe',    // text
    year: 2023,            // number
    published: '2023-05-15' // date
  }
})
```

### Tag Creation

**Markdown approach:**
- Tags are just text (`#tag`)
- No schema or structure

**DB approach:**
```typescript
// Tags are classes with properties
const tag = await logseq.Editor.createTag('zotero')
await logseq.API['tag-add-property']('zotero', 'itemType')
await logseq.API['tag-add-property']('zotero', 'year')
```

### Queries

**Markdown approach:**
```clojure
[:find (pull ?b [*])
 :where [?b :block/marker "TODO"]]
```

**DB approach:**
```clojure
{:query [:find (pull ?b [*])
         :where
         [?b :block/tags ?t]
         [?t :block/title "Task"]
         [?b :logseq.property/status ?s]
         [?s :block/title "Todo"]]}
```

## API Reference Summary

### Page/Block Creation
- `logseq.Editor.createPage(name, { tags, properties, customUUID })`
- `logseq.Editor.createTag(name, { uuid })`
- `logseq.Editor.insertBatchBlock(uuid, blocks, opts)`
- `logseq.Editor.prependBlockInPage(uuid, content)`

### Tag Management
- `logseq.Editor.addTag(blockUuid, tagName)`
- `logseq.Editor.removeTag(blockUuid, tagName)`
- `logseq.Editor.getTag(nameOrUuidOrIdent)`
- `logseq.Editor.getTagObjects(nameOrIdent)`
- **`parent.logseq.api.add_tag_property(tagUuid, propName)`** ✅ Confirmed working
- **`parent.logseq.api.remove_tag_property(tagUuid, propName)`** ✅ Confirmed working
- `logseq.API['tag-add-property'](tagName, propName)` - may be undefined in plugin context
- `logseq.Editor.addTagProperty(tagId, propertyIdOrName)` - may not be available in all versions

### Property Management
- `logseq.Editor.upsertBlockProperty(uuid, key, value)`
- `logseq.API['db-based-save-block-properties!'](uuid, props, opts)`

### Queries
- `logseq.DB.datascriptQuery(queryString)`
- `logseq.API['get-class-objects'](tagName)`

## Documentation Sources

This skill synthesizes information from:

1. **Official Plugin Docs**: https://plugins-doc.logseq.com/
2. **Logseq DB Knowledge Skill**: Foundational DB concepts
3. **Recent Commits**: Latest API additions (2024-2025)
   - 0a54e807b: Plugin class namespaces
   - 51fbc705d: createTag, addTag, removeTag
   - 7f4d8ad22: tag-add-property, tag-remove-property
   - 501230b0d: devEntry support
   - 28bc28ecd: Custom UUID for pages
   - bd4b022a0: Custom UUID for tags
   - 94a2d9c28: reset-property-values option
   - 025e2e70d: prependBlockInPage
4. **Real-World Projects**: Production plugin development experience

## Contributing

Contributions are welcome! If you discover new API features, better patterns, or common pitfalls:

1. Fork this repository
2. Add your improvements to SKILL.md
3. Update this README if needed
4. Submit a pull request

## License

MIT License - feel free to use, modify, and distribute.

## Support

For questions or issues:
- Open an issue on GitHub
- Check the official Logseq plugin documentation
- Consult the `logseq-db-knowledge` skill for DB graph fundamentals

## Acknowledgments

- **Logseq Team**: For the excellent DB graph architecture and plugin API
- **Community Contributors**: For documenting best practices and patterns
- **Claude Code**: For enabling AI-assisted plugin development

---

**Ready to build Logseq DB plugins?** Install this skill and start developing with confidence!
