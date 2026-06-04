#!/usr/bin/env bash
# Restores .mcp.json from the backup created by activate-local-mcp.sh.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE="$REPO_ROOT/.mcp.json"
BACKUP="$REPO_ROOT/.mcp.json.backup"

if [ ! -f "$BACKUP" ]; then
  echo "No backup found at .mcp.json.backup — nothing to restore."
  exit 0
fi

mv "$BACKUP" "$BASE"
echo "Restored .mcp.json from backup."
echo "Restart Claude Code to deactivate the local servers."
