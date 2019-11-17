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

&emsp;&emsp;那么接下来，我们来研究一下，为什么`ThreadLocal`可以做到线程间隔离，并且，它的内部优势如何实现的呢？

## 原理

&emsp;&emsp;首先，我们看下`ThreadLocal`的UML类图：

![ThreadLocal-UML类图](http://static.shengouqiang.cn/blog/img/Java/LearnDay01/ThreadLocalUML.jpg)

&emsp;&emsp;通过类图，我们发现，`ThreadLocal`的内部，主要是通过一个内部类`ThreadLocalMap`来实现的。而`ThreadLocalMap`内部，由定义了一个`Entry`内部类。同时，在途中我们发现了`InheritableThreadLocal`。对于这连个类的不同，我们会在下面的文章中逐一进行讲解。下面，我们先来说一下`ThreadLocal`这个类。

## ThreadLocal类

&emsp;&emsp;这次讲解的方式和之前的有所不同。因为我不会一上来就贴上所有的源码。这回采用的是，我用到了哪部分源码，就贴哪部分源码。这样的讲解，会有更大的针对性和可读性。

### 初始化方法

&emsp;&emsp;对于`ThreadLocal`而言，如果我们想要用到，那么我们就需要在我们的线程中去创建一个`ThreadLocal`。对于ThreadLocal，我们的创建方式主要是已下两种：

```java
    @Test
    public void initOneTest(){
        ThreadLocal<String> threadLocal = new ThreadLocal<>();
        System.out.println("initOneTest result is :" + threadLocal.get());
    }

    @Test
    public void initTwoTest(){
        ThreadLocal<String> threadLocal = ThreadLocal.withInitial(String::new);
        System.out.println("initTwoTest result is :" + threadLocal.get());
    }
```

&emsp;&emsp;此时，我们程序的执行结果如下：

```
initOneTest result is :null
initTwoTest result is :
```

&emsp;&emsp;既然我们的`ThreadLocal`有两种创建方式，那么这两种方式有什么不同吗？接下来，我们对比下这两种方式

#### 构造函数

```java
    /**
     * Creates a thread local variable.
     * @see #withInitial(java.util.function.Supplier)
     */
    public ThreadLocal() {
    }
```

&emsp;&emsp;我们看到，对于构造函数而言，`JDK`的库工程师们并没有帮我们去做任何的事情，就是提供了一个默认的构造函数来供我们调用。同时，对于`ThreadLocal`内部的成员变量`threadLocalHashCode`、`nextHashCode`、`HASH_INCREMENT`，提供了一个默认的值。

#### withInitial 方法

```java
    /**
     * Creates a thread local variable. The initial value of the variable is
     * determined by invoking the {@code get} method on the {@code Supplier}.
     *
     * @param <S> the type of the thread local's value
     * @param supplier the supplier to be used to determine the initial value
     * @return a new thread local variable
     * @throws NullPointerException if the specified supplier is null
     * @since 1.8
     */
    public static <S> ThreadLocal<S> withInitial(Supplier<? extends S> supplier) {
        return new SuppliedThreadLocal<>(supplier);
    }
```

&emsp;&emsp;我们看到，对于`withInital`方法，`ThreadLocal`的内部是采用的调用了一个静态内部类`SuppliedThreadLocal`来实现的。而这个静态类的源码如下：

```java
/**
    * An extension of ThreadLocal that obtains its initial value from
    * the specified {@code Supplier}.
    */
static final class SuppliedThreadLocal<T> extends ThreadLocal<T> {

    private final Supplier<? extends T> supplier;

    SuppliedThreadLocal(Supplier<? extends T> supplier) {
        this.supplier = Objects.requireNonNull(supplier);
    }

    @Override
    protected T initialValue() {
        return supplier.get();
    }
}
```

&emsp;&emsp;通过代码我们可以知道，对于`SuppliedThreadLocal`的构造方法，它接收的是一个`Supplier`的泛型接口，这个接口是`Java8`提供的一个函数式接口，因此在这里，我们可以采用`lamdba`表达式的形式，将我们的参数传递近来，例如上文的`String::new`。至于具体的，请参考相应的文章。

&emsp;&emsp;在这里接口，我们看见，它仅仅只是一个判空的操作和赋值的操作。

### get方法

&emsp;&emsp;对于`get`方法，`ThreadLocal`的源码如下：

```java
  /**
     * Returns the value in the current thread's copy of this
     * thread-local variable.  If the variable has no value for the
     * current thread, it is first initialized to the value returned
     * by an invocation of the {@link #initialValue} method.
     *
     * @return the current thread's value of this thread-local
     */
    public T get() {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            ThreadLocalMap.Entry e = map.getEntry(this);
            if (e != null) {
                @SuppressWarnings("unchecked")
                T result = (T)e.value;
                return result;
            }
        }
        return setInitialValue();
    }
```

&emsp;&emsp;对于官方给定的解释，返回的是以当前线程为`Key`，然后获取到这个线程下的变量的值，如果在当前线程不存在，则先进行初始化，然后再返回对应的值。

&emsp;&emsp;接下来，我们解读下代码，首先通过`Thread.currentThread()`获取到当前线程。然后通过`getMap`的方法来获取到对应的`ThreadLocalMap`中的值。而`getMap`的方法如下：

```java
    /**
     * Get the map associated with a ThreadLocal. Overridden in
     * InheritableThreadLocal.
     *
     * @param  t the current thread
     * @return the map
     */
    ThreadLocalMap getMap(Thread t) {
        return t.threadLocals;
    }
```

&emsp;&emsp;通过这段代码，我们发现，对于每个线程，都有一个`ThreadLocalMap`，而`ThreadLocalMap`又是`ThreadLoal`的静态内部类。因此在`Thread`中，每个线程都会存在一个`ThreadLocal.ThreadLocalMap`的成员变量。因此，这个就证实了，`ThreadLocal`是线程间私有的，不存在`并发`的问题的。同时，我们发现，对于ThreadLocal而言，它的内部存储都是采用一个`ThreadLocalMap`的方式进行存储的。因此，对于整个`ThreadLocal`而言，最最重要的就是`ThreadLocalMap`。

&emsp;&emsp;如果当前线程的`ThreadLocalMap`不为`null`,则我们获取到`map`后，会通过`ThreadLocalMap.Entry e = map.getEntry(this);`的方式去获取`Entry`。可能到这里，读者会别叫晕，一会是`ThreadLocalMap`,一会又是`ThreadLocal.ThreadLocalMap.Entry`的。不要急，在解释完这个方法后，我们会讲解下`ThreadLocalMap`这个类的。

&emsp;&emsp;在获取到`Entry`后，我们判断当前`Entry`是否为`null`，如果不为`null`，此时我们回去对应的`value`,将`value`返回即可。

&emsp;&emsp;最后，如果我们发现`ThreadLocalMap`为`null`，或者`Entry`为null，此时会执行`setInitialValue`方法。这个方法的源码如下：

```java
    /**
     * Variant of set() to establish initialValue. Used instead
     * of set() in case user has overridden the set() method.
     *
     * @return the initial value
     */
    private T setInitialValue() {
        T value = initialValue();
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null)
            map.set(this, value);
        else
            createMap(t, value);
        return value;
    }
```

&emsp;&emsp;在这个方法中，我们首先会通过`initialValue`获取到`value`。而这个方法的源码又分为两部分，如果我们是通过`new ThreadLocal<>()`方式创建的，此时调用的源码如下：

```java
    protected T initialValue() {
        return null;
    }
```

&emsp;&emsp;而如果我们是通过`ThreadLoacl.withInitial`方法创建的，那么此时调用的就是

```java
@Override
protected T initialValue() {
    return supplier.get();
}
```

&emsp;&emsp;而这里面的`supplier`就是我们上面将的第二种初始化的时候，传进来的`lamdba`表达式。

&emsp;&emsp;同样的，我们继续获取当前线程。然后再次调用`getMap`方法，如果我们发现`map`存在，则只需要将`value`添加到`map`中即可。如果`map`不存在，则调用`createMap`方法。

```java
    /**
     * Create the map associated with a ThreadLocal. Overridden in
     * InheritableThreadLocal.
     *
     * @param t the current thread
     * @param firstValue value for the initial entry of the map
     */
    void createMap(Thread t, T firstValue) {
        t.threadLocals = new ThreadLocalMap(this, firstValue);
    }
```

&emsp;&emsp;而创建`Map`的过程，就是对线程的`threadLocals`进行赋值，而创建值的过程就是调用`ThreadLocalMap`的一个构造方法。

```java
    void createMap(Thread t, T firstValue) {
        t.threadLocals = new ThreadLocalMap(this, firstValue);
    }
```

&emsp;&emsp;整个`get`方法的调用流程图如下：

![ThreadLocal-GET方法](http://static.shengouqiang.cn/blog/img/Java/LearnDay01/ThreadLocalGet.jpg)

### ThreadLocalMap内部类

&emsp;&emsp;在刚刚进行讲解的时候，我们发现，其实在`ThreadLocal`的内部，其实是用`ThreadLocalMap`进行存储的。因此为了理解`ThreadLocal`，`ThreadLocalMap`就显得十分的重要。那么既然要好好的理解`ThreadLocalMap`，那么我们首先要看看他的源码：

#### 构造方法

&emsp;&emsp;根据之前的时候，我们首先要看下`ThreadLocalMap`的构造方法：

```java
/**
    * Construct a new map initially containing (firstKey, firstValue).
    * ThreadLocalMaps are constructed lazily, so we only create
    * one when we have at least one entry to put in it.
    */
ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue) {
    table = new Entry[INITIAL_CAPACITY];
    int i = firstKey.threadLocalHashCode & (INITIAL_CAPACITY - 1);
    table[i] = new Entry(firstKey, firstValue);
    size = 1;
    setThreshold(INITIAL_CAPACITY);
}

/**
    * Construct a new map including all Inheritable ThreadLocals
    * from given parent map. Called only by createInheritedMap.
    *
    * @param parentMap the map associated with parent thread.
    */
private ThreadLocalMap(ThreadLocalMap parentMap) {
    Entry[] parentTable = parentMap.table;
    int len = parentTable.length;
    setThreshold(len);
    table = new Entry[len];

    for (int j = 0; j < len; j++) {
        Entry e = parentTable[j];
        if (e != null) {
            @SuppressWarnings("unchecked")
            ThreadLocal<Object> key = (ThreadLocal<Object>) e.get();
            if (key != null) {
                Object value = key.childValue(e.value);
                Entry c = new Entry(key, value);
                int h = key.threadLocalHashCode & (len - 1);
                while (table[h] != null)
                    h = nextIndex(h, len);
                table[h] = c;
                size++;
            }
        }
    }
}
```

&emsp;&emsp;我们先来看看第一个构造函数，通过上面的注释，我们可以知道，`ThreadLocalMap`是进行延迟构建的。也就是说它并不会在创建一个线程的时候，就会初始化`ThreadLocalMap`。而是在我们第一次需要从里面拿值的话，才会进行调用的。因为`ThreadLocalMap`并没有提供默认的构造函数，因此想要调用的时候，必须要有一个默认的值。

&emsp;&emsp;通过代码我们可以知道，程序首先会创建一个`Entry`数组，而`Entry`的定义是什么呢？

```java
/**
* The entries in this hash map extend WeakReference, using
* its main ref field as the key (which is always a
* ThreadLocal object).  Note that null keys (i.e. entry.get()
* == null) mean that the key is no longer referenced, so the
* entry can be expunged from table.  Such entries are referred to
* as "stale entries" in the code that follows.
*/
static class Entry extends WeakReference<ThreadLocal<?>> {
    /** The value associated with this ThreadLocal. */
    Object value;

    Entry(ThreadLocal<?> k, Object v) {
        super(k);
        value = v;
    }
}
```

&emsp;&emsp;因为在`ThreadLocalMap`中，每一个线程和对应的私有的变量，都是一对一对的。采用的是`K-V`模式。因此，我们可以将这样的映射关系封装成一个`Entry`。这里采用的是`JDK`中`Map`的思想，因为`ThreadLocalMap`本身也是一种`Map`数据结构，通过`hash`去进行结算的。并且，对于`Key`的采用，是对`ThreadLocal`采用的一种弱引用的方式进行引用的。因此，我们发现，真正的将线程与变量之间连接起来的，是通过`Entry`进行封装的。而`Entry`又是存储在`ThreadLocal`中的。因此，`Entry`仅仅只是一个`POJO`,它仅仅给我们提供了一个构造函数而已。

&emsp;&emsp;接下来，我们继续分析第一个构造函数的代码，首先是创建了一个`Entry`的数组，并且数组默认的大小是`16`。这个大小与`HashMap`的默认容量是一致的。接下来，我们根据`ThreadLocal`这个`Key`的`hash code`与`INITIAL_CAPACITY - 1`进行与运算，之所以这样，是因为默认情况下，数组的大小是`INITIAL_CAPACITY`，又因为数组是从0开始的，因此数组的下标范围是`[0,INITIAL_CAPACITY-1]`。而我们通过代码可以发现，在`ThreadLocal`中有一个神奇的数字`0x61c88647`。这个数字的目的是为了实现让多个`ThreadLocal`中可以实现让`hash code`均匀的分布在`2的n次方`中，同时，如果发生了碰撞，此时还可以利用了`开放定址法`来解决碰撞的问题。

&emsp;&emsp;在上面的代码中，当我们获取到数组下边后，通过创建一个`Entry`来放到数组中，同时设置数组的使用度`size`为`1`。同时设置`Map`的阈值为`16*2/3`为`10`。当数组中的使用度`size`大于10的时候，将进行扩容。

&emsp;&emsp;接下来，我们看下第二个构造函数。第二个构造函数的目的是当我们已经有一个`ThreadLocalMap`的时候，来创建另外一个`ThreadLocalMap`时进行调用。这个构造函数的调用仅会被`InheritableThreadLocal`调用。此时我们会在讲解`InheritableThreadLocal`时进行讲解。

#### resize方法

&emsp;&emsp;当`ThreadLocalMap`中的`Entry数组`超过阈值之后，此时会对`Entry数组`进行扩容，扩容的代码如下：

```java
/**
* Double the capacity of the table.
*/
private void resize() {
    Entry[] oldTab = table;
    int oldLen = oldTab.length;
    int newLen = oldLen * 2;
    Entry[] newTab = new Entry[newLen];
    int count = 0;

    for (int j = 0; j < oldLen; ++j) {
        Entry e = oldTab[j];
        if (e != null) {
            ThreadLocal<?> k = e.get();
            if (k == null) {
                e.value = null; // Help the GC
            } else {
                int h = k.threadLocalHashCode & (newLen - 1);
                while (newTab[h] != null)
                    h = nextIndex(h, newLen);
                newTab[h] = e;
                count++;
            }
        }
    }
    
    setThreshold(newLen);
    size = count;
    table = newTab;
}
```

&emsp;&emsp;我们来看下，`JDK`的库工程师是如何对数组进行高效扩容的。首先会去创建一个有原来两倍大小的新`Entry`数组，然后遍历老数组，获取老数组中每个数组的元素。如果元素不为空，则判断当前元素的`ThreadLocal`是否还在被引用，如果没有，则直接将`value`设置为null，帮助`GC`清理。否则的话，将会根据`int h = k.threadLocalHashCode & (newLen - 1);`的值，同时根据`线性开放定址法`来元素应该在数组中的真正下标，然后将元素放入到数组中。最后设置新的数组的阈值和使用度`size`。

#### rehash方法

&emsp;&emsp;在上面，我们讲解了`resize`方法，其实，`resize`方法是被`rehash`方法调用的。我们发现在`set`方法中，有如下的源码：

```java
if (!cleanSomeSlots(i, sz) && sz >= threshold)
    rehash();
```

&emsp;&emsp;我们发现，如果在`set`方法触发了某些条件后，将会执行`rehash`方法。至于具体的条件的原因，会在接下来的`set`方法讲解的时候进行说明。

&emsp;&emsp;既然知道了是从何处进行调用的，那么我们就来看下`rehash`的源码：

```java
    /**
    * Re-pack and/or re-size the table. First scan the entire
    * table removing stale entries. If this doesn't sufficiently
    * shrink the size of the table, double the table size.
    */
private void rehash() {
    expungeStaleEntries();

    // Use lower threshold for doubling to avoid hysteresis
    if (size >= threshold - threshold / 4)
        resize();
}
```

&emsp;&emsp;通过源码，我们可以发现，此时回去调用`expungeStaleEntries`方法。在调用后，如果`size`依然大于`threshold - threshold / 4`。此时会执行`resize`方法。因此，在这个方法中，`expungeStaleEntries`是重点。

## InheritableThreadLocal类

