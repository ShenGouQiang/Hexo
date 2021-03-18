---
title: TCP之三次握手、四次挥手
permalink: NetWork/NetWorkLearnDay01/
date: 2020-08-24 21:57:41
categories:
- 计算机网络
tags:
- 计算机网络
- https
---

# TCP之三次握手、四次挥手

## 前言

因为对于`TCP`而言，是默认的全双工协议，因此可以是客户端向服务器端发起连接，也可以是服务端向客户端发起连接。在这里，我们以客户端向服务端发起连接请求。

## 大体过程

![TCP协议流程图](https://shengouqiang.cn/img/NetWork/Day01/TCP_01.png)

## 详细介绍

下面，我们分别介绍下一些专有名词：

1. `SYN`：发起一个新的连接
2. `ACK`：代表确认序列号生效
3. `SEQ`：序列号：代表的是从源端到目标端的序列号
4. `ACK`：确认序列号，一般为接收到的`SEQ +1`，并且只有在`ACK`的`Flag`位为`1`的时候生效
5. `FIN`：释放一个连接
6. `MSL`： 最大报文生成时间

### 三次握手流程

1. 当`server`端 开放了某个端口后，此时 会从` CLOSED` 阶段 进入到`LISTEN` 接口
2. 当`client`想要连接`server`的时候，此时会从 发送一个 `SYN` 报文，同时从` CLOSED` 阶段进入到` SYN-SENT`阶段。
3. 当`server`收到了来自`client`的`SYN`后，此时会从 `LISTEN` 阶段 转到 `SYN-RCVD` 接口，同时通知`client`的`ACK`和`SYN`
4. 当`client`接收到`server`的确认和请求连接后，发送`ACK`告知`server`端，同时 `client` 端从` SYN-SENT` 阶段 进入到` ESTABLISHED` 阶段
5. 当`server`收到了`client`的确认后，也从 `SYN-RCVD` 阶段 进入到 `ESTABLISHED` 阶段

#### 为什么要三次握手？

1. 保证服务器资源的防止浪费的情况，如果是两次握手，就会出现当网络阻塞，客户端没有在一定的时间内收到服务端的请求，此时客户端会重新启动一个新的连接，此时客户端又会启动一个新的端口连接对应。此时就会出现服务器端资源浪费的情况
2. 因为有`SEQ`的版本控制问题，当有一个请求包在网络阻塞很久之后，到达`server`端，`server`端可以根据`SEQ`判断当前的包是否是有效的数据包

#### 为什么不是四次握手？

没有必要，因为三次已经能够保证全双工了

### 四次挥手流程

1. 当`client`准备关闭与`server`的连接时，此时会发送一个报文通知`server`端，同时客户端会从 `ESTABLISHED` 状态进入到 `FIN-WAIT-1` 状态，此时客户端处于半关闭状态，已经无法通过`client`向`server`发送数据包，但是允许接收`server`到`client`的数据包。这里要注意一点，这里`client`不能向`server`发送的仅仅是数据包，不代表不能发送确认包。
2. 当`server`端收到了`client`端想要断开连接的请求后，此时`server`会从 `ESTABLISHED` 状态进入到` CLOSE-WAIT `状态。此时客户端也进入了一个半关闭的状态。
3. 当执行完第2步骤后，此时`client`端接收到了`server`的确认，则可以正式的关闭了从`client`端到`server`端的连接。并且进入到 `FIN-WAIT-2` 阶段。
4. 当`server`端经历过 `CLOSE_WAIT` 阶段后，并且做好了与客户端断开连接的准备后，此时`server`端会向`client`发送关闭从`server`端到`client`端的连接的请求，并且自动进入到 `LAST-ACK` 阶段。在这个阶段，`server`端不在向`client`端发送任何数据，但是允许接收从`client`发送过来的确认包。
5. 当`client`端收到了`server`端的主动关闭请求后，此时会从` FIN-WAIT-2`阶段到 `TIME-WAITED` 阶段。并且告知`server`端已收到关闭请求通知。
6. 当`server`端接收到回应后，此时会停止 `CLOSE-WAIT` 阶段，进入 `CLOSED` 阶段。在这个时候，已经正式的确认了从 `server` 到 `client `端的连接的关闭。
7. 当客户端发送了`server`端关闭请求的回应后，等到`2MSL`，自动进入`CLOSED` 阶段，在这个时候，已经正式的确认了从` client `到 `server `端的连接的关闭。

#### 为什么客户端的`TIME_WAIT`需要`2MSL`？

为了保证`server`端能够最大安全的关闭：

1. 如果`client`在`2MSL`时间内，再次收到了来自`server`的`FIN`报文，说明`server`由于各种原因没有接收到`client`发出的`ACK`确认报文。`client`再次向`server`发出`ACK`确认报文，计时器重置，重新开始`2MSL`的计时
2. `client`在`2MSL`内没有再次收到来自`server`的`FIN`报文，说明`server`正常接收了`ACK`确认报文，`client`可以进入`CLOSED`阶段

## SYN攻击

### 原理

1. `client`伪造大量的`虚拟IP`，并向`server`端发送`SYN`包
2. `server`端收到后，发送 `ACK +SYN`包给`虚拟IP`
3. 因为`虚拟IP`不存在，所以不会回应`server`端的 `ACK+SYN`
4. 当`server`端收不到确认后，此时会认为是确认包丢失，此时会不断重发，直到超时

因为这些虚拟的`SYN`包会长期占用未连接队列，就会导致真实的`client`端请求无法加入到队列中，从而被丢弃，最终造成网络拥堵和瘫痪。

在`Linux`系统中，我们可以采用`netstat -nap | grep SYN_RECV`命令进行查看

## 系统存在大量的`TIME_WAIT`:

### 原因

1. 系统中存在非常频繁的 `TCP`连接打开-关闭的进程
2. 网络状态不太好，`server`端总是在`2MSL`的时间内，重新发送 `FIN` 关闭请求，导致 `client`端总是在重置`2MSL`

### 危害

1. 消耗系统的连接数
2. 过多的消耗内存，平均一个 `TIME-WAIT`要占用`4K`大小的内存

### 解决方案

```shell
1.vi /etc/sysctl.conf

#表示开启SYN Cookies。当出现SYN等待队列溢出时，启用cookies来处理，可防范少量SYN攻击，默认为0，表示关闭；
net.ipv4.tcp_syncookies = 1    
#表示开启重用。允许将TIME-WAIT sockets重新用于新的TCP连接，默认为0，表示关闭；
net.ipv4.tcp_tw_reuse = 1       
#表示开启TCP连接中TIME-WAIT sockets的快速回收，默认为0，表示关闭；
net.ipv4.tcp_tw_recycle = 1    
#修改系統默认的 TIMEOUT 时间。
net.ipv4.tcp_fin_timeout        

#表示当keepalive起用的时候，TCP发送keepalive消息的频度。缺省是2小时，改为20分钟。
net.ipv4.tcp_keepalive_time = 1200   
#表示用于向外连接的端口范围。缺省情况下很小：32768到61000，改为10000到65000。（注意：这里不要将最低值设的太低，否则可能会占用掉正常的端口！）
net.ipv4.ip_local_port_range = 10000 65000   
#表示SYN队列的长度，默认为1024，加大队列长度为8192，可以容纳更多等待连接的网络连接数。
net.ipv4.tcp_max_syn_backlog = 8192
#表示系统同时保持TIME_WAIT的最大数量，如果超过这个数字，TIME_WAIT将立刻被清除并打印警告信息。默 认为180000，改为5000。对于Apache、Nginx等服务器，上几行的参数可以很好地减少TIME_WAIT套接字数量，但是对于 Squid，效果却不大。此项参数可以控制TIME_WAIT的最大数量，避免Squid服务器被大量的TIME_WAIT拖死
net.ipv4.tcp_max_tw_buckets = 5000

2./sbin/sysctl -p
```

