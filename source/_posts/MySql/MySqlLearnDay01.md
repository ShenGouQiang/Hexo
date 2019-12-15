---
title: MySql--隔离级别
permalink: MySql/MySqlLearnDay01
date: 2019-12-12 20:32:31
categories:
- MySql
- 理论学习
tags:
- MySql学习
- 隔离级别
---

# MySql--隔离级别

&emsp;&emsp;在我们日常开发的过程中，我们经常要用到`Oracle`和`MySql`数据库。但是目前也仅仅只是在用的阶段而已。对于数据库的学习，现在想达到知其然，知其所以然的地步。在这里，我们以这篇文章作为开头，进行研究。

&emsp;&emsp;在讲解数据库的隔离级别前，我们需要了解下关于数据库的各种问题：

1. 脏读
2. 不可重复读
3. 幻读

&emsp;&emsp;正是对应要解决这三种问题，数据库给出了对应的解决方案，就是数据库的隔离级别：

1. 读未提交
2. 读已提交
3. 可重复度
4. 串行化

## 脏读与读未提交

&emsp;&emsp;我们首先说下什么是脏读：

>脏读就是指当一个事务正在访问数据，并且对数据进行了修改，而这种修改还没有提交到数据库中，这时，另外一个事务也访问这个数据，然后使用了这个数据。因为这个数据是还没有提交的数据，那么另外一个事务读到的这个数据是脏数据，依据脏数据所做的操作可能是不正确的。

&emsp;&emsp;要验证`脏读`与`读未提交`这个特性。我们首先需要两个session去连接相同的数据库。并且将这两个`session`的隔离级别设置为`READ UNCOMMITTED`。为了方便接下来的讨论，我们将两个session分别命名为`session1`和`session2`。

&emsp;&emsp;接下来，我们看下`session1`的执行`sql`：

```sql

SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select @@tx_isolation;
```

&emsp;&emsp;同理，我们将`session2`也进行上面的设置。此时`session1`和`session2`的隔离级别都是`读未提交`。

&emsp;&emsp;接下来，我们创建一个`test`表。表中仅有一个字段：`id`。

```sql
create table test(
    id int
);
```

&emsp;&emsp;此时我们查询下表：

```sql
select * from test;
```

&emsp;&emsp;执行结果如下：

![查询test表](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/querytest01.jpg)

&emsp;&emsp;接下来，我们在`session1`中执行如下的`SQL`语句

```sql
insert into test (id)
value (1);
```

&emsp;&emsp;执行结果如下：

![test表执行insert语句](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/testinsert01.jpg)


&emsp;&emsp;此时，我们在`session2`中执行如下`SQL`语句：

```sql
select * from test;
```

&emsp;&emsp;执行结果如下：

![test表执行select语句](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/querytest02.jpg)

&emsp;&emsp;此时我们发现，在`session2`中，可以查到`session1`中插入但是还没有`commit`的`SQL`语句。这样的情况，就是`脏读`的情况。而这个也正是`读未提交`隔离级别所带来的问题。有了上面的演示，此时我们可以很好的理解什么是`脏读`了。

&emsp;&emsp;那么为了避免这个问题，我们需要将我们的数据库隔离级别提高，将数据库的隔离级别设置为：`读已提交`。但是`读已提交`还是有会新的问题，那就是`不可重复读`。

## 不可重复读与读已提交

### 脏读问题是否解决

&emsp;&emsp;既然我们将隔离级别从`读未提交`升级到`读已提交`。此时，我们看下是否已经解决了`脏读`的问题。

&emsp;&emsp;还是上面的例子，此时我们在`session2`中开启事务，然后查询`test`表，结果如下：

![test表执行select语句](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/querytest05.jpg)

&emsp;&emsp;此时在`session1`中插入一条记录：

![test表执行insert语句](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/testinsert02.jpg)

&emsp;&emsp;此时`session2`再次查询的结果为：

![test表执行select语句](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/querytest06.jpg)

&emsp;&emsp;通过上面的例子，我们发现，`读已提交`已经克服了`脏读`的问题。

### 什么是不可重复读问题

&emsp;&emsp;我们首先说下什么是不可重复读：

>在一个事务内，多次读同一个数据。在这个事务还没有结束时，另一个事务也访问该同一数据并修改数据。那么，在第一个事务的两次读数据之间。由于另一个事务的修改，那么第一个事务两次读到的数据可能不一样，这样就发生了在一个事务内两次读到的数据是不一样的，因此称为不可重复读，即原始读取不可重复

&emsp;&emsp;接下来，我们还是进行演示，什么是`不可重复读`。

&emsp;&emsp;跟上面的例子一下，我们将我们的`session1`和`session2`的隔离级别改为`READ COMMITTED`。执行`SQL`如下：

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

&emsp;&emsp;我们先在`session2`中，先开启事务，然后查询一次`test`表:

```sql
select * from test;
```

&emsp;&emsp;此时，我们的查询结果如下：

![test表执行select语句](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/querytest03.jpg)

&emsp;&emsp;接下来，我们在`session1`中将`test`表中的`id`改为2，然后提交事务：

```sql
update  test set id=2 ;
```

&emsp;&emsp;然后，我们在`session2`中重新进行查询,注意，此时还没有提交事务

```sql
select * from test;
```

&emsp;&emsp;此时，我们的查询结果如下：

![test表执行select语句](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/querytest04.jpg)

&emsp;&emsp;果然，我们发现，在`session2`这个事务执行的过程中，因为有`session`1将`tes`t表的`id`改为了2，此时在`session2`这同一个事务中，会出现两次查询结果不一致的情况，也就是第一次查询的结果为1，第二次查询的结果为2。这个就是`不可重复读`。为了解决不可重复读的问题，接下来，我们讨论下`可重复读`这个隔离级别。

&emsp;&emsp;这里补充一下，`Oracle`默认的数据库隔离级别就是`读已提交`。

## 幻读与可重复读

### 可重复读是否解决了不可重复读问题

&emsp;&emsp;既然我们将隔离级别从`读已提交`升级到`可重复读`。此时，我们看下是否已经解决了`不可重复读`的问题。

&emsp;&emsp;还是上面的例子，此时我们在`session2`中开启事务，然后查询`test`表，结果如下：

![test表执行select语句](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/querytest07.jpg)

&emsp;&emsp;此时在`session1`中更新记录,并提交：

![test表执行update语句](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/testupdate01.jpg)

&emsp;&emsp;此时`session2`再次查询的结果为：

![test表执行select语句](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/querytest08.jpg)

&emsp;&emsp;通过上面的例子，我们发现，`可重复读`已经克服了`不可重复读`的问题。

### 什么是幻读

&emsp;&emsp;我们首先说下什么是幻读：

>是指当事务不是独立执行时发生的一种现象，例如第一个事务对一个表中的数据进行了修改，这种修改涉及到表中的全部数据行。同时，第二个事务也修改这个表中的数据，这种修改是向表中插入一行新数据。那么，以后就会发生操作第一个事务的用户发现表中还有没有修改的数据行，就好象发生了幻觉一样

&emsp;&emsp;注意，这里要说明一下，之前的`脏读`与`不可重复读`都是针对一条记录而言的。但是幻读一般是针对一批数据而言的。在这里，我们举个栗子，假如公司中工资大于5000的有10人，此时session2查询的记录就是10。但是在`session2`查询完之后，此时`session1`向表中插入一条工资大于5000的记录，此时`session2`再查询就是11人了。这个就是幻读。

&emsp;&emsp;接下来，我们还是以`session2`为例，查询所有的`test`记录，但是此时提交事务

```sql
select * from test;
```

![test表执行select语句](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/querytest09.jpg)

&emsp;&emsp;此时在`session1`中插入一条`id=1`的记录，并且提交事务

```sql
insert into test (id)
value (1);
```

![test表执行insert语句](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/testinsert03.jpg)

&emsp;&emsp;此时我们再次在`session2`中进行查询

![test表执行select语句](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/querytest10.jpg)

&emsp;&emsp;此时我们发现两次结果就处于不一致的状态，多了一个`id=1`的记录。这个就是`幻读`。解决`幻读`的办法就是使用`串行化`隔离级别。

&emsp;&emsp;这里补充一下，`MySql`默认的数据库隔离级别就是`可重复读`。

## 串行化

&emsp;&emsp;我们首先说下什么是串行化：

>这是数据库最高的隔离级别，这种级别下，事务“串行化顺序执行”，也就是一个一个排队执行

&emsp;&emsp;这种级别下，`脏读`、`不可重复读`、`幻读`都可以被避免，但是执行效率奇差，性能开销也最大，所以基本没人会用。

### 串行化是否解决了幻读的问题

&emsp;&emsp;此时我们先在`session2`中查询表`test`，得到的结果如下：

![test表执行select语句](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/querytest11.jpg)

&emsp;&emsp;此时我们再在`session1`中执行插入语句，插入一条`id=3`的记录

```sql
insert into test (id)
value (3);
```

&emsp;&emsp;此时我们发现，`MySql`报错了，内容如下：

![test表执行insert语句](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/testinsert04.jpg)

&emsp;&emsp;这是说明，当前执行`insert`语句没有获取到锁。这也说明了上面`MySql`中对于`串行化`的定义。此时也就解决了`幻读`的问题。

# 数据库第一类更新丢失

&emsp;&emsp;第一类更新丢失是指，由于某个事务的回滚操作，参与回滚的旧数据将其他事务的数据更新覆盖了。比如如下两个事务，事务一先开启查询账户有1000元，然后准备存款100元，使其账户变为1100，此时事务尚未结束，其后，事务二发生了转账，并提交了事务，使账户金额变为900，而事务一并不知情，最后事务一没有提交，而是回滚了事务，将账户金额重新设置为1000。但其实，账户已经被转走了100元，这种回滚导致了更新丢失。

&emsp;&emsp;`SQL92`没有定义这种现象，标准定义的所有隔离界别都不允许第一类丢失更新发生。基本上数据库的使用者不需要关心此类问题。

# 数据库第二类更新丢失

&emsp;&emsp;第二类数据丢失的问题是关于多个事务同时更新一行数据导致的问题，如下表所示，事务一和事务二都更新一行数据，他们事务开始的时候都查询到账户有1000元，然后都往账户添加了100元，最后大家都提交了各自的事务，结果却是错误的。

&emsp;&emsp;解决办法就是`悲观锁(for update)`、`乐观锁(通过where指定)`、将隔离级别改成`串行化`。

## 总结

&emsp;&emsp;通过上面的讲解，我们知道了数据库的隔离级别与对应的问题，已经数据库的第一、二类更新丢失的问题。在实际的开发中，`读未提交`级别的风险性特别的高，在生产上基本不会使用。`串行化`级别的并发性会特别的低，很容易资源的浪费，造成系统的瓶颈，在生产上基本也不会使用。而`读已提交`是`Oracle`的默认隔离级别，`可重复读`是`MySql`的默认隔离级别。这两种隔离级别是使用最多的两种。在本文，我们仅仅只是讲解了每个隔离级别和对应的问题。至于具体的`MySql`在内部是如何实现的，我们并没有进行讲解。在接下来的文章，我会主要讲解`MySql`在内部是如何实现各种隔离级别的。

&emsp;&emsp;我们采用一张图的方式，来说明下每个隔离级别的能力与对应的问题：

![隔离级别总结图](http://static.shengouqiang.cn/blog/img/SQL/isolation/day01/isolation.jpg)