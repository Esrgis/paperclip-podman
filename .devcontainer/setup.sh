#!/bin/bash
set -e
    
echo "--- Bắt đầu setup môi trường AI Agent ---"

# Vá lỗi EACCES cho npm install global trong container
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

# Cài đặt các tool cần thiết    
# Cập nhật node trước (nếu cần)
npm install -g npm@10
# Cài tool
npm install -g pnpm opencode-ai @anthropic-ai/claude-code

# Vá lỗi RTK: Tắt telemetry trước để không bị treo
echo "Đang cài đặt RTK..."
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

rtk telemetry disable
rtk init -g --auto-patch --opencode

# Setup free-claude-code proxy
if [ -d "/workspace/free-claude-code" ]; then
    echo "Đang cấu hình free-claude-code proxy..."
    cd /workspace/free-claude-code
    uv sync
fi

echo "--- Setup hoàn tất! ---"