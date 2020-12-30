---
layout: post
title: shadowsocksR 客户端配置 (CentOS7.6)
date: 2020-12-21 12:20:23 +0900
category: VPN
---
## 前言
shadowsocks(ss)、shadowsocksr(ssr)、是凉个不同的软件，我的onecat只支持ssr或者kitsunebi,所以我才选择用ssr.

## Quickstart
```ruby
#!/bin/bash
# 安装 ssr 和 privoxy

# 下载项目
git clone https://github.com/shadowsocksrr/shadowsocksr.git
# 添加配置文件 输入配置内容
cat <<EOF >> config.json
{
    "server": "服务器域名/IP",
    "local_address": "127.0.0.1",    
    "local_port": 1080,
    "timeout": 300,
    "workers": 1,
    "server_port": 20443,
    "password": "密码",
    "method": "加密方式",
    "obfs": "plain",
    "obfs_param": "a97709873.acat.fun",
    "protocol": "auth_aes128_sha1",
    "protocol_param": "9873:m3RNU5"
}
EOF
# 运行客户端，server.py是服务端
python ./shadowsocksr/shadowsocks/local.py -c config.json
# ssr与服务端默认的通信方式为socks5，
# 需要一个 转化 把 http/https专为为 socks5
yum install -y privoxy
# 需要改配置文件，添加
# vi /etc/privoxy/config
# + forward-socks5t / 127.0.0.1:1020 . # ssr客户端监听端口
# + listen-address 127.0.0.1:8118 # privoxy 监听端口
# 添加环境变量设置代理
export http_proxy=http://localhost:8188
export https_proxy=http://localhost:8188
# 取消用 unset http_proxy
# 启动 privoxy 服务
sytemctl start privoxy 
# 测试，不卡能获取首页就证明没问题 
curl -X -G http://www.google.com.hk -v
```
