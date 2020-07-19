---
title: Redis的RDB与AOF
permalink: Redis/RedisPersistence
date: 2020-06-08 16:47:08
categories:
- 中间件
- Redis
tags:
- Redis
- 持久化
- RDB
- AOF
---

# Redis的RDB与AOF

&emsp; 对于`Redis`而言，它的数据都是存在内存当中的。如果我们想要将数据永久性的存下来，或者下次重启`Server`后，想要以前的数据依然在，那么我们就需要将内存中的数据持久化到硬盘中。而`Redis`对于这样的需求，为我们提供了两套服务，分别是`RDB`与`AOF`。

## 前言

&emsp; 在讲解什么是`RDB`，什么是`AOF`之前，我们要先明白对于任何一个`内存型`的`DB`而言，如果我们想要持久化数据，我们应该怎么做？但是，本节主讲`Redis`。因此在这里，我们依然以`Redis`举例。

&emsp; 假如我们有一个`Redis`，这个`Redis`运行了很久，在内存中产生了很多的数据。此时我们需要将这些内存中的数据持久化到硬盘上，供后续的其他操作使用。在这样的情况下，我们有两个操作：

1.  阻塞掉前端所有的`client`端的操作。然后将这些数据缓缓的写到磁盘当中。只有将全部的数据写入完毕之后，此时再放行`client`端的操作。
2. 通过新启动一个子进程的方式，通过子进程的方式，将内存中的数据缓缓的写入到磁盘当中。`Redis`的工作线程依然处理客户端的请求。

&emsp; 这两种方式各自有各自的特点。接下来，我们开始一一讨论。

## 第一种方式

&emsp; 首先，我们要明确一点，对于整个系统而言，最大的瓶颈是`IO`操作，至于为什么是`IO`操作，详情可以参考[百度](https://www.baidu.com)。那么如果采用的是当前的方式，就会出现如果当前内存的数据量特别大的时候，此时`Redis`将内存中的数据写入硬盘的时间就会特别的长，从而就会造成`Redis`长时间处于一种服务不可用的状态。对于这样的情况，虽然可以保证我们缓存到硬盘的内容是`100%`准确的，但是我想没有几个公司会同意这样的解决方案的。这也是为什么很多公司将`Redis`的`SAVE`命令给禁用的原因。

&emsp; 这里说明下，`Redis`是支持第一种方案的。对应的的命令是`SAVE`。

## 第二种方式

&emsp; 既然第一种方式公司不让用，那么我们来看下第二种方案。对于第二种方案而言，你可能会想，这样的方式虽然保证了服务的可用性，但是如果我在缓存的过程中，如果我将对应的`key`的值给改了，或者将这个`Key`对应的值给删除了，怎么办？这样就会造成数据不一致的问题。如果想要数据一致的话，还是需要`STW`的，事实上真的是这样吗？我们做一个例子：

***

### 进程间资源隔离的例子

&emsp;&emsp;首先，我们新开一个`session`，然后执行`pstree`命令，如图所示：

![父进程的PSTREE](https://oss.shengouqiang.cn/img/Redis/RDB_AOF/Parent_PSTree_01.jpg)

&emsp;&emsp;我们发现，目前我们处在`bash`下，执行的`pstree`命令。此时我们设定一个变量`b`，值为`10`。

![父进程设值](https://oss.shengouqiang.cn/img/Redis/RDB_AOF/Parent_Set_b_01.jpg)

&emsp;&emsp;通过上图所示，我们已经在当前的`session`中，设置了一个变量`b`，值为`10`，并且已经能够成功的取出。

&emsp;&emsp;接下来，我们创建一个子进程，使用`/bin/bash`命令。然后我们再看一下`pstree`。

![子进程的PSTREE](https://oss.shengouqiang.cn/img/Redis/RDB_AOF/Child_PSTree_01.jpg)

&emsp;&emsp;此时我们发现，和之前的`pstree`进行比较，我们目前是在`bash->bash`下执行的`pstree`。此时我们在获取之前创建的变量`b`.

![子进程取值](https://oss.shengouqiang.cn/img/Redis/RDB_AOF/Child_Get_b_01.jpg)

&emsp;&emsp;此时我们发现，我们并没有得到`b`的值，这是为什么呢？

&emsp;&emsp;这是因为在`Linux`系统中，进行之间的资源是相互隔离的。如果我们想要让`b`在两个`session`之前共享，最简单的办法就是使用`export`命令，然后在子进程就能够获取的到了。

***

&emsp;&emsp;`OK`，通过上面的例子，我们知道了线程间的资源隔离问题。那么对应到`Redis`而言，又是怎么做的呢？在这里，我们还需要另外一个知识，`虚拟地址映射。`

&emsp;&emsp;对于`Redis`而言，我们每次存储的一个`key-value`的键值对，都是存在真实的物理内存中的，而这些地址，在`Redis`中存在着一份映射关系。我们通过下面的图，举个栗子，<span style="color:red;" >(这里说明下，下图的内容仅仅只是为了理解，而不是Redis底层的真正实现) </span>。

![工作进程映射关系](https://oss.shengouqiang.cn/img/Redis/RDB_AOF/memory_map_01.jpg)

&emsp;&emsp;此时`Redis`要进行数据持久化的时候，是通过调用系统的`fork`命令来创建一个子进程的。而子进程依然会保留着这份映射关系，并且`fork`的时间特别的快，不会阻塞到`client`端的请求。也就是会变成下图的样子：

![fork子进程](https://oss.shengouqiang.cn/img/Redis/RDB_AOF/memory_map_fork_01.jpg)

&emsp;&emsp;如果我们的`Redis`的工作进程，需要对`k1`进行修改，此时`Redis`会采用`copy-on-write`的方式，也就是说，他不会去改`物理内存`中`1号位置`的值，而是将新的内容写入到`2号位置`，`改变指针`即可。这样对于`子进程`而言，我拿到的依然是`修改前`的值。

![copy-on-write](https://oss.shengouqiang.cn/img/Redis/RDB_AOF/memory_map_fork_02.jpg)

&emsp;&emsp;对于这样的操作方式，`Redis`也为我们提供了指令`BGSAVE`。我们可以通过调用`BGSAVE`，来实现将数据异步的存储到硬盘中。

## 什么是RDB

&emsp;&emsp;通过上面的解释，我们知道了`Redis`是如何将数据存储到硬盘中的。而`RDB`就是采用的上述描述的第二种方式。因此，对于`RDB`而言，我们存储的数据并不是`实时`的。例如我们在8点钟执行了`BGSAVE`，或者系统自动触发。在9点钟的时候，完成了数据的持久化，根据上面的讲解，我们知道对于8点到9点之间的数据变更，并没有存储到`RDB`文件当中，并且`BGSAVE`操作，每次存储数据都是全量存储的。所以这样的存储方式会产生数据遗漏的问题。

### `RDB`的配置

&emsp;&emsp;对于`RDB`的生成，我们可以采用前面介绍的命令`BGSAVE`，或者也可以采用配置文件的方式进行配置，在这里，我主要讲解下配置文件的配置方式：

```
save 900 1
save 300 10
save 60 10000
```

&emsp;&emsp;对于`Redis`而言，默认已经开启了`RDB`持久化，同时，给出的默认设置是：

```
1.如果60s内的写操作大于10000次，则自动开启BGSAVE
2.如果300s内的写操作大于10次，则自动开启BGSAVE
3.如果900s内的写操作大于1次，则自动开启BGSAVE
```

&emsp;&emsp;以上的三个条件，只要满足其中的一个，就会触发`BGSAVE`。

&emsp;&emsp;这里要注意下，在配置文件中，虽然我们是通过`save指令`来指定`RDB`的触发机制，但是在`Redis`中，触发的不是`save指令`，而是`BGSAVE指令`。

&emsp;&emsp;同时，我们可以通过`dbfilename`与`dir`分别指定`RDB`文件的名称和存储的路径。

## 什么是`AOF`

&emsp;&emsp;上面我们介绍了`RDB`的一个执行的原理和过程，但是我们发现一个问题，它并不能实时的持久化最新的数据，基于这个问题，Redis给我们提供了另外一种存储方式`AOF`。

&emsp;&emsp;对于`AOF`而言，他存储的并不是内存中的数据，而是用户的一条条指令。`Redis`会将用户的每一条指令，通过追加到文件的方式，写入到一个日志文件中，这个就是`AOF`。

&emsp;&emsp;在这里，我们要注意下，对于`AOF`，`Redis`默认并没有自动开启，需要我们手动的在`redis.conf`配置文件中开启。开启的命令就是将`appendonly`从`no`改成`yes`。同时可以通过`appendfilename`指定AOF文件的名称。

&emsp;&emsp;在这里，我们要注意下，对于`AOF`的写入存在着以下三个时机：

1. `no`：指的是当每次内核中的`缓冲buffer`满了以后，会自动的往`AOF文件`中`flush`一次。
   - 优点：降低了`IO`的频率
   - 缺点：容易丢失一个`buffer`的数据
2. `always`：指的是当每次发生一次写操作，都会立即往`AOF`文件中`flush`一次。
   - 优点：最大可能的保证了数据的准确性
   - 确定：提高了`IO`的频率
3. `everysec`：每秒中调用一次`flush`，是上面两个方案的折中。

&emsp;&emsp;在`Redis`的配置文件中，默认采用的是`第3种`方案，可以通过修改`redis.conf`中的`appendfsync`对应的`value`来起到改变策略的目的。

&emsp;&emsp;同样的，对于`AOF`的操作，我们也可以采用`BGREWRITEAOF`命令来手动的发起。

### AOF策略的优化

#### Redis 4.0之前的版本

&emsp;&emsp;在`Redis4.0`之前的版本中，`Redis`对于`AOF`的操作的优化主要是在`rewrite`中进行的。

&emsp;&emsp;在这里我们举个栗子：假如我们有一个新的`Redis`实例，里面的数据为空，此时我们有个程序，不停的对同一个`key`进行`incr`。在执行完`100W`次以后，此时我们的`AOF`文件会变得很大。因为`AOF`文件，相当于要记录下`100W`操作的每次的完整的命令。在这里，我们以`k1`为`key`做演示，仅`INCR`一次，我们看下`AOF`的文件内容：

![Redis-INCR](https://oss.shengouqiang.cn/img/Redis/RDB_AOF/Redis_INCR_01.jpg)

&emsp;&emsp;此时我们通过客户端，执行` set incr get` 命令后，通过配置文件，找到对应的`AOF`文件，然后打开(我已将`appendfsync`改成了`always`,方便看到效果 )：

```
*2
$6
SELECT
$1
0
*3
$3
set
$2
k1
$1
1
*2
$4
incr
$2
k1
```

&emsp;&emsp;此时我们发现，AOF的文件内容居然是这样的。接下来，我们解读下当前命令：

1. `*2`:代表的是接下来，我要读取两个值，分别是`SELECT`和`0`。代表我们读取第0号数据库。
2. `$6`、`$1`代表的是指令的长度，并不在`*2`的读取范围内。
3. 接下来，所有的命令依次类推即可。

&emsp;&emsp;上面的内容还仅仅只是`incr`依次的结果，如果我们`incr`多次呢？这个`AOF`的文件会变得特别的大，将来`Server`启动，`load`数据的时候，会变得的慢。试下一下，如果我执行了`100W`次的`incr k1`,其实下次程序启动，直接设置` set k1 = 10100000 `即可。

&emsp;&emsp;对了，在这里要说明下，在程序启动的时候，如果没有开启`AOF`,此时程序会以`RDB`的文件内容为准，如果开启了`AOF`,则会以`AOF`文件中的内容为准。

&emsp;&emsp;基于上面的原因， `Redis`在文件达到指定大小和指定增加百分比的时候，对`AOF文件`会进行`rewrite`操作。其中可以通过`Redis.conf`的`auto-aof-rewrite-min-size`来指定重写文件的最小值，`auto-aof-rewrite-percentage`来指定当文件达到多大的百分比时进行`rewrite`。在`Redis`中，设置的默认大小分别为`64MB`和`100`。

&emsp;&emsp;`rewrite`操作，会对文件中的命令进行整合，从而起到消除文件大小的作用，但是一旦Redis发生了rewrite操作之后，此时仅仅保留的就是最终的信息，对于数据的一个变迁的过程，无法再看见了。同时，对于文件的整合，是非常消耗`CPU`性能的。

&emsp;&emsp;接着上面的命令，我们执行下`BGREWRITEAOF`指令，再来看下`AOF`文件的内容：

```
*2
$6
SELECT
$1
0
*3
$3
SET
$2
k1
$1
2
```

&emsp;&emsp;此时我们发现，在`AOF`文件中，已经将`k1`直接设置成了`2`。删去了`k1`的数据变迁过程。

#### Redis 4.0及之后的版本

&emsp;&emsp;在`Redis 4.0`之前的版本，对于`RDB`和`AOF`可以同时开启，但是`Redis`在启动的时候，仅仅只会使用其中的一个。但是在`Redis4.0`之后的版本中，可以通过`redis.conf`中的`aof-use-rdb-preamble`来指定是否将`RDB`与`AOF`混合起来一起使用。在`Redis4.0`之后的版本中，`Redis`已经默认开启了混合使用的策略。

&emsp;&emsp;那么什么是混合使用呢？混合使用其实就是在`rewrite`的时候，对于`rewrite`之前的数据，采用`RDB`的方式存到文件中，便于后续程序在启动的过程中能够快读的`laod`数据，而对于`rewrite`期间，`redis`产生的写操作，则通过`AOF`的方式，追加到文件的末尾。大大的提高了程序的效率。

&emsp;&emsp;接下来，还是上面的例子，我们将`redis`清空，删除所有的持久化文件，将`aof-use-rdb-preamble`改成yes。再执行上线的操作，查看`AOF`文件：

```
set k1 1
incr k1
get k1
BGREWRITEAOF
set k2 10
get k2
```

![工作进程映射关系](https://oss.shengouqiang.cn/img/Redis/RDB_AOF/AOF_RDB_ALL_USE.jpg)

&emsp;&emsp;我们发现，文件的开头已经是一堆乱码了。但是在程序只有，依然是我们的`set k2 10`这个命令。同时我们发现，在`AOF`的文件的开头，是`REDIS`。这个算是`RDB`文件开头的一个标识。代表的是`RDB`文件的内容。

## 总结

&emsp;&emsp;在这篇文件中，我们学习了`Redis`的`RDB`与`AOF`的存储原理和存储过程。同时对于配置文件中的配置，也起到了说明的作用。供自己以后的参看。