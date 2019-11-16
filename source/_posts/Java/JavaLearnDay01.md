---
title: JDK学习--ThreadLocal
permalink: Java/JavaLearnDay01
date: 2019-11-14 22:40:24
categories:
- Java
- 锁问题
tags:
- Java学习
- 锁问题
---

# JDK学习--ThreadLocal

&emsp;&emsp;对于`ThreadLocal`而言，我想做过后台Java开发的都不会太陌生。对于线程间的隔离，最简单的方法就是采用`ThreadLocal`的模式。那么，什么是`ThreadLocal`呢？官网给出的答案是：

> &emsp;&emsp;ThreadLocal类提供了线程局部 (thread-local) 变量。这些变量与普通变量不同，每个线程都可以通过其 get 或 set方法来访问自己的独立初始化的变量副本。ThreadLocal 实例通常是类中的 private static 字段，它们希望将状态与某一个线程（例如，用户 ID 或事务 ID）相关联。

&emsp;&emsp;说白了，`ThreadLocal`就是为我们的每个线程提供了一个变量。并且这个变量仅仅只能当前线程访问，保证了线程间变量的隔离性，防止出现并发的一种解决方案。

&emsp;&emsp;那么接下来，我们来研究一下，为什么`ThreadLocal`可以做到线程间隔离，并且，他的内部优势如何实现的呢？

## 原理



## 初始化方法

