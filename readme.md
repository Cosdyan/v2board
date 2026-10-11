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

需要 Docker Engine、Docker Compose v2、Git、OpenSSL：

```bash
curl -fsSLo install-v2board.sh https://raw.githubusercontent.com/Cosdyan/v2board/master/docker/install.sh
sudo bash install-v2board.sh
```

安装说明：[`docker/INSTALL.md`](docker/INSTALL.md)。默认仅监听 `127.0.0.1:8080`，请配置 HTTPS 反向代理。
