#!/bin/bash

# Kill các process cũ nếu còn treo ở port 8082 (Thêm 2>/dev/null để ẩn luôn cái lỗi fuser rác)
fuser -k 8082/tcp 2>/dev/null || true

# Bật free-claude-code proxy ở background
if [ -d "/workspace/free-claude-code" ]; then
    echo "Đang khởi động Proxy NIM (port 8082)..."
    cd /workspace/free-claude-code
    # Lưu ý: Cần có file .env ở trong thư mục free-claude-code chứa NVIDIA_NIM_API_KEY
    uv run uvicorn server:app --port 8082 &     
    cd /workspace # Đảm bảo luôn quay về gốc
    sleep 3
fi

# Bật Paperclip
echo "Đang khởi động Paperclip UI..."
cd /workspace/paperclip 
export HOST=0.0.0.0
export BIND=0.0.0.0
pnpm dev