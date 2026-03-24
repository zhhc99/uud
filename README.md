# uud

**部署 uuplugin 在 Linux 上的守护进程.**

## 做了什么

去官方 API 拉取 steamdeck 版本的 UU 加速器, 部署到你的电脑, 然后保证它持续存活. 只在每次开机时检查一次更新.

效果和官方脚本基本一样.

## 如何使用

**安装:**

```bash
curl -sSL https://raw.githubusercontent.com/zhhc99/uud/main/install.sh | sudo bash
```

安装之后, 和官方脚本一样: 用 UU 主机加速器 APP 绑定 SteamDeck. 只在每次重启时需要重新绑定一次.

**卸载:**

```bash
curl -sSL https://raw.githubusercontent.com/zhhc99/uud/main/uninstall.sh | sudo bash
```

## 为什么要重写一个

官方的 uudeck 脚本有以下缺点:

- 目录不规范
- 多余的守护进程

**我觉得它可以更好 :p**

## 需要

- systemd
- curl
- bash
- jq, md5sum

如果你的 Linux 发行版没有这些, 你肯定可以自己解决问题.
