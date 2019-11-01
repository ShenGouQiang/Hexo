---
title: Swagger文档API学习--API注解
permalink: Swagger/SwaggerDocumentLearnDay01
date: 2019-10-31 21:18:25
categories:
- Swagger
tags:
- Swagger
---

# Swagger--文档API学习--API

&emsp;&emsp;在日常的开发当中，我们经常需要维护我们自己工程的一份接口文档。接口文档准备的好，起到了事半功倍的作用，接口文档准备的不好，往往起到事倍功半的作用。因此，对于后台服务来说，有一份好的接口文档，就显得尤为重要。

&emsp;&emsp;在我经理的工作中，用来组织接口文档的方式有很多。有采用`showDoc`方式的，也有采用`cwiki`方式的。在这里，我们讲解另外的一种方式--`Swagger`方式。

&emsp;&emsp;`Swagger`的官方文档地址是:[Swagger官方文档](https://github.com/swagger-api/swagger-core/wiki/Annotations-1.5.X#quick-annotation-overview "Swagger官方文档")

&emsp;&emsp;`Swagger`的API文档地址是:[Swagger API](http://docs.swagger.io/swagger-core/v1.5.X/apidocs/index.html?io/swagger/annotations/Api.html "Swagger API")

&emsp;&emsp;对于`Swagger`的解释，网上的说法有很多，总结的说：

>> Swagger 是一个规范和完整的框架，用于生成、描述、调用和可视化 RESTful 风格的 Web 服务。总体目标是使客户端和文件系统作为服务器以同样的速度来更新。文件的方法，参数和模型紧密集成到服务器端的代码，允许API来始终保持同步。

## API接口

&1;&emsp;在讲解这个注解`@API`之前，我们首先看一下这个接口的源码

```java
package io.swagger.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Inherited;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Inherited
public @interface Api {
    String value() default "";

    String[] tags() default {""};

    /** @deprecated */
    @Deprecated
    String description() default "";

    /** @deprecated */
    @Deprecated
    String basePath() default "";

    /** @deprecated */
    @Deprecated
    int position() default 0;

    String produces() default "";

    String consumes() default "";

    String protocols() default "";

    Authorization[] authorizations() default {@Authorization("")};

    boolean hidden() default false;
}
```

&emsp;&emsp;通过上面的源码`@Target({ElementType.TYPE})`，我们可以发现，这个注解是作用在类上面的。因此，这个注解`@API`是类的注解，可以给控制器添加描述和标签信息，同时，我们将这个注解添加在控制器上，代表这个类是`Swagger`的资源，受`Swagger`的管理与解析。

### API--value属性

&emsp;&emsp;请注意，这个属性在`Swagger2.0`之后的版本中，没有什么实际的意义了。因为在`Swagger2.0`之后的版本中，`Swagger`官网推荐的是使用`tags`属性进行代替，并且，如果我们在`@API`中同时声明了`value`和`tags`，此时`value`的属性会被覆盖掉，同时，对于`tags`属性，我们可以设置多个标签。

### API--tags属性

&emsp;&emsp;对于官网，给定的是`API`文档的的控制标签的列表。在实际的使用中，我们经常会将`Controller`进行分类，因此，我们可以采用`tags`标签将我们的请求分类。

### API--description属性

&emsp;&emsp;这个属性在`Swagger1.5X`版本中已经不再推荐使用了。因此标记了`@Deprecated`注解。对于这个属性，一般描述的是某个`Controller`的一个详细的具体信息。

### API--basePath属性

&emsp;&emsp;这个属性在`Swagger1.5X`版本中已经不再推荐使用了。因此标记了`@Deprecated`注解。标识的是请求的基本路径。

### API--position属性

&emsp;&emsp;这个属性在`Swagger1.5X`版本中已经不再推荐使用了。因此标记了`@Deprecated`注解。如果配置多个Api想改变显示的顺序位置

### API--produces属性

&emsp;&emsp;指定返回的内容类型，仅当`request`请求头中的(`Accept`)类型中包含该指定类型才返回，例如:`application/json`。

### API--consumes属性

&emsp;&emsp;指定处理请求的提交内容类型(`Content-Type`)，例如`application/json`。

### API--protocols属性

&emsp;&emsp;标识的是当前的请求支持的协议，例如：`http`、`https`、`ws`、`wss`。

### API--authorizations属性

&emsp;&emsp;高级特性认证时配置。

### API--hidden属性

&emsp;&emsp;配置为`true`将在文档中隐藏。隐藏整个`Controller`资源。作用与`@ApiIgnore`类似，但是没有`@ApiIgnore`功能强大。

## 总结

&emsp;&emsp;`@API`注解是`@Swagger`文档注解中比较比较重要的一个。在下面的时间中，我会总结其他的`Swagger`的注解，在所有的注解讲解完之后，会有一个通用的例子，来辅助理解这些注解的内容。