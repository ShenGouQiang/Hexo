---
title: JDK学习--String
permalink: Java/JavaLearnDay02
date: 2019-11-27 19:04:22
categories:
- Java
- JDK
tags:
- Java学习
- JDK学习
---

# JDK学习--String

&emsp;&emsp;在我们第一天开始学习`Java`的时候，我们就开始使用字符串了。说起来，`String`类可以说成是`Java`中最最重要的类了。正因为如此，我们才需要对`String`应该有一些深刻的认识，从而能够让我们更好的使用他们。

&emsp;&emsp;首先这个类位于`java.util`包下。并且这个类是一个`final`类。这也就意味着对于这个类，我们对于他仅仅只是能使用，如果想要修改和继承，那是不可能的了。其次，在`String`类的内部，同样也有一个用`final`修饰的字符数组。因此一旦我们给一个字符串赋值了以后，就不可以再对这个字符串进行修改了。

## String对象的创建

&emsp;&emsp;在我们讲解`String`创建之前，我们首先需要知道一个关于`String`的技术--`String Pool`(以下简称`String池`)。`String`池存在于方法区中，初始为空，并且为各个进程所共享。`String池`中存放的是当我们运行程序时，所创建的字符串常量，并且这些常量是不可以重复的，并且这个`String池`为`String`类私有的维护。

&emsp;&emsp;还有一点就是`String`的`intern`方法。这个方法时一个`native`方法,同时这个方法的作用首先将字符串常量放入到常量池中，然后再堆中自动的创建一个`intern`字符串对象(拘留字符串对象)。此时这个对象的地址会默认的指向常量池的这个字符串。注意，刚才说的这些，都是`Java`自动执行的。不需要我们去进行操作。之所以讲解这些，是为了更好的去理解`Java`对于字符串的创建。

### 使用字面量进行创建一个String变量

```java
String S1 = "ABC";
String S2 = "ABC";
String S3 = "A" + "BC";
String S4 = "A";
String S5 = "BC";
String S6 = S4 + S5;
```

![String-字面量创建过程](http://static.shengouqiang.cn/blog/img/Java/LearnDay02/StringLearn01.jpg)

&emsp;&emsp;在`Java`编译器遇到上面的这句话时，首先会将`"ABC"`放入到常量池中，形成`.class`文件。而在JVM解释字节码、执行程序的时候，首先会在`String`池中创建常量`"ABC"`(图中的①)，然后在堆中自动的创建一个对象(在这里我们将这个堆中自动创建的对象称之为`$_CON_STR3`)(图中的②)。并且这个对象对应`String池`中常量`"ABC"`的地址，此时当我们创建一个`String`类型的引用变量`S1`的时候(图中的③)，此时直接指向了堆中的这个对象`$_CON_STR3`，而这个对象对应的又是`String`池中常量`"ABC"`的地址，因此`S1`也就相当于指向了常量`"ABC"`的地址。此时当`JVM`再执行这句话的时候，此时会发现`String池`中已经存在了`"ABC"`这个常量，同样的也存在了这个对象。因此，`JVM`会直接创建这个`String池`的引用变量`S2`会直接的指向内存中的对象`$_CON_STR3`(图中的④)。因此对于`S1==S2`这个结果，应该是`true`。

&emsp;&emsp;接下来，当`Java`编译源代码的时候，发现在`"+"`号的左右两侧均是字符串常量的时候，此时在编译期间会自动的将两个字符串进行合并，形成`"ABC"`常量，以提高程序的执行效率。同样的，在`JVM`执行时，发现已经在`String池`中存在常量`"ABC"`,因此，`S3`与`S2`的执行操作相同。均是指向已经存在的对象`$_CON_STR3`(图中的⑨)

&emsp;&emsp;同样的，在执行第四行代码时，发现了还存在字符串常量`"A"`，此时`Java`首先回去`String池`中进行检测，是否已经含有字符串常量`"A"`，如果存在直接调用；如果不存在，则在`String`中首先放入字符串常量`"A"`(图中的⑤),然后再内存中自动的进行创建一个`intern`字符串对象`$_CON_STR1`(图中的⑥)，然后创建了一个`String`类型的引用变量，用来存放`$_CON_STR1`的地址(图中的⑩)。接下来，⑦、⑧、⑪与⑤、⑥、⑩的执行操作相同，在这里不再赘述。

&emsp;&emsp;接下来是最最重要的。在执行`S6`这行代码的时候，首先`Java`会再内存中创建一个`StringBuffer`对象`$_STRINGBUFFER_S1`，并且使用`S4`指向的`intern`字符串对象进行初始化(图中的⑫)。并且通过调用`append`方法(图中的⑬)，以`S5`执行的`intern`字符串对象作为参数，让两个字符串拼接起来。然后通过调用`toString`函数(图中的⑭)，在堆中再次生成一个`String`对象`$_CON_STR4`(图中的⑮)。然后会创建一个`String`类型的变量`S6`，用来存储`$_CON_STR4`的地址。

### 通过关键字来创建一个对象

```java
String S1 = new String("ABC");
String S2 = new String("ABC");
String S3 = "ABC";
String S4 = new String(S3);
String S5 = new String("AB");
String S6 = new String("C");
String S7 = S5 + S6;
String S8 = S5 + "C";
```

&emsp;&emsp;同样的，我们还是用一张图进行讲解：

![String-字面量创建过程](http://static.shengouqiang.cn/blog/img/Java/LearnDay02/StringLearn02.jpg)

&emsp;&emsp;在这里，我们需要知道的一点就是，当我们使用`new`关键字来创建一个`String`对象的时候，此时一定会在堆中创建一个对象。因此，当程序执行第一行代码的时候，此时程序首先会在`String池`中查看时候有没有常量`"ABC"`，如果没有，则在`String池`中添加常量`"ABC"`(图中的①)，然后会在堆中自动的创建一个`intern`字符串对象`$_CON_STR1`(图中的②)，然后我们使用`new`关键字来创建一个`String`对象(图中的③)，并且以`$_CON_STR1`为参数，最后创建一个`String`类型的引用变量`S1`(图中的④)用以保存这个通过关键字`new`创建来的对象。

&emsp;&emsp;当程序执行第二行代码的时候，他的执行步骤与很相似。`Java`首先还是会在`String池`中检测时候包含常量`"ABC"`，当`Java`方向包含的时候，会去内存中找到这个常量对应的`intern`字符串对象`$_CON_STR1`，然后再堆中以`$_CON_STR1`对象作为参数，创建一个`String`类型的对象(图中的⑤)，然后创建一个`String`类型的引用变量`S2`(图中的⑥)，用`S2`来存储新创建出来的这个`String`对象。

&emsp;&emsp;同样的，当`Java`在执行第三行代码的时候，此时与第一种情况及其类似。此时方向了`String池`中的常量`"ABC"`,并且找到了`intern`字符串对象，此时`Java`仅仅只是创建了一个`String`类型的引用变量(图中的⑦)，用来保存这个`intern`字符串对象。

&emsp;&emsp;至于第四、五、六行代码的过程与第一、二行及其的相似，再次不再赘述。

&emsp;&emsp;当执行第七行代码的时候，此时`Java`首先会在堆中创建一个`StringBuffer`的对象(图中的⑱)，并且以`S5`作为参数进行初始化，然后通过调用`StringBuffer`类的`append`方法(图中的⑲)，以`S6`为参数进行字符串的合并，然后通过调用该类的`toString`方法，将这个`StringBuffer`对象转换成一个`String`对象`$_CON_STR4`(图中的⑳)，然后`Java`创建一个`String`类型的引用变量`S7`，用来存储这个`String`对象。

&emsp;&emsp;至于第八行代码，此时与第七行及其的相似，再次也不再赘述。

## String类的一些常用的函数

### trim()

&emsp;&emsp;这个函数的目的是为了消除在`Unicode`编码中小于`32`的字符。然后返回给我们修改后的字符串。这个函数的原理是:如果调用的字符串中的第一个字符和最后一个字符都大于`32`，则直接返回这个字符串的引用。但是如果这个字符串中的所有的字符都不大于`32`,则直接`new`一个新的空的`String`对象返回给我们。如果这个字符串的前面或者是后面有小于等于`32`的编码字符，则`new`一个新的空的字符串，然后将这个原来字符串两端的小于等于`32`的编码字符删除后的新字符串赋值给这个新的空字符串，最终返回给我们。

### intern()

&emsp;&emsp;`intern()`是`String`类的一个`public`方法，这个方法的作用是首先拿调用这个函数的字符串和`String池`中的字符串相比较，如果`String池`中含有这个字符串，那么就返回这个字符串的地址，如果没有这个字符串，那么就将这个字符串放入到`String池`中，然后将这个字符串的地址返回回去。它遵循的规则是:假若存在两个字符串`s`、`t`，当且仅当`s.equals(t)==true`时，`s.intern()==t.intern()`才为`true`。

### concat(String str)

&emsp;&emsp;`concat()`是`String`类的一个`public`方法，这个方法是具有参数的。这个方法的目的是将两个字符串拼接在一起。和`"+"`在功能上很类似，但是原理上却大不相同。因为，当`str`的长度为`0`的时候，此时直接返回这个字符串。但是如果这个`str`的长度不为`0`的时候，此时`JAVA`就会创建一个新的字符串。将这两个字符串拼接在一起，返回回来。

### split()

&emsp;&emsp;这个函数在`Java`中有两个重载的方法：`split(String regex,int limit)`和`split(String regex)`;这个函数的作用就是按照我们自己定义的正则表达式，将一个字符串拆分成许多子字符串，并且放在一个`String`类型的数组中返回给我们，如果这个字符串不满足这个正则表达式，那么直接就返回给我们一个空的`String`数组。

&emsp;&emsp;`split(String regex,int limit)`这个方法的两个参数分别代表的是正则表达式和我们可以使用正则表达式匹配的次数。这里需要注意的是，我们能够匹配的次数与`limit`有关:

1. 当`limit>0`的时候，此时我们能够匹配的次数仅仅为`limit-1`次，并且此时返回的数组的长度不会大于`limit`。
2. 当`limit<0`的时候，此时`split`尽可能多的此时被使用，并且返回的数组的长度没有任何的限制。
3. 当`limit=0`的时候，此时`split`尽可能多的此时被使用，并且返回的数组的长度没有任何的限制,并且结尾的空字符串将会被舍弃。

&emsp;&emsp;接下来，我们还有通过一张图进行演示：

![String-字面量创建过程](http://static.shengouqiang.cn/blog/img/Java/LearnDay02/StringLearn03.jpg)

&emsp;&emsp;`split(String regex)`这个方法是上面那个方法的特例，此时他的效果和`split(String regex,0)`的效果是一致的。

&emsp;&emsp;此时有一个特别需要注意的就是，如果我们要拆分的字幕就是这个字符串的最开始的部分，那么返回来的数组的第一项就是一个值为空的字符串。还有，如果`regex`的值为`"|"`，那么他和`""`的效果是等同的。他的效果是逐个字符进行拆分。

### replace与replaceAll

&emsp;&emsp;相同点：

&emsp;&emsp;这两个函数均在`java.util.String`中。并且这两个函数相同的目的都是为了去替换在字符串中出现的所有的我们想要替换的字符或者是字符串。

&emsp;&emsp;对于这两个方法，他们对于原字符串的遍历都是从头开始的。例如：如果在原字符串中出现`"aaa"`子字符串时，我们想要将`"aa"`替换成`"b"`的时候，此时系统会自动替换成`"ba"`，而不会是`"ab"`。对于字符的替换，也是这样。

&emsp;&emsp;不同点：

&emsp;&emsp;1.对于`replace`这个函数，在`String`这个类中，对这个函数进行了重载.
&emsp;&emsp;&emsp;&emsp;1.1 `String replce(char oldChar,char newChar)`通过字面意思，我们不难理解，它是利用字符来进行替换的。它的目的就是从头开始查这个字符串是否出现`oldChar`这个字符，如果出现，那么就替换成`newChar`这个字符。

&emsp;&emsp;&emsp;&emsp;它的运行机制是：首先是遍历这个字符串的每个字符，如果没有发现有`oldChar`这个字符，那么就返回当前这个字符串的一个引用回去。但是一旦在遍历的过程中，找到了`oldChar`这个字符，那么此时就会创建一个新的字符串，是原字符串的副本，然后再这个副本上进行替换操作，最后将这个新的字符串的引用返回给调用方。

&emsp;&emsp;&emsp;&emsp;1.2 `String replace(CharSequence target,CharSequence replacement)`这个方法和上面的方法唯一不同的是，这个方法替换的不是单个的字符，而是一个字符串。机制和上面的差不多。在此不再重述。

&emsp;&emsp;2.对于`replaceAll`这个函数，在`String`这个类中，仅仅只有一个。 `String replaceAll(String regex,String replacement)`这个函数的俩个参数分别是要查找的字符串和要被替换的字符串。

&emsp;&emsp;但是这个类和`replace`确实有很大的区别。因为`replace`不管是两个函数中的哪个，都是进行简简单单的替换而已。但是`replaceAll`的替换却是基于正则表达式的(具体参见度娘)。他的替换很有学问。需要参照正则表达式来进行替换，否则会出错的。并且这个正则表达式是针对于这两个参数的。例如：`"."`这个在正则表达式里面代表的是除了换行符以外的任意符号。因此：

```java
public static void main(String[] args){
    String str="java.util.String";
    String temp=str.replaceAll(".","/");
    System.out.println(temp);
}
```

&emsp;&emsp;对于这个函数，输出的结果正如上面所讲，他的结果是`"////////////////"`，而不是`"java/util/String"`。这仅仅是一个例子，对于这个函数的使用，首先是要了解正则表达式和转义字符`('\')`这两个概念。

&emsp;&emsp;对于上面的那段代码，如果使用的是`replace`函数而不是`replaceAll`函数，那么结果就是`"java/util/String"`。

&emsp;&emsp;还有一个函数，`replaceFirst`这个函数，这个函数就是`replaceAll`这个函数的一个阉割版本，他的作用见名知义，就是通过正则表达式替换第一个符合条件的函数而已。而`replaceAll`替换的是所有的。上面的代码如果用`replaceFirst`这个函数，那么结果就是`"/ava.util.String"`。