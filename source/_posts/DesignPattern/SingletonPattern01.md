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
        return INSTANCES;
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
      <source id="mp4" src="https://static.shengouqiang.cn/blog/video/DesignPattern/SingletonPattern/singletonOneIfSynchronized.mp4" type="video/mp4">
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

大致的讲，就是为了实现变量在多个线程之间的可见性，以及防止指令重排。在这里，我不会过多的进行讲解。我会在之后的文章中，单独用一篇文章进行讲解的。

### 因序列化导致的单例失败

### 因反射导致的序列化失败

### 因克隆导致的序列化失败



## 饿汉模式

首先，我们先贴上代码

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



## Effective Java中用enum实现

首先，我们先贴上代码

```java
package designpatterns.singleton;

import java.io.Serializable;

/**
 * 枚举模式
 *
 * 防止：
 *  1.并发
 *  2.反射(防君子，不妨小人)
 *  3.克隆
 *
 * @author shengouqiang
 * @date 2020/3/19
 */
public enum EnumSingleton implements Serializable,Cloneable {
    INSTANCES;

    public static EnumSingleton getInstances(){
        return INSTANCES;
    }
}
```



