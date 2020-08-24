---
title: 自编写Shell脚本-删除Maven无效的文件
permalink: Shell/BatchDeleteUnusedMavenFile
date: 2020-08-13 00:09:56
categories:
- Linux
- Shell脚本
tags:
- Linux
- 脚本
---

# 自编写Shell脚本-删除Maven无效的文件

&emsp;&emsp;这几天家里的网有问题，总是在`maven`下载`jar`包的时候断开，然后就在本地`maven`的`localRepository`中生成了`"*.lastUpdated"`和`"_remote.repositories"`等文件，导致当网络恢复的时候就下载不下来了。为了能下载，只能一个一个的删除。但是这种删除方式过于的麻烦。所以写了一个脚本放在这里，如果脚本本身有问题，烦请各位大佬批评指正。

&emsp;&emsp;对于这两个文件的含义，网上一搜一大堆，在这里不在过多的阐述。下面不废话，直接上代码：

```shell
#bin/bash

# author：BiggerShen

# date：2020年08月12日 23:51:15

# 下面的maven_localRepository_Path和should_be_deleted_file_array是唯一要改动的地方

# 其中，maven_localRepository_Path 代表的是你的maven的localRepository的Path路径，可以使用绝对路径，也可以采用相对路径whoami，路径中可以存在".",例如路径是"/Users/$(whoami)/.m2/repository"
# 也可以是下面demo中的普通路径

# 另外，当前脚本支持一次删除多种类型的文件，对于要删除的文件，只需要下载在 should_be_deleted_file_array 数组中即可，一行代表一种类型，在这里可以指定明确的文件名称，也可以采用通配符的方式，
# 详情请见下面的demo

maven_localRepository_Path="/Users/$(whoami)/maven/localRepository"

should_be_deleted_file_array=(
"*.lastUpdated"
"_remote.repositories"
)

# 下面的代码是删除逻辑执行代码，如无必要，请尽量不要改动，若因私自改动造成文件的误删和破坏，本人不承担任何责任。

echo "Maven 的 LocalRepository Path 是--->\033[36m $maven_localRepository_Path \033[0m"

for single_file_name in ${should_be_deleted_file_array[@]}
do
    tempCount=`(find $maven_localRepository_Path  -name $single_file_name  | wc -l)`
    echo -e "当前操作的对象文件名为：\033[36m $single_file_name \033[0m, 个数为：\033[31m $tempCount \033[0m"
    find $maven_localRepository_Path  -name $single_file_name  | xargs rm -rf
    echo "文件：\033[36m $single_file_name \033[0m 删除成功"
done
```

