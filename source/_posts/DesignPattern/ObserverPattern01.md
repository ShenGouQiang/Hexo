---
title: 设计模式--观察者模式
permalink: DesignPattern/ObserverPattern01
date: 2019-09-28 12:23:42
categories:
- 设计模式
tags:
- 设计模式
---

# 设计模式--观察者模式

&emsp;&emsp;在设计模式中，有一类模式是我们经常提到的，或者在观看源代码的时候，也经常能够遇到的。那就是--`观察者模式`。观察者模式是一种常用的设计模式。

## 什么是观察者模式

&emsp;&emsp;既然观察者模式是常用设计模式中的一种，那么什么是观察者模式呢？在这里，我们举个栗子：

&emsp;&emsp;观察者模式其实十分的简单。说白了就是`发布-订阅`的模式，如果你不知道什么是`发布-订阅`的模式化，那么我们可以采取`通知-收到`的模式进行讲解。

&emsp;&emsp;例如，有一天，警察收到通知，说在XX店铺经常发生盗窃的行为，警察为了抓住小偷，会经常穿着便衣到店铺进行潜伏。某一天，当小偷进来后，开始逛商场而没有发现发现警察的存在。当小偷开始进行盗窃后，此时警察关注了小偷偷窃的行为，会立即上前逮捕小偷。在这里，就是一个典型的`观察者`模式。当小偷开始偷东西后，此时警察因为关注着小偷，发现小偷的举动，来进行逮捕。在这里，我们可以理解为：小偷偷东西这个动作，可以是通知警察可以逮捕的一个行为、命令，当警察接收到这个命令后，此时会对小偷进行逮捕。接下来，我们将这段偷盗，逮捕的行为，写成一段代码：

## 普通的偷盗、逮捕代码

&emsp;&emsp;小偷的代码：

```java
public class Thief {

    private Police police1 = new Police();

    private Police police2 = new Police();

    private String name="thief";

    public Thief(){

    }

    public  Thief(String name){
        this.name=name;
    }

    /**
     * 偷东西后被警察发现
     */
    public void nodifyPolice(){
        police1.arrestThief(this);
        police2.arrestThief(this);
    }

    public String getName() {
        return name;
    }
}
```

&emsp;&emsp;警察的代码：

```java
public class Police {

    /**
     * 逮捕小偷
     * @return
     */
    public void arrestThief(Thief thief){
        System.out.println(thief.getName() + " 双手举起，你被逮捕了");
    }

    @Override
    public int hashCode() {
        return super.hashCode();
    }

    @Override
    public boolean equals(Object obj) {
        return super.equals(obj);
    }
}
```

&emsp;&emsp;客户端类：

```java
public class Client {

    public static void main(String[] args) {
        Thief thief = new Thief("偷心贼");
        thief.nodifyPolice();
    }
}
```

&emsp;&emsp;程序运行截图：

![程序运行结果](/blog/img/DesignPattern/ObserverPattern01/01.jpg)

## 优化一：提炼出警察个数问题

&emsp;&emsp;ok，到此，我们发现我们的代码目前处于仅仅只能跑通的成分。但是对于我们程序员而言，我们追求的是代码的完善和代码的通读性。我们发现，上面的代码中，对于小偷而言，他并不知道当他要被逮捕的时候，到底有多少个警察？难道以后每次增加一个警察就要改动这个类，新增一个对象吗？这明显不符合设计模式中的`开放-封闭原则`这么做显然是有问题的：因此，我们需要对我们的代码进行改动。

&emsp;&emsp;小偷的代码：

```java
public class Thief {

    private List<Police>  policeList;

    private String name="thief";

    public Thief(){
        policeList = new ArrayList<>();
    }

    public  Thief(String name){
        this();
        this.name=name;

    }

    /**
     * 增加警察
     * @param police
     */
    public void addPolice(Police police){
        if(null == police){
            return;
        }
        policeList.add(police);
    }

    /**
     * 删除警察
     * @param police
     */
    public void delPolice(Police police){
        policeList.remove(police);
    }

    /**
     * 偷东西后被警察发现
     */
    public void nodifyPolice(){
        policeList.forEach(police -> police.arrestThief(this));
    }

    public String getName() {
        return name;
    }
}
```

&emsp;&emsp;客户端的代码：

```java
public class Client {

    public static void main(String[] args) {
        Thief thief = new Thief("偷心贼");
       thief.addPolice(new Police());
       thief.addPolice(new Police());
       thief.addPolice(new Police());
       thief.addPolice(new Police());
       thief.addPolice(new Police());
       thief.nodifyPolice();
    }
}
```

&emsp;&emsp;程序运行截图：

![程序运行结果](/blog/img/DesignPattern/ObserverPattern01/02.jpg)

&emsp;&emsp;至此，我们已经实现了将警察的个数与小偷逮捕的过程进行了解构。在小偷逮捕的过程中，我们可以随意的修改警察的个数，而不是修改`Thief`的代码了

## 优化问题二：只有警察追捕小偷吗？还是警察只抓捕小偷

&emsp;&emsp;通过上面的问题，我们知道了，在上面的代码中，我们知道了警察可以追捕小偷，但是如果此时街道命令的是刑警，而不是普通警察呢？如果此时追捕的不是小偷，而是抢劫银行的大盗呢？我们总不能再去写一份十分相似的代码吧？在这里，我们用到了设计模式中的另一个原则`依赖倒转原则`。因此，我们需要做的是将小偷的偷窃和警察的抓捕都封装成对应的接口，如果以后来了刑警或者是大盗，我们只需要实现这个接口就行了。

&emsp;&emsp;在这里，我们把小偷、大盗出现出来一个接口：
