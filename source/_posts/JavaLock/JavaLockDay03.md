---
title: Java--ReentrantLock
permalink: JavaLock/JavaLockDay03
date: 2019-11-08 21:07:14
categories:
- Java
- 锁问题
tags:
- 锁问题
- Java学习
---

# Java--ReentrantLock

&emsp;&emsp;在`JDK`的代码中，我们用于实现`同步方法`的常用的来说，有三种

1. `synchronize`
2. `ReentrantLock`
3. `countDownLatch`

&emsp;&emsp;其中，我们已经在上一篇文章中讲解了<a href="/JavaLock/JavaLockDay02/">synchronize</a>，现在，我们讲解下`ReentrantLock`。

&emsp;&emsp;在`ReentrantLock`中，我们的锁既可以是`公平锁`,也可以是`非公平锁`。至于具体是哪一种，是根据我们在初始化`ReentrantLock`时，通过构造函数的请求参数来设置的。另外，提一句，`synchronize`只能是非公平锁。 

```java
    public ReentrantLock() {
        sync = new NonfairSync();
    }

    public ReentrantLock(boolean fair) {
        sync = fair ? new FairSync() : new NonfairSync();
    }
```

&emsp;&emsp;通过上面的代码，我们可以发现，如果我们调用无参的构造函数`ReentrantLock()`，则默认的是`非公平锁`；而如果我们调用的是有参的构造函数`ReentrantLock(boolean fair)`,则取决于我们传入的参数，如果是`false`，则采用的是`非公平锁`，而如果是`true`，则采用的是`公平锁`。

&emsp;&emsp;那么，对于`公平锁`和`非公平锁`，`ReentrantLock`是怎么实现的呢？

## ReentrantLock实现非公平锁

&emsp;&emsp;我们通过上面的代码可以看出，如果我们采用`ReentrantLock()`和`ReentrantLock(false)`的时候，此时获取的是`非公平锁`。此时，我们使用的是`NonfairSync`这个静态内部类产生的对象，那么`ReentrantLock`是怎么实现非公平锁的呢？

&emsp;&emsp;首先，我们看下`NonfairSync`的源码：

```java
static final class NonfairSync extends Sync {
        private static final long serialVersionUID = 7316153563782823691L;

        /**
         * Performs lock.  Try immediate barge, backing up to normal
         * acquire on failure.
         */
        final void lock() {
            if (compareAndSetState(0, 1))
                setExclusiveOwnerThread(Thread.currentThread());
            else
                acquire(1);
        }

        protected final boolean tryAcquire(int acquires) {
            return nonfairTryAcquire(acquires);
        }
    }
```

&emsp;&emsp;通过源码可知，当我们执行`lock`方法的时候，此时我们首先会采用`CAS`自旋的方式，来获取一次锁，如果我们此时锁是获取成功的，那么我们直接将当前的线程记录一下，以便后续重入的时候，可以直接获取到当前锁。如果我们通过第一次`CAS`自旋的方式获取锁失败的话，那么此时我们会执行`acquire`方法。

&emsp;&emsp;那么我们看下`acqurie`方法的源码：

```java

```