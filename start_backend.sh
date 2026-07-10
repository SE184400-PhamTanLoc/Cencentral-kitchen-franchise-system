#!/bin/bash

# Script khởi động song song Backend và Ngrok
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$PROJECT_DIR/central_kitchen_backend"
PORT=5170
DOMAIN="untanned-fritz-actinally.ngrok-free.dev"

# Hàm dọn dẹp khi tắt script (Ctrl+C)
cleanup() {
    echo ""
    echo "================================================="
    echo "   ĐANG DỪNG CẢ BACKEND VÀ NGROK...             "
    echo "================================================="
    kill $BACKEND_PID 2>/dev/null
    kill $NGROK_PID 2>/dev/null
    exit 0
}

# Đăng ký bẫy Ctrl+C để tắt cả 2 tiến trình cùng lúc
trap cleanup SIGINT SIGTERM

echo "================================================="
echo "   ĐANG KHỞI ĐỘNG HỆ THỐNG (BACKEND + NGROK)     "
echo "================================================="

# 1. Khởi động Ngrok chạy ngầm (Background)
echo "[1/2] Đang khởi động Ngrok trỏ đến cổng $PORT..."
echo "      Domain: https://$DOMAIN"
ngrok http --domain=$DOMAIN $PORT > /dev/null 2>&1 &
NGROK_PID=$!

# Đợi 2 giây cho ngrok ổn định
sleep 2

# 2. Khởi động Backend chạy nổi (Foreground) để bạn xem được Log
echo "[2/2] Đang khởi động Backend ở cổng $PORT..."
echo "      (Log của backend sẽ được hiển thị bên dưới)"
echo "-------------------------------------------------"
echo "Nhấn Ctrl + C để dừng cả Backend và Ngrok."
echo "-------------------------------------------------"

cd "$BACKEND_DIR" || exit 1
dotnet run --project Central_kitchen_API --launch-profile http &
BACKEND_PID=$!

# Chờ tiến trình Backend (khi tắt dotnet run thì script cũng dừng)
wait $BACKEND_PID
cleanup
