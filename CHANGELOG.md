# Changelog

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
