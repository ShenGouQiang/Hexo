---
title: EffectiveJava--第一条：用静态工厂方法代替构造器
permalink: EffectiveJava/EffectiveJavaLearnDay01
date: 2019-11-22 20:47:02
categories:
- Java
- EffectiveJava
tags:
- Java学习
- 代码优化
- Java进阶
---

# EffectiveJava--第一条：用静态工厂方法代替构造器

&emsp;&emsp;在我们日常的开发当中，我们经常会接触到各种各样的`POJO`。并且在我们使用的过程中，我们每当需要使用这个对象的时候，第一时间想到的就是`new`一个出来。其实，除了`new`,我们还可以采用其他的方法，来获取这个`POJO`对象，那就是-`静态工厂方法`。

&emsp;&emsp;那么你可能会问，什么是`静态工厂方法`呢？其实，在我们日常的使用中，我们已经在经常的使用了。例如，我们有一个`boolean`类型的变量，希望可以获取到这个变量的一个包装类，那么对于你而言，你可能第一时间想到的是`Boolean.valueOf(boolean b)`这个方法，通过这个方法，我们就可以获得一个对应的`Boolean`类型的变量了。

&emsp;&emsp;但是，你是否想过，`JDK`的库工程师们，在`valueOf`这个方法中，到底做了什么？是怎么把一个`boolean`变成`Boolean`类型的？接下来，我们看下`JDK`的库源码：

```java
public static Boolean valueOf(boolean b) {
        return (b ? TRUE : FALSE);
    }
```

看到这里，你可能明白点了什么，但是你可能会继续问？那为什么不在`valueOf`方法的内部给我们`new`一个出来呢？要解答这个问题，我们可以接着看`TRUE`和`FALSE`的源码。

```java
public static final Boolean TRUE = new Boolean(true);

public static final Boolean FALSE = new Boolean(false);
```

看到这里，我们发现，在`class`加载的时候，就一个创建了两个对象`TRUE`和`FALSE`。而我们每次通过`valueOf`获取对应包装类的时候，其实都是获取的这两个对象。这么做的好处之一是可以节省内存，同时降低内存中重复类的数量。那么我们在日常开发中，采用`静态工厂方法`有哪些利弊呢？

## 优点

### 优点一：有名称

&emsp;&emsp;说到这里，你可能觉得，这个很简单。的确，`Boolean.valueOf(boolean b)`的确是我们经常采用的一种方式，来产生`Boolean`包装类的方法。那么你有没有想过，我们为什么要采用`valueOf`的方式，而不是采用`new Boolean(true)`的方式呢？的确，对于懂的人而言，都知道无论这两种方式中的那一种，都可以给我们返回一个对应值的包装类型。但是如果我们单单从方法名称上看，`new Boolean(true)`我们仅仅只是创建了一个对象，那么在`Boolean`中的构造函数里面有什么隐藏的含义，你其实是不确定的。但是通过`Boolean.valueOf(boolean b)`我们可以知道，这个方法的目的就是把我们的基本类型转换成一个包装类型。起到了`见名知意`的作用。

### 优点二：不必再每次调用他们的时候都创建一个新对象

&emsp;&emsp;还是以`Boolean`这个类为例，我们都知道，当我们通过`new Boolean(true)`的时候，每次都会创建一个对象出来的。但是通过上面的`valueOf`方法。我们发现，在源码中使用了一个三目运算符。对于运算的结果，仅仅只是返回了两个常量。无论我们调用多少次，其实每次返回的都是同一个对象。

### 优点三：他们可以返回原返回类型的任何子类型对象

&emsp;&emsp;

### 优点四：所返回的对象的类可以随着每次调用而发生变化，这都取决于静态工厂方法的参数值

### 优点五：方法返回的对象所属的类，在编写包含该静态工厂方法的类时可以不存在。

## 缺点

### 缺点一：类如果不含共有的或者受保护的构造器，就不能被子类化。

### 缺点二：程序员很难发现他们。

## 总结