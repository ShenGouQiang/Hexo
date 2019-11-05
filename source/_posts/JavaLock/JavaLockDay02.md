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

