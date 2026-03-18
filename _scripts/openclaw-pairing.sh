#!/bin/bash
# OpenClaw Telegram 配对管理
# 用法:
#   ./openclaw-pairing.sh list          查看待处理的配对请求
#   ./openclaw-pairing.sh approve CODE  审批配对码

SERVER="root@192.168.1.12"
OPENCLAW_DIR="/opt/openclaw"

if ! command -v sshpass &>/dev/null; then
  echo "❌ 需要安装 sshpass: brew install sshpass"
  exit 1
fi

read -s -p "服务器密码: " PASSWORD
echo ""

run_remote() {
  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
    "$SERVER" "cd $OPENCLAW_DIR && node openclaw.mjs $*" 2>&1
}

case "${1:-list}" in
  list)
    echo "🔍 查询待处理的配对请求..."
    run_remote pairing list
    ;;
  approve)
    if [[ -z "$2" ]]; then
      echo "❌ 用法: $0 approve <配对码>"
      exit 1
    fi
    echo "✅ 审批配对码: $2"
    run_remote pairing approve "$2"
    ;;
  *)
    echo "用法:"
    echo "  $0 list          查看待处理的配对请求"
    echo "  $0 approve CODE  审批配对码"
    ;;
esac
