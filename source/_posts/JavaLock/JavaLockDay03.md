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

&emsp;&emsp;那么我们看下`acqurie(int arg)`方法的源码，需要注意的是，`acqurie(int arg)`方法是`AbstractQueuedSynchronizer`抽象类的方法，因为`NonfairSync`集成了`Sync`，而`Sync`又继承了`AbstractQueuedSynchronizer`：

```java
    public final void acquire(int arg) {
        if (!tryAcquire(arg) &&
            acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
            selfInterrupt();
    }
```

&emsp;&emsp;通过上述的代码，我们可以知道，在执行`acqurie(int arg)`方法中，主要是一个`if`判断。但是在判断中，处理了好多的事情。我们一点一点的进行分析：

&emsp;&emsp;首先，我们看下`tryAcquire(int acquires)`这个方法的源码，需要注意的的是在`NonfairSync`中对`tryAcquire(int acquires)`进行了重写。因此在这里，我们需要查看的是`NonfairSync`中对于`tryAcquire(int acquires)`的编码：

```java
    protected final boolean tryAcquire(int acquires) {
        return nonfairTryAcquire(acquires);
    }
```

&emsp;&emsp;而在`tryAcquire(int acquires)`中，调用了当前方法的`nonfairTryAcquire(int acquires)`，因此，我们要查看`nonfairTryAcquire(int acquires)`源码：

```java
    final boolean nonfairTryAcquire(int acquires) {
        final Thread current = Thread.currentThread();
        int c = getState();
        if (c == 0) {
            if (compareAndSetState(0, acquires)) {
                setExclusiveOwnerThread(current);
                return true;
            }
        }
        else if (current == getExclusiveOwnerThread()) {
            int nextc = c + acquires;
            if (nextc < 0) // overflow
                throw new Error("Maximum lock count exceeded");
            setState(nextc);
            return true;
        }
        return false;
    }
```

&emsp;&emsp;在`nonfairTryAcquire(int acquires)`方法中，我们首先获取到当前线程，然后获取当前的同步状态的值，也就是是否获取到锁，在`ReentrantLock`中，如果`state`的状态为`0`，则代表没有获取到锁，如果`state`为非`0`，则代表获取到锁。接下来的执行流程是：

1. 通过`CAS`自旋一次，看是否能够获取到锁。如果能获取到锁，则将当前线程记录一下，可以在后续的锁重入中方便查看是否是当前线程已经获取到了锁。
2. 如果我们在`CAS`中没有拿到锁，则直接查看当前线程时候已经获取到了锁，此时就是`锁重入`的情况，如果获取到了。并且如果此时发现state小于`0`，则直接代表程序异常，报出异常。否则的话，则直接将当前锁的`state`加`1`。

&emsp;&emsp;此时，我们看下`addWaiter(Node mode)`方法，源码如下：

```java

    private Node addWaiter(Node mode) {
        Node node = new Node(Thread.currentThread(), mode);
        // Try the fast path of enq; backup to full enq on failure
        Node pred = tail;
        if (pred != null) {
            node.prev = pred;
            if (compareAndSetTail(pred, node)) {
                pred.next = node;
                return node;
            }
        }
        enq(node);
        return node;
    }

    private final boolean compareAndSetTail(Node expect, Node update) {
        return unsafe.compareAndSwapObject(this, tailOffset, expect, update);
    }

    private Node enq(final Node node) {
        for (;;) {
            Node t = tail;
            if (t == null) { // Must initialize
                if (compareAndSetHead(new Node()))
                    tail = head;
            } else {
                node.prev = t;
                if (compareAndSetTail(t, node)) {
                    t.next = node;
                    return t;
                }
            }
        }
    }
```

&emsp;&emsp;在我们看`addWaiter(Node mode)`之前，我们首先应该知道，对于`ReentrantLock`方法而言，如果存在多个线程同时访问同一个`同步资源`的时候，其实是在代码的内容，以`队列`的形式组织起来的，而`队列`的内部，采用的是`链表`的形式实现的。因此，这个方法的作用就是：

1. 根据当前线程，创建一个`Node`节点
2. 获取链表的尾结点，如果尾结点不为空，代表的是当前`队列`中已经存在节点，则将当前节点通过`compareAndSetTail`插入到尾结点，如果成功，返回当前节点，如果失败，则走`步骤3`
3. 如果通过`compareAndSetTail`插入失败，则调用`enq`方法，则通过一个`死循环`的方式，来进行初始化和赋值操作，我们首先判断当前队列是否存在节点，如果不存在，则一直调用`compareAndSetHead`方法，初始化头结点，在初始化成功后，再次调用`compareAndSetTail`方法，将当前节点插入到队列的尾部。

&emsp;&emsp;最后，我们看下`acquireQueued`这个方法，这个方法的源码如下：

```java
    final boolean acquireQueued(final Node node, int arg) {
        boolean failed = true;
        try {
            boolean interrupted = false;
            for (;;) {
                final Node p = node.predecessor();
                if (p == head && tryAcquire(arg)) {
                    setHead(node);
                    p.next = null; // help GC
                    failed = false;
                    return interrupted;
                }
                if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())
                    interrupted = true;
            }
        } finally {
            if (failed)
                cancelAcquire(node);
        }
    }
```

&emsp;&emsp;在这个方法有点饶，我们一点点去进行分析。首先，我们在一个`死循环`中，进行判断，如果当前节点的前置节点是`head`，并且我们获取到锁，则执行下面的方法，在这里，我们要注意下`tryAcquire`方法，因为这个方法在`NonfairSync`中也进行了重写，并且在前面的代码中已经讲过，因此，我们这里不在过多的叙述。当获取到锁后，我们会