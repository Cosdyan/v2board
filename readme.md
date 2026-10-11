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
