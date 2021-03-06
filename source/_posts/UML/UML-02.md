---
title: UML类图学习--类图
permalink: UML/UML-02/
categories:
  - UML学习
tags:
  - UML
  - 工具学习
date: 2019-09-12 23:07:55
---
# UML类图学习--类图
## 类图包含了什么
### 属性元素  
&emsp;&emsp;在日常的开发和文档编写中，我们用到的最多的就是类图。在这里，我们讲解下类图的使用方法。

&emsp;&emsp;对于类图而言，我们包含了一个重要的元素，这个元素就是类。当然，在实际中，我们把接口也当作一种特殊的类。因此实际上，类图所包含的属性元素有：
1. 接口
2. 真正的类

&emsp;&emsp;而这个“真正的类”中，我们包含了
1. 实体类
2. 控制类
3. 边界内

&emsp;&emsp;下面我们一一进行讲解
#### 实体类
&emsp;&emsp;实体类对应系统需求中的每个实体，它们通常需要保存在永久存储体中，一般使用数据库表或文件来记录，实体类既包括存储和传递数据的类，还包括操作数据的类。实体类来源于需求说明中的名词，例如学生、商品等。
#### 控制类
&emsp;&emsp;控制类用于体现应用程序的执行逻辑，提供相应的业务操作，将控制类抽象出来可以降低界面和数据库之间的耦合度。控制类一般是由动宾结构的短语（动词+名词）转化来的名词，如增加商品对应有一个商品增加类，注册对应有一个用户注册类等。
#### 边界类
&emsp;&emsp;边界类用于对外部用户与系统之间的交互对象进行抽象，主要包括界面类，如对话框、窗口、菜单等。
### 模型元素
1. 依赖关系
2. 泛化关系
3. 关联关系
4. 聚合关系
5. 组合关系
6. 实现关系

## 类图模型元素讲解
### 接口
&emsp;&emsp;对于接口而言，我们在上文已经说明了，在UML中我们把接口当作一中特殊的类。下面我们先来一个图片，看一下，在UML中接口是长什么样子的，在这里，我们以ProcessOn为例进行描述，与网上的图片可能有差异。

![UML类图之接口描述](https://oss.shengouqiang.cn/img/UML/10/interface.png)

&emsp;&emsp;其实，在这里，我们用这一个图就可以说明：

1. 首先，在最上面我们定了一个接口的名字，叫做"EatInterface"。
2. 在这个接口中，我们定义了三个方法，而这三个方法含有描述符。
   - <font color=red>+</font>  代表该方法是public
   - <font color=red>-</font>  代表该方法是private
   - <font color=red>#</font>  代表该方法是protected
3. 如果当前方法存在参数，则需要将参数列出来
4. 方法与返回值之间用":"进行分割，":"后面的是方法的返回值

### 真正的类
&emsp;&emsp;对于实体类而言，在processOn方法中，与接口的展示是一致的。只不过在实体类中，可以存在成员变量。

![UML类图之实类描述](https://oss.shengouqiang.cn/img/UML/10/class.png)

&emsp;&emsp;在这里，我们对于方法不在进行过多的阐述，因为与之前的接口中的说明一致，在这里，我们发现在"Student"类，存在成员变量"name"、"id"。改描述与方法一致。在这里，不再阐述。

### 依赖关系
&emsp;&emsp;依赖关系真的是多个类之间的依存关系。比如：植物类依赖土壤、水源、空气等。同时，依赖关系可以继续细分，分成5个小类：

1. 绑定依赖
2. 实现依赖
3. 使用依赖
4. 抽象依赖
5. 授权依赖

&emsp;&emsp;依赖关系是用<font color=red>虚线箭头</font>来表示的，箭头指向的方向，就是当前类所需要依赖的实体。
&emsp;&emsp;下面我们举例说明：

![UML类图之依赖关系描述](https://oss.shengouqiang.cn/img/UML/10/dependency.png)

### 泛化关系
&emsp;&emsp;泛化关系这个名词头一次听的一定比较懵逼，不知道是什么高大上的意思。其实，泛化关系就是继承关系，是用<font color=red>空心三角形+实线</font>来表示的，箭头指向的方向，就是当前类所需要依赖的实体。

&emsp;&emsp;下面我们举例说明：

![UML类图之泛化关系描述](https://oss.shengouqiang.cn/img/UML/10/generalization.jpg)

### 关联关系
&emsp;&emsp;关联关系是一种相关影响的关系。例如，森林可以影响气候，而气候也可以影响森林。关联关系是用<font color=red>双向箭头+实线</font>来进行表示的。

&emsp;&emsp;下面我们举例说明：

![UML类图之关联关系描述](https://oss.shengouqiang.cn/img/UML/10/composition.png)

### 聚合关系
&emsp;&emsp;聚合关系是类之间的一种较弱的耦合关系，如一个字符串数组和一个字符串就是一种聚合关系。在UML中，聚合关系用<font color=red>空心的菱形+实线箭头</font>来表示，箭头指向为被聚合的类。

&emsp;&emsp;下面我们举例说明：

![UML类图之聚合关系描述](https://oss.shengouqiang.cn/img/UML/10/association.png)

### 组合关系
&emsp;&emsp;组合关系是类之间一种整体与部分之间的关系，如一只青蛙有四条腿，青蛙类与青蛙腿类之间的关系就是组合关系。在UML中，组合关系用<font color=red>实心的菱形+实线箭头</font>来表示，箭头指向为被组合的类。

&emsp;&emsp;下面我们举例说明：

![UML类图之组合关系描述](https://oss.shengouqiang.cn/img/UML/10/aggregation.png)

### 实现关系
&emsp;&emsp;一般来讲实现关系是针对类与接口之间的关系而言的。在UML中，实现关系用<font color=red>空心三角形+虚线</font>来表示。

&emsp;&emsp;下面我们举例说明：

![UML类图之实现关系描述](https://oss.shengouqiang.cn/img/UML/10/realization.png)

## 组合成一个整体

![UML类图之实现关系描述](https://oss.shengouqiang.cn/img/UML/10/all.png)

