---
title: Swagger文档API学习--ApiIgnore注解
permalink: Swagger/SwaggerDocumentLearnDay08/
date: 2019-11-03 17:45:05
categories:
- Swagger
tags:
- Swagger
---

# Swagger文档API学习--ApiIgnore注解

这个注解主要是用来在`Swagger`生成文档的时候，自动忽略掉、隐藏掉打上该注解的内容。

## 源码

```java
package springfox.documentation.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.METHOD, ElementType.TYPE, ElementType.PARAMETER})
public @interface ApiIgnore {
  /**
   * A brief description of why this parameter/operation is ignored
   * @return  the description of why it is ignored
   */
  String value() default "";
}
```

### value属性

简明的说明为什么要忽略掉这个参数。

## 总结

这个注解和其他注解中的`hidden`属性有很多类似的地方。在实际的使用中，我们可以根据自己的习惯，进行选择性的使用。