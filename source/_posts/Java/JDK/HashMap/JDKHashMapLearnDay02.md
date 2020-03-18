---
title: Java学习--HashMap详解(put操作)
permalink: Java/JDK/HashMap/JDKHashMapLearnDay02
date: 2020-03-18 11:48:18
categories:
- Java
- 集合
tags:
- Java
- 集合
- Map
---

# Java学习--HashMap详解(put操作)



&emsp;&emsp;在上一篇文章中，我们讲解了关于`HashMap`的构造函数，如有不了解的，可以查看[Java学习--HashMap详解(构造函数)](/Java/JDK/HashMap/JDKHashMapLearnDay02)。在本节内容中，我们主要讲解下关于`HashMap`的`put`操作。

&emsp;&emsp;首先我们先看下源码：

## put操作源码

```java
    /**
     * Associates the specified value with the specified key in this map.
     * If the map previously contained a mapping for the key, the old
     * value is replaced.
     *
     * @param key key with which the specified value is to be associated
     * @param value value to be associated with the specified key
     * @return the previous value associated with <tt>key</tt>, or
     *         <tt>null</tt> if there was no mapping for <tt>key</tt>.
     *         (A <tt>null</tt> return can also indicate that the map
     *         previously associated <tt>null</tt> with <tt>key</tt>.)
     */
    public V put(K key, V value) {
        return putVal(hash(key), key, value, false, true);
    }
```

&emsp;&emsp;通过上面的代码，我们发现其实没有什么好看的。主要是要看它调用的`putVal`方法和`hash`方法。关于注释，我们都能看懂，如果看不懂的，请直接进行[谷歌翻译](https://translate.google.com/)。

&emsp;&emsp;首先，我们先来看下`hash`方法

## hash方法

```java
    /**
     * Computes key.hashCode() and spreads (XORs) higher bits of hash
     * to lower.  Because the table uses power-of-two masking, sets of
     * hashes that vary only in bits above the current mask will
     * always collide. (Among known examples are sets of Float keys
     * holding consecutive whole numbers in small tables.)  So we
     * apply a transform that spreads the impact of higher bits
     * downward. There is a tradeoff between speed, utility, and
     * quality of bit-spreading. Because many common sets of hashes
     * are already reasonably distributed (so don't benefit from
     * spreading), and because we use trees to handle large sets of
     * collisions in bins, we just XOR some shifted bits in the
     * cheapest possible way to reduce systematic lossage, as well as
     * to incorporate impact of the highest bits that would otherwise
     * never be used in index calculations because of table bounds.
     */
    static final int hash(Object key) {
        int h;
        return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
    }
```

&emsp;&emsp;乍一看，感觉很简单。没有什么特别的地方。但是实际上，这个里面我们要掌握的东西还是有的。我们学习源码的过程，不仅仅只是作为一个Reader进行读一遍就可以了。我们要做的，更多的是要学习他们为什么要这么做？这么做有什么好处？能够运用到现在的工作中？如果以后自己设计系统，能不能想到这样的处理方式？这个才是我们学习源码的目的。

&emsp;&emsp;不知不觉，又讲了一堆的废话。我们还是回归正题，看下为什么`HashMap`中要自定义一个`hash`方法，而不是采用操作系统自带的`hash`方法，来获取`Key`的`hashcode`。



## putVal方法