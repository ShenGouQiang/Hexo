---
title: Swagger文档API学习--ApiModel注解
permalink: Swagger/SwaggerDocumentLearnDay04
date: 2019-11-01 15:25:31
categories:
- Swagger
tags:
- Swagger
---

# Swagger文档API学习--ApiModel注解

&emsp;&emsp;`@ApiModel`这个注解是比较重要的一个注解。因为在实际的开发过程中，我们知道了请求的地址后，我们更加重要的是关心这个接口的请求入参和返回值。而对于`@ApiModel`这个注解,可以良好的展示出请求参数的含义和返回参数的含义。

## 源码展示

```java
import java.lang.annotation.ElementType;
import java.lang.annotation.Inherited;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Provides additional information about Swagger models.
 * <p>
 * Classes will be introspected automatically as they are used as types in operations,
 * but you may want to manipulate the structure of the models.
 */
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Inherited
public @interface ApiModel {
    /**
     * Provide an alternative name for the model.
     * <p>
     * By default, the class name is used.
     */
    String value() default "";

    /**
     * Provide a longer description of the class.
     */
    String description() default "";

    /**
     * Provide a superclass for the model to allow describing inheritance.
     */
    Class<?> parent() default Void.class;

    /**
     * Supports model inheritance and polymorphism.
     * <p>
     * This is the name of the field used as a discriminator. Based on this field,
     * it would be possible to assert which sub type needs to be used.
     */
    String discriminator() default "";

    /**
     * An array of the sub types inheriting from this model.
     */
    Class<?>[] subTypes() default {};

    /**
     * Specifies a reference to the corresponding type definition, overrides any other metadata specified
     */

    String reference() default "";
}
```

## `@ApiModel`这个注解

&emsp;&emsp;这个注解的是作用在类上面的，是用来描述类的一些基本信息的。下面，我们会逐个的进行讲解。

### value属性

&emsp;&emsp;这个属性，提供的是类的一个备用名。如果我们不设置的的话，那么默认情况下，将使用的是`class`类的名字。

### description属性

&emsp;&emsp;对于类，提供一个详细的描述信息

### parent属性

&emsp;&emsp;这个属性，描述的是类的一些父类的信息。

### discriminator属性

&emsp;&emsp;这个属性解释起来有些麻烦，因为这个类主要是体现出了断言当中。

### subTypes属性

&emsp;&emsp;举个实例，如果我们此时有一个父类`Animal`。同时，对于这个父类，我们的系统中有这个类的子类`Cat`、`Dog`、`Pig`等。如果我们在我们的父类上，通过这个属性，指定了我们想要使用的子类的话，那么在生成`Swagger`的文档的话，会自动的展示的是`Animal`这个属性，但是在属性的字段中，会显示出子类的一些独有的属性，其实在这里，是不推荐使用的。因为这样会让别人认为，这些子类独有的属性，也是父类才有的。

&emsp;&emsp;假如我们有如下的几个类：

&emsp;&emsp;Pet类

```java
@ApiModel(value = "Pet", subTypes = {Cat.class},discriminator = "type")
public class Pet {
    private long id;
    private Category category;
    private String name;
    private List<String> photoUrls = new ArrayList<String>();
    private List<Tag> tags = new ArrayList<Tag>();

    @ApiModelProperty(value = "pet status in the store", allowableValues = "available,pending,sold")
    private String status;


    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public Category getCategory() {
        return category;
    }

    public void setCategory(Category category) {
        this.category = category;
    }

    @ApiModelProperty(example = "doggie", required = true)
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<String> getPhotoUrls() {
        return photoUrls;
    }

    public void setPhotoUrls(List<String> photoUrls) {
        this.photoUrls = photoUrls;
    }


    public List<Tag> getTags() {
        return tags;
    }

    public void setTags(List<Tag> tags) {
        this.tags = tags;
    }


    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    private String type;

    @ApiModelProperty(required = true)
    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

}
```

&emsp;&emsp;Cat类

```java
import  javax.xml.bind.annotation.XmlRootElement;

public class Cat extends Pet {

    String catBreed;

    public String getCatBreed() {
        return catBreed;
    }

    public void setCatBreed(String catBreed) {
        this.catBreed = catBreed;
    }
}
```

&emsp;&emsp;接口类

```java
public interface OrderWebApi {
    
    @RequestMapping(value = "/shen/testOne",method = RequestMethod.GET)
    Result<Cat> getOrderDetail(@RequestParam("order_id") Integer orderId);
}
```

&emsp;&emsp;真正的`Controller`类

```java
@RestController
public class OrderWebController  implements OrderWebApi {

    @Override
    public Result<Cat> getOrderDetail(Integer orderId) {
        System.out.println(orderId);
        OrderWebResVo orderWebResVo = new OrderWebResVo();
        orderWebResVo.setAb(SexEnum.MAN);
        orderWebResVo.setAge(20);
        orderWebResVo.setMoney(4000L);
        orderWebResVo.setMoneyOne(3000.0F);
        orderWebResVo.setName("shen");
        orderWebResVo.setSex(new Byte("1"));
        Result<Cat> result = new Result<>();
        result.setCode(20080);
        result.setMessage("SUCCESS");
        result.setData(new Cat());
        return result;
    }
}

```

&emsp;&emsp;但是真正的`Swagger`文档为

![subTypes属性](https://static.shengouqiang.cn/blog/img/swagger/DocumentDay04/subTypes.png)

### reference属性

&emsp;&emsp;指定对相应类型定义的引用，覆盖指定的任何其他元数据。

## 总结

&emsp;&emsp;这个注解主要讲解的是`model`的信息信息，但是对于`POJO`中的内在属性需要参考下一篇文章讲解的`@ApiModelProperty`属性。
