---
title: Redis数据结构--字典
permalink: Redis/RedisDictht/
date: 2020-06-09 11:50:34
categories:
- 中间件
- Redis
tags:
- Redis
- 数据结构
- 字典
---

#  Redis数据结构--字典

## 简介

&emsp;&emsp;字典，又称为符号表（`symbol table`）、关联数组（`associative array`）或映射（`map`），是一种用于保存键值对（`key-value pair`）的抽象数据结构。

&emsp;&emsp;字典在`Redis`中的应用相当广泛，比如`Redis`的数据库就是使用字典来作为底层实现的，对数据库的增、删、查、改操作也是构建在对字典的操作之上的。除了用来表示数据库之外，字典还是哈希键的底层实现之一，当一个哈希键包含的键值对比较多，又或者键值对中的元素都是比较长的字符串时，`Redis`就会使用字典作为哈希键的底层实现。

## 实现

&emsp;&emsp;`Redis`的字典使用哈希表作为底层实现，一个哈希表里面可以有多个哈希表节点，而每个哈希表节点就保存了字典中的一个键值对。

### 哈希表

```c
typedef struct dictht {    
  // 哈希表数组    
  dictEntry **table;    
  // 哈希表大小    
  unsigned long size;    
  //哈希表大小掩码，用于计算索引值    
  //总是等于size-1    
  unsigned long sizemask;    
  // 该哈希表已有节点的数量    
  unsigned long used;
 } dictht;
```

&emsp;&emsp;`table`属性是一个数组，数组中的每个元素都是一个指向`dict.h/dictEntry`结构的指针，每个`dictEntry`结构保存着一个键值对。`size`属性记录了哈希表的大小，也即是`table`数组的大小，而`used`属性则记录了哈希表目前已有节点（键值对）的数量。`sizemask`属性的值总是等于`size-1`，这个属性和哈希值一起决定一个键应该被放到table数组的哪个索引上面。

#### 哈希表节点

&emsp;&emsp;哈希表节点使用`dictEntry`结构表示，每个`dictEntry`结构都保存着一个键值对：

```c
typedef struct dictEntry {
  // 键    
  void *key;    
  // 值    
  union{        
    void *val;        
    uint64_tu64;        
    int64_ts64;    
  } v;    
  // 指向下个哈希表节点，形成链表    
  struct dictEntry *next;
} dictEntry;
```

&emsp;&emsp;`key`属性保存着键值对中的键，而v属性则保存着键值对中的值，其中键值对的值可以是一个指针，或者是一个`uint64_t`整数，又或者是一个`int64_t`整数。

&emsp;&emsp;`next`属性是指向另一个哈希表节点的指针，这个指针可以将多个哈希值相同的键值对连接在一次，以此来解决键冲突`（colli-sion）`的问题。

&emsp;&emsp;接下来， 我们通过图片的方式，展示哈希表的结构：

![哈希表存储结构](https://oss.shengouqiang.cn/img/Redis/Redis_Dict/Redis_dictht_struct.jpg)

### 字典

&emsp;&emsp;首先，我们看下字典的数据结构

```c
typedef struct dict {    
  // 类型特定函数    
  dictType *type;    
  // 私有数据    
  void *privdata;    
  // 哈希表    
  dictht ht[2];    
  // rehash索引    
  //当rehash不在进行时，值为-1    
  int rehashidx; 
} dict;
```

&emsp;&emsp;`type`属性和`privdata`属性是针对不同类型的键值对，为创建多态字典而设置的：

- `type`属性是一个指向`dictType`结构的指针，每个`dictType`结构保存了一簇用于操作特定类型键值对的函数，`Redis`会为用途不同的字典设置不同的类型特定函数。
  - 而`privdata`属性则保存了需要传给那些类型特定函数的可选参数。

```c
typedef struct dictType {    
  // 计算哈希值的函数    
  unsigned int (*hashFunction)(const void *key);    
  // 复制键的函数    
  void *(*keyDup)(void *privdata, const void *key);    
  // 复制值的函数    
  void *(*valDup)(void *privdata, const void *obj);    
  // 对比键的函数    
  int (*keyCompare)(void *privdata, const void *key1, const void *key2);    
  // 销毁键的函数    
  void (*keyDestructor)(void *privdata, void *key);    
  // 销毁值的函数    
  void (*valDestructor)(void *privdata, void *obj);
} dictType;
```



&emsp;&emsp;`ht`属性是一个包含两个项的数组，数组中的每个项都是一个`dictht`哈希表，一般情况下，字典只使用`ht[0]`哈希表，`ht[1]`哈希表只会在对`ht[0]`哈希表进行`rehash`时使用。

&emsp;&emsp;除了`ht[1]`之外，另一个和`rehash`有关的属性就是`rehashidx`，它记录了`rehash`目前的进度，如果目前没有在进行`rehash`，那么它的值为`-1`。

&emsp;&emsp;接下来， 我们通过图片的方式，展示字典的结构：

![字典存储结构](https://oss.shengouqiang.cn/img/Redis/Redis_Dict/Redis_dict_struct.jpg)

## 算法

### hash算法 & 解决冲突

&emsp;&emsp;对于整个`Redis`的算法很简单，大致流程如下：

1. 根据`key`来确定`hash`
2. 根据`rehashidx`确定使用 `ht[0]` 还是` ht[1]`
3. 根据 `hash & sizemask` 来确定最终的数组下标位置
4. 将节点添加到数据，如果当前节点有值，则添加到链表上，采用的是`链地址法`，并且采用的是`头插法`。

&emsp;&emsp;基于上面的内容，我们可以发现一个现象，哈希表的`length`大小始终为2<sup>n</sup>。至于`redis`是如果通过`key`来获取`hash`的，则是通过`MurmurHash2`算法实现的。

### rehash & 渐进式rehash

&emsp;&emsp;随着操作的不断执行，哈希表保存的键值对会逐渐地增多或者减少，为了让哈希表的负载因子`（load factor）`维持在一个合理的范围之内，当哈希表保存的键值对数量太多或者太少时，程序需要对哈希表的大小进行相应的扩展或者收缩。

&emsp;&emsp;扩展和收缩哈希表的工作可以通过执行`rehash`（重新散列）操作来完成，`Redis`对字典的哈希表执行`rehash`的步骤如下：

1. 为字典的`ht[1]`哈希表分配空间，这个哈希表的空间大小取决于要执行的操作，以及ht[0]当前包含的键值对数量（也即是`ht[0].used`属性的值）
   - 如果执行的是扩展操作，那么`ht[1]`的大小为第一个大于等于`ht[0].used*2`的2<sup>n</sup>
   - 如果执行的是收缩操作，那么`ht[1]`的大小为第一个大于等于`ht[0].used`的2<sup>n</sup>
2. 将保存在`ht[0`]中的所有键值对`rehash`到`ht[1]`上面：`rehash`指的是重新计算键的哈希值和索引值，然后将键值对放置到ht[1]哈希表的指定位置上
3. 当`ht[0]`包含的所有键值对都迁移到了`ht[1]`之后（`ht[0`]变为空表），释放`ht[0]`，将`ht[1]`设置为`ht[0]`，并在`ht[1]`新创建一个空白哈希表，为下一次`rehash`做准备

***

#### 负载因子的计算

&emsp;&emsp;<span style="color:red">负载因子= 哈希表已保存节点数量/ 哈希表大小</span>

#### 触发条件

&emsp;&emsp;当以下条件中的任意一个被满足时，程序会自动开始对哈希表执行扩展操作：

- 服务器目前没有在执行`BGSAVE`命令或者`BGREWRITEAOF`命令，并且哈希表的负载因子大于等于`1`
- 服务器目前正在执行`BGSAVE`命令或者`BGREWRITEAOF`命令，并且哈希表的负载因子大于等于`5`

&emsp;&emsp;根据`BGSAVE`命令或`BGREWRITEAOF`命令是否正在执行，服务器执行扩展操作所需的负载因子并不相同，这是因为在执行`BGSAVE`命令或`BGREWRITEAOF`命令的过程中，`Redis`需要创建当前服务器进程的子进程，而大多数操作系统都采用写时复制`（copy-on-write）`技术来优化子进程的使用效率，所以在子进程存在期间，服务器会提高执行扩展操作所需的负载因子，从而尽可能地避免在子进程存在期间进行哈希表扩展操作，这可以避免不必要的内存写入操作，最大限度地节约内存。

&emsp;&emsp;另一方面，当哈希表的负载因子小于`0.1`时，程序自动开始对哈希表执行收缩操作。

***

&emsp;&emsp;但是对于`rehash`而言，如果我们的哈希表中存放的数据特别的多，此时就会造成阻塞`client`的现象，也就造成了服务不可用的问题，为了解决这个问题，从而衍伸出了`渐进式rehash`。

&emsp;&emsp;`渐进式rehash`，服务器不是一次性将`ht[0]`里面的所有键值对全部`rehash`到`ht[1]`，而是分多次、渐进式地将`ht[0]`里面的键值对慢慢地`rehash`到`ht[1]`。

&emsp;&emsp;以下是哈希表渐进式`rehash`的详细步骤：

1. 为`ht[1]`分配空间，让字典同时持有`ht[0]`和`ht[1]`两个哈希表
2. 在字典中维持一个索引计数器变量`rehashidx`，并将它的值设置为`0`，表示`rehash`工作正式开始。
3. 在`rehash`进行期间，每次对字典执行添加、删除、查找或者更新操作时，程序除了执行指定的操作以外，还会顺带将`ht[0`]哈希表在`rehashidx`索引上的所有键值对`rehash`到`ht[1]`，当`rehash`工作完成之后，程序将`rehashidx`属性的值增一。
4. 随着字典操作的不断执行，最终在某个时间点上，`ht[0]`的所有键值对都会被`rehash`至`ht[1]`，这时程序将`rehashidx`属性的值设为`-1`，表示`rehash`操作已完成。

&emsp;&emsp;渐进式`rehash`的好处在于它采取分而治之的方式，将`rehash`键值对所需的计算工作均摊到对字典的每个添加、删除、查找和更新操作上，从而避免了集中式`rehash`而带来的庞大计算量。

&emsp;&emsp;因为在进行渐进式`rehash`的过程中，字典会同时使用`ht[0]`和`ht[1]`两个哈希表，所以在渐进式`rehash`进行期间，字典的删除（`delete`）、查找（`find`）、更新（`update`）等操作会在两个哈希表上进行。例如，要在字典里面查找一个键的话，程序会先在`ht[0]`里面进行查找，如果没找到的话，就会继续到`ht[1]`里面进行查找，诸如此类。

&emsp;&emsp;另外，在渐进式`rehash`执行期间，新添加到字典的键值对一律会被保存到`ht[1]`里面，而`ht[0]`则不再进行任何添加操作，这一措施保证了`ht[0]`包含的键值对数量会只减不增，并随着`rehash`操作的执行而最终变成空表。

## 总结

&emsp;&emsp;对于`Redis`而言，字典和哈希表的数据结构是非常重要的。并且对于哈希表的`rehash`也是非常重要的。在这里，做一个总结。