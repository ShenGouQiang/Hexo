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

&emsp;&emsp;通过上面的注释，我们发现，`HashMap`之所以这样做，是采用一种最简单的方式来让我们的值在table中更加均匀的分布的。主要的做法是

1. 如果`key`为`null`,则放在`第0位`
2. 如果`key`不为`null`,则调用系统的`hashCode`方法，获取hash值
3. 将当前获取的`hash`值`右移16`位，然后与当前`hashcode`进行`异或`操作

&emsp;&emsp;在这里，这个`hash`函数，其实就是一个扰动函数，为什么这么说呢？因为如果在这里我们直接以`hashCode`作为我们的散列特征的情况下，那么就会有一个问题，假如我们的`Array`的大小是`16`的话，那么真正能够起到的作用的，其实也就是`hashCode`的低位，而高位直接被屏蔽掉<span style="color:red;">(为什么会这样，在下面讲解index的时候会说)</span>。如果我们有一批数据，正好这些数据的`hashCode`的低位是相似的或者是很相同的，而高位的差别很大，在采用这样的方式进行获取`index`的时候，此时会发生极大的`hash碰撞`，极大的降低了`HashMap`的一个性能。因此，我们采用将一个`hashCode`的`高16位`与`低16位`进行`异或`的方式，使得到的一个最终的`hash`值更加随机，相当于间接的保留了部分`hashCode的高16位`的一个特征。可以极大的避免上述的问题，起到了干扰的作用。

&emsp;&emsp;这是因为这样的情况，可以保证`HashMap`的一个均匀分布的结果。

## putVal方法

```java
    /**
     * Implements Map.put and related methods
     *
     * @param hash hash for key
     * @param key the key
     * @param value the value to put
     * @param onlyIfAbsent if true, don't change existing value
     * @param evict if false, the table is in creation mode.
     * @return previous value, or null if none
     */
    final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        else {
            Node<K,V> e; K k;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }
```

&emsp;&emsp;上面的代码就是在JDK1.8中的HashMap中的put的真实操作。在这里，我们主要从三个方面进行讲解

1. `index`的确定
   1. 为什么`Array`的容量是2<sup>n</sup>（作用一）。
2. `resize`
   1. `resize`的原理
   2. 为什么`Array`的容量是2<sup>n</sup>（作用二）。
   3. `resize`何时会发生
3. 当发生`hash碰撞`时的处理操作
   1. 链表操作
   2. 链表转树
   3. 树转链表
   4. 树操作

&emsp;&emsp;其中关于树的部分，我会单独拉出一篇文章进行讲解，在这里不做过多的阐述。我们这篇文章主要是从1、2、3.1这三个部分进行讲解。

### index的确定

&emsp;&emsp;首先，我们看下关于index的一个确定的操作。这个操作和之前第二部分的`hash`方法的原理有关。同时，也可以让你更加的理解，为什么`HashMap`要用自己的`hash`方法。

&emsp;&emsp;在上述的源码中，真正确定`index`的，只有一句话`(n - 1) & hash`。注意，这里的hash就是第二部分我们计算出的真实的hash值。而n这是获取`Array`的长度，如果`Array`为null，则会先进行`resize`操作，初始化`Array`。然后获取`Array`的长度。

&emsp;&emsp;初看这段代码，我们会发现，就是一个<span style="color:red;">与(&)</span>操作。获取index就可以了。如果是这样的话，那么我们有几个问题?

1. 既然我们获取到数组的长度为`n`了，那么为什么还要进行`n-1`操作呢？这不是始终要空出一个`index`，降低了使用效率吗？

&emsp;&emsp;我们首先来解答第二个疑问，为什么要进行`n-1`操作。其实，这个就是要说的关于为什么`Array`的容量必须要为2<sup>n</sup>的一个原因。这里面主要涉及到了二级制的一个操作。下面我们举个例子，说明下：

&emsp;&emsp;因为在之前，我们已经确定了，`HashMap`的`Array`的`size`大小一定是2<sup>n</sup>。此时我们假设我们的数组的大小是`16`。而`16`的二进制是`0001 0000`。此时，当进行`n-1`时，此时变成`15`，对应的二进制为`0000 1111`。此时我们发现，当我们与`hash`进行<span style="color:red;">与(&)</span>操作，也就是在仅仅保留`hashcode`的`最后四位`2进制数，转成10进制，便是当前元素要存在数组中的下标。因此，在这里，我们先解释一部分为什么`Array`的数组长度是2<sup>n</sup>。通过也解释了<span style="color:red;">与(&)</span>的作用。这这样做的目的，主要的根本原因还是因为，计算机操作2进制是最快的。这样写，是能够更好的提升性能的。



### resize

### 哈希碰撞的解决(链表相关)



