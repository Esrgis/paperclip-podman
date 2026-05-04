#!/bin/bash
set -e

echo "=== Paperclip Setup ==="

# 1. Symlink paperclip-data
echo "[1/5] Setup paperclip-data symlink..."
rm -rf /workspace/paperclip-data
ln -s /home/node/paperclip-data /workspace/paperclip-data

# 2. Clone paperclip upstream
echo "[2/5] Clone paperclip upstream..."
rm -rf /workspace/paperclip
git clone https://github.com/paperclipai/paperclip.git /workspace/paperclip

# 3. Install dependencies + onboard
echo "[3/5] Install dependencies..."
cd /workspace/paperclip
pnpm install
pnpm paperclipai onboard

# 4. RTK init cho OpenCode
echo "[4/5] Init RTK for OpenCode..."
~/.local/bin/rtk init -g --opencode || echo "Warning: RTK init failed, skip"

# 5. Inject Caveman skill
echo "[5/5] Inject Caveman skill..."
mkdir -p /home/node/.claude/skills/
cat > /home/node/.claude/skills/caveman.md << 'EOF'
## Communication Style

Terse like caveman. Technical substance exact. Only fluff die.
Drop: articles, filler (just/really/basically), pleasantries, hedging.
Fragments OK. Short synonyms. Code unchanged.
Pattern: [thing] [action] [reason]. [next step].
ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift.
Code/commits/PRs: normal. Off: "stop caveman" / "normal mode".
EOF

echo "=== Setup complete ==="
echo ""
echo "Next: tag image as stable"
echo "  podman images"
echo "  podman tag <IMAGE_ID> localhost/paperclip-env:stable"
echo "  Then update devcontainer.json args.BASE to localhost/paperclip-env:stable"