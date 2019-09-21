---
title: MySql学习--Day01
permalink: mysql/MYSQL-LEARN-DAY-01
date: 2019-09-21 14:24:12
categories:
- mysql
tags:
- mysql学习
- mysql
---
#MySql学习--Day01

```sql
-- 查看自动提交设置
SHOW VARIABLES LIKE 'AUTOCOMMIT';

-- 开启自动提交
SET AUTOCOMMIT =1;

-- 关闭自动提交
SET AUTOCOMMIT =0;

-- 查看当前会话隔离级别
select @@tx_isolation;

-- 查看系统当前隔离级别
select @@global.tx_isolation;


-- 设置当前会话隔离级别
-- READ UNCOMMITTED  未提交读
-- READ COMMITTED    不可重复读
-- REPEATABLE READ   可重复读
-- SERIALIZABLE      串行化
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- 设置系统当前隔离级别
set global transaction isolation level repeatable read;

-- 查看相关表的信息
SHOW TABLE STATUS  like 'test_table';
```
