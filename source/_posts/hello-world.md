---
title: 对于Lamdba的引入
date: 2019-09-08 04:53:15
categories:
- Java8
tags:
- Lamdba
- Java8
---
# 前言
&emsp;&emsp;文章如有不足之处，敬请指出 。欢迎多多交流。本人看到，会第一时间回复信息的。
# Lamdba表达式的引入
## 前言
&emsp;&emsp;在日常的开发过程中，我们能够唯一确定的就是对于需求总是在不停的变化的。而对于一个好的开发人员而言，我们所能做的，就是尽可能的让我们的代码适应尽可能的需求变化，对于每次需求的改动，尽可能的在减少开发量的同事，保持程序的稳定性和健壮性，以及对于未来的可扩展性性是我们追求的目标。
## 概述
&emsp;&emsp;在这篇文章中，我们并不会讲解`lamdba`表达式的具体用法和高级特性，而是讲解下为什么我们需要使用`lamdba`表达式，和用了`lamdba`表达式对于我们的好处是什么。
## 问题一
&emsp;&emsp;下面我们举个栗子，例如我们给一个果农做一个产品筛选系统，目前，这个果农仅仅只是售卖苹果这一种产品，而对于苹果而言，果农需要对于苹果进行进行不同的区分，苹果的颜色分为绿色、红色等，将所有的红颜色的苹果都筛选出来。
## 解决一
&emsp;&emsp;基于以上的例子，只要是会`Java`开发的人而言，我们可以迅速的进行代码开发，然后交给果农进行验证：
首先我们创建一个`Apple`的类
```java
public class Apple{

    private final String color;

    private final  Double weight;

    private Apple(AppleBuilder appleBuilder){
        this.color = appleBuilder.getColor();
        this.weight = appleBuilder.getWeight();
    }

    public String getColor() {
        return color;
    }

    public Double getWeight() {
        return weight;
    }

    @Override
    public String toString() {
        return "Apple{" +
                "color='" + color + '\'' +
                ", weight=" + weight +
                '}';
    }

    static class AppleBuilder{

        private String color;

        private Double weight;


        public AppleBuilder color(String color){
            this.color = color;
            return this;
        }

        public AppleBuilder weight(Double weight){
            this.weight = weight;
            return this;
        }

        public String getColor() {
            return color;
        }

        public void setColor(String color) {
            this.color = color;
        }

        public Double getWeight() {
            return weight;
        }

        public void setWeight(Double weight) {
            this.weight = weight;
        }

        public Apple build(){
            return new Apple(this);
        }

    }

}
```
&emsp;&emsp;然后如下解决问题：
```java
import org.junit.Before;
import org.junit.Test;

import java.util.Arrays;
import java.util.List;

public class TestOne {

    public static final String APPLE_COLOR_RED_CODE="red";

    private List<Apple> appleList;

    @Before
    public void prepare(){
        appleList=Arrays.asList(new Apple.AppleBuilder().color("red").weight(12.0).build(),new Apple.AppleBuilder().color("green").weight(9.8).build(),new Apple.AppleBuilder().color("red").weight(6.6).build());
    }

    @Test
    public void testOne(){
        for(Apple apple : appleList){
            if(checkApple(apple)){
                System.out.println(apple);
            }
        }
    }

    private boolean checkApple(Apple apple){
        if(APPLE_COLOR_RED_CODE.equals(apple.getColor())){
            return true;
        }
        return false;
    }
}
```
## 问题二
&emsp;&emsp;很好，到目前为止，你已经完成了将系统中所有的红苹果都筛选出来的需求了。当你兴高采烈的将功能提供给果农用的时候，果农突然改变了注意，他不再想要红颜色的苹果了，而是想要绿颜色的苹果。
## 解决二
&emsp;&emsp;此时，你也许会觉得那我直接在代码中定义一个绿色的常量，然后将判断改成判断绿色不就可以了吗？
然后你迅速的将代码改成了如下的方式：
```java
import org.junit.Before;
import org.junit.Test;

import java.util.Arrays;
import java.util.List;

public class TestOne {

    public static final String APPLE_COLOR_RED_CODE="red";

    public static final String APPLE_COLOR_GREEN_CODE="green";



    private List<Apple> appleList;

    @Before
    public void prepare(){
        appleList=Arrays.asList(new Apple.AppleBuilder().color("red").weight(12.0).build(),new Apple.AppleBuilder().color("green").weight(9.8).build(),new Apple.AppleBuilder().color("red").weight(6.6).build());
    }

    @Test
    public void testOne(){
        for(Apple apple : appleList){
            if(checkApple(apple)){
                System.out.println(apple);
            }
        }
    }

    private boolean checkApple(Apple apple){
        if(APPLE_COLOR_GREEN_CODE.equals(apple.getColor())){
            return true;
        }
        return false;
    }

}
```
&emsp;&emsp;当你写完这样的代码，你们的技术经理肯定会有这样的疑问？那如果果农突然又想要筛选红色的苹果呢？你难道再改回来吗？
带着这样的疑问，你开始了代码的第一版优化：
```java
public class TestOne {

    public static final String APPLE_COLOR_RED_CODE="red";

    public static final String APPLE_COLOR_GREEN_CODE="green";



    private List<Apple> appleList;

    @Before
    public void prepare(){
        appleList=Arrays.asList(new Apple.AppleBuilder().color("red").weight(12.0).build(),new Apple.AppleBuilder().color("green").weight(9.8).build(),new Apple.AppleBuilder().color("red").weight(6.6).build());
    }

    @Test
    public void testOne(){
        for(Apple apple : appleList){
            if(checkAppleRed(apple)){
                System.out.println(apple);
            }
        }
    }

    private boolean checkAppleRed(Apple apple){
        if(APPLE_COLOR_RED_CODE.equals(apple.getColor())){
            return true;
        }
        return false;
    }

    private boolean checkAppleGreen(Apple apple){
        if(APPLE_COLOR_GREEN_CODE.equals(apple.getColor())){
            return true;
        }
        return false;
    }

}
```
&emsp;&emsp;此情此景，你觉得你可以满足用户的需求，当用户想要从查询红色苹果到绿色苹果，我们只需要替换一下调用的方法而已：可是，这真的最好的方法吗？我们写代码的根本目的在于让程序更加的通用，能够更加满足需求的变化，那如果以后摘选粉色的、白色的苹果呢？难道还需要添加一个新的方法吗？这样只能会让你的方法、你的代码越来越不受控制。拿到我们就没有更好的办法来解决这个问题了吗？
&emsp;&emsp;此时，你可能回想，我可以把颜色这个作为一个参数传递进去，从而达到优化代码的作用：
&emsp;&emsp;代码的第二版优化：
```java
public class TestOne {

    public static final String APPLE_COLOR_RED_CODE="red";

    public static final String APPLE_COLOR_GREEN_CODE="green";



    private List<Apple> appleList;

    @Before
    public void prepare(){
        appleList= Arrays.asList(new Apple.AppleBuilder().color("red").weight(12.0).build(),new Apple.AppleBuilder().color("green").weight(9.8).build(),new Apple.AppleBuilder().color("red").weight(6.6).build());
    }

    @Test
    public void testOne(){
        for(Apple apple : appleList){
            if(checkApple(apple,APPLE_COLOR_RED_CODE)){
                System.out.println(apple);
            }
        }
    }

    private boolean checkApple(Apple apple,String appleColor){
        if(appleColor.equals(apple.getColor())){
            return true;
        }
        return false;
    }
```
&emsp;&emsp;ok，此时你认为终于找到了这个问题的通用方法。终于找到了最优解。no,you are wrong.此时果农又有了新的需求，他需要查找出红色的苹果，并且重量大于150g的苹果。显然，你目前的代码是肯定不支持的。如果你想要将重量也传进去，那无疑会对现在已有的代码起到了冲击(需要对于已经调用的地方都添加重量参数)，并且也会让你的方法的参数也来越多。这显然不是一个很好的解决办法。
&emsp;&emsp;因此，在这里，我们借鉴下设计模式中的"策略者模式"进行对代码第三版优化：
&emsp;&emsp;我们通过上面的分析可以发现，真正变化的，其实是`private boolean checkApple(Apple apple)`这个方法，第一版优化，也仅仅只是在对于这个函数实现了不同的扩展而已。那么我们可以将这个方法抽象成一个接口--`算法族`，等到以后我们采用不同的筛选条件的时候，也只需要去实现这个接口，实现当前这个接口的方法而已--`策略`。
&emsp;&emsp;首先，我们定义一个接口：
```java
public interface AppleCheckInterface {
    public static final String APPLE_COLOR_RED_CODE="red";

    public static final String APPLE_COLOR_GREEN_CODE="green";
    
    boolean checkApple(Apple apple);
}
```
&emsp;&emsp;在这个接口中，我们将对于苹果的筛选抽取出一个接口，然后我们对于红苹果、绿苹果的筛选，试下两个不同的实现类：
&emsp;&emsp;第一个是筛选红苹果：
```java
public class CheckRedApple implements AppleCheckInterface {
    @Override
    public boolean checkApple(Apple apple) {
       if(APPLE_COLOR_RED_CODE.equalsIgnoreCase(apple.getColor())){
           return true;
       }
       return false;
    }
}
```
&emsp;&emsp;第二个是筛选绿苹果：
```java
public class CheckGreenApple implements  AppleCheckInterface {
    @Override
    public boolean checkApple(Apple apple) {
        if(APPLE_COLOR_GREEN_CODE.equalsIgnoreCase(apple.getColor())){
            return true;
        }
        return false;
    }
}
```
&emsp;&emsp;此时我们的筛选调用代码改为：
```java
public class TestOne {

    private List<Apple> appleList;

    @Before
    public void prepare(){
        appleList= Arrays.asList(new Apple.AppleBuilder().color("red").weight(12.0).build(),new Apple.AppleBuilder().color("green").weight(9.8).build(),new Apple.AppleBuilder().color("red").weight(6.6).build());
    }

    @Test
    public void testOne(){
        for(Apple apple : appleList){
            if(checkApple(apple,new CheckRedApple())){
                System.out.println(apple);
            }
        }
    }

    private boolean checkApple(Apple apple, AppleCheckInterface appleCheckInterface){
        if(appleCheckInterface.checkApple(apple)){
            return true;
        }
        return false;
    }
}
```
&emsp;&emsp;此时，我们发现这种方式比之前的方式优美了很多，等到以后我来了一个新的筛选条件的时候，我也仅仅只是需要实现一个`AppleCheckInterface`接口，然后在调用的时候，传入适合的对象即可。同时，和上面不同的是，我们无需改动其他的类。减少了回归测试的成本。但是这种方式还是有一个问题，那就是每次实现一个筛选条件，就需要创建一个新的`AppleCheckInterface`接口的实现类。等待筛选条件特别多的时候，会出现实现类也超级多，不方便管理的情况。对于这种情况，我们可以采用JDK提供的另外一种方法--匿名内部类来实现，下面是第四版代码优化：
```java
public class TestOne {

    private List<Apple> appleList;

    @Before
    public void prepare(){
        appleList= Arrays.asList(new Apple.AppleBuilder().color("red").weight(12.0).build(),new Apple.AppleBuilder().color("green").weight(9.8).build(),new Apple.AppleBuilder().color("red").weight(6.6).build());
    }

    @Test
    public void testOne(){
        for(Apple apple : appleList){
            if(checkApple(apple, new AppleCheckInterface() {
                @Override
                public boolean checkApple(Apple apple) {
                    if(APPLE_COLOR_RED_CODE.equals(apple.getColor())){
                        return true;
                    }
                    return false;
                }
            })){
                System.out.println(apple);
            }
        }
    }

    private boolean checkApple(Apple apple, AppleCheckInterface appleCheckInterface){
        if(appleCheckInterface.checkApple(apple)){
            return true;
        }
        return false;
    }
}

```
&emsp;&emsp;在这里，我们采用匿名内部类的方式，来替代了我们`AppleCheckInterface`接口的实现类，但是匿名内部类有个致命的缺陷，就是十分不利于代码的阅读。当前是因为程序的简单，可能你还能读得懂这个匿名内部类的意思，一旦这个接口是一个超级复杂的接口，直接回导致你崩溃掉。那就没有更好的方式来实现了吗？
&emsp;&emsp;在上面我们分析到，其实真正有用的代码就是你的那个判断而已，其他都是为了让这句话的语法通顺和符合JDK的标准而写的样板代码而已。那么我们可不可以有这样的一个函数，将这个判断像是参数一样传递进去，然后直接返回我们想要的结果呢？
&emsp;&emsp;不用担心，在`JDK1.8`中已经支持了你的这个想法，那就是--`“行为参数化”`。
&emsp;&emsp;下面我们直接使用`JDK1.8`中的`Stream`流和`lamdba`来实现这个需求，至于这两个功能，会在后面的文章中进行介绍，此处仅仅只是体验先JDK1.8的`Stream`流和`lamdba`表达式给我们带来的便捷：
&emsp;&emsp;首先，我们先定义一个接口：
```java
public interface Predicate<T> {

    boolean test(T t);

    static <T> boolean check(T t,Predicate<T> p){
        if(p.test(t)){
            return true;
        }
        return false;
    }

}
```
&emsp;&emsp;然后看调用方法：
```java
public class TestOne {

    public static final String APPLE_COLOR_RED_CODE="red";

    public static final String APPLE_COLOR_GREEN_CODE="green";

    private List<Apple> appleList;

    @Before
    public void prepare(){
        appleList= Arrays.asList(new Apple.AppleBuilder().color("red").weight(12.0).build(),new Apple.AppleBuilder().color("green").weight(9.8).build(),new Apple.AppleBuilder().color("red").weight(6.6).build());
    }

    @Test
    public void testOne(){
        for(Apple apple : appleList){
            if(Predicate.check(apple,a -> APPLE_COLOR_RED_CODE.equals(a.getColor()))){
                System.out.println(apple);
            }
        }
    }
}
```
&emsp;&emsp;此时我们看到，原来啰嗦的第一版、第二版、第三版、第四版代码直接由现在的一行代码搞定。这个就是`JDK1.8`中`Stream`流和`lamdba`表达式给我们带来的便捷与优越。
&emsp;&emsp;在这里，不用去考虑程序的效率问题，后期会有一片单独的文章来讲解`lamdba`的性能问题。