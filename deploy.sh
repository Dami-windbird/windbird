#!/bin/bash
set -euo pipefail

SERVER="$1"
DEPLOY_DIR="/tmp/windbird"

# 单次认证流程
read -s -p "请输入服务器密码：" PASS
echo

echo "[INFO] 正在同步部署文件...${DEPLOY_DIR}"
sshpass -p "${PASS}" rsync -azv \
  windbird.tar \
  docker-compose.yml \
  .env.prod \
  ${SERVER}:${DEPLOY_DIR}

echo "[INFO] 正在执行远程部署..."
sshpass -p "${PASS}" ssh -tt ${SERVER} bash << EOF
  set -e
  echo "[REMOTE] 切换目录：${DEPLOY_DIR}"
  cd ${DEPLOY_DIR}

  echo "[REMOTE] 加载镜像..."
  docker load -i windbird.tar

  echo "[REMOTE] 停止旧容器..."
  docker compose -f docker-compose.yml down

  echo "[REMOTE] 启动新容器..."
  docker compose -f docker-compose.yml up -d

  echo "[REMOTE] 部署完成。"
EOF

echo "[INFO] ✅ 部署完成，访问地址：http://your_server:8000"
