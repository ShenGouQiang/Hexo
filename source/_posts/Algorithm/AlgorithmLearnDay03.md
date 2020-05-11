---
title: 利用双向链表+HashMap实现LRU算法
permalink: Algorithm/AlgorithmLearnDay03
date: 2020-03-31 21:35:19
categories:
- 算法学习
- 常用算法证明
tags:
- 算法
- 算法学习
- 面试算法总结
---

# 利用双向链表+HashMap实现LRU算法

&emsp;&emsp;在上一篇文章中，我们讲解了利用单链表实现`LRU`算法的功能。在上一篇文章中，我们无论是新增，还是替换，我们的时间复杂度都是`O(n)`。那么有没有什么办法让我们的时间发杂度是`O(1)`的呢？其实是有的。

&emsp;&emsp;首先，对于在链表中是否存在当前节点，我们可以通过`HashMap`来进行实现的。这样，利用`hash`的特性，可以让我们将查找的时间复杂度控制在`O(1)`。

&emsp;&emsp;其次我们规定，越靠近`head`节点的元素，是越不常使用的。而越靠近`tail`节点的，则是刚刚使用的。因此，如果我们可以随时知道一个链表的`head`和`tail`节点的话，同时，对于链表中的任何一个元素，我们可以知道节点的`prev`和`next`节点，就能够实现无论是插入，还是获取，都可以实现时间复杂度为`O(1)`的代码。

## 前置变量定义

&emsp;&emsp;OK，废话不多说，在这里，我们要强调几个变量：

1. capacity 代表的是`LRU`中最多的缓存个数
2. valueMap 是一个`Map<T, Node<T>>`类型的数据结构，其中，`T`代表的是`value`值，而`Node<T>`代表的是当前节点在链表中的位置。
3. head 代表的是链表的`head`节点。

## 代码展示

### Node节点的定义

```java
package datastructure.lru;

import lombok.Getter;
import lombok.Setter;

import java.util.Objects;

@Getter
@Setter
public class Node<T>{

    private Node<T> prev;

    private Node<T> next;

    private T value;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Node<?> node = (Node<?>) o;
        return value.equals(node.value);
    }

    @Override
    public int hashCode() {
        return Objects.hash(value);
    }

    @Override
    public String toString() {
        return "Node{" +
                "prev=" + prev +
                ", next=" + next +
                ", value=" + value +
                '}';
    }
}
```

### LRU算法实现

```java
package datastructure.lru;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/**
 * LRU算法实现
 */
public class LruAlgorithm<T> {

    private Integer capacity;

    private Map<T, Node<T>> valueMap;

    private Node<T> head;

    public LruAlgorithm(Integer capacity) {
        this.capacity = capacity;
        this.valueMap = new HashMap<>();
        this.head = new Node<>();
    }

    public T getValue(T t) {
        if (Objects.isNull(valueMap) || Objects.isNull(valueMap.get(t))) {
            return null;
        }
        changeLocation(t);
        showLinkList();
        return t;
    }

    public Node<T> setValue(T t) {
        if (Objects.isNull(valueMap.get(t))) {
            if (capacity <= valueMap.size()) {
                replaceNode(t);
            } else {
                addNode(t);
            }
        } else {
            changeLocation(t);
        }
        showLinkList();
        return head;
    }

    public Node<T> lruOperate(T[] array) {
        if (Objects.isNull(array) || 0 == array.length) {
            return null;
        }
        for (int i = 0; i < array.length; i++) {
            setValue(array[i]);
        }
        return head;
    }

    private void addNode(T value) {
        Node<T> tmp = new Node<>();
        tmp.setValue(value);
        if (Objects.isNull(head) || Objects.isNull(head.getNext())) {
            head.setNext(tmp);
            head.setPrev(tmp);
            tmp.setPrev(head);
        } else {
            head.getPrev().setNext(tmp);
            tmp.setPrev(head.getPrev());
            head.setPrev(tmp);
        }
        valueMap.put(value, tmp);
    }

    private void replaceNode(T value) {
        Node<T> tmp = new Node<>();
        tmp.setValue(value);
        valueMap.remove(value);
        Node<T> firstNode = head.getNext();
        head.setNext(firstNode.getNext());
        firstNode.getNext().setPrev(head);
        addNode(value);
    }

    private void changeLocation(T value) {
        Node<T> queryNode = valueMap.get(value);
        if (head.getPrev().equals(queryNode)) {
            return;
        }
        valueMap.remove(value);
        queryNode.getPrev().setNext(queryNode.getNext());
        queryNode.getNext().setPrev(queryNode.getPrev());
        addNode(value);
    }

    public void showLinkList() {
        Node<T> tailNode = head.getPrev();
        while (!Objects.isNull(tailNode) && !Objects.isNull(tailNode.getValue())) {
            System.out.print(tailNode.getValue() + "\t");
            tailNode = tailNode.getPrev();
        }
        System.out.println();
    }

    public static void main(String[] args) {
        Integer[] array = {10, 4, 6, 8, 7, 4, 10, 5};
        LruAlgorithm<Integer> lru = new LruAlgorithm<>(5);
        System.out.println("------------------start lru ------------------");
        lru.lruOperate(array);
        System.out.println("------------------end lru ------------------");
        System.out.println("------------------start get ------------------");
        Integer value = lru.getValue(1);
        System.out.println("value = " + value);
        lru.getValue(4);
        System.out.println("------------------end get ------------------");
        System.out.println("------------------start set ------------------");
        lru.setValue(1);
        System.out.println("----------------------------------------------");
        lru.setValue(10);
        System.out.println("------------------end set ------------------");
    }
}
```

### 实验结果

```
------------------start lru ------------------
10	
4	10	
6	4	10	
8	6	4	10	
7	8	6	4	10	
4	7	8	6	10	
10	4	7	8	6	
5	10	4	7	8	
------------------end lru ------------------
------------------start get ------------------
value = null
4	5	10	7	8	
------------------end get ------------------
------------------start set ------------------
1	4	5	10	7	
----------------------------------------------
10	1	4	5	7	
------------------end set ------------------
```

## 动画展示

&emsp;&emsp;对于上面代码不是很熟悉的小伙伴，可以先看下下面的视频展示，然后再回顾代码，可以更好的理解。

<video id="video" controls="controls" controlslist="nodownload"  width="1000" height="480" preload="none" poster="/img/video/fengmian1000480.jpg">
      <source id="mp4" src="/video/Algorithm/LRU/LRU_Hash_Link.mp4" type="video/mp4">
</video>