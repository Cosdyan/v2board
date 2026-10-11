#!/usr/bin/env bash
set -Eeuo pipefail
REPO_URL="https://github.com/Cosdyan/v2board.git"
BRANCH="${BRANCH:-master}"
DIR="${INSTALL_DIR:-/opt/v2board-docker}"
HTTP_PORT="${HTTP_PORT:-8080}"
BIND_IP="${BIND_IP:-127.0.0.1}"
APP_URL="${APP_URL:-http://localhost:${HTTP_PORT}}"
ADMIN_EMAIL="${ADMIN_EMAIL:-}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"
[[ $(id -u) -eq 0 ]] || { echo "请使用 root 执行"; exit 1; }
for c in docker git openssl; do command -v "$c" >/dev/null || { echo "缺少 $c，请先安装"; exit 1; }; done
docker compose version >/dev/null || { echo "需要 Docker Compose v2"; exit 1; }
[[ "$HTTP_PORT" =~ ^[0-9]+$ ]] && (( HTTP_PORT >= 1 && HTTP_PORT <= 65535 )) || { echo "HTTP_PORT 不合法"; exit 1; }
if [[ ! -d "$DIR/.git" ]]; then
  [[ ! -e "$DIR" ]] || { echo "$DIR 已存在而非 Git 仓库，拒绝覆盖"; exit 1; }
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$DIR"
fi
cd "$DIR"
if [[ -f .env ]]; then
  echo "检测到已有 .env，拒绝重复初始化；更新请执行 docker compose up -d --build"
  exit 1
fi
if [[ -z "$ADMIN_EMAIL" && "${NONINTERACTIVE:-0}" != 1 ]]; then
  read -rp "请输入管理员邮箱: " ADMIN_EMAIL
fi
[[ "$ADMIN_EMAIL" == *@*.* ]] || { echo "ADMIN_EMAIL 不合法"; exit 1; }
if [[ -z "$ADMIN_PASSWORD" ]]; then ADMIN_PASSWORD="$(openssl rand -hex 16)"; fi
(( ${#ADMIN_PASSWORD} >= 12 )) || { echo "管理员密码至少12位"; exit 1; }
DB_PASSWORD="$(openssl rand -hex 24)"
DB_ROOT_PASSWORD="$(openssl rand -hex 24)"
APP_KEY="$(openssl rand -base64 32 | tr -d '\n')"
umask 077
cat > .env <<ENV
APP_NAME=V2Board
APP_ENV=production
APP_KEY=base64:${APP_KEY}
APP_DEBUG=false
APP_URL=${APP_URL}
LOG_CHANNEL=stderr
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=v2board
DB_USERNAME=v2board
DB_PASSWORD=${DB_PASSWORD}
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
BIND_IP=${BIND_IP}
HTTP_PORT=${HTTP_PORT}
BROADCAST_DRIVER=log
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
REDIS_CLIENT=phpredis
REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379
MAIL_DRIVER=log
ENV
chmod 600 .env
echo "启动 MariaDB 和 Redis ..."
docker compose up -d db redis
echo "构建应用镜像 ..."
docker compose build app
echo "初始化数据库 ..."
docker compose run --rm -T app php artisan docker:bootstrap --email="$ADMIN_EMAIL" --password="$ADMIN_PASSWORD"
docker compose up -d --no-build
printf '\n部署完成！\n站点: %s\n管理员: %s\n初始密码: %s\n目录: %s\n' "$APP_URL" "$ADMIN_EMAIL" "$ADMIN_PASSWORD" "$DIR"
echo "请妥善保存密码，并配置 HTTPS 反向代理。"
