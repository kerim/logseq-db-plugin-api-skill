# Logseq DB Plugin API Skill

A comprehensive Claude Code skill for developing Logseq plugins specifically for **DB (database) graphs**.

## Overview

This skill provides essential knowledge for building Logseq plugins that work with the new DB graph architecture. It covers the latest plugin API features including tag/class management, property handling, EDN import capabilities, and best practices for DB-specific development.

**Target Audience**: Developers building plugins for Logseq DB graphs using Claude Code.

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

1. **Page & Block Management**
   - Creating pages with tags, properties, and custom UUIDs
   - Inserting nested block structures
   - Batch operations

2. **Tag/Class System**
   - Creating tags programmatically
   - Defining tag schemas (properties)
   - Plugin-specific namespaces
   - Tag association and removal

3. **Property Management**
   - Setting typed properties during creation
   - Multi-value properties
   - Reserved property names to avoid
   - Property auto-hide behavior

4. **Import Workflows**
   - Property API approach (recommended)
   - Template auto-apply pattern
   - EDN import considerations

5. **Queries & Database**
   - Datalog queries for DB graphs
   - Tag-based retrieval
   - Property filtering
   - Result caching patterns

6. **Common Pitfalls**
   - Tag creation validation
   - Property name conflicts
   - Query syntax issues
   - Multi-value property handling

## Installation

### For Claude Code Users

1. **Clone or download this repository:**
   ```bash
   cd ~/Documents/Code
   git clone https://github.com/yourusername/logseq-db-plugin-api-skill.git
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
  // Create #mydata tag
  const tag = await logseq.Editor.createTag('mydata')

  if (!tag) {
    console.error('Tag creation failed')
    return
  }

  // Define properties on the tag
  await logseq.API['tag-add-property']('mydata', 'title')
  await logseq.API['tag-add-property']('mydata', 'source')
  await logseq.API['tag-add-property']('mydata', 'date')

  // Create a page using the tag
  await logseq.Editor.createPage('Example Item', {
    tags: ['mydata'],
    properties: {
      title: 'My First Item',
      source: 'External API',
      date: '2024-01-15'
    }
  })

  console.log('✅ Plugin setup complete!')
}

logseq.ready(setupPlugin).catch(console.error)
```

## Version Requirements

- **Logseq**: 0.12.0+ (for full DB graph support)
- **@logseq/libs**: 0.2.8+ (for latest tag management APIs)
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
- `logseq.API['tag-add-property'](tagName, propName)`
- `logseq.API['tag-remove-property'](tagName, propName)`

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
