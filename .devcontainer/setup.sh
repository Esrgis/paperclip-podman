#!/bin/bash
# Lệnh set -e giúp script dừng ngay lập tức nếu có bất kỳ lỗi nào xảy ra
set -e 

echo "1. Cấu hình Volume và Symlink an toàn..."
rm -rf /workspace/paperclip-data
ln -s /home/node/paperclip-data /workspace/paperclip-data

echo "2. Tải Paperclip gốc và Cài đặt thư viện..."
git clone https://github.com/paperclip-ai/paperclip.git /workspace/paperclip
cd /workspace/paperclip
pnpm install
pnpm paperclipai onboard

echo "3. Cài đặt RTK (Bộ nén Input Token)..."
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
rtk init -g --opencode

echo "4. Cài đặt Cavemem (SQLite MCP Server)..."
npm install -g @juliusbrussee/cavemem

echo "5. Tải và cấu hình Skills chuẩn cho OpenCode..."
# Tạo thư mục theo chuẩn OpenCode (đọc vào .claude)
mkdir -p /workspace/.claude/skills/caveman
mkdir -p /workspace/.claude/skills/podman-env

# Tải Caveman và đổi tên thành SKILL.md
git clone https://github.com/JuliusBrussee/caveman.git /tmp/caveman
cp /tmp/caveman/caveman.md /workspace/.claude/skills/caveman/SKILL.md

# Copy file skill nội bộ của bạn vào đúng vị trí
cp /workspace/my-skills/podman-env.md /workspace/.claude/skills/podman-env/SKILL.md || echo "Cảnh báo: Chưa tìm thấy podman-env.md, bỏ qua..."

echo "HOÀN TẤT SETUP MÔI TRƯỜNG!"
