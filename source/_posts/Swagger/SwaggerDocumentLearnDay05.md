---
title: Swagger文档API学习--ApiModelProperty注解
permalink: Swagger/SwaggerDocumentLearnDay05
date: 2019-11-02 23:09:28
categories:
- Swagger
tags:
- Swagger
---

# Swagger文档API学习--ApiModelProperty注解

&emsp;&emsp;这个注解是配合`@ApiModel`注解一起使用的。同时这个注解与`@ApiModel`不同，`@ApiModel`是描述的是类的信息，而`@ApiModelProperty`属性描述的是类的属性的信息。

## 源码

```java
package io.swagger.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Adds and manipulates data of a model property.
 */
@Target({ElementType.METHOD, ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
public @interface ApiModelProperty {
    /**
     * A brief description of this property.
     */
    String value() default "";

    /**
     * Allows overriding the name of the property.
     *
     * @return the overridden property name
     */
    String name() default "";

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
     * Allows for filtering a property from the API documentation. See io.swagger.core.filter.SwaggerSpecFilter.
     */
    String access() default "";

    /**
     * Currently not in use.
     */
    String notes() default "";

    /**
     * The data type of the parameter.
     * <p>
     * This can be the class name or a primitive. The value will override the data type as read from the class
     * property.
     */
    String dataType() default "";

    /**
     * Specifies if the parameter is required or not.
     */
    boolean required() default false;

    /**
     * Allows explicitly ordering the property in the model.
     */
    int position() default 0;

    /**
     * Allows a model property to be hidden in the Swagger model definition.
     */
    boolean hidden() default false;

    /**
     * A sample value for the property.
     */
    String example() default "";

    /**
     * Allows a model property to be designated as read only.
     *
     * @deprecated As of 1.5.19, replaced by {@link #accessMode()}
     *
     */
    @Deprecated
    boolean readOnly() default false;

    /**
     * Allows to specify the access mode of a model property (AccessMode.READ_ONLY, READ_WRITE)
     *
     * @since 1.5.19
     */
    AccessMode accessMode() default AccessMode.AUTO;


    /**
     * Specifies a reference to the corresponding type definition, overrides any other metadata specified
     */

    String reference() default "";

    /**
     * Allows passing an empty value
     *
     * @since 1.5.11
     */
    boolean allowEmptyValue() default false;

    /**
     * @return an optional array of extensions
     */
    Extension[] extensions() default @Extension(properties = @ExtensionProperty(name = "", value = ""));

    enum AccessMode {
        AUTO,
        READ_ONLY,
        READ_WRITE;
    }
}
```

## @ApiModelProperty注解

### value属性

&emsp;&emsp;简洁的介绍字段描述。

### name属性

&emsp;&emsp;如果设置这个字段，会覆盖原本属性的名字。

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

### access属性

&emsp;&emsp;这个属性的意思是允许从API文档中过滤属性，详情，我们可以参见`io.swagger.core.filter.SwaggerSpecFilter`。在接下来的代码中我们会讲到。

### notes属性

&emsp;&emsp;该字段是预留字段，目前并未被使用。

### dataType属性

&emsp;&emsp;参数的数据类型，如果我们设置了这个属性，将被覆盖掉通过内省获得的参数的数据类型。并且这个数据类型可以是基本数据类型，也可以是类的名字。如果是基本数据类型，为了防止抛出`java.lang.NumberFormatException: For input string: ""`的错误
&emsp;&emsp;&emsp;&emsp;1.我们可以采用配置`example`属性一起使用
&emsp;&emsp;&emsp;&emsp;2.我们可以通过升级`swagger-annotations`和`swagger-models`的版本来避免，升级到`1.5.21`版本即可。

### required属性

&emsp;&emsp;表示的是当前字段是否是必须的，默认是`false`。

### position属性

&emsp;&emsp;已过时的方法，代表是属性在文档中的位置排序。

### hidden属性

&emsp;&emsp;表示的是是否隐藏当前字段，默认是`false`。

### example属性

&emsp;&emsp;举例说明。

### readOnly属性

&emsp;&emsp;过时方法，在`Swagger1.5.19`版本之后，采用`accessMode`注解代替。

### accessMode属性

&emsp;&emsp;属性的数据模式。使用的是一个枚举`AccessMode`的值，其中包括`AUTO`、`READ_ONLY`、`READ_WRITE`。

### reference属性

&emsp;&emsp;指定了属性的类型引用，如果设置了当前属性，会覆盖任何其他的元数据(`不常使用`)。

### allowEmptyValue属性

&emsp;&emsp;是否允许该字段为空，默认是`false`。

### extensions属性

&emsp;&emsp;该属性用于进行额外的描述。是一个可选项的数组组成。

## 总结

&emsp;&emsp;`@ApiModelProperty`注解主要是对于类的内部的一个属性的描述。