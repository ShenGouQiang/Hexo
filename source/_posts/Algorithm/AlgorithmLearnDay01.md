---
title: 算法：从1+1000000的O(1)的时间复杂度
permalink: Algorithm/AlgorithmLearnDay01/
date: 2019-11-27 13:49:50
categories:
- 算法学习
- 常用算法证明
tags:
- 算法
- 算法学习
- 面试算法总结
---

# 从1+1000000的O(1)的时间复杂度

```java
package com.gouqiang.other;

import org.junit.Test;

/**
 * @author shengouqiang
 * @date 2019/11/27
 */
public class TestTwo {
    @Test
    public void testOne(){
        addToResult(1000000L);
        addToResult(1000001L);
    }

    /**
     * 判断请求数是否为单数
     * @param requestNumber
     * @return
     */
    private boolean checkNumberIsSingular(long requestNumber){
        if(0== requestNumber%2){
            return false;
        }
        return true;
    }

    /**
     * 计算求和
     * @param reqNumber
     */
    private void addToResult(long reqNumber){
        if(checkNumberIsSingular(reqNumber)){
            System.out.println(reqNumber*(reqNumber/2+1));
            return;
        }
        System.out.println((reqNumber+1)*(reqNumber/2));
    }

}
```

运行结果如下：

```java
500000500000
500001500001
```

这里主要利用了数学中的`等差数列求和公式`。