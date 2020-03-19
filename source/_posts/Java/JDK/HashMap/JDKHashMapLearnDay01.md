---
title: Java学习--HashMap详解(构造函数)
permalink: Java/JDK/HashMap/JDKHashMapLearnDay01
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

![Java版本信息](https://static.shengouqiang.cn/blog/img/Java/JDK/DAY01/java-version.jpg)

&emsp;&emsp;接下来，我们在这篇文章主要讲解的是`HashMap`的构造函数。

&emsp;&emsp;在`HashMap`中，`HashMap`一共有四个构造函数，接下来，我们逐一进行讲解。

## 负载因子(loadFactor)

&emsp;&emsp;首先，在讲解无参构造函数之前，我们先来讲解下为什么在`JDK`的官方源码中，将`HashMap`的负载因子设置为`0.75`。

&emsp;&emsp;首先，我们知道，在计算机的运行过程中，我们主要注重的是两个问题，一个是希望我们的程序尽可能的运行的快。另一个，我们希望我们程序在运行的过程中，尽可能的少消耗我们的内存。这个就是计算机中评判一个程序经常用到的两个维度，`时间复杂度`和`空间复杂度`。在实际的程序运行过程中，我们不可能同时将这两个标准都优化到极致，因此在很多的程序，对于这两个标准，会根据实际的业务需求，采用以下三种方案进行开发：

- 牺牲程序的时间复杂度，尽可能的降低程序的空间复杂度
- 牺牲程序的空间复杂度，尽可能的降低程序的时间复杂度
- 综合考虑程序的时间复杂度和空间复杂度，在这两者中，选择一个折中平衡点

&emsp;&emsp;而在`JDK`的`HashMap`中，就是采用了第三种方案，经过了无数的证明与总结，人们发现，当负载因子为`0.75`的时候，此时程序的效率最高。因此，在`JDK`的源码中，将`HashMap`的默认负载因子设置成了`0.75`。

&emsp;&emsp;上面我们讲解了这么多，又是`负载因子`，又是`时间复杂度`，又是`空间复杂度`的。那么在`HashMap`中，这些含义到时是干什么用的呢？其实，我们都知道，对于`HashMap`而言，他就是一个集合。那么对于集合，一定要提供两个功能 --> `“读取”`和`“存储”`。 既然要存储和读取，那么我们关心的其实就是两个问题:

- 是否足够快
- 是否省内存
  

对于`JDK`而言，在保证效率的同时，势必要进行内存的无休止消耗。因此在两者之间做了一个权衡，也就是所谓的`0.75`的存在了。而这个数值的存在，也是在大量的试验下的出的一个最优解。

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

&emsp;&emsp;我们首先来看下我们的最最常用的无参构造函数。该函数仅仅只是设置了程序的默认负载因子，也就是上文提到的`0.75`。并没有去进行`Bucket`的初始化操作。

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

&emsp;&emsp;在这里，我们发现，它调用了另外的一个构造函数，至于在这个构造函数值的操作，不要着急，我们在下个构造函数中进行操作。我们发现，当我们使用这个构造函数的时候，我们可以指定默认的`Bucket`的大小，只不过这个大小会进行清洗，让它变成最接近于2<sup>n</sup>，且该值要大于等于我们设置的默认`Bucket`的大小，至于是怎么进行操作的，在此先卖个关子，在下面我们会进行着重讲解。同时，我们发现，在默认的情况下，此时默认的负载因子为`0.75`。

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

&emsp;&emsp;接下来，是我们最最重要的一个构造函数了。这个构造函数我们可以同时指定`Bucket`的大小和负载因子的比例。只不过，在这里要强调一点的是，默认情况下，我们可以改变`Bucket`的大小，但是对于负载因子，除了特殊的情况外，我们一般用默认值即可。

&emsp;&emsp;接下在，我们看下上面的代码，我们发现，`Bucket`的最大的大小为`2<<30`(`static final int MAXIMUM_CAPACITY = 1 << 30;`)。要解释为什么是2<sup>30</sup>呢？通过代码我们可以发现：

- 因为int是4个字节，代表了32位，又因为第一位代表的是`+/-`。所以，只能是2<sup>30</sup>了。
- 同时，为什么要使用`int`，而不是使用`byte、short、long`等类型呢？其实，这个是为了系统的性能考虑，做的一个折中的处理。

&emsp;&emsp;接下来，就是最重要的一步。对于我们传入的初始`Bucket`大小`initialCapacity`，此时会传入`tableSizeFor`方法中，并且将返回的结果返回给`threshold`。通过这里，我们发现，`HashMap`并没有使用我们直接传入的初始容量，而是在进行一系列的运算后，才最终确定我们最终的`Bucket`的大小的。

### tableSizeFor 方法

&emsp;&emsp;接下来，我们看下`tableSizeFor`这个方法的源码。

```java
    static final int tableSizeFor(int cap) {
        int n = cap - 1;
        n |= n >>> 1;
        n |= n >>> 2;
        n |= n >>> 4;
        n |= n >>> 8;
        n |= n >>> 16;
        return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
    }
```

&emsp;&emsp;在讲解上面的代码之前，我们要知道`>>>`方法的含义

#### >>> 含义

&emsp;&emsp;`>>>表示无符号右移，也叫逻辑右移，即若该数为正，则高位补0，而若该数为负数，则右移后高位同样补0`

&emsp;&emsp;接下来，我们说下，`n | n -1`的含义。在这里`|`是`或`的含义。我们举个例子:

```
1001 | 0101 = 1101 
```

&emsp;&emsp;接下来，我们看下，在`HashMap`中，是如果将一个数洗成一个2<sup>n</sup>的。

&emsp;&emsp;此时，我们假设`cap`为`7944525`。此时对应的二进制为`0111 1001 0011 1001 0100 1101`。接下来，我们手动进行计算：

```
n = 0111 1001 0011 1001 0100 1101            最原始值
n >>> 1 = 0011 1100 1001 1100 1010 0110
此时我们计算 n | n >>> 1 的结果为：
n | n >>> 1 = 0111 1101 1011 1101 1100 1111
此时我们的n 也就变成了 0111 1101 1011 1101 1100 1111
接下来，我们计算 n >>> 2
此时 n >>> 2 的结果为: 0001 1111 0110 1111 0111 0011
此时 n | n >>> 2 的结果为：0111 1111 1111 1111 1111 1111
接下来，以此类推，我们通过每次的运算结果与 最原始值 进行观察，我们发现，这样做的目的，是为了让 最原始值中的1的后X位于1进行或，就可以得到结果：
最后，我们用我们得出的结论与上面的结果进行验证：
n = 0111 1001 0011 1001 0100 1101
n | n >>> 1 = 0111 1101 1011 1101 1100 1111
n | n >>> 2 = 0111 1111 1111 1111 1111 1111
n | n >>> 4 = 0111 1111 1111 1111 1111 1111
n | n >>> 8 = 0111 1111 1111 1111 1111 1111
n | n >>>16 = 0111 1111 1111 1111 1111 1111
```

&emsp;&emsp;此时，我们得到 `n+1 = 8388608`。也就是2<sup>23</sup>。

&emsp;&emsp;接下来，我们以`cap=14669`进行举例，我们直接以上面的结论进行计算：

```
n = 0011 1001 0100 1101
n | n >>> 1 = 0011 1101 1110 1111
n | n >>> 2 = 0011 1111 1111 1111
n | n >>> 4 = 0011 1111 1111 1111
n | n >>> 8 = 0011 1111 1111 1111
n | n >>>16 = 0011 1111 1111 1111
```

&emsp;&emsp;此时`n+1=16384`。也就是2<sup>14</sup>。通过上面的两个例子，我们发现，当`HashMap`拿到一个值后，首先对值进行`减1`操作，然后将值进行清洗，让2进制的值，从又开始遇到的`第一个1`开始，后面都清洗成`1`。最后在将`减去的1加回去`，变成2<sup>n</sup>。

&emsp;&emsp;`HashMap`正是通过这样的做法，保证了我们的`Bucket`的数组大小为2<sup>n</sup>。至于为什么一定要是2<sup>n</sup>，这个在后续的文章中会进行讲解的。

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

&emsp;&emsp;对于这个构造函数，在实际的工作中，我们用到的不多，在`putMapEntries`中，主要是进行了`resize()`操作与`putVal()`操作，这个会在后续的文章中进行讲解。至于代码中其他的部分，十分的简单，都是利用了本文所讲解的内容，在这里不再进行额外的赘述。



## 总结

&emsp;&emsp;对于`HashMap`的构造函数，我们知道了以下几点信息

- `HashMap`提供了四种构造函数，至于他们之前的原理，请参考上面的文章
- 对于负载因子为什么是`0.75`,在上文中进行了讲解。
- 对于`HashMap`中`Bucket`的最大容量为`1<<30`，我们也进行了讲解
- 对于`HashMap`中，是如果将一个随意的初始容量洗成2<sup>n</sup>，在上面的文章中进行了讲解。

&emsp;&emsp;学无止境，只有不断的学习，才能配得上更好的自己。