# Plugin Architecture Patterns

Best practices for organizing production-quality Logseq plugins based on real-world implementations.

## File Organization

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

## Settings Registration

Use Logseq's built-in settings schema system for user configuration.

###Settings Schema Definition

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

### Settings Schema Types

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

### Accessing Settings

Settings are available via `logseq.settings` object:

```typescript
// Anywhere in your plugin code
const settings = getSettings()  // Use accessor function for type safety

// Or direct access
const tagName = logseq.settings?.tagName || 'default'
```

## Error Handling

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

## TypeScript Configuration

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

## Build Configuration (Vite)

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

## Complete Mini-Plugin Example

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

## Testing Strategy

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

## Deployment Checklist

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

## Source Reference

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
