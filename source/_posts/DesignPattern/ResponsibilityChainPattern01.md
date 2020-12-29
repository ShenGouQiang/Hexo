---
title: 设计模式–责任链模式
permalink: DesignPattern/ResponsibilityChainPattern01/
date: 2019-10-27 18:06:22
categories:
- 设计模式
tags:
- 设计模式
---

# 设计模式--责任链模式

&emsp;&emsp;在工作当中，或多或少都会有一些报销上面的问题，经常情况下，我们的报销流程是“经理-->总经理-->总监”这样的一个流程。如果采用`Java`代码的话，不考虑任何的设计模式的话，此时我们的代码会很长，并且在`Java`代码中，我们会采用很多的`if-else`的方式，或者是`switch`的方式，但是这样的代码，扩展性不高，每次有新的审批流的时候，都需要改动原来的代码，此时非常的不便于程序的维护。因此，面对这样的场景，我们可以采用设计模式中的“责任链”模式进行开发，便于程序的后续维护和扩展。

&emsp;&emsp;并且在`Spring`中，也大量的采用了责任链的模式，例如它的`Filter`和`Interceptor`。在这样的情况下，为了后续研究`Spring`源码的方便，我们也需要研究一下什么是“责任链模式”。

## 定义

&emsp;&emsp;使多个对象都有机会处理请求。从而避免请求的发送者和接收者之间的耦合关系。将这个对象连成一条链，并沿着这条链传递该请求，直到有一个对象处理它为止。

## 使用设计模式之前

&emsp;&emsp;使用设计模式之前，我们也可以使用`Java`代码达到上面的要求。

&emsp;&emsp;举例：例如，公司有规定，对于每次报销，如果是低于500元的，直接经理就可以报销，如果是超过500元，小于1000元的，需要总经理进行报销，对于超过1000元的，需要总监才可以报销。因此，对于这样的规则，我们可以采用下面的代码进行判断：

&emsp;&emsp;此时审批类代码如下：

```java
public class AuditService {

    public void handle(double money) {
        if (money <= 0) {
            System.out.println("金额异常，无须报销，结束流程");
            return;
        }
        if (money < 500.0D) {
            System.out.println("经理审批通过，报销金额为：" + money);
        } else if (money < 1000.0D) {
            System.out.println("总经理审批通过，报销金额为：" + money);
        } else {
            System.out.println("总监审批通过，报销金额为：" + money);
        }
    }
}
```

&emsp;&emsp;此时客户端的代码如下：

```java
public class Client {

    public static void main(String[] args) {
        AuditService auditService = new AuditService();
        double money1 = 100.0D;
        auditService.handle(money1);
        double money2 = 600.0D;
        auditService.handle(money2);
        double money3 = 2000.0D;
        auditService.handle(money3);
    }
}
```

&emsp;&emsp;此时程序的运行结果如下：

```
经理审批通过，报销金额为：100.0
总经理审批通过，报销金额为：600.0
总监审批通过，报销金额为：2000.0
```

&emsp;&emsp;咋一看，这样的代码没有什么问题，依然可以满足业务上的需要，同时也没有任何的BUG问题。但是这样的代码的可扩展性特别的差，因为如果以后规则的改变，我们需要去修改上面的`handle`方法，违反了设计模式的`开放-封闭`的原则，同时，因为修改原有的代码，导致程序的测试覆盖率也会上升。并且面临着每修改一次，之前的业务功能也要覆盖一次的问题。那么有没有好的方法，能够实现上面的业务逻辑呢？答案是有的。

## 使用设计模式之后

&emsp;&emsp;还是上面的业务需求，此时我们采用`责任链模式`进行开发，你就会发现，在满足业务需求的同时，我们可以让我们的代码更加的简洁、易懂、优雅。

&emsp;&emsp;首先，我们观察上面的`AuditService`方法，在这个方法中，其实承担了`经理`、`总经理`、`总监`的职责，其实这样是严重的违反了设计模式中的`单一原则`的。因此，我们完全可以抽象出三个类，来代表`经理`、`总经理`、`总监`。同时，我们会发现，在这三个类中，都有了对于金额的处理，如果不在自己处理的范围内，将请求扔给下一个人，如果自己有处理请求的能力，则直接中断请求链，返回即可。
&emsp;&emsp;因此，我们首先可以抽象出来一个接口，这个接口中有两个抽象的方法，一个是处理当前的请求，一个是指定下一个处理人是谁即可。

&emsp;&emsp;此时接口代码如下：

```java
public interface Manager {

    void handle(double money);

    void superior(Manager manager);
}
```

&emsp;&emsp;此时经理实现类如下：

```java
public class ProjectManager implements  Manager {

    private Manager superiorManager;

    @Override
    public void handle(double money) {
        if(money < 500.0D){
            System.out.println("经理审批通过，报销金额为：" + money);
            return;
        }
        if(this.superiorManager != null){
            this.superiorManager.handle(money);
        }
    }

    @Override
    public void superior(Manager manager) {
        if(null != manager){
            this.superiorManager = manager;
        }
    }
}
```

&emsp;&emsp;此时总经理实现类如下：

```java
public class TotalManager implements Manager {

    private Manager superiorManager;

    @Override
    public void handle(double money) {
        if(money < 1000.0D){
            System.out.println("总经理审批通过，报销金额为：" + money);
            return;
        }
        if(this.superiorManager != null){
            this.superiorManager.handle(money);
        }
    }

    @Override
    public void superior(Manager manager) {
        if(null != manager){
            this.superiorManager = manager;
        }
    }
}
```

&emsp;&emsp;此时总监实现类如下：

```java
public class GeneralManager implements Manager {

    private Manager superiorManager;

    @Override
    public void handle(double money) {
        if(money >= 1000.0D){
            System.out.println("经理审批通过，报销金额为：" + money);
            return;
        }
        if(this.superiorManager != null){
            this.superiorManager.handle(money);
        }
    }

    @Override
    public void superior(Manager manager) {
        if(null != manager){
            this.superiorManager = manager;
        }
    }
}
```

&emsp;&emsp;此时客户端类如下：

```java
public class Client {

    public static void main(String[] args) {
       Manager projectManager  = new ProjectManager();
       Manager totalManager = new TotalManager();
       Manager generalManager = new GeneralManager();
       projectManager.superior(totalManager);
       totalManager.superior(generalManager);
       projectManager.handle(100.0D);
       projectManager.handle(600.0D);
       projectManager.handle(2000.0D);
    }
}
```

&emsp;&emsp;运行结果如下：

```
经理审批通过，报销金额为：100.0
总经理审批通过，报销金额为：600.0
经理审批通过，报销金额为：2000.0
```

&emsp;&emsp;此时我们发现，当我们要新增一个审批节点的时候，其实，我们只需要新建一个类，实现`Manager`接口，然后，修改一下客户端`Client`的调用方法即可。此时，实现了程序良好的扩展性。

## 继续优化

&emsp;&emsp;在上面的代码中，我们发现，其实在`经理`、`总经理`、`总监`的实体类中，存在了大量的重复代码，因此，我们可以在接口与实体类之间，添加一层实现类，从而实现代码复用的效果。

&emsp;&emsp;抽象虚类--`CommonManager`

```java
public abstract class CommonManager implements Manager {

    private Manager superiorManager;

    public abstract boolean canHandle(double money);

    @Override
    public void handle(double money) {
        if(canHandle(money)){
            return;
        }
        if(this.superiorManager != null){
            this.superiorManager.handle(money);
        }
    }

    @Override
    public void superior(Manager manager){
        if(null != manager){
            this.superiorManager = manager;
        }
    }
}
```

&emsp;&emsp;接下来修改三个实体类：

&emsp;&emsp;经理类

```java
public class ProjectManager  extends CommonManager {
    
    @Override
    public boolean canHandle(double money) {
        if(money < 500.0D){
            System.out.println("经理审批通过，报销金额为：" + money);
            return true;
        }
        return false;
    }
}
```


&emsp;&emsp;总经理类

```java
public class TotalManager extends CommonManager {

    @Override
    public boolean canHandle(double money) {
        if(money < 1000.0D){
            System.out.println("总经理审批通过，报销金额为：" + money);
            return true;
        }
        return false;
    }

}
```

&emsp;&emsp;总监类

```java
public class GeneralManager extends CommonManager {

    @Override
    public boolean canHandle(double money) {
        if(money >= 1000.0D){
            System.out.println("经理审批通过，报销金额为：" + money);
            return true;
        }
        return false;
    }
    
}
```

&emsp;&emsp;客户端的代码不变，测试运行结果如下：

```
经理审批通过，报销金额为：100.0
总经理审批通过，报销金额为：600.0
经理审批通过，报销金额为：2000.0
```

&emsp;&emsp;此时，我们发现，通过抽象出了`CommonManager`虚类，可以让我们的实体类更加的通俗易懂，可以让整个处理流程，更加的清晰明朗。

## 总结

&emsp;&emsp;在日常的开发当中，我们经常会用到`责任链`模式，因此对于学习`责任链`模式显得就尤为的重要。