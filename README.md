# Logseq DB Plugin API Skill

**Version**: 2.1.0
**Updated**: 2025-12-18

A comprehensive Claude Code skill for developing Logseq plugins specifically for **DB (database) graphs**, now with modular documentation and production-tested patterns.

## Overview

This skill provides essential knowledge for building Logseq plugins that work with the new DB graph architecture. It covers the complete plugin API verified against LSPlugin.ts TypeScript definitions, including tag/class management (with **CORRECTED method names**), property handling (with **complete upsertProperty signature**), icon management, tag inheritance, comprehensive type definitions, and proper Vite bundling setup.

**Target Audience**: Developers building plugins for Logseq DB graphs using Claude Code.

## What's New in v2.1.0

### Advanced Query Patterns 🔍

This update adds production-tested patterns for **complex Datalog queries**, including tag inheritance and disjunctive query patterns discovered through real-world plugin development.

**New Query Capabilities**:

1. **Tag Inheritance Queries** - Query items tagged with parent tags OR any child tags that extend them
   - Use `:logseq.property.class/extends` to traverse tag hierarchies
   - Find all tasks including #shopping, #feedback, etc. that extend #task
   - Production-tested `or-join` pattern for reliable results

2. **Disjunctive Queries with or-join** - Combine query branches with different variables
   - Solve "All clauses in 'or' must use same set of free vars" errors
   - Understand when to use `or-join [?vars]` vs standard `or`
   - Complete explanation with error examples and fixes

3. **:block/title vs :block/name** - Clear documentation of tag attribute differences
   - `:block/title` = Display name (case-sensitive, "Task")
   - `:block/name` = Normalized name (lowercase, "task")
   - When to use each in queries (app vs CLI contexts)

4. **Query Context Guide** - Same Datalog works across different contexts
   - Plugin API: `logseq.DB.datascriptQuery(query)`
   - App query blocks: Direct Datalog syntax
   - CLI: `logseq query` command patterns

**Documentation Updates**:
- **queries-and-database.md**: New "Advanced Query Patterns" section (~140 lines)
- **core-apis.md**: Tag hierarchy creation examples with cross-references
- **pitfalls-and-solutions.md**: Pitfall #9 about `or-join` variable mismatch
- **SKILL.md**: Updated search patterns and inheritance query examples

**Real-World Use Case**: Query all tasks of status "Todo" with any priority, including items tagged with tags that extend #task:

```clojure
{:query [:find (pull ?b [*])
         :where
         (or-join [?b]
           ;; Direct #task tags
           (and [?b :block/tags ?t]
                [?t :block/title "Task"])
           ;; Tags extending #task
           (and [?b :block/tags ?child]
                [?child :logseq.property.class/extends ?parent]
                [?parent :block/title "Task"]))
         [?b :logseq.property/status ?s]
         [?s :block/title "Todo"]
         [?b :logseq.property/priority ?p]]}
```

This pattern is essential for plugins that work with tag hierarchies and need to query derived relationships.

## What's New in v2.0.0

### Major Restructuring: Modular Documentation 📚

**Breaking Change**: SKILL.md is now lean (~420 lines) with detailed content in modular reference files.

**Why This Matters**:
- **Performance**: Only loads what's needed (SKILL.md loads on trigger, references load as needed)
- **Maintainability**: Each file has clear scope, easier to update specific topics
- **Context Efficiency**: Claude only loads relevant documentation for current task

**New Structure**:

```
logseq-db-plugin-api-skill/
├── SKILL.md                          # Lean entry point (~420 lines)
└── references/                       # Modular detailed docs
    ├── core-apis.md                  # Essential API methods
    ├── event-handling.md             # DB.onChanged patterns
    ├── plugin-architecture.md        # Best practices
    ├── property-management.md        # Property iteration patterns
    ├── queries-and-database.md       # Datalog query patterns
    ├── tag-detection.md              # Multi-layered detection
    └── pitfalls-and-solutions.md     # Common errors & fixes
```

**How to Use**:
- SKILL.md provides overview and quick start
- Each reference file covers specific functionality in detail
- Claude automatically loads reference files as needed
- Search patterns provided for finding specific topics

**Benefits**:
- ✅ 87% reduction in SKILL.md size (3200+ lines → 420 lines)
- ✅ Faster skill loading - core guidance available immediately
- ✅ Better organization - find what you need quickly
- ✅ Easier maintenance - update one file without affecting others
- ✅ Context-aware loading - only load what's relevant

### Content Preserved from v1.8.0

All content from v1.8.0 has been preserved and reorganized:

## Previous Updates

### v1.8.0 - Event Handling & Architecture Patterns

### Production Patterns from Real Plugins 🎯

This update adds **practical, battle-tested patterns** discovered while building the [logseq-checklist](https://github.com/kerim/logseq-checklist) plugin (v1.0.0). All examples are production-validated code from a working plugin.

### New Sections Added ✨

**1. Event-Driven Updates with DB.onChanged**:
- Complete event structure and datom filtering
- Debouncing strategies (300ms pattern with Set-based deduplication)
- Real-world example: automatic checkbox change detection
- Performance optimization for UI responsiveness

**2. Multi-Layered Tag Detection**:
- Three-tier detection approach for reliability
- Content check → datascript query → properties fallback
- Handles `block.properties.tags` unreliability
- 80% fast path, 100% reliable fallback

**3. Property Value Iteration**:
- Reading property values from block objects via namespaced keys
- Iteration patterns for unknown property names
- Type-based property detection (boolean, number, string)
- Direct key access vs iteration performance trade-offs

**4. Plugin Architecture Best Practices**:
- File organization patterns (index.ts, events.ts, logic.ts, settings.ts, types.ts)
- Settings registration with Logseq's schema system
- Production-ready error handling and graceful degradation
- Complete mini-plugin example (~350 lines)
- TypeScript and Vite configuration
- Testing strategy and deployment checklist

### Real-World Case Study 📚

**logseq-checklist plugin** referenced throughout as working example:
- GitHub: [https://github.com/kerim/logseq-checklist](https://github.com/kerim/logseq-checklist)
- Features: Automatic progress indicators for checklist blocks
- Architecture: Clean separation of concerns, zero configuration
- Lines of code: ~350 (maintainable, production-quality)

### Key Patterns Documented

✅ **Debouncing updates**: 300ms delay with Set-based deduplication
✅ **Multi-strategy tag detection**: Fast path + reliable fallback
✅ **Property iteration**: Finding values without knowing exact names
✅ **Error handling**: Try/catch with user-friendly messages
✅ **Settings system**: Type-safe configuration with defaults

### What's Changed

- **~1,200 lines of new content** - Practical patterns and complete examples
- **All code production-tested** - From logseq-checklist v1.0.0
- **Performance metrics included** - Real-world optimization strategies
- **Architecture guidance** - How to structure maintainable plugins

See [CHANGELOG.md](CHANGELOG.md) for complete v1.8.0 details.

## Previous Updates

### v1.7.0 - API Corrections & New Methods

**Critical Fixes**:
- Method name corrections: `addBlockTag()` and `removeBlockTag()` (not `addTag()`/`removeTag()`)
- Complete `upsertProperty` signature with cardinality, hide, public options

**New APIs**: Icon management (`setBlockIcon`, `removeBlockIcon`), tag inheritance (`addTagExtends`, `removeTagExtends`), utility methods (`getAllTags`, `getAllProperties`, etc.)

**Type Definitions**: Complete `BlockEntity`, `PageEntity`, `IDatom` interfaces

### v1.6.0 - Property Value Formats (100% SOLVED)

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
