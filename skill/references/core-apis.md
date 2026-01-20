# Core APIs Quick Reference

Essential Logseq DB plugin APIs for common operations.

## Tag/Class Management

### createTag - Create Class Pages

```typescript
// Basic tag creation
const tag = await logseq.Editor.createTag('zot')

// Create tag with custom UUID
const tag = await logseq.Editor.createTag('zot', {
  uuid: 'plugin-namespace-zot-tag'
})
```

**Validation Rules**:
- Tag name cannot be blank
- Tag name cannot contain forward slashes
- Tag name must be a string

### addBlockTag / removeBlockTag

```typescript
// Add tag to a block
await logseq.Editor.addBlockTag(blockUuid, 'zot')

// Remove tag from a block
await logseq.Editor.removeBlockTag(blockUuid, 'zot')
```

### getTag / getTagObjects

```typescript
// Get tag by name, UUID, or ident
const tag = await logseq.Editor.getTag('zot')

// Get all objects with a tag
const zotItems = await logseq.Editor.getTagObjects('zot')
```

### Tag Property Management

```typescript
// Add property to tag schema (using parent frame API)
const parentLogseq = (window as any).parent?.logseq
await parentLogseq.api.add_tag_property(tagUuid, 'propertyName')

// Remove property from tag schema
await parentLogseq.api.remove_tag_property(tagUuid, 'propertyName')
```

## Page & Block Creation

### createPage

```typescript
// Create page with tags and properties
const page = await logseq.Editor.createPage('Item Name', {
  tags: ['zot'],
  title: 'My Title',
  author: 'Jane Doe',
  year: '2023',
  url: 'https://example.com'
})

// With custom UUID
const page = await logseq.Editor.createPage('Item', {
  tags: ['data'],
  customField: 'value'
}, {
  uuid: 'custom-uuid-here'
})
```

### insertBatchBlock

```typescript
// Insert nested blocks
const blocks = [
  {
    content: 'Parent block',
    properties: { status: 'active' },
    children: [
      { content: 'Child 1' },
      { content: 'Child 2', children: [
        { content: 'Grandchild' }
      ]}
    ]
  }
]

await logseq.Editor.insertBatchBlock(parentUuid, blocks, {
  sibling: false  // Insert as children, not siblings
})
```

## Property Management

### upsertProperty - Define Property Types

```typescript
// Define property types BEFORE using them
await logseq.Editor.upsertProperty('title', { type: 'string' })
await logseq.Editor.upsertProperty('year', { type: 'number' })
await logseq.Editor.upsertProperty('isPublished', { type: 'checkbox' })
await logseq.Editor.upsertProperty('modifiedAt', { type: 'datetime' })
await logseq.Editor.upsertProperty('link', { type: 'url' })
await logseq.Editor.upsertProperty('relatedPage', { type: 'node' })

// Multi-value property
await logseq.Editor.upsertProperty('tags', {
  type: 'default',
  cardinality: 'many'
})

// Hidden property
await logseq.Editor.upsertProperty('internalId', {
  type: 'string',
  hide: true
})
```

### upsertBlockProperty

```typescript
// Update single property
await logseq.Editor.upsertBlockProperty(blockUuid, 'status', 'Done')

// Set multi-value property
await logseq.Editor.upsertBlockProperty(blockUuid, 'tags', ['tag1', 'tag2'])
```

### Property Utility Methods

```typescript
// Get property entity
const prop = await logseq.Editor.getProperty('propertyName')

// Get all properties of a block
const blockProps = await logseq.Editor.getBlockProperties(blockUuid)

// Get single property value
const value = await logseq.Editor.getBlockProperty(blockUuid, 'propertyName')

// Remove property from block
await logseq.Editor.removeBlockProperty(blockUuid, 'propertyName')
```

## Block Icons

```typescript
// Set emoji icon
await logseq.Editor.setBlockIcon(blockId, 'emoji', 'smile')

// Set tabler icon
await logseq.Editor.setBlockIcon(blockId, 'tabler-icon', 'calendar')

// Remove icon
await logseq.Editor.removeBlockIcon(blockId)
```

## Tag Inheritance

```typescript
// Create parent-child relationship
await logseq.Editor.addTagExtends(childTagId, parentTagId)

// Remove inheritance
await logseq.Editor.removeTagExtends(childTagId, parentTagId)
```

**Example - Creating tag hierarchy**:

```typescript
// Create parent tag (Task)
const taskTag = await logseq.Editor.createTag('Task')

// Create child tags that extend Task
const shoppingTag = await logseq.Editor.createTag('shopping')
const feedbackTag = await logseq.Editor.createTag('feedback')

// Establish parent-child relationships
await logseq.Editor.addTagExtends(shoppingTag.id, taskTag.id)
await logseq.Editor.addTagExtends(feedbackTag.id, taskTag.id)

// Now items tagged with #shopping or #feedback are also considered tasks
// See queries-and-database.md for how to query tag hierarchies
```

**Querying Tag Hierarchies**:

See [queries-and-database.md](./queries-and-database.md#tag-inheritance-with-or-join) for how to find items tagged with parent OR child tags using `or-join`.

## Utility Methods

```typescript
// Get all tags
const allTags = await logseq.Editor.getAllTags()

// Get all properties
const allProperties = await logseq.Editor.getAllProperties()

// Rename page
await logseq.Editor.renamePage(oldName, newName)

// Create journal page
const journalPage = await logseq.Editor.createJournalPage('2024-12-25')

// Get all pages
const pages = await logseq.Editor.getAllPages()

// Delete page
await logseq.Editor.deletePage(pageName)
```

## Block Operations

### getBlock

```typescript
// Get block
const block = await logseq.Editor.getBlock(uuid)

// Get block with children
const block = await logseq.Editor.getBlock(uuid, {
  includeChildren: true
})

// Get by entity ID
const block = await logseq.Editor.getBlock(entityId)
```

### updateBlock / appendBlock / insertBlock

```typescript
// Update block content
await logseq.Editor.updateBlock(uuid, 'New content')

// Append to page
await logseq.Editor.appendBlockInPage(pageUuid, 'Content')

// Prepend to page
await logseq.Editor.prependBlockInPage(pageUuid, 'Content')

// Insert before/after block
await logseq.Editor.insertBlock(targetUuid, 'Content', {
  before: true,  // Insert before target
  sibling: true  // Insert as sibling
})
```

## Database Hooks

### DB.onChanged

```typescript
// Listen to database changes
if (logseq.DB?.onChanged) {
  logseq.DB.onChanged((changeData) => {
    const { blocks, txData, deletedBlockUuids } = changeData

    // Process changes
    for (const datom of txData) {
      const [entityId, attribute, value, txId, added] = datom
      // Handle change
    }
  })
}
```

## Settings

### useSettingsSchema

```typescript
import { SettingSchemaDesc } from '@logseq/libs/dist/LSPlugin.user'

const settings: SettingSchemaDesc[] = [
  {
    key: 'tagName',
    type: 'string',
    title: 'Tag Name',
    description: 'Tag to monitor',
    default: 'mytag'
  },
  {
    key: 'enabled',
    type: 'boolean',
    title: 'Enable Plugin',
    description: 'Toggle functionality',
    default: true
  }
]

logseq.useSettingsSchema(settings)

// Access settings
const value = logseq.settings?.tagName || 'default'
```

## UI Methods

```typescript
// Show message
logseq.UI.showMsg('Operation complete', 'success')  // 'success' | 'error' | 'warning'

// Close UI element
logseq.UI.close(id)
```

## Query Methods

See [queries-and-database.md](./queries-and-database.md) for detailed query patterns.

```typescript
// Execute Datalog query
const results = await logseq.DB.datascriptQuery(query)

// Get class objects
const items = await logseq.API['get-class-objects']('tagName')
```

## Important Notes

1. **Property Types**: Always define property types with `upsertProperty()` before using them
2. **Tag Methods**: Use `addBlockTag()` / `removeBlockTag()` (not `addTag()` / `removeTag()`)
3. **Properties in createPage()**: Properties go at top level, NOT in `properties:{}` wrapper
4. **Namespaced Keys**: Properties stored as `:user.property/name` on block objects
5. **Date Properties**: Use journal page entity ID (`journalPage.id`), not date strings
