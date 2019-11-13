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

&emsp;&emsp;我们通过上面的代码可以看出，如果我们采用`ReentrantLock()`和`ReentrantLock(false)`的时候，此时获取的是`非公平锁`。此时，我们使用的是`NonfairSync`这个静态内部类产生的对象，那么`ReentrantLock`是怎么实现非公平锁的呢？

&emsp;&emsp;在我们真正的讲解`ReentrantLock`的非公平锁，其实，我们就是在讲`NonFairSync`这个类。既然，我们想要讲解这个类，那么就面临着我们要知道这个类的一个类图：

![ReentrantLockNonFairLock](http://static.shengouqiang.cn/blog/img/JavaLock/JavaLockDay02/NonFairSync.jpg)

&emsp;&emsp;接下来，问主要看下这个类。

## NonFairSync实现非公平锁(加锁)

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

public abstract class AbstractQueuedSynchronizer
    extends AbstractOwnableSynchronizer
    implements java.io.Serializable {

     public final void acquire(int arg) {
        if (!tryAcquire(arg) &&
            acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
            selfInterrupt();
    }

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
}
```

&emsp;&emsp;在上面，我们已经罗列出了所有的主要的源码的信息。接下来，我们一点一点的进行分析。

### lock方法

&emsp;&emsp;首先，我们查看`NonFairSync`的`lock`方法，我们发现，其实对于`lock`方法而言，很简单。就是如果当前线程需要锁，则首先通过`CAS`自旋的方式，去获取锁，如果锁不存在，那么就去执行`acquire`方法。

### acquire方法

&emsp;&emsp;然而，在`acquire`方法中，我们看到，主要的业务逻辑在`if`的判断中。在这里，我们发现，`JDK`的库工程师们采用了`模板方法`的设计模式，将整个加锁的过程，已经固化了，只是在不同的地方，需要实现者自己去实现而已。因此，`tryAcquire`方法就是由`NonFairSync`自己去实现的。而`NonFairSync`中的`tryAcquire`方法，仅仅只是调用底层的`nonfairTryAcquire`方法而已。而在`nonfairTryAcquire`方法中，我们发现一个神奇的事情，那就是这个方法中对于获取锁，它仍然通过了一次`CAS`自旋的方式去获取锁。如果没有获取到，才会执行下面的步骤。

&emsp;&emsp;那在这里就有一个问题了，因为我们在之前的`lock`方法中，已经通过`CAS`自旋的方式去尝试获取锁而失败了，那么为什么我们还要在`nonfairTryAcquire`中再执行一次呢？其实，这里面有一个效率的问题。在这里，是一个典型的通过增加一些冗余代码的方式，来提高执行效率的问题。

&emsp;&emsp;OK，到这里，我们开始重新的讲解一下`acquire`这个方法。在这个方法中，我们发现：他的主要部分是放在了`if`语句的里面。在`if`语句中，采用的是短路的原则，来进行一步一步的设置。接下俩，我们讲解下：

### tryAcquire方法

&emsp;&emsp;我们首先执行的是`tryAcquire`方法。通过名字可以知道，这个代码的含义是"获取锁"。只有我们获取失败的时候，才会执行后续的流程。

1.  `tryAcquire`方法调用的是`nonfairTryAcquire`方法。
2.  在`nonfairTryAcquire`中，我们首先会拿到当前线程，通过新创建一个`Node`的方式，将当前线程信息存放到`Node`信息中。此时我们会判断当前线程是否已经获取到锁。
   - 如果没有获取到锁，则通过一次`CAS`自旋来获取锁，如果获取成功，此时我们继续下当前线程的信息，以便后续重入锁的时候使用。
   - 如果我们获取锁失败，此时我们查看当前线程是否已经获取到锁，如果发现已经获取，则直接通过重入锁来获取当前锁。并且将`state`加`1`。在这里，`state`表示的是锁的重入次数。
   - 如果上述两种情况，我们都没有获取到锁，则直接返回`false`,表示获取锁失败。

### addWaiter方法

&emsp;&emsp;这个方法的调用前提是在`tryAcquire`获取锁失败的时候进行调用的。这个方法的主要目的是为了将未获取到锁的线程，通过`Node`的方式来添加到`队列`中。到此，我们需要介绍一下`AbstractQueuedSynchronizer`也就是`AQS`和他用户存储阻塞线程的`队列`的数据结构。

#### AbstractQueuedSynchronizer

&emsp;&emsp;`AbstractQueuedSynchronizer`，我们俗称`AQS`。这个类是实现`ReentrantLock`锁的重要类。这个类采用的是设计模式中的`模板方法`。他帮我们默认了提供了一套关于锁的解决方法。但是对于内部的一些实现，是需要子类去自己实现的,例如`tryAcquire`方法。同时，我们的`NonFairSync`也是继承了这个类。在这个类中，存在了两个成员变量`head`和`tail`。这两个变量，一个是指定了`队列`的头节点，一个指定了`队列`的尾节点。注意的是，这个`队列`采用的是`懒加载`模式。默认情况下，`head`和`tail`的值为`null`。如果举例，我们可以这样表示：

![ReentrantLockNonFairLock](http://static.shengouqiang.cn/blog/img/JavaLock/JavaLockDay02/AQSStructor.jpg)

对于`AbstractQueuedSynchronizer`的介绍，我们会在后续的文章中进行讲解的。

#### `队列`的存储结构

&emsp;&emsp;在`AbstractQueuedSynchronizer`中，我们所有的未获取到锁的线程都会添加到一个`队列`当中。而这个队列，采用的是一个数据结构中典型的`无头的双向链表`的数据模型。对于`列表`中的每一个节点`Node`，主要是由

- `waitStatus`<span style="color:red;"> - </span>当前节点的状态，其中有
    - `SIGNAL`<span style="color:red;"> - </span>值为`-1`，被标识为该等待唤醒状态的后继结点，当其前继结点的线程释放了同步锁或被取消，将会通知该后继结点的线程执行。说白了，就是处于唤醒状态，只要前继结点释放锁，就会通知标识为SIGNAL状态的后继结点的线程执行
    - `CANCELLED`<span style="color:red;"> - </span>值为`1`，在同步队列中等待的线程等待超时或被中断，需要从同步队列中取消该Node的结点，其结点的waitStatus为CANCELLED，即结束状态，进入该状态后的结点将不会再变化
    - `CONDITION`<span style="color:red;"> - </span>值为`-2`，与Condition相关，该标识的结点处于等待队列中，结点的线程等待在Condition上，当其他线程调用了Condition的signal()方法后，CONDITION状态的结点将从等待队列转移到同步队列中，等待获取同步锁
    - `PROPAGATE`<span style="color:red;"> - </span>值为`-3`，与共享模式相关，在共享模式中，该状态标识结点的线程处于可运行状态
    - `0`<span style="color:red;"> - </span>值为`0`，代表初始化状态
- `prev`<span style="color:red;"> - </span>当前节点的前置节点
- `next`<span style="color:red;"> - </span>当前节点的后置节点
- `thread`<span style="color:red;"> - </span>当前节点对应的线程

&emsp;&emsp;当前，`Node`节点还存在一些其他的变量，在这里，我们主要关注的就是上面的这几个。对于`AQS`而言，我们创建的队列正是通过`Node`节点组成的一个`FIFO`的队列。他的格式如下

![AQS的FIFO队列](http://static.shengouqiang.cn/blog/img/JavaLock/JavaLockDay02/AQSFIFOQUEUE.jpg)

***

&emsp;&emsp;OK，有了上面的前提，我们再看看`addWaiter`这段代码。同样的，这段代码中，`JDK`的库工程师们依然采用了通过冗余代码来提高效率的方式来提升性能，因此，我们只需要看`enq`这个方法即可。其中，源码如下：

```java
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

&emsp;&emsp;在这段代码中，我们依然是通过一个死循环的方式来执行的。首先我们会判断`tail`这个指针。如果我们发现`tail`指针为`null`，那么此时这个队列中根本就不存在。这个也是之前我们讲解的，`AQS`的`队列`采用的`懒加载`的模式进行初始化的(也就是说，并不是事先初始化，而是在我们使用的时候进行初始化)。因此，在`for`循环中的第一个`if`中，就是为了来初始化`队列`的操作。在初始化完成操作之后，会将`head`和`tail`都指向这个新创建的`Node`节点。注意，这个节点不存在任何的`thread`信息。它仅仅指向的是一个`阻塞队列`。

&emsp;&emsp;在这里，我们会想到，会不会存在并发的问题呢？其实，是不存在。因为就算是有多个线程进入了`for`循环内，此时多个线程都获取到了`tail`为`null`的情况，此时都回去执行`compareAndSetHead`方法。但是在`compareAndSetHead`中，采用了`CAS`自旋锁的方式进行设置，因此，只可能有一个线程成功，其他的线程都是不会成功的。这样也就解决了`并发`的问题。

&emsp;&emsp;当执行完第一个`if`语句后，或者是当前的`队列`不为空时，此时会执行`else`里面的语句。此时，我们会当前节点`node`的`prev`指向队列的前一个节点，然后通过`CAS`自旋的方式，将当前节点添加到队列的后面。然后将前面一个节点`next`指向当前节点。最后返回插入节点的`prev`节点。

### acquireQueued方法

&emsp;&emsp;你有可能会问，到目前为止，我们都是将线程添加到了阻塞队列中，但是并没有去获取锁啊。别急，`acquireQueued`方法就是对于锁`队列`的操作过程。同时，也是`lock`方法的重点方法，我们会以最简便的方式，来进行讲解。

方法的源码如下：

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

    private static boolean shouldParkAfterFailedAcquire(Node pred, Node node) {
        int ws = pred.waitStatus;
        if (ws == Node.SIGNAL)
            /*
             * This node has already set status asking a release
             * to signal it, so it can safely park.
             */
            return true;
        if (ws > 0) {
            /*
             * Predecessor was cancelled. Skip over predecessors and
             * indicate retry.
             */
            do {
                node.prev = pred = pred.prev;
            } while (pred.waitStatus > 0);
            pred.next = node;
        } else {
            /*
             * waitStatus must be 0 or PROPAGATE.  Indicate that we
             * need a signal, but don't park yet.  Caller will need to
             * retry to make sure it cannot acquire before parking.
             */
            compareAndSetWaitStatus(pred, ws, Node.SIGNAL);
        }
        return false;
    }

    private final boolean parkAndCheckInterrupt() {
        LockSupport.park(this);
        return Thread.interrupted();
    }       
```

&emsp;&emsp;首先，我们发现这里仍然是一个`死循环`的方式。然后再`for`循环中进行了两次判断。

&emsp;&emsp;对于第一个`if`语句，我们首先获取当前节点`prev`节点是不是一个`head`节点，如果不是`head`节点，则跳出当前的`if`判断。那么，这里就有一个问题，我们为什么非要看当前节点是不是在`head`之后的第一个呢？是因为

1. `head`节点是不存在获取权限判断的。`head`节点存在的目的，是为了形成一个队列
2. 我们始终认为，`head`节点后面的第一个节点是目前正在获取锁的节点，对于之后的节点，都需要前置的节点已经获取锁才可以。
3. 对于当前获取锁的节点，我们需要保证我们的后续节点的`waitState`一定是`SIGNAL`。

&emsp;&emsp;所以，在这里，我们解释了为什么判断当前的节点的`prev`一定是`head`的原因。接下来，就是如果当前的`node`是`head`的后置节点，我们就要去获取锁，如果获取锁失败，则会执行第二个`if`语句。如果获取成功

1. 将当前的node节点设置为`head`节点。
2. 将之前的head节点弃用,从`GCRoots`下摘掉，帮助`GC`进行清理
3. 将`failed`改成false，表示我们已经获取到锁。防止在`finally`中执行`cancelAcquire`操作。
4. 通过返回一个`false`

&emsp;&emsp;你有可能会问，我们已经拿到锁了，为什么还要返回`false`呢？其实，这个方法的返回值表示的并不是我们有没有拿到锁，而是我们在获取锁的过程中，是否发生了`interrupt`操作。正是因为我们拿到了锁，所以，才是返回`false`。

&emsp;&emsp;接下来，我们看下关于第二个`if`操作。第二个`if`操作，主要对于如果我们获取锁失败，或者当前节点不是`head`的后继节点的情况，这样的情况，笼统的讲，就是将自己变成`waiting`状态。具体如下：

1. 程序首先执行`shouldParkAfterFailedAcquire`方法，通过这个方法，我们可以猜到，这个方法的目的就是当我们获取锁失败的时候，应该去阻塞我们的线程。在这里`Park`和我们的`wait`是很像的。通过方法的源码我们可以知道：
    - 如果当前节点的`prev`节点是`SIGNAL`状态，则是允许我们将当前节点阻塞的。因为只有是`SIGNAL`状态的节点，才会被`head`进行唤醒，并且获取锁。
    - 如果我们的`prev`节点是`CANCELLED`状态，那么证明这些节点是在等待的过程中，已经取消的了，是不需要在获取锁的。我们会一直往前找，直到找到第一个节点的状态是`SIGNAL`的节点为止，然后将当前节点挂在这个节点的后面。
    - 如果我们的节点是一个初始化的节点，那么需要将前置节点的`waitState`设置为`SIGNAL`状态。
2. 对于上面的第`2`、`3`点，是需要重新执行`for`循环的。因为我们之前的`队列`是存在问题。因此需要重新执行。之后当队列不存在问题，此时，我们会执行`parkAndCheckInterrupt`方法。通过方法的源码可以知道，它其实是调用`LockSupport.park`的方法，将线程进行阻塞。

### cancelAcquire方法

&emsp;&emsp;如果程序在执行的过程中，发生了异常，此时会执行`finally`的方法。正常来讲，`finally`方法是方法结束后必须执行的方法，那么在这里，我们为什么要说是在发生异常后执行的呢？因为如果程序正常退出`for`循环，`failed`一定是`false`。只有当程序发生异常，此时`failed`才会为`true`。接下来，我们看下`cancelAcquire`方法的源码：

```java
    private void cancelAcquire(Node node) {
        // Ignore if node doesn't exist
        if (node == null)
            return;

        node.thread = null;

        // Skip cancelled predecessors
        Node pred = node.prev;
        while (pred.waitStatus > 0)
            node.prev = pred = pred.prev;

        // predNext is the apparent node to unsplice. CASes below will
        // fail if not, in which case, we lost race vs another cancel
        // or signal, so no further action is necessary.
        Node predNext = pred.next;

        // Can use unconditional write instead of CAS here.
        // After this atomic step, other Nodes can skip past us.
        // Before, we are free of interference from other threads.
        node.waitStatus = Node.CANCELLED;

        // If we are the tail, remove ourselves.
        if (node == tail && compareAndSetTail(node, pred)) {
            compareAndSetNext(pred, predNext, null);
        } else {
            // If successor needs signal, try to set pred's next-link
            // so it will get one. Otherwise wake it up to propagate.
            int ws;
            if (pred != head &&
                ((ws = pred.waitStatus) == Node.SIGNAL ||
                 (ws <= 0 && compareAndSetWaitStatus(pred, ws, Node.SIGNAL))) &&
                pred.thread != null) {
                Node next = node.next;
                if (next != null && next.waitStatus <= 0)
                    compareAndSetNext(pred, predNext, next);
            } else {
                unparkSuccessor(node);
            }

            node.next = node; // help GC
        }
    }
```

&emsp;&emsp;此时在程序中，我们进行了判断。

1. 如果当前节点为`null`,则不作任何处理，直接方法结束
2. 将当前`node`与`thread`进行解绑
3. 如果我们当前节点的`prev`的`waitState`大于`0`，则一直往前找，直到找到`waitState`为`SIGNAL`或者是初始化的。
4. 获取这个`waitState`为`SIGNAL`或者是初始化的的节点的后置节点
5. 将当前的节点设置为`CANCELLED`
6. 在这里，我们要分为`3`中情况进行考虑
    - 如果我们当前节点是`tail`节点，则我们将当前节点的`tail`指针指向当前节点的`prev`节点。然后将当前节点的`prev`节点的`next`指针设置为`null`，在下面我们用图1进行表示。
        ![图1](http://static.shengouqiang.cn/blog/img/JavaLock/JavaLockDay02/AQSFIFOQUEUE.jpg)
    - 对于第二种情况，我们判断两个条件，如果满足以下条件，则获取当前`node`节点的`next`节点。如果`next`节点不为`null`,并且`next`节点的`waitState`为`SIGNAL`，则我们将当前`node`的`prev`指针指向`node`节点的`next`节点，在下面，我们用图2进行表示。
        - 当前`node`的`prev`节点不是`head`节点
        - 当前`node`的`prev`节点的`waitState`为`SIGNAL`，或者我们可以将当前`node`的`prev`节点的`waitState`设置为`SIGNAL`
        - 当前`node`的`prev`节点的`thread`不为`null`
        ![图2](http://static.shengouqiang.cn/blog/img/JavaLock/JavaLockDay02/AQSFIFOQUEUE.jpg)
    - 对于第三种情况，我们首先获取`node`的`waitState`，如果`waitState`小于`0`,则更新为`0`。如果当前`node`的`next`节点为`null`或者是`next`节点的`waitState`大于0，则从`tail`节点开始往前，一致找到在`node`节点之后的第一个`waitState`小于0的节点，然后将当前节点执行`LockSupport.unpark`。如果没有找到，则不进行任何操作，在下面，我们用图3进行表示。
        ![图3](http://static.shengouqiang.cn/blog/img/JavaLock/JavaLockDay02/AQSFIFOQUEUE.jpg)



    

    




























## ReentrantLock实现公平锁

&emsp;&emsp;`ReentrantLock`的公平锁，就比非公平锁简单的多。唯一的区别是，当执行`tryAcquire`的时候，此时从原来的执行一次`CAS`自旋，改成判断在队列中是否存在。

## 总结

&emsp;&emsp;`ReentrantLock`在实际的开发过程中是十分的重要的。对于`ReentrantLock`的源码的研究是十分的有必要的。