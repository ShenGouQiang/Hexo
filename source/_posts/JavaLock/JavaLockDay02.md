---
title: Java--synchronize关键字
permalink: JavaLock/JavaLockDay02
date: 2019-11-05 20:49:00
categories:
- Java
- 锁问题
tags:
- Java学习
- 锁问题
---

# Java--synchronize关键字

&emsp;&emsp;`synchronize`是`JDK`中的一个关键字。是用来实现线程安全的。接下来，我们好好的研究下`synchronize`的魅力。

## 使用场景

1. 修饰实例方法<span style="color:red;"> --- </span>这个锁是作用在当前实例对象上的。当我们要进入到同步代码之前，我们需要当前实例对象获得锁。在执行完代码后，要释放锁。
2. 修饰静态方法<span style="color:red;"> --- </span>这个锁是作用在类对象上的。当我们要执行同步代码的时候，要获取到类对象的锁
3. 修饰代码块<span style="color:red;"> --- </span>指定了锁的对象，默认情况下，我们会使用`this`作为加锁条件。当我们使用`this`的时候，就相当于是第一种情况的当前实例对象。

&emsp;&emsp;注意，这三种情况的获取锁、释放锁都是`JDK`自己完成的。不需要我们手动的完成。

## synchronize关键字原理

&emsp;&emsp;既然我们说了这么多，那么在`JDK`的底层中，对于`synchronize`关键字是怎么处理的呢？在这里，我们在解释这个问题，要先引申出另一个问题<span style="color:red;"> --- </span>什么是`Monitor`？

### Monitor解释

[^_^]:# (https://blog.csdn.net/wojiao228925661/article/details/100145157)

&emsp;&emsp;对于`Monitor`,我们可以把它理解成一个同步工具，也可以理解为一种同步机制，但是更多的，我们将它描述为一个对象。对于`Monitor`，它是线程私有的数据结构，而这个`Monitor`在什么地方呢？其实，`Monitor`在Java的`对象头`中。

&emsp;&emsp;那么`Monitor`到底是什么呢？其实`Monitor`只是一种数组结构，在`Monitor`中，包含了以下的信息：

1. _owner：指向持有ObjectMonitor对象的线程
2. _WaitSet：存放处于wait状态的线程队列
3. _EntryList：存放处于等待锁block状态的线程队列
4. _recursions：锁的重入次数
5. _count：用来记录该线程获取锁的次数

&emsp;&emsp;当多个线程同时访问一段同步代码时，首先会进入`_EntryList`队列中，当某个线程获取到对象的`monitor`后进入`_Owner`区域并把`monitor`中的`_owner`变量设置为当前线程，同时`monitor`中的计数器`_count`加1。即获得对象锁。

&emsp;&emsp;若持有`monitor`的线程调用`wait()`方法，将释放当前持有的`monitor`，`_owner`变量恢复为`null`，`_count`自减1，同时该线程进入`_WaitSet`集合中等待被唤醒。若当前线程执行完毕也将释放`monitor`(锁)并复位变量的值，以便其他线程进入获取`monitor`(锁)。

&emsp;&emsp;而对于`synchronize`而言，我们获取锁的过程，其实就是对象的一个从`Monitor`的`进入`到`走出`的过程。当对象获得锁的时候，此时使用的是`monitorenter`指令，而对象释放锁的时候，此时使用的是`monitorexit`指令。对于`JDK1.5`以及之前的`synchronize`,采用的就是这样的方式，但是这样的方式需要与操作系统进行打交道，因此，我们经常称呼为`重量级`锁。而线程之所以能够知道当前线程需不需要锁，也是通过方法上修饰的`ACC_SYNCHRONIZED`来进行判断的。

### Java的对象头

[^_^]:# (https://juejin.im/post/5c17964df265da6157056588)
[^_^]:# (https://www.jianshu.com/p/3d38cba67f8b)

&emsp;&emsp;那么什么是`Java`的对象头呢？其实，在JVM中，我们的每个对象，都是由`对象头`和`实例数据`两部分组成的。对象头保存了一个对象的元数据信息，而其他的数据，则是存在了`实例对象`中，那么对象头，都是由什么组成的呢？其实，对象头是由`markword`、`类型指针`和`数组长度`(<span style="color:red;">可选，只有对象为数组的时候，才存在这个值</span>)组成的。

#### markword

![markword示意图](http://static.shengouqiang.cn/blog/img/JavaLock/JavaLockDay02/markword.jpg)

&emsp;&emsp;接下来，我们解释一下各个字段的含义

##### biased_lock

&emsp;&emsp;在`JDK1.6`的版本之后，`JDK`的库工程师们对于`synchronize`关键字进行了优化，从之前的`重量级锁`，改成了可以是`无锁`、`偏向锁`、`轻量级锁`和之前就有的`重量级锁`。而这个字段表示的就是当前的锁状态是否是偏向锁，如果是`1`的话，则表示的是当前对象启用了`偏向锁`，而`0`表示的是当前对象并未启用`偏向锁`。在`markword`中，这个字段仅仅占用`1`位。

##### lock

&emsp;&emsp;这个字段表示的是锁的一个状态，由`2`位组成。我们可以将这个状态以一个表格的形式展示出来

|biased_lock|lock|含义|
|:---:|:---:|:---:|
|0|01|无锁|
|1|01|偏向锁|
|0|00|轻量级锁|
|0|10|重量级锁|
|0|11|GC标记|

##### age

&emsp;&emsp;这个字段表示的是`Java`对象的一个年龄。由`4`位组成。在`GC`中，如果对象在`Survivor`中存活一次，则直接age加`1`，当超过了设置的年龄阈值的时候，此时对象会晋升到老年代。默认情况下，并行`GC`的年龄阈值为`15`，并发`GC`的年龄阈值为`6`。由于`age`只有`4`位，所以最大值为`15`，这就是`-XX:MaxTenuringThreshold`选项最大值为`15`的原因。

##### identity_hashcode：

&emsp;&emsp;`25`位的对象标识`Hash`码，采用延迟加载技术。调用方法`System.identityHashCode()`计算，并会将结果写到该对象头中。当对象被锁定时，该值会移动到管程`Monitor`中。

##### thread

&emsp;&emsp;持有偏向锁的线程ID

##### epoch

&emsp;&emsp;偏向时间戳

##### ptr_to_lock_record

&emsp;&emsp;指向栈中锁记录的指针

##### ptr_to_heavyweight_monitor

&emsp;&emsp;指向管程Monitor的指针

#### 类型指针

&emsp;&emsp;这一部分用于存储对象的类型指针，该指针指向它的类元数据，JVM通过这个指针确定对象是哪个类的实例。该指针的位长度为`JVM`的一个字大小，即`32`位的`JVM`为`32`位，`64`位的`JVM`为`64`位。

&emsp;&emsp;如果应用的对象过多，使用`64`位的指针将浪费大量内存。为了节约内存可以使用选项`+UseCompressedOops`开启指针压缩，其中，`oop`即`ordinary object pointer`普通对象指针。开启该选项后，下列指针将压缩至`32`位：

1. 每个Class的属性指针（即静态变量）
2. 每个对象的属性指针（即对象变量）
3. 普通对象数组的每个元素指针

&emsp;&emsp;当然，也不是所有的指针都会压缩，一些特殊类型的指针`JVM`不会优化，比如指向`PermGen`的`Class`对象指针(`JDK8`中指向元空间的`Class`对象指针)、`本地变量`、`堆栈元素`、`入参`、`返回值`和`NULL指针`等。

#### 数组长度

&emsp;&emsp;如果对象是一个数组，那么对象头还需要有额外的空间用于存储数组的长度，这部分数据的长度也随着`JVM`架构的不同而不同：`32`位的`JVM`上，长度为`32`位；`64`位`JVM`则为`64`位。`64`位`JVM`如果开启`+UseCompressedOops`选项，该区域长度也将由`64`位压缩至`32`位。

### synchronize优化

&emsp;&emsp;`jdk1.6`以后对`synchronized`的锁进行了优化，引入了`偏向锁`、`轻量级锁`，锁的级别从低到高逐步升级：`无锁->偏向锁->轻量级锁->重量级锁`。

#### synchronize锁升级过程

&emsp;&emsp;下面，我们可以借用网上的一张图片来进行说明

![synchronize锁升级](http://static.shengouqiang.cn/blog/img/JavaLock/JavaLockDay02/lockUpdate.png)

## 总结

&emsp;&emsp;对于同步方法，`synchronize`可谓是元老级的任务。对于`synchronize`的研究，在日后的学习中，还是很有必要的。对我们的帮助也是很大的。