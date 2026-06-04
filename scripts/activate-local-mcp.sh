#!/usr/bin/env bash
# Merges .mcp.local.json servers into .mcp.json for testing private/secret MCP configs.
# Backs up .mcp.json first so you can restore it cleanly.
# After running, restart Claude Code to pick up the new servers.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL="$REPO_ROOT/.mcp.local.json"
BASE="$REPO_ROOT/.mcp.json"
BACKUP="$REPO_ROOT/.mcp.json.backup"

if [ ! -f "$LOCAL" ]; then
  echo "Error: .mcp.local.json not found at $REPO_ROOT" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required. Install with: brew install jq" >&2
  exit 1
fi

LOCAL_COUNT=$(jq '.mcpServers | length' "$LOCAL")
if [ "$LOCAL_COUNT" -eq 0 ]; then
  echo "No servers in .mcp.local.json mcpServers — nothing to merge."
  exit 0
fi

cp "$BASE" "$BACKUP"
echo "Backed up .mcp.json → .mcp.json.backup"

jq -s '
  .[0] as $base |
  .[1].mcpServers as $local |
  $base | .mcpServers = ($base.mcpServers + $local)
' "$BASE" "$LOCAL" > "$BASE.tmp"

mv "$BASE.tmp" "$BASE"

NAMES=$(jq -r '.mcpServers | keys[]' "$LOCAL")
echo "Merged $LOCAL_COUNT server(s) into .mcp.json:"
echo "$NAMES" | sed 's/^/  + /'
echo ""
echo "Restart Claude Code (ctrl+c → claude) to activate new servers."
echo "When done testing: bash scripts/restore-mcp.sh"