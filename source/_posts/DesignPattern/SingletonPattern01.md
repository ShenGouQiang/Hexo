---
title: 设计模式–单例模式
permalink: DesignPattern/SingletonPattern01
date: 2020-03-20 23:03:45
categories:
- 设计模式
tags:
- 设计模式
---

# 设计模式–单例模式

&emsp;&emsp;在写这篇文章之前，想了好久。一直在想要不要写这么一篇文章出来。为什么呢？主要是这个模式在我的后续的学习当中真的十分的重要。但同样的，这个模式现在又是一个被玩坏了的模式。因为只要你去面试，就一定会被问道。但是呢？问的又不是特别的深(大厂可能问的深，请原谅我这个渣渣，哈哈~~)。思来想去，觉得还是要写一下，在这里，我不会说明单例模式的一个发展的过程。仅仅只贴出最终的一个结果。并且简单说明下，在反射、序列号、克隆的情况下，对于单例模式的破坏，以及如何的修复。

## 懒汉模式

&emsp;&emsp;首先，我们先贴上代码

```java
package designpatterns.singleton;

import java.io.Serializable;
import java.util.Objects;

/**
 * 懒汉模式
 *
 * 防止：
 *  1.并发
 *  2.反射(防君子，不妨小人)
 *  3.克隆
 *
 * @author shengouqiang
 * @date 2020/3/19
 */
public class LazySingleton implements Serializable,Cloneable{

    private static int loadCount = 0;

    private static volatile LazySingleton INSTANCES;

    private LazySingleton(){
        synchronized (HungarySingleton.class){
            if(loadCount < 1){
                loadCount++;
            }else{
                throw new RuntimeException("HungarySingleton 已被加载过，请直接调用getInstances处理");
            }
        }
    }

    private Object readResolve(){
        return getInstances();
    }

    public static LazySingleton getInstances(){
        if(Objects.isNull(INSTANCES)){
            synchronized (LazySingleton.class){
                if(Objects.isNull(INSTANCES)){
                    INSTANCES = new LazySingleton();
                }
            }
        }
        return INSTANCES;
    }

    @Override
    protected Object clone(){
        return getInstances();
    }
}
```

&emsp;&emsp;在上面的代码中，我们这个代码中的次要部分，这些部分，主要是用来防止序列号、反射、和克隆的破坏，实际上，真正的代码是：

```java
package designpatterns.singleton;

import java.util.Objects;

/**
 * 懒汉模式
 *
 * 防止：
 *  1.并发
 *  2.反射(防君子，不妨小人)
 *  3.克隆
 *
 * @author shengouqiang
 * @date 2020/3/19
 */
public class LazySingleton{

    private static volatile LazySingleton INSTANCES;

    private LazySingleton(){
    }

    public static LazySingleton getInstances(){
        if(Objects.isNull(INSTANCES)){
            synchronized (LazySingleton.class){
                if(Objects.isNull(INSTANCES)){
                    INSTANCES = new LazySingleton();
                }
            }
        }
        return INSTANCES;
    }
}
```

&emsp;&emsp;OK，上面的这个就是懒汉模式下的单例最核心的代码。在这里，我会主要讲解懒汉式，至于其他的比较简单。

&emsp;&emsp;`懒汉`，顾名思义，就是在真正我们要用到的时候才会去做这件事情，有点类似于现在的`拖延症`。它是在真正要用到单例实例的时候才会进行初始化操作。降低了内存的开销<span style="color:red;">(说句实话，真心觉得没啥用，纯粹是为了应付面试的一个优点)</span>。在这里，我们要注意的是`DCL`。这里的`DCL`是从一篇文章中学到的一个关键字，`DCL`的真实含义是`Double Check + volatile`。也就是说，在我们写懒汉模式下，我们要注意的一个步骤。

### 为什么要使用Double Check

&emsp;&emsp;在这里，我们要说明为什么要使用`Double Check`。这是因为，对于单例模式，我们要保证的是在我们的系统中，只能有一个实例。因此，在高并发的情况下，可能会出现多个实例的问题，不仅影响到内存的使用率，更有可能因为我们的业务代码的问题，导致一些隐藏的`bug`，很难被修复。

&emsp;&emsp;在这里，我们要进行逐步优化的优化

#### 无判断的getInstances

```java
    public static LazySingleton getInstances(){      
        return INSTANCES = new LazySingleton();
    }
```

&emsp;&emsp;我们可以发现，在这种情况下，如果有两个线程，都需要调用`getInstances`方法，则每次返回，都返回的是一个新的值。因此这种情况下，是肯定不行的。

&emsp;&emsp;那么接下来，我们家一层if判断，看下结果：

#### 只有一层if判断的getInstances

```java
    public static LazySingleton getInstances(){
        if(Objects.isNull(INSTANCES)){
            INSTANCES = new LazySingleton();
        }
        return INSTANCES;
    }
```

&emsp;&emsp;这种情况下，虽然可以保证在单线程的情况下，能够保证是单例模式的。但是在高并发下，依然会存在问题。我们可以通过下面的视频来进行讲解。

<video id="video" controls="controls" controlslist="nodownload"  width="1000" height="480" preload="none" poster="https://static.shengouqiang.cn/blog/img/video/fengmian1000480.jpg">
      <source id="mp4" src="https://static.shengouqiang.cn/blog/video/DesignPattern/SingletonPattern/singletonOneIf.mp4" type="video/mp4">
</video>


&emsp;&emsp;既然这样，涉及到高并发的问题，那么我们可以采用锁的方式

#### 单if+synchronized 方法

```java
    public static LazySingleton getInstances(){
        if(Objects.isNull(INSTANCES)){
            synchronized (LazySingleton.class){
                INSTANCES = new LazySingleton();
            }
        }
        return INSTANCES;
    }
```

&emsp;&emsp;在这里，也有人会问，那为什么不直接将`synchronized`放入到`getInstances`方法上呢？首先这么做，也是可以结果多线程的并发问题，但是无论在什么时候，我们调用一次`getInstances`方法的时候，都要进行一次`加锁、释放锁`的操作。并且如果后续程序中出现`synchronized`的方法时候，还会造成阻塞的问题。

&emsp;&emsp;那么，如果是像上面的代码，仅仅只是锁代码块，会解决并发的问题吗？其实是解决不了的。在这里，我们还是通过一个动画的形式，进行讲解。

<video id="video" controls="controls" controlslist="nodownload"  width="1000" height="480" preload="none" poster="https://static.shengouqiang.cn/blog/img/video/fengmian1000480.jpg">
      <source id="mp4" src="https://static.shengouqiang.cn/blog/video/DesignPattern/SingletonPattern/SingletonOneIfSynchronized.mp4" type="video/mp4">
</video>


&emsp;&emsp;既然如此，我们在`synchronized`内再进行一次`if`判断，就可以实现并发情况下的单例模式：

#### 双if+synchronized 方法

```java
    public static LazySingleton getInstances(){
        if(Objects.isNull(INSTANCES)){
            synchronized (LazySingleton.class){
                if(Objects.isNull(INSTANCES)){
                    INSTANCES = new LazySingleton();
                }
            }
        }
        return INSTANCES;
    }
```

&emsp;&emsp;通过上面的代码，我们可以实现，在并发的模式下，依然可以保证我们的`INSTANCES`是单例的。接下来，我们依然通过视频进行讲解。

<video id="video" controls="controls" controlslist="nodownload"  width="1000" height="480" preload="none" poster="https://static.shengouqiang.cn/blog/img/video/fengmian1000480.jpg">
      <source id="mp4" src="https://static.shengouqiang.cn/blog/video/DesignPattern/SingletonPattern/singletonTwoIfSynchronized.mp4" type="video/mp4">
</video>


&emsp;&emsp;至此，我们讲解了关于单例模式中`DCL`的中`DC`。接下来，我们讲解下`DCL`中的`L`。

### 为什么要使用 volatile

&emsp;&emsp;大致的讲，就是为了实现变量在多个线程之间的可见性，以及防止指令重排。在这里，我不会过多的进行讲解。我会在之后的文章中，单独用一篇文章进行讲解的。

### 因序列化导致的单例失败

&emsp;&emsp;在之前的`懒汉式`单例模式的完成代码内，我们发现，有一部分代码是

```java
    private Object readResolve(){
        return getInstances();
    }
```

&emsp;&emsp;在这里，我们发现这段代码在`LazySingleton`中并没有被调用，那么为什么还要添加这段代码呢？这是因为，这段代码是为了方式在反序列化的时候，给`ObjectInputStream`进行调用的。

&emsp;&emsp;为什么要这么说呢？我们知道，当我们在将对象`序列化、反序列化`的时候，都是通过`ObjectInputStream/ObjectOutputStream`操作的。那么当我们反序列化的时候，会调用`readObject`方法。而反序列化一个对象在`ObjectStreamConstants`中的定义是`TC_OBJECT`，也就是`0x73`。此时会调用`readOrdinaryObject`方法。而在`readOrdinaryObject`方法中，会通过`reflect`，来检测当前的类中是否存在`readResolve`方法。如果存在，则直接返回我们重新的`readResolve`方法的返回值。

&emsp;&emsp;下面是这段源代码，如果有想要研究的同学，可以参考这段源代码：

```java
        if (obj != null &&
            handles.lookupException(passHandle) == null &&
            desc.hasReadResolveMethod())
        {
            Object rep = desc.invokeReadResolve(obj);
            if (unshared && rep.getClass().isArray()) {
                rep = cloneArray(rep);
            }
            if (rep != obj) {
                handles.setObject(passHandle, obj = rep);
            }
        }
```

&emsp;&emsp;因此，对于防止反序列化来破坏单例模式的方法，我们可以在我们的单例模式代码中，添加`readReslove`方法即可。

### 因反射导致的序列化失败

&emsp;&emsp;对于反射破坏单例模式的问题，我这里仅仅只给出一个基本的方案。因此`reflect`实在是太强大了。无论怎么防止，程序员们都能够进行破坏。因此，在这里，我仅仅只是给出一个最简单的方式。也就是在程序中添加一个内置的计数器，每次在调用构造函数的时候，进行判断计数器是否大于1，如果大于1，则代表当前系统中已经存在当前实例。如果小于1，则可以通过构造函数进行获取。

&emsp;&emsp;正式因为反射模式的强大。因此，才说这种方式是一种`“防君子，不防小人”`的办法了。

### 因克隆导致的序列化失败

&emsp;&emsp;对于克隆破坏的单例模式，我们仅仅只需要实现`Cloneable`接口。然后直接调用`getInstances`方法返回即可。也就是下面的代码：

```java
    @Override
    protected Object clone(){
        return getInstances();
    }
```

## 饿汉模式

&emsp;&emsp;首先，我们先贴上代码

```java
package designpatterns.singleton;

import java.io.Serializable;

/**
 * 饿汉模式
 *
 * 防止：
 *  1.并发
 *  2.反射(防君子，不妨小人)
 *  3.克隆
 *
 * @author shengouqiang
 * @date 2020/3/19
 */
public class HungarySingleton implements Serializable,Cloneable {

    private static int loadCount = 0;

    private HungarySingleton(){
        synchronized (HungarySingleton.class){
            if(loadCount < 1){
                loadCount++;
            }else{
                throw new RuntimeException("HungarySingleton 已被加载过，请直接调用getInstances处理");
            }
        }

    }

    private Object readResolve(){
        return getInstances();
    }

    private static class  HungarySingletonHolder {
        private static final HungarySingleton INSTANCES = new HungarySingleton();
        private HungarySingletonHolder(){

        }
    }

    public static HungarySingleton getInstances() {
        return HungarySingletonHolder.INSTANCES;
    }

    @Override
    protected Object clone(){
        return getInstances();
    }
}
```

&emsp;&emsp;对于`饿汉`模式而言，他的单例是通过`JVM`对于一个class仅加载一次来进行保证的。至于具体的内部细节，我会在后期的`jvm`章节进行讲解。我们在这里，只需要知道，当`jvm`的`ClassLoader`加载一个`class`后，会自动的初始化静态变量。虽然这么说不是十分的严谨，但是对于理解`饿汉`模式已经足够了。因此，在`懒汉`和`饿汉`模式中，相比较而言，`饿汉`模式是比较简单的。也是比较推荐的一种。

&emsp;&emsp;而这里之所以采用匿名内部类，是因为应付有些面试的时候，说`饿汉`模式的情况下，我都不需要使用这个单例，但是你还是加载到内存里面的一种`吹毛求疵`的问题。

&emsp;&emsp;至于`反射`、`序列化`和`克隆`的讲解，和`懒汉模式相同`，在这里不再过多的赘述了。

## Effective Java中用enum实现

&emsp;&emsp;首先，我们先贴上代码

```java
package designpatterns.singleton;

import java.io.Serializable;

/**
 * 枚举模式
 *
 * @author shengouqiang
 * @date 2020/3/19
 */
public enum EnumSingleton{
    INSTANCES;

    public static EnumSingleton getInstances(){
        return INSTANCES;
    }
}
```

对于这种写法，是`Effective Java`的作者推荐的一种写法。对于这种写法，因为`enum`的原因，天生的提供了`反射`、`序列化`、`克隆`的手法来放着程序创建多个实例。

但是这种写法比较的让人迷惑，因为我们想要的是一个单例模式，是一个类，而这样做，把我们的单例变成了一个枚举，就感觉别扭。

