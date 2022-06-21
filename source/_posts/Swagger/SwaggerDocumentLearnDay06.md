---
title: Swagger文档API学习--ApiImplicitParams注解
permalink: Swagger/SwaggerDocumentLearnDay06/
date: 2019-11-03 15:03:38
categories:
- Swagger
tags:
- Swagger
---

# Swagger文档API学习--ApiImplicitParams注解

这个注解主要是用来描述方法的请求参数的。例如我们在做`MVC`的开发过程中，当我们需要别人给我们传递参数的时候，我们就可以使用这样的注解，而在我们的代码当中，我们可以使用`Request request`进行接收。例如下面的代码：

```java
 @ApiImplicitParams({
    @ApiImplicitParam(name = "name", value = "User's name", required = true, dataType = "string", paramType = "query"),
    @ApiImplicitParam(name = "email", value = "User's email", required = false, dataType = "string", paramType = "query"),
    @ApiImplicitParam(name = "id", value = "User ID", required = true, dataType = "long", paramType = "query")
  })
 public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {...}
```

## 源码 -- ApiImplicitParams

```java
package io.swagger.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * A wrapper to allow a list of multiple {@link ApiImplicitParam} objects.
 *
 * @see ApiImplicitParam
 */
@Target({ElementType.METHOD, ElementType.ANNOTATION_TYPE, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface ApiImplicitParams {
    /**
     * A list of {@link ApiImplicitParam}s available to the API operation.
     */
    ApiImplicitParam[] value();
}
```

通过源码我们知道,`@ApiImplicitParams`注解仅仅只是接收一个`@ApiImplicitParam`注解的数组而已，因此，真正的重点在于`@ApiImplicitParam`注解。

## 源码 -- ApiImplicitParam

```java
package io.swagger.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Represents a single parameter in an API Operation.
 * <p>
 * While {@link ApiParam} is bound to a JAX-RS parameter,
 * method or field, this allows you to manually define a parameter in a fine-tuned manner.
 * This is the only way to define parameters when using Servlets or other non-JAX-RS
 * environments.
 * <p>
 * This annotation must be used as a value of {@link ApiImplicitParams}
 * in order to be parsed.
 *
 * @see ApiImplicitParams
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface ApiImplicitParam {
    /**
     * Name of the parameter.
     * <p>
     * For proper Swagger functionality, follow these rules when naming your parameters based on {@link #paramType()}:
     * <ol>
     * <li>If {@code paramType} is "path", the name should be the associated section in the path.</li>
     * <li>For all other cases, the name should be the parameter name as your application expects to accept.</li>
     * </ol>
     *
     * @see #paramType()
     */
    String name() default "";

    /**
     * A brief description of the parameter.
     */
    String value() default "";

    /**
     * Describes the default value for the parameter.
     */
    String defaultValue() default "";

    /**
     * Limits the acceptable values for this parameter.
     * <p>
     * There are three ways to describe the allowable values:
     * <ol>
     * <li>To set a list of values, provide a comma-separated list.
     * For example: {@code first, second, third}.</li>
     * <li>To set a range of values, start the value with "range", and surrounding by square
     * brackets include the minimum and maximum values, or round brackets for exclusive minimum and maximum values.
     * For example: {@code range[1, 5]}, {@code range(1, 5)}, {@code range[1, 5)}.</li>
     * <li>To set a minimum/maximum value, use the same format for range but use "infinity"
     * or "-infinity" as the second value. For example, {@code range[1, infinity]} means the
     * minimum allowable value of this parameter is 1.</li>
     * </ol>
     */
    String allowableValues() default "";

    /**
     * Specifies if the parameter is required or not.
     * <p>
     * Path parameters should always be set as required.
     */
    boolean required() default false;

    /**
     * Allows for filtering a parameter from the API documentation.
     * <p>
     * See io.swagger.core.filter.SwaggerSpecFilter for further details.
     */
    String access() default "";

    /**
     * Specifies whether the parameter can accept multiple values by having multiple occurrences.
     */
    boolean allowMultiple() default false;

    /**
     * The data type of the parameter.
     * <p>
     * This can be the class name or a primitive.
     */
    String dataType() default "";

    /**
     * The class of the parameter.
     * <p>
     * Overrides {@code dataType} if provided.
     */
    Class<?> dataTypeClass() default Void.class;

    /**
     * The parameter type of the parameter.
     * <p>
     * Valid values are {@code path}, {@code query}, {@code body},
     * {@code header} or {@code form}.
     */
    String paramType() default "";

    /**
     * a single example for non-body type parameters
     *
     * @since 1.5.4
     *
     * @return
     */
    String example() default "";

    /**
     * Examples for the parameter.  Applies only to BodyParameters
     *
     * @since 1.5.4
     *
     * @return
     */
    Example examples() default @Example(value = @ExampleProperty(mediaType = "", value = ""));

    /**
     * Adds the ability to override the detected type
     *
     * @since 1.5.11
     *
     * @return
     */
    String type() default "";

    /**
     * Adds the ability to provide a custom format
     *
     * @since 1.5.11
     *
     * @return
     */
    String format() default "";

    /**
     * Adds the ability to set a format as empty
     *
     * @since 1.5.11
     *
     * @return
     */
    boolean allowEmptyValue() default false;

    /**
     * adds ability to be designated as read only.
     *
     * @since 1.5.11
     *
     */
    boolean readOnly() default false;

    /**
     * adds ability to override collectionFormat with `array` types
     *
     * @since 1.5.11
     *
     */
    String collectionFormat() default "";
}
```

### name属性

请求参数的名字，如果在你的代码中，设置了`paramType`,则该属性代表的是请求路径中的某个关联值，如果没有设置`paramType`属性，则name代表的就是普通的参数的名字。

### value属性

参数的简明描述。

### defaultValue属性

参数默认值

### allowableValues属性

标明字段的取值范围，设置的方式有三种
1.第一种是采用枚举的形式。
例如：`allowableValue="{first, second, third}"`
2.第二种是采用一个有限的范围，例如`"range[1, 5]"`、`"range(1, 5)"`、`"range[1, 5)"`。其中，
2.1 `[`表示是大于等于
2.2 `(`表示是大于
2.3 `]`表示是小于等于
2.4 `)`表示是小于
3.标识的是一个无限的范围。其中，我们使用`infinity`表示无限大，使用`-infinity`表示负无限大。
例如:`"range[1, infinity]"`。

### required属性

确定是否是必传字段，默认`是false`。

### access属性

这个属性的意思是允许从API文档中过滤属性，详情，我们可以参见`io.swagger.core.filter.SwaggerSpecFilter`。在接下来的代码中我们会讲到。

### allowMultiple属性

表示的是允许多个，一般用在`Array`、`List`上面。

### dataType属性

参数的数据类型，如果我们设置了这个属性，将被覆盖掉通过内省获得的参数的数据类型。并且这个数据类型可以是基本数据类型，也可以是类的名字。如果是基本数据类型，为了防止抛出`XXX`的错误
1.我们可以采用配置`example`属性一起使用
2.我们可以通过升级`swagger-annotations`和`swagger-models`的版本来避免，升级到`XXX`版本即可。

### dataTypeClass属性

指定参数的class文件。如果我们在设置中提供了该参数，将自动的覆盖掉`dataType`参数。

### paramType属性

参数的参数类型，一般有：
1. path
2. query
3. body
4. header
5. form

### example属性

对于非`body`类型的参数的一个举例说明。

### examples属性

参数的举例说明，仅适用于`body`类型。

### type属性

参数的类型。这字段适用于`paramType`为非`body`的情况，可选的参数类型为：
1. string
2. number
3. integer
4. boolean
5. array
6. file --如果是file的话，那么`consumes`字段必须是`multipart/form-data`, `application/x-www-form-urlencoded`中的一种或几种。


### format属性

自定义参数的格式。

实际参数名(Common Name)|类型(type)|参数格式(format)|备注(Comments)
:-:|:-:|:-:|:-:
integer|integer|int32|32位整数
long|integer|int64|64位整数
float|number|float|
double|number|double|
string|string||
byte|string|byte|一个byte数组
binary|string|binary|二进制序列
boolean|boolean||
date|string|date|根据`RFC3339`定义的日期格式
dateTime|string|date-time|根据`RFC3339`定义的时间格式
password|string|password|用于提示是否需要掩码输入

### allowEmptyValue属性

允许参数为空，模式是`false`。

### readOnly属性

设置参数是只读模式，不允许修改。

### collectionFormat属性

在这里，如果我们的参数类型是一个数组的话，在这里，我们可以设定数组的格式，通常有：
1. csv---利用逗号`,`分割值
2. ssv---利用空格分割值
3. tsv---利用制表符`\t`分割值
4. pipes---利用管道`|`分割值
5. multi---多元素分割值。
默认情况下，是`csv`格式的。


## 总结

`@ApiImplicitParams`和`@ApiImplicitParam`注解主要是用来描述请求参数的一些基本信息的，在实际的工作中经常会用的到。
