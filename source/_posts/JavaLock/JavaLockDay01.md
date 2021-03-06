---
title: Java常见的锁问题汇总(持续更新中)
permalink: JavaLock/JavaLockDay01/
date: 2019-11-05 18:01:36
categories:
- Java
- 锁问题
tags:
- Java学习
- 锁问题
---

# Java常见的锁问题汇总

&emsp;&emsp;说到锁，这个话题就比较长了。在最开始程序是单线程执行的时候，此时根本用不到锁。因为锁的目的是为了防止程序的并发执行。后来，在Java中出现了多线程、线程池的概念，为了保证`临界资源`的正常访问，我们推出了锁的概念，用的最多的就是`synchronize`和`Lock`。但是随着互联网的兴起，和请求业务量的增加，此时往往一台`Server`已经很难满足我们的业务需求，因此出现了`分布式`的概念，而上面说的两种锁，仅仅在单`Server`上生效，无法保证在分布式的系统中的数据一致性，因此，我们又提出了`分布式锁`。

&emsp;&emsp;接下来，我们讲解下，每种锁的应用和不同。

## Java中一共有哪些锁

1. 公平锁/非公平锁
2. 可重入锁
3. 独享锁/共享锁
4. 互斥锁/读写锁
5. 乐观锁/悲观锁
6. 分段锁
7. 偏向锁/轻量级锁/重量级锁
8. 自旋锁

&emsp;&emsp;注意，这里面提到的这么多锁的名字，并不代表在JDK中都是一一对应存在的。这些都是按照锁的特性，来进行划分的。

## 前提

&emsp;&emsp;在讲解这些锁之前，我们先说一下<a href="/JavaLock/JavaLockDay02/">synchronize</a>和<a href="/JavaLock/JavaLockDay03/">ReentrantLock</a>。

### 公平锁/非公平锁

&emsp;&emsp;对于JDK自身提供的锁内容，`synchronize`关键字只能是非公平锁。而`ReentrantLock`既可以是公平锁、也可以是非公平锁。

