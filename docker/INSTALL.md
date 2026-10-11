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

## 优化与注意事项

- 已修复 PHP 镜像中 `/bin/sh` 不支持 Bash 花括号目录展开的问题，确保 `storage/framework/cache/data`、`sessions`、`views` 被正确创建。
- 初始化管理员账号的邮箱及密码通过临时容器环境变量提供，不再作为 `php artisan` 的命令行参数传入。
- 数据库只允许在**完全没有表**时导入 `database/install.sql`，因为原始 SQL 含 `DROP TABLE IF EXISTS`，严禁拿此脚本直接迁移已有站点。
- 安装器会验证本地 Git 仓库的远程地址，避免误对其他项目执行部署。
- 新增 GitHub Actions 的 Docker YAML、Bash、PHP 静态验证。

### 首次部署失败恢复

若容器启动失败，可以先检查：

```bash
cd /opt/v2board-docker
docker compose ps
docker compose logs --tail=150 app db worker scheduler
```

**不要直接执行 `docker compose down -v`**，该命令会永久删除 MariaDB、Redis 和应用存储卷。首次初始化若已经部分创建表，则需要人工检查数据库并恢复到可信的空库或备份后再初始化；不要覆盖已有数据。

### 当前限制

目前未完成实际容器镜像构建及端到端业务测试。本方案需要已安装的 Docker Engine / Compose v2；不自动安装 Docker。默认只开放回环地址 `127.0.0.1:8080`，域名与 HTTPS 反向代理需要自行配置。原仓库未固定 `composer.lock`，未来依赖解析可能随第三方版本变化；生产部署推荐验证通过后锁定依赖及镜像版本。
