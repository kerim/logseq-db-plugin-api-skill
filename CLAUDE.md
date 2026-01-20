# Development Instructions for logseq-db-plugin-api-skill

<!-- SKILL-WORKFLOW-START -->
## Skill Development Workflow

This project follows the standardized skill workflow. The skill files are in the `skill/` subfolder, which is symlinked to `~/.claude/skills/logseq-db-plugin-api-skill/`.

### Important Rules

1. **Only edit files in the `skill/` folder** - Never edit `~/.claude/skills/` directly (it's a symlink to this folder)
2. **Update README.md** if functionality changes
3. **Ask user to review changes** before committing
4. **Commit and push** after user approval (if remote exists)

### File Structure

```
logseq-db-plugin-api-skill/
├── skill/                    # Symlinked to ~/.claude/skills/logseq-db-plugin-api-skill/
│   ├── SKILL.md              # The actual skill definition
│   └── references/           # Modular detailed documentation
│       ├── core-apis.md
│       ├── event-handling.md
│       ├── plugin-architecture.md
│       ├── property-management.md
│       ├── queries-and-database.md
│       ├── tag-detection.md
│       └── pitfalls-and-solutions.md
├── README.md                 # GitHub install instructions
├── CLAUDE.md                 # This file - workflow instructions
├── CHANGELOG.md              # Version history
└── LICENSE                   # MIT License
```

### Before Committing

- [ ] Changes are in `skill/` folder only
- [ ] README.md updated if needed
- [ ] User has reviewed changes
- [ ] Version number updated (if applicable)
<!-- SKILL-WORKFLOW-END -->
