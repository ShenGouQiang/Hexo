---
title: Swagger文档API学习--ApiParam注解
permalink: Swagger/SwaggerDocumentLearnDay07/
date: 2019-11-03 17:30:23
categories:
- Swagger
tags:
- Swagger
---

# Swagger文档API学习--ApiParam注解

&emsp;&emsp;这个注解也是用来描述一些请求的请求参数的。和`@ApiImplicitParams`比较类似。

## 源码

```java
package io.swagger.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Adds additional meta-data for operation parameters.
 * <p>
 * This annotation can be used only in combination of JAX-RS 1.x/2.x annotations.
 */
@Target({ElementType.PARAMETER, ElementType.METHOD, ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
public @interface ApiParam {
    /**
     * The parameter name.
     * <p>
     * The name of the parameter will be derived from the field/method/parameter name,
     * however you can override it.
     * <p>
     * Path parameters must always be named as the path section they represent.
     */
    String name() default "";

    /**
     * A brief description of the parameter.
     */
    String value() default "";

    /**
     * Describes the default value for the parameter.
     * <p>
     * If the parameter is annotated with JAX-RS's {@code @DefaultValue}, that value would
     * be used, but can be overridden by setting this property.
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
     * Path parameters will always be set as required, whether you set this property or not.
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
     * Hides the parameter from the list of parameters.
     */
    boolean hidden() default false;

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

&emsp;&emsp;参数的命名。

### value属性

&emsp;&emsp;参数的简明描述。

### defaultValue属性

&emsp;&emsp;参数默认值

### allowableValues属性

&emsp;&emsp;标明字段的取值范围，设置的方式有三种
&emsp;&emsp;&emsp;&emsp;1.第一种是采用枚举的形式。
&emsp;&emsp;&emsp;&emsp;&emsp;例如：`allowableValue="{first, second, third}"`
&emsp;&emsp;&emsp;&emsp;2.第二种是采用一个有限的范围，例如`"range[1, 5]"`、`"range(1, 5)"`、`"range[1, 5)"`。其中，
&emsp;&emsp;&emsp;&emsp;&emsp;2.1 `[`表示是大于等于
&emsp;&emsp;&emsp;&emsp;&emsp;2.2 `(`表示是大于
&emsp;&emsp;&emsp;&emsp;&emsp;2.3 `]`表示是小于等于
&emsp;&emsp;&emsp;&emsp;&emsp;2.4 `)`表示是小于
&emsp;&emsp;&emsp;&emsp;3.标识的是一个无限的范围。其中，我们使用`infinity`表示无限大，使用`-infinity`表示负无限大。
&emsp;&emsp;&emsp;&emsp;&emsp;例如:`"range[1, infinity]"`。

### required属性

&emsp;&emsp;确定是否是必传字段，默认`是false`。

### access属性

&emsp;&emsp;这个属性的意思是允许从API文档中过滤属性，详情，我们可以参见`io.swagger.core.filter.SwaggerSpecFilter`。在接下来的代码中我们会讲到。

### allowMultiple属性

&emsp;&emsp;表示的是允许多个，一般用在`Array`、`List`上面。

### hidden属性

&emsp;&emsp;从参数列表中隐藏该属性，默认`是false`。

### example属性

&emsp;&emsp;对于非`body`类型的参数的一个举例说明。

### examples属性

&emsp;&emsp;参数的举例说明，仅适用于`body`类型。

 ### type属性

&emsp;&emsp;参数的类型。这字段适用于`paramType`为非`body`的情况，可选的参数类型为：
&emsp;&emsp;&emsp;&emsp;1. string
&emsp;&emsp;&emsp;&emsp;2. number
&emsp;&emsp;&emsp;&emsp;3. integer
&emsp;&emsp;&emsp;&emsp;4. boolean
&emsp;&emsp;&emsp;&emsp;5. array
&emsp;&emsp;&emsp;&emsp;6. file --如果是file的话，那么`consumes`字段必须是`multipart/form-data`, `application/x-www-form-urlencoded`中的一种或几种。

### format属性

&emsp;&emsp;自定义参数的格式。

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

&emsp;&emsp;允许参数为空，模式是`false`。

### readOnly属性

&emsp;&emsp;设置参数是只读模式，不允许修改。

### collectionFormat属性

&emsp;&emsp;在这里，如果我们的参数类型是一个数组的话，在这里，我们可以设定数组的格式，通常有：
&emsp;&emsp;&emsp;&emsp;1. csv---利用逗号`,`分割值
&emsp;&emsp;&emsp;&emsp;2. ssv---利用空格分割值
&emsp;&emsp;&emsp;&emsp;3. tsv---利用制表符`\t`分割值
&emsp;&emsp;&emsp;&emsp;4. pipes---利用管道`|`分割值
&emsp;&emsp;&emsp;&emsp;5. multi---多元素分割值。
&emsp;&emsp;默认情况下，是`csv`格式的。

## 总结

&emsp;&emsp;`@ApiImplicitParams`和`@ApiParam`注解的功能高度的类似，在实际的使用中，我们可以有选择的使用即可。