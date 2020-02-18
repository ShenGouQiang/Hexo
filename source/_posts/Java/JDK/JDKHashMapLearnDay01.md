---
title: Java学习--HashMap详解(构造函数)
permalink: Java/JDK/JDKHashMapLearnDay01
date: 2020-02-18 15:52:55
categories:
- Java
- 集合
tags:
- Java
- 集合
- Map
---

# Java学习--HashMap详解(构造函数)

&emsp;&emsp;在`JDK`的使用过程当中，我们经常要用到的莫过于集合类型了。而在集合类型当中，我们更加注重的是`Map`这个集合。因此，在接下来的一段时间内，我主要讲解Map中的经典实现(`HashMap`)的源码分析、出现并发的情况、以及与`ConcurrentHashMap`的区别。因为本文章不知道读的人的水平如何，因此，我尽量采用通俗易懂+图文结合的方式，来讲解`HashMap`的源码，在这个系列的最后，我们我们会列出来关于不同的`JDK`的版本对于`HashMap`的一个改动。

&emsp;&emsp;本次我们主要讲解的HashMap是在JDK1.8版本中

