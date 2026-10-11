<img src="https://avatars.githubusercontent.com/u/56885001?s=200&v=4" alt="logo" width="130" height="130" align="right"/>

# **V2Board**

- PHP7.3+
- Composer
- MySQL5.5+
- Redis
- Laravel

## Demo
[Demo](https://demo.v2board.com)

## Document
[Click](https://v2board.com)

## Sponsors
Thanks to the open source project license provided by [Jetbrains](https://www.jetbrains.com/)

## Community
🔔Telegram Channel: [@v2board](https://t.me/v2board)  

## How to Feedback
Follow the template in the issue to submit your question correctly, and we will have someone follow up with you.


## Docker Compose 一键部署（Cosdyan Fork）

### 1. 手动安装 Docker Engine 和 Docker Compose v2

适用于 **Debian 12/13、Ubuntu 22.04/24.04**。以下使用 Docker 官方 APT 仓库；先执行安装，再运行 V2Board 一键部署脚本。

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl git openssl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(. /etc/os-release; echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
```

确认安装成功：

```bash
sudo docker --version
sudo docker compose version
sudo docker info
```

如安装前已有发行版提供的 `docker.io`、`docker-compose` 等冲突软件包，请先按 [Docker 官方指南](https://docs.docker.com/engine/install/) 处理，不建议直接混装。Docker 服务默认需要 root 或 sudo 权限。

### 2. 一键部署 V2Board

安装 Docker 后执行：

```bash
curl -fsSLo install-v2board.sh https://raw.githubusercontent.com/Cosdyan/v2board/master/docker/install.sh
sudo bash install-v2board.sh
```

安装说明：[`docker/INSTALL.md`](docker/INSTALL.md)。默认仅监听 `127.0.0.1:8080`，请配置 HTTPS 反向代理。

### 3. 自动编译与 GitHub Release

参考 [V2Board 1.7.4 原版发布](https://github.com/v2board/v2board/releases/tag/1.7.4)（原版 Release 不附带独立二进制文件），本 Fork 使用 GitHub Actions 自动编译完整的 PHP Docker 镜像，并生成包含 Composer `vendor/` 依赖和已有前端静态资源的 `v2board-deploy.zip`。

- 提交到 `master` 或在 Actions 中手动运行 **Build V2Board Docker and Release**：构建并发布 `ghcr.io/cosdyan/v2board:latest`，同时生成 Actions 构建附件（保留 30 天）。
- 推送 `v...` 或数字版本标签（例如 `v1.7.4-cosdyan`）：还会自动创建相应的 GitHub Release 并附上 `v2board-deploy.zip` 与 `SHA256SUMS`。
- 构建的 Docker 镜像目前为 Linux AMD64。首次执行须在仓库设置中允许 Actions 读取/写入 GitHub Packages。
- 发行 ZIP 用于传统环境部署，不会自动安装 MySQL/Redis；Docker 全环境一键部署仍使用上面的 `docker/install.sh`。

[查看构建工作流](.github/workflows/build-release.yml)
