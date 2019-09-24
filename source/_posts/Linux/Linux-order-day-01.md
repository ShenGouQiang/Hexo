---
title: 每天一个Linux命令--ls
permalink: Linux/Linux-order-day-01
date: 2019-09-23 13:31:03
categories:
- Linux
tags:
- 每天一个Linux命令
- 命令
- Linux
---

# 每天一个Linux命令--ls

&emsp;&emsp;在这里，我们不介绍一些花里胡哨的命令，介绍的是我们经常使用的命令。如果里面的命令不在我们的日常的使用当中，可以给我留言，我会第一时间补充进去的。

## ls的语法格式

```shell
ls [OPTION]... [FILE]...
```

## ls基本命令介绍

&emsp;&emsp;在我们执行ls命令的过程中，我们通常是采用`ls`，然后直接敲击回车，此时代表的是罗列出当前目录下的文件、文件夹等内容，其实，我们可以指定目录，让`ls`仅仅只是展示我们想要目录的内容，而不一定是当前目录的内容。假如，我们现在再`"/shen/A"`目录下，如果我们想要看`"/shen/B"`目录下，此时我们可以直接使用`ls /shen/B`进行查看`"/shen/B"`目录下的内容，也可以先用`cd`命令，切换到`"/shen/B"`目录下，然后执行`ls`命令即可。

&emsp;&emsp;同样的，如果一个文件夹下有很多的文件，此时我们想要查找其中的某一个文件在当前文件夹中是否存在，此时我们可以采用`ls 文件名`的方式进行查看，如果返回的是有值，则代表当前文件夹中含有这个文件，如果`ls`返回的是`No such file or directory`，则代表这个目录中，没有你想要的文件。

## ls参数介绍
### -a 

&emsp;&emsp;`-a`命令是Linux最基本的命令之一，他的主要作用是展示命令目录下，所有的文件。注意，这里所有的文件指的是

1. 当前目录，以`.`表示
2. 上一层目录，以`..`表示
3. 当前目录下的文件、文件夹、链接等
4. 当前目录下隐藏的文件、文件夹、链接等


&emsp;&emsp;举例：

``` shell
ls -a
```

&emsp;&emsp;此时的执行结果如下：

![ls -a 命令](/blog/img/Linux/Command/Day01/ls-a-down.jpg)

&emsp;&emsp;此时，我们可以发现，在当前目录中，我们已经把上面包含的内容全部显示的出来。

### -A

&emsp;&emsp;这个参数和`-a`的区别是不显示当前目录`.`和上一层目录`..`。

&emsp;&emsp;举例：

``` shell
ls -A
```

&emsp;&emsp;此时的执行结果如下：

![ls -A 命令](/blog/img/Linux/Command/Day01/ls-a-up.jpg)

### -l 

&emsp;&emsp;首先`-l`命令是以列表的形式打印出来的，一个文件占用一行。另外，除了能够查看文件的名称之外，还可以查看其它的内容。这个命令我们会着重的介绍一下的。因为真的很关键。差不过通过这个命令，我们可以查看到这个文件的大部分基本属性了。

&emsp;&emsp;举例：

```shell
ls -l
```

&emsp;&emsp;此时的执行结果如下：

![ls -l 命令](/blog/img/Linux/Command/Day01/ls-l-down.jpg)

&emsp;&emsp;好，从这里开始，我们介绍下：

&emsp;&emsp;我们可以看见，对于每个文件而言，它都存在着9列，并且列与列之间采用<b><span style="color:red;">空格</span></b>的形式进行分割的。那么接下来，我们要讲解下每一个列的含义

#### 第一列(<span style="color:red;">drwxrwxr-x</span>)

&emsp;&emsp;其中，我们以<span style="color:red;">drwxrwxr-x</span>举例，我们发现，这个值是以`d`开头的。那么这个`d`是什么含义呢？其实，这个`d`指的是目录文件的含义。另外，我们把开头的这一个字母叫做------`文件类型`。除了`d`,还有其他字符：

1. `-`  普通文件
2. `d`  目录文件
3. `p`  管理文件
4. `l`  链接文件
5. `b`  块设备文件
6. `c`  字符设备文件
7. `s`  套接字文件

&emsp;&emsp;OK,接下来我们看第2~4个字符，是`rwx`。其实这个指的是文件的一个权限。其中：

1. `r`  读权限
2. `w`  写权限
3. `x`  可执行权限
4. `-`  无权限

&emsp;&emsp;而我们发现，在这个值中，除了第一个字符，其他的值可以每三个值分成一组。分别问：`rwx`、`rwx`、`r-x`。那么为什么Linux要分成三个这样的值呢？是因为在Linux中大致的可以把用户分成三类：

1. 自己
2. 自己所在的组内的其他成员(<span style="color:red;">此时不包括自己</span>)
3. 其他组的成员(<span style="color:red;">此时不包括自己所在的组</span>)

&emsp;&emsp;那么这个值的第2\~4位指的就是自己所拥有的权限，我们可以看到，我们的权限是`rwx`，那么此时我们对于这个文件存在可读、可写、可执行的权限。

&emsp;&emsp;而这个值的第5\~7位指的是组内其他成员所拥有的权限，我们可以看到，此时的权限是`rwx`，那么我们组内的其他人对于这个文件，也同样存在着可读、可写、可执行的权限。

&emsp;&emsp;而这个值的第8\~10位指的是其他组所拥有的权限，此时我们发现，现在的权限是`r-x`。也就是说，其他组的人对于这个文件只有读取和执行的权限，没有写入的权限。

#### 第二列(<span style="color:red;">2</span>)

&emsp;&emsp;这一列比较特殊，我们发现，这一列仅仅只是一个数字`2`，没有其他任何的解释。其实，其实，这一列的话，主要是要分为文件夹和文件来进行讲解。在讲解之前，我们先来了解下Linux系统中<a href="/blog/Linux/Linux-order-day-02/">链接概念</a>。

&emsp;&emsp;通过上面的文章，我们已经很清楚了。

1. 如果当前表示的是一个文件的话，那么此时，这个值标识的是文件的硬链接数。
2. 如果表示的是一个目录的话，那么此时表示的是当前目录中子文件夹的个数。
    - 这个仅仅只是统计的是子文件夹的个数，不包括文件的个数
    - 默认情况下是2，因为就算你一个子文件夹都没有，那么他还是会默认存在两个子文件夹的。当前目录`.`和上一层目录`..`

#### 第三列(<span style="color:red;">shen</span>)

&emsp;&emsp;这一列很简单，标识的文件的拥有者，也就是这个文件是哪个账户创建的。

#### 第四列(<span style="color:red;">shen</span>)

&emsp;&emsp;这一列很简单，标识的文件的拥有者所在的组的名字。

#### 第五列(<span style="color:red;">4096</span>)

&emsp;&emsp;在这里，也是要进行区分的。如果是一个文件，标识的是文件的大小。而如果是一个文件夹的话，表示的是文件夹的大小。注意，而不是文件夹以及它下面的文件的总大小。之所以这样，是因为在Linux中，其实把文件夹当做了一个特殊的文件而已。

#### 第六、七、八列(<span style="color:red;">May 24 19:37 </span>)

&emsp;&emsp;这里表示的是文件夹或者是文件的最后的修改时间。

&emsp;&emsp;这里要注意一下，如果当前指的是文件，那么很好说，就是修改文件的时间。

&emsp;&emsp;如果这里指的是文件夹，那么如果我们单纯的修改文件夹下已有文件的内容的时候，Linux是不会更新文件夹的最后修改时间的。只有当我们在文件夹添加/删除-文件夹/文件的时候，此时Linux才会去更新文件夹的最后更新时间。

#### 第九列(<span style="color:red;">bin</span>)

&emsp;&emsp;这里表示的是文件或文件夹的名字。

#### 特殊行(<span style="color:red;">total 32</span>)

&emsp;&emsp;我们会发现，当我们执行命令的时候，在命令结果的第一行，有个`total 32`这个内容。那么这个内容到底是什么呢？

&emsp;&emsp;其实，这个内容是当前这个文件夹中所占用的文件块的总大小。

&emsp;&emsp;首先，我们通过命令`getconf PAGESIZE`可以查看到我的系统中，一块的大小是4096。因此，我们认为a.txt占用了3块，而后面的每个文件夹，占用了1块。因此一共占用了9块。而每块的大小是4K。因此一共占用了36K。也就是上面展示的36。

&emsp;&emsp;另外，如果在当前目录中我们存在`软链接(符号链接)`。那么，是不计入到计算当中的。因为符号连接的`st_size`表示的是符号链接所指地址的长度。

### -i

&emsp;&emsp;显示文件和目录的inode编号

&emsp;&emsp;举例：

``` shell
ls -i
```

&emsp;&emsp;此时的执行结果如下：

![ls -i 命令](/blog/img/Linux/Command/Day01/ls-i-down.jpg)

### -m
&emsp;&emsp;用","号区隔每个文件和目录的名称

&emsp;&emsp;举例：

``` shell
ls -m
```

&emsp;&emsp;此时的执行结果如下：

![ls -m 命令](/blog/img/Linux/Command/Day01/ls-m-down.jpg)

### -h
&emsp;&emsp;显示文件大小(人类可读的显示方法),在这里，我们通常配合`-l`命令一起显示。

&emsp;&emsp;举例：

``` shell
ls -lh
```

&emsp;&emsp;此时的执行结果如下：

![ls -lh 命令](/blog/img/Linux/Command/Day01/ls-lh-down.jpg)

### -r 

&emsp;&emsp;此时进行逆向排序，这个命令一般与`-h`、`-t`、`-S`配合使用。

### -t

&emsp;&emsp;按照时间进行排序,在这里，我们通常配合`-l`命令一起显示。

&emsp;&emsp;举例：

``` shell
ls -lt
```

&emsp;&emsp;此时的执行结果如下：

![ls -lt 命令](/blog/img/Linux/Command/Day01/ls-lt-down.jpg)

&emsp;&emsp;此时默认是进行了时间的倒叙排列，如果我们想要按照时间的正序排列，可以使用上面的`-r`命令。

&emsp;&emsp;举例：

``` shell
ls -ltr
```

&emsp;&emsp;此时的执行结果如下：

![ls -ltr 命令](/blog/img/Linux/Command/Day01/ls-ltr-down.jpg)

### -S

&emsp;&emsp;按照文件的大小进行排序,在这里，我们通常配合`-l`命令一起显示。

&emsp;&emsp;举例：

``` shell
ls -lS
```

&emsp;&emsp;此时的执行结果如下：

![ls -lS 命令](/blog/img/Linux/Command/Day01/ls-lS-up.jpg)

&emsp;&emsp;此时默认是进行了文件大小的倒叙排列，如果我们想要按照文件大小的正序排列，可以使用上面的`-r`命令。

&emsp;&emsp;举例：

``` shell
ls -lSr
```

&emsp;&emsp;此时的执行结果如下：

![ls -lSr 命令](/blog/img/Linux/Command/Day01/ls-lSr-up.jpg)

### --color

&emsp;&emsp;以指定颜色显示

&emsp;&emsp;举例：

``` shell
ls --color="red"
```

&emsp;&emsp;此时的执行结果如下：

![ls --color 命令](/blog/img/Linux/Command/Day01/ls--color.jpg)

&emsp;&emsp;此时常用的参数有：

1. always
2. yes
3. force
4. no
5. never
6. none
7. auto
8. tty
9. if-tty

### -u

&emsp;&emsp;以文件上次被访问的时间排序

&emsp;&emsp;举例：

``` shell
ls -lu
```

&emsp;&emsp;此时的执行结果如下：

![ls -lu 命令](/blog/img/Linux/Command/Day01/ls-lu-down.jpg)

### -o

&emsp;&emsp;与`-l`命令一致，只不过不展示组信息

&emsp;&emsp;举例：

``` shell
ls -o
```

&emsp;&emsp;此时的执行结果如下：

![ls -o 命令](/blog/img/Linux/Command/Day01/ls-o-down.jpg)

### -R 

&emsp;&emsp;以递归的方式列出所有的目录和所有目录下的所有的文件

&emsp;&emsp;举例：

``` shell
ls -lR
```

&emsp;&emsp;此时的执行结果如下：

![ls -lR 命令](/blog/img/Linux/Command/Day01/ls-lR-up.jpg)

### -Q

&emsp;&emsp;把输出的文件名用双引号括起来

&emsp;&emsp;举例：

``` shell
ls -Q
```

&emsp;&emsp;此时的执行结果如下：

![ls -Q 命令](/blog/img/Linux/Command/Day01/ls-Q-up.jpg)

### -pf 

&emsp;&emsp;每个文件后附上一个字符说明该文件的类型。

1. “*”代表可执行的普通文件
2. “/”表示目录
3. “@”表示符号链接
4. “|”表示FIFO
5. “=”表示套接字

&emsp;&emsp;举例：

``` shell
ls -pF
```

&emsp;&emsp;此时的执行结果如下：

![ls -pF 命令](/blog/img/Linux/Command/Day01/ls-pF-up.jpg)

