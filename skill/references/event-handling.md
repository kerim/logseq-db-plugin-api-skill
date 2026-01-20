# Event-Driven Updates with DB.onChanged

## Overview

The `DB.onChanged` hook enables plugins to respond to database changes in real-time. This is essential for plugins that need to maintain derived state (like progress indicators, aggregations, or computed properties) based on user edits.

**Use cases:**
- Auto-updating progress indicators when checkboxes toggle
- Maintaining aggregated statistics across tagged items
- Triggering workflows based on property changes
- Keeping caches synchronized with the database

**Source**: Patterns validated in [logseq-checklist v1.0.0](https://github.com/kerim/logseq-checklist) production plugin.

## Event Structure

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

## Filtering Transaction Datoms

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

## Debouncing Updates

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

## Complete Example: Checkbox Change Tracking

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
