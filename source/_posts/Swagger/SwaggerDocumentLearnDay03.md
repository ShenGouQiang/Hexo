---
title: Swagger文档API学习--ApiResponses注解
permalink: Swagger/SwaggerDocumentLearnDay03/
date: 2019-11-01 14:06:19
categories:
- Swagger
tags:
- Swagger
---

# Swagger文档API学习--ApiResponses注解

今天我们讲解`Swagger`的第三个注解，也是一个比较重要的注解---`@ApiResponses`注解。根据以往的惯例，首先先上源码。

## ApiResponses源码

```java
package io.swagger.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * A wrapper to allow a list of multiple {@link ApiResponse} objects.
 * <p>
 * If you need to describe a single {@link ApiResponse}, you still
 * must use this annotation and wrap the {@code @ApiResponse} in an array.
 *
 * @see ApiResponse
 */
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface ApiResponses {
    /**
     * A list of {@link ApiResponse}s provided by the API operation.
     */
    ApiResponse[] value();
}
```

```java
package io.swagger.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Describes a possible response of an operation.
 * <p>
 * This can be used to describe possible success and error codes from your REST API call.
 * You may or may not use this to describe the return type of the operation (normally a
 * successful code), but the successful response should be described as well using the
 * {@link ApiOperation}.
 * <p>
 * This annotation can be applied at method or class level; class level annotations will
 * be parsed only if an @ApiResponse annotation with the same code is not defined at method
 * level or in thrown Exception
 * <p>
 * If your API has uses a different response class for these responses, you can describe them
 * here by associating a response class with a response code.
 * Note, Swagger does not allow multiple response types for a single response code.
 * <p>
 * This annotation is not used directly and will not be parsed by Swagger. It should be used
 * within the {@link ApiResponses}.
 *
 * @see ApiOperation
 * @see ApiResponses
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface ApiResponse {
    /**
     * The HTTP status code of the response.
     * <p>
     * The value should be one of the formal <a target="_blank" href="http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html">HTTP Status Code Definitions</a>.
     */
    int code();

    /**
     * Human-readable message to accompany the response.
     */
    String message();

    /**
     * Optional response class to describe the payload of the message.
     * <p>
     * Corresponds to the `schema` field of the response message object.
     */
    Class<?> response() default Void.class;

    /**
     * Specifies a reference to the response type. The specified reference can be either local or remote and
     * will be used as-is, and will override any specified response() class.
     */

    String reference() default "";

    /**
     * A list of possible headers provided alongside the response.
     *
     * @return a list of response headers.
     */
    ResponseHeader[] responseHeaders() default @ResponseHeader(name = "", response = Void.class);

    /**
     * Declares a container wrapping the response.
     * <p>
     * Valid values are "List", "Set" or "Map". Any other value will be ignored.
     */
    String responseContainer() default "";

    /**
     * Examples for the response.
     *
     * @since 1.5.20
     *
     * @return
     */
    Example examples() default @Example(value = @ExampleProperty(value = "", mediaType = ""));
}
```

## @ApiResponses注解

通过上面的源码，我们依然可以看出，这个注解可以使用在方法上和类的上面，但是一般的情况下， 我们都是用在方法上面。代表的是一个`Http`请求的返回值的描述。通过上面我们可以看出，`@ApiResponses`仅仅只是接收一个`@ApiResponse`的数组，因此，真正的重点其实是`@ApiResponse`注解。

### code属性

`http`返回状态码

### message属性

响应码对应的描述

### response属性

描述的是返回的类型

### responseHeaders属性

指定`response`中`header`的信息列表

### responseContainer属性

在这里，说明的是包装相应的容器。默认情况下，有效值为 `List`、`Set`、`Map`，任何其它值都将被忽略

### examples属性

`response`返回的举例说明

## 总计

`@ApiResponses`主要描述的是接口的返回信息。
