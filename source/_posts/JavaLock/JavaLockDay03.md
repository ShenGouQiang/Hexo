---
title: Java--ReentrantLock
permalink: JavaLock/JavaLockDay03
date: 2019-11-08 21:07:14
categories:
- Java
- Lock
tags:
- 锁问题
- Java学习
---

# Java--ReentrantLock

&emsp;&emsp;在`JDK`的代码中，我们用于实现`同步方法`的常用的来说，有三种

1. `synchronize`
2. `ReentrantLock`
3. `countDownLatch`

&emsp;&emsp;其中，我们已经在上一篇文章中讲解了<a href="/JavaLock/JavaLockDay02/">synchronize</a>，现在，我们讲解下`ReentrantLock`。

