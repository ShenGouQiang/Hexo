---
title: 设计模式-策略模式
permalink: DesignPattern/StrategyPattern01/
date: 2020-03-27 21:06:47
categories:
- 设计模式
tags:
- 设计模式
---

# 设计模式-策略模式

在本文，我们要讲解下策略模式的学习。在百度百科中，对于策略是这样定义的：

> 策略模式作为一种[软件设计模式](https://baike.baidu.com/item/软件设计模式)，指对象有某个行为，但是在不同的场景中，该行为有不同的实现算法。

其实，在实际的生活中，我们可以在很多的地方用到策略模式。我们可以举一些例子：

1. 假如你的公司在中国和美国都有子公司，中国子公司招中国员工，美国子公司招收美国员工。每个员工都需要缴纳“个税”。因此，对于美国和中国的个税的计算，我们就可以采用策略模式进行设计。
2. 假如你有一个超市，这个超市会在不同的节假日进行不同的打折促销活动。例如：在国庆期间可以有满100减20的活动，在劳动节，可以实现打七折的活动，这种情况下，也可以采用策略模式。

你也许会问，我不用策略模式依然可以实现啊。我可以在我的代码中多几个`if else`就搞定了，或者对于相应的代码，我可以将原来的代码删除，将新的业务逻辑写进去。

这么做不是不行，在这里，我们要知道，设计模式的目的，不是在于如果我们不这么做，就不能实现我们的业务。而是在于如果我们这么做，我们可以将我们的系统设计的更好，可以达到更好的健壮性和扩展性，对于后期人员的代码维护和业务扩展，不至于那么的痛苦。说白了，设计模式本就是一个“锦上添花”的东西。但是仅仅就是这个“锦上添花”，可以让我们更加的丰富我们的系统。

接下来，就是一个代码展示的部分了。当时我在考虑用什么样的例子的时候，直接看到了`JDK`的`java.util.Comparator`接口，得到的灵感。

首先说明：本文为了展示什么是设计模式，没有采用`lamdba`表达式进行代码优化，而是采用`new`对象的方式进行实现的。在实际的使用中，我们可以采用`lamdba`表达式进行实现。

下面，我们希望可以通过不同的比较规则，来对于`Cat`进行排序。

## Cat的Domain实现

```java
package designpatterns.strategy.domain;

import lombok.AllArgsConstructor;
        import lombok.Data;
        import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Cat {
    private String name;
    private Double weight;
    private Integer age;
    private Sex sex;
}
```



## 自义定的函数式比较接口

```java
package designpatterns.strategy.compare;

@FunctionalInterface
public interface StrategyComparator<T> {
    int compare(T t1,T t2);
}
```

```java
package designpatterns.strategy.domain;

import lombok.Getter;

@Getter
public enum Sex {

    /**
     * 雄性
     */
    MALE("1","雄性"),
    /**
     * 雌性
     */
    FEMALE("2","雌性");

    private String code;

    private String desc;

    Sex(String code,String desc){
        this.code=code;
        this.desc=desc;
    }
}
```



在这里，我们定义了一个函数式接口，这个接口支持泛型，仅有一个抽象函数，目的在于比较两个变量的大小。并且，我们规定，如果` t1`小于`t2`，返回`-1`，`t1`等于`t2`，返回`0`，`t1`大于`t2`，返回`1`。

接下来，我们采用`选择排序`的方式进行排序

### 选择排序的实现

```java
package designpatterns.strategy.sort;

import designpatterns.strategy.compare.StrategyComparator;

@FunctionalInterface
public interface Sort<T> {

    void sort(T[] arrray,StrategyComparator<T> comparator);
}

```

```java
package designpatterns.strategy.sort.impl;

import designpatterns.strategy.compare.StrategyComparator;
import designpatterns.strategy.sort.Sort;

public class SelectSort<T> implements Sort<T> {
    @Override
    public void sort(T[] arrray, StrategyComparator<T> comparator) {
        for (int i = 0; i < arrray.length - 1; i++) {
            int minPos = i;
            for (int j = i + 1; j < arrray.length; j++) {
                minPos = comparator.compare(arrray[j], arrray[minPos]) == -1 ? j : minPos;
            }
            swap(arrray, i, minPos);
        }
    }

    private void swap(T[] array, int i, int j) {
        T tmp = array[i];
        array[i] = array[j];
        array[j] = tmp;
    }
}
```

这里不多说，就是一个简单的选择排序实现。

接下来，是重头戏，首先，我们先通过年龄对`Cat`进行排序。

## 通过`Age` 对`Cat`进行排序

```JAVA
package designpatterns.strategy.compare.impl;

import designpatterns.strategy.compare.StrategyComparator;
import designpatterns.strategy.domain.Cat;

public class CatComparatorByAge implements StrategyComparator<Cat> {
    @Override
    public int compare(Cat t1, Cat t2) {
        return t1.getAge() < t2.getAge() ? -1 :  t1.getAge()  > t2.getAge()  ?  1 : 0;
    }
}
```

然后我们看下测试类：

```java
package designpatterns.strategy.test;

import designpatterns.strategy.compare.impl.CatComparatorByAge;
import designpatterns.strategy.compare.impl.CatComparatorByWeight;
import designpatterns.strategy.domain.Cat;
import designpatterns.strategy.domain.Sex;
import designpatterns.strategy.sort.Sort;
import designpatterns.strategy.sort.impl.SelectSort;
import org.junit.Test;

public class StrategyTest {

    @Test
    public void catSort() {
        Cat[] catArray = {
                new Cat("zhao", 18.0D, 10, Sex.MALE),
                new Cat("zhao", 12.0D, 2, Sex.MALE),
                new Cat("zhao", 28.0D, 1, Sex.MALE),
                new Cat("zhao", 8.0D, 8, Sex.MALE),
                new Cat("zhao", 38.0D, 9, Sex.MALE),
                new Cat("zhao", 5.0D, 5, Sex.MALE),
                new Cat("zhao", 2.1D, 3, Sex.MALE),
                new Cat("zhao", 6.6D, 4, Sex.MALE),
                new Cat("zhao", 48.0D, 15, Sex.MALE),
                new Cat("zhao", 0.1D, 7, Sex.MALE)
        };
        Sort<Cat> sort = new SelectSort<>();
        sort.sort(catArray, new CatComparatorByAge());
        //sort.sort(catArray,new CatComparatorByWeight());
        for (Cat cat : catArray) {
            System.out.println(cat);
        }
    }
}
```

实验结果为:

```
Cat(name=zhao, weight=28.0, age=1, sex=MALE)
Cat(name=zhao, weight=12.0, age=2, sex=MALE)
Cat(name=zhao, weight=2.1, age=3, sex=MALE)
Cat(name=zhao, weight=6.6, age=4, sex=MALE)
Cat(name=zhao, weight=5.0, age=5, sex=MALE)
Cat(name=zhao, weight=0.1, age=7, sex=MALE)
Cat(name=zhao, weight=8.0, age=8, sex=MALE)
Cat(name=zhao, weight=38.0, age=9, sex=MALE)
Cat(name=zhao, weight=18.0, age=10, sex=MALE)
Cat(name=zhao, weight=48.0, age=15, sex=MALE)
```

## 通过`Weight`对`Cat`进行排序

```java
package designpatterns.strategy.compare.impl;

import designpatterns.strategy.compare.StrategyComparator;
import designpatterns.strategy.domain.Cat;

public class CatComparatorByWeight implements StrategyComparator<Cat> {
    @Override
    public int compare(Cat t1, Cat t2) {
        return t1.getWeight() < t2.getWeight() ? -1 :  t1.getWeight()  > t2.getWeight()  ?  1 : 0;
    }
}
```

然后我们看下测试类：

```java
package designpatterns.strategy.test;

import designpatterns.strategy.compare.impl.CatComparatorByAge;
import designpatterns.strategy.compare.impl.CatComparatorByWeight;
import designpatterns.strategy.domain.Cat;
import designpatterns.strategy.domain.Sex;
import designpatterns.strategy.sort.Sort;
import designpatterns.strategy.sort.impl.SelectSort;
import org.junit.Test;

public class StrategyTest {

    @Test
    public void catSort() {
        Cat[] catArray = {
                new Cat("zhao", 18.0D, 10, Sex.MALE),
                new Cat("zhao", 12.0D, 2, Sex.MALE),
                new Cat("zhao", 28.0D, 1, Sex.MALE),
                new Cat("zhao", 8.0D, 8, Sex.MALE),
                new Cat("zhao", 38.0D, 9, Sex.MALE),
                new Cat("zhao", 5.0D, 5, Sex.MALE),
                new Cat("zhao", 2.1D, 3, Sex.MALE),
                new Cat("zhao", 6.6D, 4, Sex.MALE),
                new Cat("zhao", 48.0D, 15, Sex.MALE),
                new Cat("zhao", 0.1D, 7, Sex.MALE)
        };
        Sort<Cat> sort = new SelectSort<>();
        //sort.sort(catArray, new CatComparatorByAge());
        sort.sort(catArray,new CatComparatorByWeight());
        for (Cat cat : catArray) {
            System.out.println(cat);
        }
    }
}
```

实验结果为:

```
Cat(name=zhao, weight=0.1, age=7, sex=MALE)
Cat(name=zhao, weight=2.1, age=3, sex=MALE)
Cat(name=zhao, weight=5.0, age=5, sex=MALE)
Cat(name=zhao, weight=6.6, age=4, sex=MALE)
Cat(name=zhao, weight=8.0, age=8, sex=MALE)
Cat(name=zhao, weight=12.0, age=2, sex=MALE)
Cat(name=zhao, weight=18.0, age=10, sex=MALE)
Cat(name=zhao, weight=28.0, age=1, sex=MALE)
Cat(name=zhao, weight=38.0, age=9, sex=MALE)
Cat(name=zhao, weight=48.0, age=15, sex=MALE)
```

# 总结

最后，我们总结下，对于策略模式而言，我们可以通过策略模式，在不改变原有代码的情况下<span style="color:red;">(这里的原有代码指的是非客户端代码)</span>。我们可以通过继承接口的方式，来实现一个新的模式。从而达到`开闭原则`。并且，以后不管有多少种策略，我们只需要不停的实现这个新的接口，来新写一个策略具体实现即可。大致上的一个调用关系如下：

![UML类图之接口描述](https://shengouqiang.cn/img/DesignPattern/StrategyPattern01/StrategyCallingRelationship.jpg)