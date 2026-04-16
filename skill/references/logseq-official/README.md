# Mirrored Upstream: logseq/logseq Development Notes

The markdown files in this directory are copied **unmodified** from
[logseq/logseq](https://github.com/logseq/logseq) and are licensed under
**GNU AGPL-3.0** (see `LICENSE` in this directory).

**All other content in this skill** — the root `SKILL.md`, the other files
under `skill/references/`, the project-root scripts and documentation — is
licensed **MIT** per the repo-root `LICENSE` file.

## What's here

| File | Source on master |
|------|------------------|
| `AGENTS.md` | `libs/development-notes/AGENTS.md` |
| `starter_guide.md` | `libs/development-notes/starter_guide.md` |
| `db_properties_skill.md` | `libs/development-notes/db_properties_skill.md` |
| `db_properties_guide.md` | `libs/development-notes/db_properties_guide.md` |
| `db_query_guide.md` | `libs/development-notes/db_query_guide.md` |
| `db_tag_property_idents_notes.md` | `libs/development-notes/db_tag_property_idents_notes.md` |
| `experiments_api_guide.md` | `libs/development-notes/experiments_api_guide.md` |

Each file has a 3-line footer appended (inside HTML comments, does not alter
rendered content) recording the upstream commit SHA and fetch timestamp:

```
<!-- logseq-mirror: commit=<SHA> fetched=<ISO-8601 UTC> -->
<!-- logseq-mirror: upstream=https://github.com/logseq/logseq/blob/<SHA>/libs/development-notes/<file> -->
```

One normalization is applied: if the upstream file lacks a trailing newline
(a common editor quirk), one is added before the footer. This guarantees the
footer-strip operation cleanly recovers the original content. Byte-for-byte
verification against upstream succeeds once upstream is similarly normalized.

## Current sync state

The file `.last-synced-sha` in this directory records the upstream commit the
mirrored files were copied from. Check it or the footer of any mirrored file
to see the current pinned SHA.

## Refresh

From the repo root:

```bash
bash scripts/sync-logseq-docs.sh
```

The script is idempotent: if upstream HEAD matches `.last-synced-sha` it exits
without rewriting. Otherwise it performs a `git pull --ff-only` on the local
sparse clone at `upstream/logseq-repo/` and atomically replaces the mirrored
files in this directory.

## License boundary (important for redistribution)

- Files in this directory (except this README) are **AGPL-3.0**
- The `LICENSE` file here is the full text of AGPL-3.0
- Modifications to these files in any public fork must comply with AGPL-3.0's
  copyleft and network-use provisions
- The MIT license at the repo root covers only the skill's own original
  content — it does **not** extend into this subfolder
