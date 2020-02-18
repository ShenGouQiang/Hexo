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

&emsp;&emsp;本次我们主要讲解的`HashMap`是在`JDK1.8`版本的。

![Java版本信息](http://static.shengouqiang.cn/blog/img/Java/JDK/DAY01/java-version.jpg)

&emsp;&emsp;接下来，我们在这篇文章主要讲解的是`HashMap`的构造函数。

&emsp;&emsp;在`HashMap`中，`HashMap`一共有四个构造函数，接下来，我们逐一进行讲解。

## 负载因子(loadFactor)

&emsp;&emsp;首先，在讲解无参构造函数之前，我们先来讲解下为什么在JDK的官方源码中，将HashMap的负载因子设置为`0.75`。

&emsp;&emsp;首先，我们知道，在计算机的运行过程中，我们主要注重的是两个问题，一个是希望我们的程序尽可能的运行的快。另一个，我们希望我们程序在运行的过程中，尽可能的少消耗我们的内存。这个就是计算机中评判一个程序经常用到的两个维度，`时间复杂度`和`空间复杂度`。在实际的程序运行过程中，我们不可能同时将这两个标准都优化到极致，因此在很多的程序，对于这两个标准，会根据实际的业务需求，采用以下三种方案进行开发：

- 牺牲程序的时间复杂度，尽可能的降低程序的空间复杂度
- 牺牲程序的空间复杂度，尽可能的降低程序的时间复杂度
- 综合考虑程序的时间复杂度和空间复杂度，在这两者中，选择一个折中平衡点

&emsp;&emsp;而在`JDK`的`HashMap`中，就是采用了第三种方案，经过了无数的证明与总结，人们发现，当负载因子为`0.75`的时候，此时程序的效率最高。因此，在`JDK`的源码中，将`HashMap`的默认负载因子设置成了`0.75`。

&emsp;&emsp;上面我们讲解了这么多，又是`负载因子`，又是`时间复杂度`，又是`空间复杂度`的。那么在`HashMap`中，这些含义到时是干什么用的呢？其实，我们都知道，对于`HashMap`而言，他就是一个集合。那么对于集合，一定要提供两个功能 --> `“读取”`和`“存储”`。 既然要存储和读取，那么我们关心的其实就是两个问题

- 是否足够快
- 是否省内存
  


## 无参构造函数

```java
    /**
     * Constructs an empty <tt>HashMap</tt> with the default initial capacity
     * (16) and the default load factor (0.75).
     */
    public HashMap() {
        this.loadFactor = DEFAULT_LOAD_FACTOR; // all other fields defaulted
    }
```

## 仅设置初始容量的构造函数

```java
    /**
     * Constructs an empty <tt>HashMap</tt> with the specified initial
     * capacity and the default load factor (0.75).
     *
     * @param  initialCapacity the initial capacity.
     * @throws IllegalArgumentException if the initial capacity is negative.
     */
    public HashMap(int initialCapacity) {
        this(initialCapacity, DEFAULT_LOAD_FACTOR);
    }
```

## 设置初始容量和负载因子的构造函数

```java
    /**
     * Constructs an empty <tt>HashMap</tt> with the specified initial
     * capacity and load factor.
     *
     * @param  initialCapacity the initial capacity
     * @param  loadFactor      the load factor
     * @throws IllegalArgumentException if the initial capacity is negative
     *         or the load factor is nonpositive
     */
    public HashMap(int initialCapacity, float loadFactor) {
        if (initialCapacity < 0)
            throw new IllegalArgumentException("Illegal initial capacity: " +
                                               initialCapacity);
        if (initialCapacity > MAXIMUM_CAPACITY)
            initialCapacity = MAXIMUM_CAPACITY;
        if (loadFactor <= 0 || Float.isNaN(loadFactor))
            throw new IllegalArgumentException("Illegal load factor: " +
                                               loadFactor);
        this.loadFactor = loadFactor;
        this.threshold = tableSizeFor(initialCapacity);
    }
```

## 以Map进行初始化的构造函数

```java
    /**
     * Constructs a new <tt>HashMap</tt> with the same mappings as the
     * specified <tt>Map</tt>.  The <tt>HashMap</tt> is created with
     * default load factor (0.75) and an initial capacity sufficient to
     * hold the mappings in the specified <tt>Map</tt>.
     *
     * @param   m the map whose mappings are to be placed in this map
     * @throws  NullPointerException if the specified map is null
     */
    public HashMap(Map<? extends K, ? extends V> m) {
        this.loadFactor = DEFAULT_LOAD_FACTOR;
        putMapEntries(m, false);
    }
```

## 总结