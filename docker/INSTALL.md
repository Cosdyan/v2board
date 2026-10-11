# V2Board Docker Compose 一键部署

本目录为 `Cosdyan/v2board` 的 Docker 部署支持。根据仓库的 Laravel 8、MySQL、Redis、Horizon、Artisan Scheduler 和原有 `database/install.sql` 设计。

## 快速安装

适用于已安装 **Docker Engine、Docker Compose v2、Git 和 OpenSSL** 的 Linux 服务器。建议首次在全新测试机部署：

```bash
curl -fsSLo install-v2board.sh https://raw.githubusercontent.com/Cosdyan/v2board/master/docker/install.sh
sudo bash install-v2board.sh
```

脚本默认安装到 `/opt/v2board-docker`，询问管理员邮箱并随机生成管理员密码。密码会在终端显示，请及时保存。默认监听 **127.0.0.1:8080**，建议由宿主机 Nginx/Caddy/Cloudflare Tunnel 提供 HTTPS。

支持环境变量：`INSTALL_DIR`、`HTTP_PORT`、`BIND_IP`、`APP_URL`、`ADMIN_EMAIL`、`ADMIN_PASSWORD`、`NONINTERACTIVE=1`。例如：

```bash
sudo env ADMIN_EMAIL=admin@example.com APP_URL=https://panel.example.com bash install-v2board.sh
```

## 组件

- `app`: Nginx + PHP-FPM 8.1（内部监听 8080）
- `db`: MariaDB 10.11（仅容器网络访问）
- `redis`: Redis 7（仅容器网络访问，AOF）
- `worker`: Laravel Horizon 任务队列
- `scheduler`: Laravel schedule:run 每分钟执行
- `app_storage`、`mysql_data`、`redis_data`: Docker 持久化卷

首次部署的 `docker:bootstrap` 命令读取仓库的 `database/install.sql`，生成管理员账号。检测到 `v2_user` 数据表时会拒绝覆盖已有数据。

## 运维

```bash
cd /opt/v2board-docker
docker compose ps
docker compose logs --tail=100 app worker scheduler
docker compose restart
docker compose up -d --build
```

更新前备份 `.env` 和所有 Docker 数据卷。生产环境必须配置 HTTPS、SMTP、备份和访问控制。不要直接公开 MariaDB 和 Redis。部署脚本目前只用于**全新实例**，不是现有手动部署站点的自动迁移工具。

**验证范围：** 已检查 Bash、PHP 文件基本语法及 Compose YAML 解析；尚未在实际运行 Docker 的服务器上完成镜像构建、MySQL 初始化及网页端到端验证。
