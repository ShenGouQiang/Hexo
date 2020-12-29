---
title: 黑苹果--BCM20702A0型号蓝牙修复
permalink: BlackMac/BCM20702A0BuleToothfix/
date: 2020-06-03 22:27:43
categories:
- 黑苹果
tags:
- 黑苹果
- 蓝牙修复
- 免驱
---

# 黑苹果--BCM20702A0型号蓝牙修复

&emsp;&emsp;在这里，首先要感谢这个网站  [X230 蓝牙BCM20702A0原生驱动，修改个ID就OK！](http://bbs.pcbeta.com/viewthread-1117415-1-1.html)  提供的一个解决思路。对于黑苹果而言，修复蓝牙的方式有很多。无疑，这个网站中的方式仅为其中的一种而已。在这里，我主要想给自己留下一份记录，同时也对于像自己一样的新手，起到一个引导的作用。

&emsp;&emsp;通过上面的文章，我们不难发现，这个文章的修复方式主要是改动`idProduct`即可。在这里，我主要讲解的是如何改动。

&emsp;&emsp;首先，你要确认你的蓝牙的型号是`BCM20702A0`。

## 在Mac系统中进行查看

### 查看usb

&emsp;&emsp;首先，我们要在Mac系统中进行检查，检查路径如下：`->关于本机->概览->系统报告`。点进去后如下图所示:

![系统报告](https://oss.shengouqiang.cn/img/BlackMac/BCM20702A0BuleToothfix/system_report.jpg)

&emsp;&emsp;接下来，点击`硬件->USB`。点击进去如下图所示:

![USB](https://oss.shengouqiang.cn/img/BlackMac/BCM20702A0BuleToothfix/usb_show.jpg)

&emsp;&emsp;我们发现，在系统中，是可以看到有蓝牙设备的存在的。此时我们需要获取到`产品ID`。如下图所示：

![USB-蓝牙模块](https://oss.shengouqiang.cn/img/BlackMac/BCM20702A0BuleToothfix/sub_buletooth_show.jpg)

&emsp;&emsp;在这里，我们的`产品ID`是`0x828d`。注意一下，现在的值是一个`16进制`的，我们真正需要的是一个`10进制`的。因此，我们需要将`0x828d`转换成`10进制`，为`33421`。

&emsp;&emsp;在这里，我们要注意下，我们的蓝牙是在`BRCM20702`下面的。我们要记住这个值，在后面的修改中有用。

### 查看蓝牙

&emsp;&emsp;在查看了`usb`之后，我们查看下`蓝牙`。具体路径如下：`硬件->蓝牙`。如下图所示：

![蓝牙](https://oss.shengouqiang.cn/img/BlackMac/BCM20702A0BuleToothfix/buletooth_show.jpg)

&emsp;&emsp;在这里，是因为我已经修复成功了。在我刚安装，没有修复之前，右侧显示的是`未发现硬件`之类的内容。

## 利用终端进入路径：

&emsp;&emsp;接下来，我们打开`终端.app`。然后执行以下命令：

```shell
cd /System/Library/Extensions/IOBluetoothFamily.kext/Contents/PlugIns/BroadcomBluetoothHostControllerUSBTransport.kext/Contents
open .
```

&emsp;&emsp;然后，系统会自动的弹出一个文件夹，如下图所示：

![访达显示info.plist](https://oss.shengouqiang.cn/img/BlackMac/BCM20702A0BuleToothfix/file_show.jpg)

&emsp;&emsp;对于图中的`info.plist`。我们用系统自带的`文本编辑.app`打开即可。

![info.plist](https://oss.shengouqiang.cn/img/BlackMac/BCM20702A0BuleToothfix/file_context_show.jpg)

## 修改文件

### 查找

&emsp;&emsp;还记得我们之前记下来的`BRCM20702`。我们通过这个进行查找：

![内容查找](https://oss.shengouqiang.cn/img/BlackMac/BCM20702A0BuleToothfix/find_in_file_show.jpg)

&emsp;&emsp;不出意外的话，你只能查到`一个`匹配项。接下来，我们确认了，我们只需要修改红色的框圈出来的地方即可。

![确定范围](https://oss.shengouqiang.cn/img/BlackMac/BCM20702A0BuleToothfix/modify_in_file_show.jpg)

&emsp;&emsp;看见了吗？我们找到了`idProduct`的位置了。接下来，就是将其修改为我们前面计算出来的`10进制`的`33421`即可。我这里是因为修改过，因此图片展示的是已经修改过的了。

## 保存

&emsp;&emsp;当我们修改的时候，此时系统会提示我们`您不是文件“Info.plist”的所有者，因此没有权限写到该文件`。对于这个问题，有两个解决方案：

1. 利用`Kext Wizard`进行修改，对于不懂`Kext Wizard`的，可以自己百度
2. 利用`Sublime Text 3`进行修改，可以正常保存。

## 重启

&emsp;&emsp;当我们都执行完毕以后，我们可以重启电脑，检测`蓝牙`是否已经能够正常使用。

# 总结

&emsp;&emsp;对于黑苹果的折腾，我也仅仅只是一个小白，还在摸索当中。对于后期如果有别的学习内容，会同步到当前博客中。另外，还是那句话------ `黑苹果，且折腾且珍惜`。