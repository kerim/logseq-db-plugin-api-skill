# Changelog

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
