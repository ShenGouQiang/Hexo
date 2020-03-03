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

&emsp;&emsp;首先，在讲解无参构造函数之前，我们先来讲解下为什么在`JDK`的官方源码中，将`HashMap`的负载因子设置`0.75`。

&emsp;&emsp;首先，我们知道，在计算机的运行过程中，我们主要注重的是两个问题，一个是希望我们的程序尽可能的运行的快。另一个，我们希望我们程序在运行的过程中，尽可能的少消耗我们的内存。这个就是计算机中评判一个程序经常用到的两个维度，`时间复杂度`和`空间复杂度`。在实际的程序运行过程中，我们不可能同时将这两个标准都优化到极致，因此在很多的程序，对于这两个标准，会根据实际的业务需求，采用以下三种方案进行开发：

- 牺牲程序的时间复杂度，尽可能的降低程序的空间复杂度
- 牺牲程序的空间复杂度，尽可能的降低程序的时间复杂度
- 综合考虑程序的时间复杂度和空间复杂度，在这两者中，选择一个折中平衡点

&emsp;&emsp;而在`JDK`的`HashMap`中，就是采用了第三种方案，经过了无数的证明与总结，人们发现，当负载因子为`0.75`的时候，此时程序的效率最高。因此，在`JDK`的源码中，将`HashMap`的默认负载因子设置成了`0.75`。

&emsp;&emsp;上面我们讲解了这么多，又是`负载因子`，又是`时间复杂度`，又是`空间复杂度`的。那么在`HashMap`中，这些含义到时是干什么用的呢？其实，我们都知道，对于`HashMap`而言，他就是一个集合。那么对于集合，一定要提供两个功能 --> `“读取”`和`“存储”`。 既然要存储和读取，那么我们关心的其实就是两个问题:

- 是否足够快
- 是否省内存
  

对于`JDK`而言，它肯定不能再不能仅仅只是偏向于某一侧，而是在这两者见找到一个平衡。因此，在大量的实与统计后，`JDK`的工程师们给出的答复是`0.75`时，此时是一个最佳的平衡点。所以，在`JDK`中，`HashMap`的默认负载因子是`0.75`。

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

&emsp;&emsp;对于无参的构造函数而言，我们发现，它仅仅只是将负载因子(`loadFactor`)设置成了默认值，并没有进行默认的`table`的一个初始化的过程。

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

&emsp;&emsp; 在这里，调用了另一个构造函数，这个构造函数是接下来我们要静姐的构造函数，在这里，我们不再重复进行讲解，看接下来的源码即可。

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

&emsp;&emsp; 在这个构造函数中，我们需要两个请求参数`initialCapacity`、`loadFactor`。接下来，我们观察下程序是如果做的。

&emsp;&emsp; 首先，对于初始容量`initialCapacity`进行了参数上的校验，要求`initialCapacity`必须大于`0`，且如果超出了数组`table`长度的最大值`MAXIMUM_CAPACITY(2^30)`，则将数组的大小设置为`2^30`次方。

&emsp;&emsp;到这里，可能有人会问，为什么`HashMap`的数组table的默认值只能是`2^30`次方呢？这是因为，我们首先看下`MAXIMUM_CAPACITY`在`HashMap`中的定义。

```java
static final int MAXIMUM_CAPACITY = 1 << 30;
```

&emsp;&emsp;通过上面的代码，我们发现，`MAXIMUM_CAPACITY`的数据类型是`int`类型，而`int`类型是`4`个字节，那么正常应该是`4*8-1=31`位吗？为什么在`HashMap`中变成`30`位呢？这是因为最左边的一位代表的是符号位，所以，是`2`的`30`次方。

&emsp;&emsp;还有，有的人可能会继续提问，那么为什么要使用`int`类型呢？如果使用`long`类型不是可以让数组的长度更大吗？是的，在程序的角度上来看，的确使用`long`类型，可以让数组更大，但是这样的话，效率可能会降低。因此JDK对于`MAXIMUM_CAPACITY`的类型上，采用了折中处理，采用`int`类型。而不是其他的`byte`、`long`类型等。

&emsp;&emsp;接下来，是对于负载因子`loadFactor`进行赋值的过程，这里要注明一下，就是负载因子在没有特殊的情况下，我们保持默认的`0.75`即可。不需要特意的进行改动。

&emsp;&emsp;接下来，就到了程序的最后一步，调用`tableSizeFor`方法。

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