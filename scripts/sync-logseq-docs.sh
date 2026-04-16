#!/usr/bin/env bash
#
# sync-logseq-docs.sh — Mirror logseq/logseq libs/development-notes/ into
# skill/references/logseq-official/ via shallow+sparse git clone.
#
# Usage (from repo root):
#   bash scripts/sync-logseq-docs.sh
#
# Idempotent: if upstream HEAD matches .last-synced-sha, exits 0 without rewriting.
# Atomic: all copies use .tmp files and are moved into place only after every file succeeds.
# Trap cleans up .tmp files on any error.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

UPSTREAM_DIR="upstream/logseq-repo"
UPSTREAM_URL="https://github.com/logseq/logseq.git"
UPSTREAM_PATH="libs/development-notes"
TARGET_DIR="skill/references/logseq-official"
SHA_FILE="$TARGET_DIR/.last-synced-sha"

EXPECTED_FILES=(
    "AGENTS.md"
    "starter_guide.md"
    "db_properties_skill.md"
    "db_properties_guide.md"
    "db_query_guide.md"
    "db_tag_property_idents_notes.md"
    "experiments_api_guide.md"
)

trap 'rm -f "$TARGET_DIR"/*.tmp 2>/dev/null || true' EXIT

mkdir -p "$TARGET_DIR"

if [[ ! -d "$UPSTREAM_DIR/.git" ]]; then
    echo "==> First run: shallow+sparse clone of $UPSTREAM_URL"
    mkdir -p upstream
    git clone --depth 1 --filter=blob:none --no-checkout --branch master "$UPSTREAM_URL" "$UPSTREAM_DIR"
    git -C "$UPSTREAM_DIR" sparse-checkout init --cone
    git -C "$UPSTREAM_DIR" sparse-checkout set "$UPSTREAM_PATH"
    git -C "$UPSTREAM_DIR" checkout
else
    echo "==> Refreshing $UPSTREAM_DIR"
    git -C "$UPSTREAM_DIR" pull --ff-only
fi

UPSTREAM_SHA="$(git -C "$UPSTREAM_DIR" rev-parse HEAD)"

if [[ -f "$SHA_FILE" ]] && [[ "$(cat "$SHA_FILE")" == "$UPSTREAM_SHA" ]]; then
    echo "==> Already up to date at $UPSTREAM_SHA"
    exit 0
fi

echo "==> Verifying ${#EXPECTED_FILES[@]} expected files exist upstream"
for f in "${EXPECTED_FILES[@]}"; do
    if [[ ! -f "$UPSTREAM_DIR/$UPSTREAM_PATH/$f" ]]; then
        echo "ERROR: expected file missing upstream: $UPSTREAM_PATH/$f" >&2
        echo "ERROR: upstream may have been reorganized; inspect $UPSTREAM_DIR/$UPSTREAM_PATH/" >&2
        exit 1
    fi
done

FETCHED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "==> Copying files (SHA=$UPSTREAM_SHA, fetched=$FETCHED_AT)"

for f in "${EXPECTED_FILES[@]}"; do
    SRC="$UPSTREAM_DIR/$UPSTREAM_PATH/$f"
    TMP="$TARGET_DIR/$f.tmp"
    DST="$TARGET_DIR/$f"
    cp "$SRC" "$TMP"
    # Normalize: some upstream files lack a trailing newline. Add one if missing,
    # so the footer append doesn't corrupt the final content line. This normalization
    # is deliberate and documented in skill/references/logseq-official/README.md.
    if [[ -n "$(tail -c 1 "$TMP")" ]]; then
        printf '\n' >> "$TMP"
    fi
    printf '\n<!-- logseq-mirror: commit=%s fetched=%s -->\n<!-- logseq-mirror: upstream=https://github.com/logseq/logseq/blob/%s/%s/%s -->\n' \
        "$UPSTREAM_SHA" "$FETCHED_AT" "$UPSTREAM_SHA" "$UPSTREAM_PATH" "$f" >> "$TMP"
    mv "$TMP" "$DST"
done

echo "==> Extracting upstream LICENSE.md (AGPL-3.0) via git show"
# LICENSE.md at repo root is not in sparse-checkout; read from git object store instead
# (Named LICENSE.md in logseq/logseq; we save it as LICENSE for clarity in this subfolder)
git -C "$UPSTREAM_DIR" show HEAD:LICENSE.md > "$TARGET_DIR/LICENSE"

echo "$UPSTREAM_SHA" > "$SHA_FILE"

echo "==> Synced ${#EXPECTED_FILES[@]} files + LICENSE at SHA $UPSTREAM_SHA"
