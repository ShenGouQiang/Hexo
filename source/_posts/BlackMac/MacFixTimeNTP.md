---
title: MacOS--修改NTP
permalink: BlackMac/MacFixTimeNTP/
date: 2020-06-06 15:34:34
categories:
- 黑苹果
tags:
- 黑苹果
- NTP
- 时间同步
---

# MacOS--修改NTP

对于`MacOS`而言，有的时候，我们需要修改`NTP`的`server`,最好是将`NTP`的`server`改成国内的地址，具体原因，你懂的。

接下来，我们讲解下如何修改：

1. 对于`MacOS`而言，我们如果想要修改`NTP`的`server`，在`->系统偏好设置->日期与时间`内，我们仅仅只能查看，但是不能够修改，如果想要修改，系统通过终端，以命令行的方式进行修改。具体路径如下：
   - `/etc/ntp.conf`
   - `/private/etc/ntp.conf`
2. 通过终端，我们修改上面两个内容中的一个即可。
3. 首先我们看下，原来的`server`是`time.asia.apple.com`。对于这个地址，我不是特别的喜欢，因此我改成了以下的国内地址
   - `ntp1.aliyun.com`
   - `ntp2.aliyun.com`
   - `ntp3.aliyun.com`
   - `ntp4.aliyun.com`
   - `ntp5.aliyun.com`
   - `ntp6.aliyun.com`
   - `ntp7.aliyun.com`
4. 在这里，我打算用第一个`ntp1.aliyun.com`。
5. 接下来是修改环节
   1. 打开`终端.app`
   2. 输入`sudo vim /etc/ntp.conf`
   3. 系统提示，输入密码，此时我们输入对应登录账号的登录密码，注意，在这里，无论我们写了多少个，在界面都不会显示的。
   4. 如果没有意外，此时只有一行内容`server time.asia.apple.com`。此时我们将`time.asia.apple.com` 改成 `ntp1.aliyun.com`。
   5. 修改完成之后，首先按一下`Esc`键，然后输入`:wq`，最后点击回车`Enter`键。
6. 到这里，我们已经将`NTP`的`server`修改完毕，此时我们需要`重启`我们的系统。
7. 重启系统后，我们打开`->系统偏好设置->日期与时间`，此时我们发现，我们的`server`已经改成了`ntp1.aliyun.com`。

![NTP_Server](https://shengouqiang.cn/img/BlackMac/MacFixTimeNTP/NTP_Server.jpg)

# 总结

其实，对于`MacOS`的`NTP`的设置，与`Linux`的设置十分的类似，会了这个，对于`Linux`系统的`NTP`的修改，也是通用的。