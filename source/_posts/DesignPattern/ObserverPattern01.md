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

![程序运行结果](https://oss.shengouqiang.cn/img/DesignPattern/ObserverPattern01/01.jpg)

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

![程序运行结果](https://oss.shengouqiang.cn/img/DesignPattern/ObserverPattern01/02.jpg)

&emsp;&emsp;至此，我们已经实现了将警察的个数与小偷逮捕的过程进行了解构。在小偷逮捕的过程中，我们可以随意的修改警察的个数，而不是修改`Thief`的代码了

## 优化二：只有警察追捕小偷吗？还是警察只抓捕小偷

&emsp;&emsp;通过上面的问题，我们知道了，在上面的代码中，我们知道了警察可以追捕小偷，但是如果此时街道命令的是刑警，而不是普通警察呢？如果此时追捕的不是小偷，而是抢劫银行的大盗呢？我们总不能再去写一份十分相似的代码吧？在这里，我们用到了设计模式中的另一个原则`依赖倒转原则`。因此，我们需要做的是将小偷的偷窃和警察的抓捕都封装成对应的接口，如果以后来了刑警或者是大盗，我们只需要实现这个接口就行了。

&emsp;&emsp;在这里，我们把小偷、大盗提取出来一个接口：

```java
public interface TheftAndRobberyInterface {

    /**
     * 添加通知者
     * @param arrestInterface
     */
    void addNotifyPerson(ArrestInterface arrestInterface);

    /**
     * 减少通知者
     * @param arrestInterface
     */
    void delNotifyPerson(ArrestInterface arrestInterface);

    /**
     * 盗窃过程
     */
    void theftAndRobbery();

    /**
     * 获取名字
     * @return
     */
    String getName();
}
```

&emsp;&emsp;在这里，我们把警察、刑警提取出来一个接口：

```java
public interface ArrestInterface {

    /**
     * 抓捕接口
     * @param t
     */
    void arrest(TheftAndRobberyInterface t);
}
```

&emsp;&emsp;此时我们重写警察和小偷的实现类：

&emsp;&emsp;小偷实现类：

```java
public class ThiefOne implements TheftAndRobberyInterface {

    private String thiefName;

    private List<ArrestInterface> arrestInterfaceList ;


    public ThiefOne(String name){
        this.thiefName=name;
        this.arrestInterfaceList = new ArrayList<>();
    }

    @Override
    public void addNotifyPerson(ArrestInterface arrestInterface) {
        if(null  == arrestInterface){
            return;
        }
        this.arrestInterfaceList.add(arrestInterface);
    }

    @Override
    public void delNotifyPerson(ArrestInterface arrestInterface) {
        this.arrestInterfaceList.remove(arrestInterface);
    }

    @Override
    public void theftAndRobbery() {
        this.arrestInterfaceList.forEach(arrestInterface -> arrestInterface.arrest(this));
    }

    @Override
    public String getName() {
        return this.thiefName;
    }
}
```

&emsp;&emsp;警察实现类：

```java
public class PoliceOne implements ArrestInterface {
    @Override
    public void arrest(TheftAndRobberyInterface t) {
        System.out.println(t.getName() + " 双手举起，你被逮捕了");
    }
}
```

&emsp;&emsp;客户端实现类：

```java
 @Test
    public  void testThree(){
        TheftAndRobberyInterface t = new ThiefOne("偷心贼");
        t.addNotifyPerson(new PoliceOne());
        t.addNotifyPerson(new PoliceOne());
        t.addNotifyPerson(new PoliceOne());
        t.addNotifyPerson(new PoliceOne());
        t.addNotifyPerson(new PoliceOne());
        t.theftAndRobbery();
    }
```

&emsp;&emsp;程序运行截图：

![程序运行结果](https://oss.shengouqiang.cn/img/DesignPattern/ObserverPattern01/03.jpg)

&emsp;&emsp;至此，我们发现，无论是小偷，还是警察，他们在内部依赖的都是借口。而不是具体的实现类。当我们有刑警追捕大盗的时候，我们仅仅只是需要新写两个具体的类，分别实现`TheftAndRobberyInterface`和`ArrestInterface`接口即可。无须改动其他的内容。同时，客户让我们的代码更加的灵活，例如：如果警察有事，需要刑警代替警察追捕小偷呢？我们只需要改动，客户端的代码即可。这样在满足了`开放-封闭原则`的同时，我们也满足了`依赖倒转原则`。

## 观察者模式适合的场景

### 观察者模式定义

&emsp;&emsp;观察者模式定义了一种一对多的依赖关系，让多个观察者对象同时监听某一个主题对象。这个主题对象在状态发生变化是，会通知所有观察者对象，使他们能够自动更新自己。

### 观察者模式的特定

&emsp;&emsp;一般情况下，我们想要将一个系统分割成一系列相互协作的类有个很不好的副作用。那就是对象间的一致性问题。我们不希望通过将类分解，导致我们的代码过度的耦合，而是希望他们能够通过`发布-订阅`的方式，让代码进行解耦。从事达到当一个对象更新的时候，只需要发出通知，这样其他的对象可以自动更新，保持一致性。在这样的情况下，我们可以采用观察者模式。

&emsp;&emsp;总的来说，观察者模式就是为了实现程序间的解耦进行操作的。让程序彼此之间依赖于抽象，而不是依赖于具体。同样的，当我们并不知道有多少观察者的时候，其实是用观察者最好的方式。

### 观察者模式的不足

&emsp;&emsp;通过上面的代码，我们发现，在观察者模式中，我们需要将观察者共同实现一个接口，然后每次通知观察者，都是调用这个接口。其实，这样是降低了程序的可读性的。因为对于小偷而言，他可能仅仅是指偷偷摸摸，而对于江洋大盗而言，他们可能抢劫银行等。如果用用一个名字作为方法的名称，不便于代码后续的维护。那么有没有什么好的方法呢？其实，这里是有的。只不过要在后续中进行讲解。
