---
title: 一次Frp引发的VPS的相关配置
permalink: Other/VpsAndNasAboutConfig/
date: 2021-05-30 19:58:11
categories:
	  - 其他
tags:
	  - 其他
	  - Frps
	  - Nginx
	  - BBR
	  - Jrebel
	  - MySql
	  - Aria
---

# 一次Frp引发的VPS的相关配置

## 前言

首先说明，这个文档，不涉及到具体的安装步骤，仅仅只是粗略的配置，以及 如何设置开机自启动。本文档的目的，是为了在后续vps迁移时，有一个可以参考的步骤。

另外，当前文档中，大部分附件，都设置密码，仅供本人使用。

前一阵时间，买了一个Nas服务器，但是呢，买完就后悔了。为什么呢？因为我的家里没有公网IP。哎。。想到`Qnap`提供的远程登录和文件传输，指的是想象就吐了。为此，在网上找了一堆`内网穿透` 的方案，最终还是决定使用`Frp`。为什么呢？

1. 网上文档比较多
2. 简单

真的，简单成为了我选择这个的最重要的方式。

废话不多说，直接上步骤吧。

## FRP

### 附件

[Frp文件](https://shengouqiang.cn/nas/frp.zip)

### 设置开机自启动

#### 文件位置

`/lib/systemd/system/frps.service`

#### 文件内容

```shell
[Unit]
Description=frps
After=network.target

[Service]
TimeoutStartSec=30
ExecStart=/root/frp/frps -c /root/frp/frps.ini
ExecStop=/bin/kill $MAINPID

[Install]
WantedBy=multi-user.target
```

#### 相关命令

```shell
systemctl enable frps
systemctl start frps
systemctl status frps
systemctl stop frps
```

## BBR

### 附件

[BBR文件](https://shengouqiang.cn/nas/bbr.sh)

## nginx

### 附件

[Nginx文件](https://shengouqiang.cn/nas/nginx.zip)

### 前置配置

```shell
yum install -y openssl openssl-devel  pcre pcre-devel zlib zlib-devel gcc gcc-c++ kernel-headers kernel-devel gcc make -y
```

### 开机自启动

#### 文件位置

`/lib/systemd/system/nginx.service`

#### 文件内容

```shell
[Unit]
Description = nginx
After = network.target

[Service]
Type = forking
ExecStart = /root/nginx/nginx/sbin/nginx -c /root/nginx/nginx/conf/nginx_443.conf
ExecReload = /root/nginx/nginx/sbin/nginx -c /root/nginx/nginx/conf/nginx_443.conf -s reload
ExecStop = /root/nginx/nginx/sbin/nginx -c /root/nginx/nginx/conf/nginx_443.conf -s stop
PrivateTmp = true

[Install]
WantedBy = multi-user.target
```

#### 相关命令

```shell
systemctl enable nginx
systemctl start nginx
systemctl status nginx
systemctl stop nginx
```

## Jrebel

### 附件

[JDK文件](https://shengouqiang.cn/nas/jdk8.zip)

[Jrebel文件](https://shengouqiang.cn/nas/Jrebel.zip)

### 环境配置

#### 文件位置

`/etc/profile`

#### 追加内容

```shell
JAVA_HOME=/root/jdk
JRE_HOME=$JAVA_HOME/jre
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
#PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:
```

### 自启动

#### java程序自启动

##### 文件位置

`/etc/rc.d/rc.local`

##### 文件内容

```shell
/root/jdk/bin/java -jar /root/Jrebel/boot.jar -p 8081 & > /root/Jrebel/default.log 2>&1
```

#### nginx程序自动启

##### 前置命令

```shell
cp nginx_jrebel.conf ~/nginx/nginx/conf/
```

##### 文件位置

`/lib/systemd/system/nginx_jrebel.service`

##### 文件内容

```shell
[Unit]
Description = nginx
After = network.target

[Service]
Type = forking
ExecStart = /root/nginx/nginx/sbin/nginx -c /root/nginx/nginx/conf/nginx_jrebel.conf
ExecReload = /root/nginx/nginx/sbin/nginx -c /root/nginx/nginx/conf/nginx_jrebel.conf -s reload
ExecStop = /root/nginx/nginx/sbin/nginx -c /root/nginx/nginx/conf/nginx_jrebel.conf -s stop
PrivateTmp = true

[Install]
WantedBy = multi-user.target
```

##### 相关命令

```shell
systemctl enable nginx_jrebel
systemctl start nginx_jrebel
systemctl status nginx_jrebel
systemctl stop nginx_jrebel
```

## MySql

### 前置命令

```shell
yum -y install docker
systemctl start docker
systemctl status docker
```

### 安装命令

<font style="color:red;">注意，要改变Root密码</font>

```shell
docker search mysql

docker pull mysql:5.7

docker run  --restart always --name mysql5.7.19 -p 3306:3306 -v /root/mysql/data:/var/lib/mysql -v /root/mysql/conf.d:/etc/mysql/conf.d  -e MYSQL_ROOT_PASSWORD=??>><<??__++ -d mysql:5.7.19

docker exec -i -t  mysql5.7.19 /bin/bash

mysql -uroot -p
```

### 参考文档

[用docker部署mysql服务](https://www.jianshu.com/p/185840de08a8)

## Aria

### AriaNg

#### 附件

[AriaNg文件](https://shengouqiang.cn/nas/aria.zip)

### Aria Pro

#### 前置命令

```shell
yum -y install docker
```

#### 安装命令

```shell
docker run -d --restart unless-stopped --log-opt max-size=1m --network host -e PUID=$UID -e PGID=$GID -v /mnt/disk/aria2-config:/config -v /mnt/disk/aria2-downloads:/downloads  p3terx/aria2-pro
```

#### 参考文档

[Aria2 Pro](https://p3terx.com/archives/docker-aria2-pro.html) 
