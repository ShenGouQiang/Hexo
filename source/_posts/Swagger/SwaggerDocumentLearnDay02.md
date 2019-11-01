---
title: Swagger文档API学习--ApiOperation注解
permalink: Swagger/SwaggerDocumentLearnDay02
date: 2019-11-01 11:50:08
categories:
- Swagger
tags:
- Swagger
---

# Swagger文档API学习--ApiOperation注解

&emsp;&emsp;今天我们讲解下`Swagger`文档的第二个注解`@ApiOperation`。首先我们先看一下源码。

```java
/**
 * Copyright 2016 SmartBear Software
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package io.swagger.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Describes an operation or typically a HTTP method against a specific path.
 * <p>
 * Operations with equivalent paths are grouped in a single Operation Object.
 * A combination of a HTTP method and a path creates a unique operation.
 */
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface ApiOperation {
    /**
     * Corresponds to the `summary` field of the operation.
     * <p>
     * Provides a brief description of this operation. Should be 120 characters or less
     * for proper visibility in Swagger-UI.
     */
    String value();

    /**
     * Corresponds to the 'notes' field of the operation.
     * <p>
     * A verbose description of the operation.
     */
    String notes() default "";

    /**
     * A list of tags for API documentation control.
     * <p>
     * Tags can be used for logical grouping of operations by resources or any other qualifier.
     * A non-empty value will override the value received from {@link Api#value()} or {@link Api#tags()}
     * for this operation.
     *
     * @since 1.5.2-M1
     */
    String[] tags() default "";

    /**
     * The response type of the operation.
     * <p>
     * In JAX-RS applications, the return type of the method would automatically be used, unless it is
     * {@code javax.ws.rs.core.Response}. In that case, the operation return type would default to `void`
     * as the actual response type cannot be known.
     * <p>
     * Setting this property would override any automatically-derived data type.
     * <p>
     * If the value used is a class representing a primitive ({@code Integer}, {@code Long}, ...)
     * the corresponding primitive type will be used.
     */
    Class<?> response() default Void.class;

    /**
     * Declares a container wrapping the response.
     * <p>
     * Valid values are "List", "Set" or "Map". Any other value will be ignored.
     */
    String responseContainer() default "";

    /**
     * Specifies a reference to the response type. The specified reference can be either local or remote and
     * will be used as-is, and will override any specified response() class.
     */

    String responseReference() default "";

    /**
     * Corresponds to the `method` field as the HTTP method used.
     * <p>
     * If not stated, in JAX-RS applications, the following JAX-RS annotations would be scanned
     * and used: {@code @GET}, {@code @HEAD}, {@code @POST}, {@code @PUT}, {@code @DELETE} and {@code @OPTIONS}.
     * Note that even though not part of the JAX-RS specification, if you create and use the {@code @PATCH} annotation,
     * it will also be parsed and used. If the httpMethod property is set, it will override the JAX-RS annotation.
     * <p>
     * For Servlets, you must specify the HTTP method manually.
     * <p>
     * Acceptable values are "GET", "HEAD", "POST", "PUT", "DELETE", "OPTIONS" and "PATCH".
     */
    String httpMethod() default "";

    /**
     * Not used in 1.5.X, kept for legacy support.
     */
    @Deprecated int position() default 0;

    /**
     * Corresponds to the `operationId` field.
     * <p>
     * The operationId is used by third-party tools to uniquely identify this operation. In Swagger 2.0, this is
     * no longer mandatory and if not provided will remain empty.
     */
    String nickname() default "";

    /**
     * Corresponds to the `produces` field of the operation.
     * <p>
     * Takes in comma-separated values of content types.
     * For example, "application/json, application/xml" would suggest this operation
     * generates JSON and XML output.
     * <p>
     * For JAX-RS resources, this would automatically take the value of the {@code @Produces}
     * annotation if such exists. It can also be used to override the {@code @Produces} values
     * for the Swagger documentation.
     */
    String produces() default "";

    /**
     * Corresponds to the `consumes` field of the operation.
     * <p>
     * Takes in comma-separated values of content types.
     * For example, "application/json, application/xml" would suggest this API Resource
     * accepts JSON and XML input.
     * <p>
     * For JAX-RS resources, this would automatically take the value of the {@code @Consumes}
     * annotation if such exists. It can also be used to override the {@code @Consumes} values
     * for the Swagger documentation.
     */
    String consumes() default "";

    /**
     * Sets specific protocols (schemes) for this operation.
     * <p>
     * Comma-separated values of the available protocols. Possible values: http, https, ws, wss.
     *
     * @return the protocols supported by the operations under the resource.
     */
    String protocols() default "";

    /**
     * Corresponds to the `security` field of the Operation Object.
     * <p>
     * Takes in a list of the authorizations (security requirements) for this operation.
     *
     * @return an array of authorizations required by the server, or a single, empty authorization value if not set.
     * @see Authorization
     */
    Authorization[] authorizations() default @Authorization(value = "");

    /**
     * Hides the operation from the list of operations.
     */
    boolean hidden() default false;

    /**
     * A list of possible headers provided alongside the response.
     *
     * @return a list of response headers.
     */
    ResponseHeader[] responseHeaders() default @ResponseHeader(name = "", response = Void.class);

    /**
     * The HTTP status code of the response.
     * <p>
     * The value should be one of the formal <a target="_blank" href="http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html">HTTP Status Code Definitions</a>.
     */
    int code() default 200;

    /**
     * @return an optional array of extensions
     */

    Extension[] extensions() default @Extension(properties = @ExtensionProperty(name = "", value = ""));

    /**
     * Ignores JsonView annotations while resolving operations and types. For backward compatibility
     *
     */
    boolean ignoreJsonView() default false;
}
```

&emsp;&emsp;接下来，我们一个一个的进行讲解。

## @ApiOperation注解

&emsp;&emsp;通过上面的代码，我们可以知道，这个注解可以使用在方法上和类的上面，但是一般的情况下， 我们都是用在方法上面。代表的是一个`Http`请求方法的描述。

### value属性

&emsp;&emsp;对于`value`属性，表示的是这个方法的一个总结性的描述，在官网的文档中，建议的是我们在描述的时候，尽可能的总结，将字数控制在`120`个字符以为就行。

### notes属性

&emsp;&emsp;对于`note`属性，标识的是对于一个方法的具体性的描述。

### tags属性

&emsp;&emsp;这个操作和之前的`@API`的`tags`属性特别的像，都是给类、请求进行分组、打标签使用的。但是在这里有一点是需要注意的，就是如果同时设置了`@API`的`tags`属性和`@ApiOperation`的`tags`属性，那么此时会通过`@API`的`tags`属性将`Controller`进行分类，而通过`@ApiOperation`的`tags`属性，`Controller`中的请求进行分类。

### response属性

&emsp;&emsp;这个属性设置的是当前请求的返回值类型。例如，我们返回的如果是一个`String`的话，那么在这里写的就是  `String.class`。

### responseContainer属性

&emsp;&emsp;在这里，说明的是包装相应的容器。默认情况下，有效值为 `List`、`Set`、`Map`，任何其它值都将被忽略。

### responseReference属性

&emsp;&emsp;这里设置的是一个相应类型的引用。这个引用可以是本地的，也可以是远程的。如果设置了这个值，将会覆盖`response`属性的值。

### httpMethod属性

&emsp;&emsp;请求方式，例如`GET`、`HEAD`、`POST`、`PUT`、`DELETE`、`OPTIONS`。

### position属性

&emsp;&emsp;这个属性在`Swagger1.5X`版本中已经不再推荐使用了。因此标记了`@Deprecated`注解。如果配置了多个请求方法，想改变显示的顺序位置

### nickname属性

&emsp;&emsp;这个字段对应的是`operationId`字段。第三方工具使用`operationId`来唯一表示此操作.在`Swagger2.0`之后的版本中，这个字段是不在强制的，如果没有，则系统默认为空。

### produces属性

&emsp;&emsp;指定返回的内容类型，仅当`request`请求头中的(`Accept`)类型中包含该指定类型才返回，例如:`application/json`。

### consumes属性

&emsp;&emsp;指定处理请求的提交内容类型(`Content-Type`)，例如`application/json`。

### protocols属性

&emsp;&emsp;标识的是当前的请求支持的协议，例如：`http`、`https`、`ws`、`wss`。

### authorizations属性

&emsp;&emsp;高级特性认证时配置。

### hidden属性

&emsp;&emsp;配置为`true`将在文档中隐藏。隐藏整个`Controller`资源。作用与`@ApiIgnore`类似，但是没有`@ApiIgnore`功能强大。

### responseHeaders属性

&emsp;&emsp;指定`response`中`header`的信息列表

### code属性

&emsp;&emsp;`http`返回状态码

### extensions属性

&emsp;&emsp;可选的扩展数组,举例：`extensions = @Extension(properties ={@ExtensionProperty(name = "author", value = "test@xx.com")})`。

### ignoreJsonView属性

&emsp;&emsp;忽略`JsonView`注解，主要的目的是为了做到向下兼容

## 总结

&emsp;&emsp;今天我们讲解了关于`@ApiOperation`注解的用法。在下面的文章中，我们会总结其他的注解。