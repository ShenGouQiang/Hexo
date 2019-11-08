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

&emsp;&emsp;对于`Monitor`,我们可以把它理解成一个同步工具，也可以理解为一种同步机制，但是更多的，我们将它描述为一个对象。对于`Monitor`，它是线程私有的数据结构，而这个`Monitor`在什么地方呢？其实，`Monitor`在Java的`对象头`中。

### Java的`对象头`

&emsp;&emsp;那么什么是`Java`的对象头呢？其实，在JVM中，我们的每个对象，都是由`对象头`和`实例数据`两部分组成的。对象头保存了一个对象的元数据信息，而其他的数据，则是存在了`实例对象`中，那么对象头，都是由什么组成的呢？其实，对象头是由`markword`、`类型指针`和`数组长度`(<span style="color:red;">可选，只有对象为数组的时候，才存在这个值</span>)组成的。
