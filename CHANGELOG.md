# Changelog

## [2.2.0] - 2026-04-16

### Added

- **Layer 1: Authoritative upstream docs** — seven files mirrored verbatim from [logseq/logseq `libs/development-notes/`](https://github.com/logseq/logseq/tree/master/libs/development-notes) into `skill/references/logseq-official/`:
  - `AGENTS.md` — AI-agent development guide (SDK repo structure, conventions)
  - `starter_guide.md` — plugin bootstrap (Node, TypeScript, hello world)
  - `db_properties_skill.md` — DB properties SDK reference
  - `db_properties_guide.md` — File graph vs DB graph property storage
  - `db_query_guide.md` — Datascript query reference (`logseq.DB.q`, `datascriptQuery`, parameterized Datalog)
  - `db_tag_property_idents_notes.md` — Ident system and namespace conventions
  - `experiments_api_guide.md` — `logseq.Experiments` API (React integration, custom renderers)
- **`scripts/sync-logseq-docs.sh`** — refreshes mirrored docs from upstream via shallow+sparse `git clone`. Idempotent (SHA-based), atomic writes, fails loudly on upstream path renames.
- **`upstream/logseq-repo/`** — gitignored local mirror, populated by the sync script.
- **SKILL.md layered structure** with explicit precedence note: Layer 1 (upstream ground truth) → Layer 2 (production patterns) → Layer 3 (related skills). Layer 1 wins on API facts; Layer 2 wins on real-world pitfalls.
- **Layer 3 cross-references** to RCmerci's skills (`logseq-schema` for Datascript schema, `logseq-electron-debug` for Chrome DevTools against Logseq), plus existing `logseq-db-knowledge` and `logseq-cli-skill`.
- **Cross-links** added to the five supplementary reference files (`core-apis.md`, `queries-and-database.md`, `event-handling.md`, `property-management.md`, `plugin-architecture.md`) pointing at their corresponding Layer 1 file (or noting "supplementary — no Layer 1 equivalent").

### Changed

- **CLAUDE.md** (repo root) — File Structure diagram now includes `scripts/` and gitignored `upstream/`; Important Rule #1 refined from "only edit files in skill/" to "skill content lives in `skill/` only; repo-maintenance files may be added or modified at repo root" (reflects pre-existing practice with README/CHANGELOG/LICENSE/.gitignore).
- **README.md** — new "Mirrored upstream docs" section and explicit license boundary between MIT (skill content) and AGPL-3.0 (mirrored subfolder).

### Preserved

- **`references/tag-detection.md`** and **`references/pitfalls-and-solutions.md`** — unchanged; unique production-tested contributions not covered in Layer 1.

### License

- Repo root remains **MIT**.
- `skill/references/logseq-official/` is **AGPL-3.0** (full license text in that subfolder's `LICENSE`, attribution in its `README.md`). Redistribution of modifications to mirrored content must comply with AGPL-3.0.

## [2.1.0] - 2025-12-18

### Added

- **Tag Inheritance Query Patterns** - Production-tested patterns for querying tag hierarchies
  - Complete documentation of `:logseq.property.class/extends` attribute for tag parent relationships
  - Working `or-join` pattern for finding items with parent tag OR any child tags
  - Real-world example: Query all #task items including #shopping, #feedback, etc. that extend #task
  - Use case: Essential for plugins working with tag taxonomies and derived relationships
  - Location: `references/queries-and-database.md` (~140 new lines)

- **Disjunctive Query Patterns with or-join** - Solve "free vars" errors in complex queries
  - Comprehensive explanation of when `or-join [?vars]` is required vs. standard `or`
  - Error example showing "All clauses in 'or' must use same set of free vars" issue
  - Solution pattern with explicit variable unification
  - Multiple working examples combining tag inheritance with property filters
  - Location: `references/queries-and-database.md` and `references/pitfalls-and-solutions.md` (Pitfall #9)

- **:block/title vs :block/name Documentation** - Clear explanation of tag attribute differences
  - Table comparing both attributes: display name vs. normalized name
  - When to use each: `:block/title` (case-sensitive, "Task") vs. `:block/name` (lowercase, "task")
  - Context-specific recommendations: Plugin queries vs. app query blocks vs. CLI
  - Best practice: Use `:block/title` throughout for consistency with user-visible names
  - Location: `references/queries-and-database.md`

- **Query Context Guide** - Same Datalog syntax across different execution contexts
  - Plugin API: `logseq.DB.datascriptQuery(query)`
  - App query blocks: Direct Datalog in `{:query [...]}`
  - CLI: `logseq query` command with escaped syntax
  - Key differences documented: string wrapping, format requirements, execution environment
  - Location: `references/queries-and-database.md`

- **Tag Hierarchy Creation Example** - Practical example in core APIs
  - Step-by-step code showing how to create parent-child tag relationships
  - Uses `addTagExtends()` API to establish inheritance
  - Cross-reference to query patterns in queries-and-database.md
  - Location: `references/core-apis.md`

- **Pitfall #9: or Clause Variable Mismatch** - Common query error and solution
  - Problem: "All clauses in 'or' must use same set of free vars" error message
  - Cause: Using standard `or` with branches that have different variables
  - ❌ WRONG example showing the error
  - ✅ CORRECT solution using `or-join [?b]`
  - How or-join works: Explicitly declare which variables must unify
  - Cross-reference to complete query patterns
  - Location: `references/pitfalls-and-solutions.md`

### Changed

- **SKILL.md** - Updated version and enhanced query documentation
  - Version bumped from 2.0.0 to 2.1.0
  - Description updated to mention advanced query patterns
  - Added search patterns for new content: `or-join`, `tag inheritance`, `:logseq.property.class/extends`
  - Added tag inheritance query example to Essential Workflows section
  - Updated Queries reference section with new capabilities

- **README.md** - New release announcement and version update
  - Version updated from 2.0.0 to 2.1.0
  - Date updated from 2025-12-15 to 2025-12-18
  - Added "What's New in v2.1.0" section with Advanced Query Patterns announcement
  - Comprehensive documentation of new query capabilities
  - Real-world use case example with complete or-join query
  - Highlights production-tested nature of patterns

- **queries-and-database.md** - Major expansion with advanced patterns
  - Added "Advanced Query Patterns" section (~140 new lines)
  - Subsection: Tag Inheritance with or-join (complete patterns and explanations)
  - Subsection: :block/title vs :block/name (table and usage guide)
  - Subsection: Query Context (plugin/app/CLI comparison)
  - All examples tested via CLI and verified in app
  - Production-validated patterns from real-world testing

- **core-apis.md** - Enhanced tag inheritance documentation
  - Added practical tag hierarchy creation example (~20 new lines)
  - Shows complete workflow: create tags → establish relationships
  - Cross-reference to query patterns in queries-and-database.md
  - Clarifies how to use `addTagExtends()` in practice

- **pitfalls-and-solutions.md** - New common error documented
  - Added Pitfall #9: or Clause Variable Mismatch (~55 new lines)
  - Complete error example with actual error message
  - Side-by-side wrong vs. correct comparison
  - Explanation of how or-join solves the problem
  - Cross-reference to queries-and-database.md for complete patterns

### Technical Highlights

- **~287 lines of new content** - Focused on advanced query patterns
- **Production-tested patterns** - All queries verified via CLI and in-app testing
- **Real-world use case** - Derived from actual plugin development scenarios
- **Complete error coverage** - Common mistakes documented with solutions
- **Cross-referenced documentation** - Each file references related content
- **Datalog syntax verified** - All queries tested for correctness

### What This Means

Before v2.1.0, the skill documented basic Datalog queries but lacked patterns for:
- Querying tag hierarchies (items tagged with child tags)
- Combining query branches with different variables
- Understanding tag attribute differences

After v2.1.0:
- ✅ Query items with parent tags OR any child tags that extend them
- ✅ Write complex disjunctive queries without "free vars" errors
- ✅ Understand when to use :block/title vs. :block/name
- ✅ Know how queries work across different contexts (plugin/app/CLI)
- ✅ Avoid common or-join pitfalls with documented solutions
- ✅ Create and query tag taxonomies confidently

**This update elevates the skill from basic queries to advanced tag taxonomy patterns.**

---

## [2.0.0] - 2025-12-15

### 🎯 Major Restructuring: Modular Documentation

**BREAKING CHANGE**: SKILL.md restructured from monolithic file (~3,200 lines) to modular architecture with references/ directory.

This is a **major version bump** because the skill structure has fundamentally changed. While the content is preserved, the way it's organized and loaded is different.

### Added

- **Modular Reference Files** - Created 7 specialized reference files:
  - `references/event-handling.md` (~270 lines) - DB.onChanged patterns, debouncing strategies
  - `references/plugin-architecture.md` (~577 lines) - Best practices, file organization, settings
  - `references/tag-detection.md` (~175 lines) - Multi-layered detection approach
  - `references/property-management.md` (~227 lines) - Property iteration, namespaced keys
  - `references/queries-and-database.md` (~160 lines) - Datalog patterns, caching
  - `references/pitfalls-and-solutions.md` (~220 lines) - Common errors and fixes
  - `references/core-apis.md` (~200 lines) - Essential API methods quick reference

- **Progressive Disclosure Pattern**
  - Three-level loading: metadata → SKILL.md → references
  - Context-efficient documentation loading
  - Only load relevant content when needed

- **Search Patterns** - Added grep-friendly patterns for finding specific topics
  - Example: `DB.onChanged`, `debouncing`, `transaction datoms` for event handling
  - Example: `hasTag`, `block.properties.tags undefined` for tag detection

### Changed

- **SKILL.md** - Complete rewrite as lean hub file
  - Reduced from 3,200+ lines to ~420 lines (87% reduction)
  - Now serves as entry point with overview and quick start
  - References modular files for detailed content
  - Updated version from 1.8.0 to 2.0.0

- **README.md** - Updated to reflect new structure
  - Added "Major Restructuring: Modular Documentation" section
  - Explained benefits and how to use modular structure
  - Updated version to 2.0.0
  - Preserved v1.8.0 content in "Previous Updates" section

### Benefits

- ✅ **87% size reduction** - SKILL.md: 3,200+ lines → 420 lines
- ✅ **Faster loading** - Core guidance available immediately
- ✅ **Better organization** - Each file has clear scope
- ✅ **Easier maintenance** - Update one file without affecting others
- ✅ **Context efficiency** - Claude only loads relevant documentation

### Content Preservation

**IMPORTANT**: All content from v1.8.0 has been preserved and reorganized. Nothing was lost in the restructuring:
- Event-driven updates → `references/event-handling.md`
- Multi-layered tag detection → `references/tag-detection.md`
- Property value iteration → `references/property-management.md`
- Plugin architecture → `references/plugin-architecture.md`
- Core APIs → `references/core-apis.md`
- Queries → `references/queries-and-database.md`
- Pitfalls → `references/pitfalls-and-solutions.md`

### New Structure

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

### Migration Notes

If you've been using v1.8.0:
- The skill will continue to work - just update to v2.0.0
- All content is still available, just organized differently
- SKILL.md now provides overview and references detailed files
- Claude automatically loads reference files as needed

---

## [1.8.0] - 2025-12-15

### Added

- **Event-Driven Updates Section** (~270 lines) - Complete DB.onChanged patterns from real-world plugin
  - DB.onChanged event structure and setup
  - IDatom transaction data format: `[entityId, attribute, value, txId, added]`
  - Filtering transaction datoms by attribute patterns
  - Debouncing strategy: 300ms window with Set-based deduplication
  - Parent block traversal with safety limits (max 50 levels)
  - Complete working example from logseq-checklist plugin showing checkbox change tracking
  - Performance optimization: batch processing prevents UI thrashing
  - Source: Production-validated in logseq-checklist v1.0.0

- **Multi-Layered Tag Detection Section** (~175 lines) - Reliable tag detection for DB graphs
  - Three-tier detection approach for maximum reliability
  - Tier 1: Fast content-based check (80% of cases, instant)
  - Tier 2: Datascript query (most reliable, always works)
  - Tier 3: Properties fallback (safety net)
  - Handles `block.properties.tags` unreliability issue
  - Complete working implementation with all three tiers
  - Performance characteristics and when to use each tier
  - Real-world usage examples (finding parent blocks, filtering children)
  - Source: Production-validated in logseq-checklist v1.0.0

- **Property Value Iteration Section** (~227 lines) - Reading properties from block objects
  - Critical understanding: Properties stored as namespaced keys on block object
  - Property storage format: `:user.property/name`, `:logseq.property/name`, `:plugin.property.{id}/name`
  - Direct key access pattern for known property names
  - Iteration pattern for unknown/dynamic property names
  - Type-based property detection (boolean, number, string, array, entity reference)
  - Complete `getCheckboxValue()` example from logseq-checklist
  - Common use cases: finding properties, reading all user properties, filtering by type
  - Performance considerations: O(1) direct access vs O(n) iteration
  - Metadata properties to skip during iteration
  - Why `block.properties` is unreliable for reading values
  - Source: Production-validated in logseq-checklist v1.0.0

- **Plugin Architecture Patterns Section** (~577 lines) - Best practices for production plugins
  - File organization: index.ts, events.ts, logic.ts, settings.ts, types.ts
  - Separation of concerns: entry point, I/O, pure logic, configuration, types
  - Settings registration with Logseq's built-in `SettingSchemaDesc` system
  - All setting types: string, number, boolean, enum, heading
  - Settings accessor pattern with type safety and defaults
  - Production-ready error handling patterns
  - Graceful degradation when APIs unavailable
  - TypeScript configuration (tsconfig.json) for Logseq plugins
  - Vite build configuration with vite-plugin-logseq
  - Complete mini-plugin example (~350 lines) demonstrating all patterns
  - Testing strategy: manual testing, debug logging, error boundaries, performance monitoring
  - Deployment checklist: version, changelog, build, testing, release
  - Source: Complete architecture from logseq-checklist v1.0.0

- **Real-World Case Study** - logseq-checklist plugin referenced throughout
  - GitHub repository: https://github.com/kerim/logseq-checklist
  - Features: Automatic progress indicators for checklist blocks
  - Architecture: Clean separation of concerns, zero configuration
  - Performance: 300ms debouncing, efficient tag detection
  - Lines of code: ~350 total (maintainable, production-quality)
  - All examples in skill are from this working plugin

### Changed

- **SKILL.md**: Updated version from 1.7.0 to 1.8.0
- **SKILL.md Description**: Added mention of event-driven updates, multi-layered tag detection, property value iteration, and production-tested plugin architecture patterns
- **README.md**: Complete rewrite of "What's New" section for v1.8.0
- **README.md**: Added "Real-World Case Study" section featuring logseq-checklist
- **README.md**: Added "Key Patterns Documented" checklist
- **README.md**: Moved v1.7.0 content to "Previous Updates" section

### Technical Highlights

- **~1,200 lines of new content** - Practical, production-tested patterns
- **All code examples verified** - From logseq-checklist v1.0.0 working plugin
- **Performance metrics included** - Real-world optimization strategies
- **Complete working examples** - Not snippets, full implementations
- **Source attribution** - Every pattern linked to source code line numbers
- **Architecture guidance** - How to structure maintainable plugins

### What This Means

Before v1.8.0, the skill documented APIs but lacked practical implementation patterns.

After v1.8.0:
- ✅ Know how to handle database events efficiently
- ✅ Understand reliable tag detection strategies
- ✅ Can read properties dynamically without knowing names
- ✅ Have complete plugin architecture template
- ✅ Can copy production-tested code patterns
- ✅ Avoid common performance pitfalls

**This update transforms the skill from API reference to complete implementation guide.**

---

## [1.7.0] - 2025-12-14

### Fixed
- **CRITICAL**: Corrected method names from `addTag`/`removeTag` to `addBlockTag`/`removeBlockTag` throughout documentation
  - Fixed 4 instances in Tag/Class Management section
  - Fixed 2 instances in Quick Reference section
  - Method naming now matches LSPlugin.ts TypeScript definitions
- **CRITICAL**: Completed `upsertProperty` signature with all parameters
  - Added `cardinality` option ('one' | 'many') for single vs multi-value properties
  - Added `hide` option (boolean) for hiding properties from UI
  - Added `public` option (boolean) for public visibility
  - Added third parameter `opts` with `name` option for display names
  - Updated return type to `Promise<IEntityID>` (was incorrectly shown as void)
  - Added comprehensive parameter documentation
  - Added advanced usage examples

### Added
- **Icon Management APIs**: Complete documentation for `setBlockIcon()` and `removeBlockIcon()`
  - Emoji icon support with emoji-mart reference
  - Tabler icon support with icon library reference
  - Use cases and practical examples
  - Example showing icon mapping by type
- **Tag Inheritance APIs**: Complete documentation for `addTagExtends()` and `removeTagExtends()`
  - Create class hierarchies with parent-child relationships
  - Multiple inheritance support
  - Comprehensive taxonomy example
  - Use cases for content categorization
- **Type Definitions Section**: Comprehensive reference for all core types
  - `BlockEntity` interface with all properties documented
  - `PageEntity` interface with all properties documented
  - `BlockIdentity` and `PageIdentity` types
  - `IBatchBlock` interface with DB graph limitations noted
  - `IEntityID` and `EntityID` types
  - `IDatom` type for transaction data
- **Utility Methods Documentation**:
  - Page methods: `getAllTags()`, `getAllProperties()`, `renamePage()`, `createJournalPage()`, `getAllPages()`, `deletePage()`
  - Property methods: `getProperty()`, `removeProperty()`, `getPageProperties()`, `getBlockProperties()`, `getBlockProperty()`, `removeBlockProperty()`
  - Complete use cases and examples for each method
- **Pitfall 8**: Wrong Tag Method Names
  - Explains the addTag/removeTag error
  - Shows correct vs incorrect method names
  - Provides quick find-and-replace fix
  - Explains why the naming matters

### Changed
- Updated Quick Reference section with all new methods and corrected names
- Enhanced property management documentation with complete utility methods
- Improved page management section with all utility methods
- Updated skill description to mention corrected method names and complete API coverage

### Documentation
- All API documentation now verified against LSPlugin.ts TypeScript definitions
- Added comprehensive type information throughout
- Improved examples with proper type annotations
- Enhanced error messages and troubleshooting guidance

---

## [1.6.0] - 2025-11-18

### Added
- **DATE Property Solution** - Complete workflow for setting date properties ✅
  - Solution: Use journal page entity ID (`journalPage.id`)
  - Step-by-step workflow: define type → create journal page → use ID
  - Key points: CORRECT vs. WRONG formats documented
  - Journal page creation explained (ISO date format, automatic `journalDay` property)
  - Full working example with all 8 property types

### Changed
- **100% Property Type Success Rate** - ALL 8 types now working!
  - Updated from 87.5% (7/8) to 100% (8/8) success rate
  - Property value formats table: Added DATE type with `journalPage.id` format
  - Complete working example: Now includes all 8 types including date
  - Best practice code: Updated to include date property initialization
  - References: Added `logseq-journal-date-property-poc` v0.0.2
  - FUTURE-RESEARCH.md reference: Updated to "FULLY SOLVED (100%)"
  - Skill description: Updated to reflect 100% success rate

### Removed
- "Known Limitations" section about unsolvable date properties
- All references to date properties being "unsolved" or "unsupported"

### Fixed
- Date properties are now fully documented and working

## [1.5.0] - 2025-11-18

### Added
- **Complete Property Value Format Reference** - 87.5% success rate (7 of 8 types)
  - Comprehensive table showing working value formats for all property types
  - Confirmed working formats for: string, number, datetime, checkbox, url, node, default
  - Complete code example showing all 7 working property types
  - Storage behavior documented: entity references vs. direct values

- **Critical Discoveries Section**
  - Namespaced property keys: `:plugin.property.{plugin-id}/{property-name}` format
  - Entity reference vs. direct value storage patterns
  - Which types store entity IDs vs. actual values
  - How to read back values with correct key format

- **Date Property Limitation Documentation**
  - Exhaustive testing results (~20+ formats tested, 100% failure rate)
  - All tested formats documented (ISO, journal, timestamps, objects, entity IDs)
  - Error messages and validation failures explained
  - Hypothesis for future research documented

### Changed
- Updated property types table with confirmed value formats for all 8 types
- Enhanced `upsertProperty` examples to show all 7 working types
- Updated best practice code to include datetime, checkbox, url, node examples
- Changed POC reference from `active POCs` to `old POCs` (v0.0.12)
- Updated FUTURE-RESEARCH.md reference to reflect 87.5% success rate

### Fixed
- Property value format documentation now accurate for all types
- Removed "format unclear" status for datetime, checkbox, url, node
- Clarified that date property TYPE definition works, but VALUES cannot be set

### References
- POC: `/Users/niyaro/Documents/Code/Logseq API/old POCs/logseq-property-type-poc` (v0.0.12)
- Research: FUTURE-RESEARCH.md Question #3 - MOSTLY SOLVED (87.5%)
- Documentation: LEARNINGS.md with complete property value format reference

---

## [1.4.0] - 2025-11-18

### Added
- **Property Type Definition API** - `logseq.Editor.upsertProperty()` documentation
  - Complete API signature and usage examples
  - All 9 valid property types documented: default, string, number, date, datetime, checkbox, url, node, json
  - Note that `text` is invalid (use `default` or `string`)

- **NUMBER Property Solution** - Solved long-standing NUMBER property issue
  - Documented cause: numbers interpreted as entity references without type definition
  - Solution: Define property type with `upsertProperty` BEFORE using numeric values
  - Complete workflow examples for plugin initialization
  - Best practices for upfront property type definition

### Fixed
- **NUMBER Property Limitation** - Removed old workaround recommendation
  - OLD: Use string values like `year: '2025'` to avoid errors
  - NEW: Define type first with `upsertProperty`, then use actual numbers: `year: 2025`
  - Updated all examples to show correct approach

### Changed
- Updated property types section with complete `upsertProperty` documentation
- Added known limitations for complex property value setting (date, datetime, etc.)
- Added references to property-type POC (v0.0.8) and research documentation

### References
- POC: `/Users/niyaro/Documents/Code/Logseq API/active POCs/logseq-property-type-poc` (v0.0.8)
- Research: FUTURE-RESEARCH.md Questions #2 and #3 - Both SOLVED
- Documentation: LEARNINGS.md 2025-11-18 updates

---

## [1.3.0] - 2025-11-18

### Added
- **API Discovery in Console** - New section in Development Features
  - How to discover undocumented Logseq plugin APIs using browser console
  - Explains parent frame vs. plugin iframe context
  - Methods for listing available APIs by keyword
  - Testing APIs in console before implementing in plugins
  - Translating console commands to plugin code
  - Property namespace discovery techniques
  - Common discovery patterns for Editor, DB, and API methods

### Documentation
- Enhanced development workflow with practical API discovery techniques
- Added best practices for exploring undocumented APIs
- Helps developers understand parent frame context differences

---

## [1.1.0] - 2025-11-17

### Added
- **Parent Frame API Documentation** - Comprehensive coverage of `parent.logseq.api.add_tag_property()`
  - Confirmed working API for tag schema definition
  - Complete usage examples with error handling
  - Property initialization requirement (temp page pattern)

- **Entity Reference Behavior** - New section explaining property storage
  - Properties stored as entity IDs, not direct values
  - Property namespacing format: `:plugin.property.{plugin-id}/{property-name}`
  - Datalog query patterns for dereferencing property values

- **Property Value Dereferencing** - Examples for reading actual values
  - Explains why `getPage()` returns entity IDs
  - Complete Datalog query examples for dereferencing
  - Pitfall #7 added to Common Pitfalls section

- **Working POC Reference** - Added logseq-tag-schema-poc to example projects
  - Links to confirmed working demonstration
  - Documents successful tag schema API usage
  - Includes future research questions

### Fixed
- **createPage API examples** - Corrected parameter structure
  - Properties go at top level, NOT wrapped in `properties:{}`
  - Added clear wrong vs. correct examples
  - Updated all code examples throughout document

### Changed
- **Minimum SDK Version** - Updated to 0.3.0+ for DB graph compatibility
- **Property Type Examples** - All examples now use TEXT properties
  - Documented NUMBER property limitations
  - Removed unreliable NUMBER property patterns
  - Added recommendation to use strings for numeric values

### Documentation
- Enhanced complete tag setup pattern with property initialization
- Added entity reference explanations to property management section
- Updated all code examples to use namespaced property keys
- Added references to tag-schema-poc throughout

---

## [1.0.0] - 2024-11-16

### Initial Release
- Comprehensive Logseq DB plugin API documentation
- Tag/class management APIs
- Property handling and types
- Datalog query patterns
- Common pitfalls and solutions
- Import workflow patterns
- Version compatibility guide
