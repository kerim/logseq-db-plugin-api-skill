# Development Instructions for logseq-db-plugin-api-skill

<!-- SKILL-WORKFLOW-START -->
## Skill Development Workflow

This project follows the standardized skill workflow. The skill files are in the `skill/` subfolder, which is symlinked to `~/.claude/skills/logseq-db-plugin-api-skill/`.

### Important Rules

1. **Skill content lives in `skill/` only** — the `skill/` folder is symlinked to `~/.claude/skills/logseq-db-plugin-api-skill/`. Never edit the symlink target directly; always edit through `skill/` in this repo. Repo-maintenance files (`scripts/`, `upstream/`, `CHANGELOG.md`, `README.md`, `LICENSE`, `.gitignore`) may be added or modified at repo root.
2. **Update README.md** if functionality changes
3. **Ask user to review changes** before committing
4. **Commit and push** after user approval (if remote exists)

### File Structure

```
logseq-db-plugin-api-skill/
├── skill/                    # Symlinked to ~/.claude/skills/logseq-db-plugin-api-skill/
│   ├── SKILL.md              # The actual skill definition
│   └── references/           # Modular detailed documentation
│       ├── logseq-official/  # Mirrored upstream docs from logseq/logseq (AGPL-3.0)
│       │   ├── AGENTS.md, starter_guide.md, db_*.md, experiments_api_guide.md
│       │   ├── LICENSE       # Full AGPL-3.0 text
│       │   ├── README.md     # Attribution + license boundary
│       │   └── .last-synced-sha
│       ├── core-apis.md
│       ├── event-handling.md
│       ├── plugin-architecture.md
│       ├── property-management.md
│       ├── queries-and-database.md
│       ├── tag-detection.md
│       └── pitfalls-and-solutions.md
├── scripts/                  # Repo-maintenance scripts
│   └── sync-logseq-docs.sh   # Refreshes skill/references/logseq-official/
├── upstream/                 # Gitignored — local mirror of logseq/logseq
│   └── logseq-repo/          # Shallow+sparse clone, populated by sync script
├── README.md                 # GitHub install instructions
├── CLAUDE.md                 # This file - workflow instructions
├── CHANGELOG.md              # Version history
└── LICENSE                   # MIT License (covers all content except skill/references/logseq-official/)
```

### Before Committing

- [ ] Skill content changes are in `skill/` only; repo-maintenance changes (scripts/, upstream/, CHANGELOG, README) are allowed at root
- [ ] README.md updated if needed
- [ ] User has reviewed changes
- [ ] Version number updated (if applicable)
<!-- SKILL-WORKFLOW-END -->
