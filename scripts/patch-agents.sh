#!/bin/bash
# patch-agents.sh — Apply all agent instruction patches to paperclip source
# Run this after cloning/updating paperclip to restore custom instructions
# Usage: bash scripts/patch-agents.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCHES_DIR="$SCRIPT_DIR/../agent-patches"
PAPERCLIP_DIR="$SCRIPT_DIR/../paperclip"
ONBOARDING="$PAPERCLIP_DIR/server/src/onboarding-assets"

echo "[patch-agents] Starting..."

# Check paperclip source exists
if [ ! -d "$ONBOARDING" ]; then
  echo "[patch-agents] ERROR: $ONBOARDING not found. Is paperclip cloned?"
  exit 1
fi

# Check patches dir exists
if [ ! -d "$PATCHES_DIR" ]; then
  echo "[patch-agents] ERROR: $PATCHES_DIR not found."
  exit 1
fi

# CEO patches
echo "[patch-agents] Patching ceo/HEARTBEAT.md..."
cp "$PATCHES_DIR/ceo/HEARTBEAT.md" "$ONBOARDING/ceo/HEARTBEAT.md"

echo "[patch-agents] Patching ceo/AGENTS.md..."
cp "$PATCHES_DIR/ceo/AGENTS.md" "$ONBOARDING/ceo/AGENTS.md"

echo "[patch-agents] Patching ceo/SOUL.md..."
cp "$PATCHES_DIR/ceo/SOUL.md" "$ONBOARDING/ceo/SOUL.md"

# Default patches
echo "[patch-agents] Patching default/AGENTS.md..."
cp "$PATCHES_DIR/default/AGENTS.md" "$ONBOARDING/default/AGENTS.md"

echo "[patch-agents] Done. All patches applied."
echo ""
echo "NOTE: These patches only affect NEW agents provisioned after this point."
echo "Existing agents in paperclip-data use their own copied instructions."
echo "To apply to existing agents, manually copy files or create a new company."