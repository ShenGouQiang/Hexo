---
title: Effective Java笔记 - 第一条：用静态工厂方法替代构造器
date: 2019-09-08 23:23:34
categories:
- Effective-Java
tags:
- Effective-Java
- Java进阶
---
# 用静态工厂方法替代构造器
对于一个类而言，如果我们想要拿到这个类的实例的话，最最传统的做法就是通过这个类的构造函数来创建一个实例。没错，这本身并没有什么问题，但是如果这个类中有很多的成员变量呢？