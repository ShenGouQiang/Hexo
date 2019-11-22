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

&emsp;&emsp;<span style="color:red;">注意：在这里，我们要注意一点，不是说我们的构造方法不能用。而是说，在一些情况下，我们采用静态工厂方法会比直接采用构造器的方式，让我们的代码更加的简洁，更加容易让人理解。</span>

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

&emsp;&emsp;对于这个优势，其实我们可以看下`JDK1.8`中的源码关于`Collections`这个类的部分方法。在这里，我们先贴出相关的源码，在进行分析：

```java
public static <T> Set<T> unmodifiableSet(Set<? extends T> s) {
    return new UnmodifiableSet<>(s);
}

static class UnmodifiableSet<E> extends UnmodifiableCollection<E>
                                implements Set<E>, Serializable {
    private static final long serialVersionUID = -9215047833775013803L;

    UnmodifiableSet(Set<? extends E> s)     {super(s);}
    public boolean equals(Object o) {return o == this || c.equals(o);}
    public int hashCode()           {return c.hashCode();}
}
```

&emsp;&emsp;在这里，我们先不来讨论这个方法是用来干什么的。我们仅仅只是通过方法的入参、返回值和方法内代码进行分析。首先我们发现，对于方法的入参和返回值都是一个关于`Set`的泛型。而在代码的内部，我们对于方法的处理，采用的是一个`UnmodifiableSet`类。

&emsp;&emsp;而通过这个类的源码我们可以知道，这个类是`Set`的一个子类而已。并且这个类是包级私有的。因此，对于我们而言，我们调用`unmodifiableSet`的方法时，并不需要了解`UnmodifiableSet`这个类，甚至都不需要这个类的存在。这也正是`静态工厂方法`的一个优点所在，它可以在方法的内部，对于数据进行包装、处理，并且可以抽象在子类的里面。而我们接收的时候，依然可以采用父类进行接收，这样不仅在降低代码复杂度的同时，同时我们还可以将细节隐藏，伴随着，我们的Doc文档也会整洁很多。

### 优点四：所返回的对象的类可以随着每次调用而发生变化，这都取决于静态工厂方法的参数值

&emsp;&emsp;这个依然可以通过`valueOf`方法进行讲解。在我们的入参是`true`的时候，此时返回的是`Boolean.TRUE`；当我们的入参是`false`的时候，此时返回的是`Boolean.FALSE`。

### 优点五：方法返回的对象所属的类，在编写包含该静态工厂方法的类时可以不存在。

&emsp;&emsp;在这里，可能很多人理解起来都十分的困难。但是如果举个例子，会很好的理解。假如我们程序有个这样的场景。需要保存我们的数据。而数据的保存在不同的阶段可以有不同的保存形式。例如，最开始的时候，我们直接采用`IO`流的形式，将数据保存在文件上。后来随着数据的越来越多和检索的需求，此时我们需要将数据保存在数据库中。在这里，我们发现，我们的程序仅仅只是保存数据的方式不同。但是其他都是相同的。在这里，我们可以把数据保存这个方法抽象出来。而文件形式、数据库形式的不同的实现，可以实现这个抽象的方法就可以了。其实，`优点五`讲的就是这个例子。而书中所讲的`服务提供者框架`也是在说这个问题。

## 缺点

### 缺点一：类如果不含公有的或者受保护的构造器，就不能被子类化。

&emsp;&emsp;通过字面意思，我们就可以知道，对于一个类而言，如果没有公有的或者受保护的构造器，就不能被子类化。

### 缺点二：程序员很难发现他们。

&emsp;&emsp;对于这个很好理解。因为当我们在使用的时候，都是使用的是我们最常使用的`API`。对于这个类的其他的方法，只有在我们需要的时候，或者我们去读`API`的时候，才会发现。

## 总结

&emsp;&emsp;其实，如果只是单纯的读《Effective Java》这本书的话，真的是一头雾水，写的太晦涩了。以`用静态工厂方法代替构造器`这个为例，我们其实真的需要掌握的就是--<span style="color:red;">尽可能的让我们的代码更加的易读，减轻读代码的压力。当一个构造函数有多重含义的时候，此时我们通过静态工厂方法来代替构造器能更好的让别人理解。</span>