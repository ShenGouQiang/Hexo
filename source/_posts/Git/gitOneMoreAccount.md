---
title: 同一电脑配置多个Git账号
permalink: Git/gitOneMoreAccount
categories:
  - 其他
tags:
  - Git
date: 2019-09-16 21:58:58
---
# 同一个电脑配置多个GIt账号

&emsp;&emsp;在我们日常开发的过程中，我们经常需要在我们的电脑中配置多个`Git`账户的`SSH-KEY`信息,但是在默认的情况下，我们通常会给我们的电脑配置一个全局的`SSH-KEY`信息，因此，在这里，我们讲解下如何配置过个`SSH-KEY`信息。

## 1.清除全局配置信息

&emsp;&emsp;因为在我们的电脑中以后会存在多个`Git`账户，因此我们需要将我们全局的`Git`的邮箱与用户名进行取消掉，取消命令如下：

```shell
git config --global --unset user.name
git config --global --unset user.email
```

&emsp;&emsp;如果你没有配置，那么是不需要删除的。如果执行完命令后，想查看是否成功，可以使用命令：

```shell
git config --list
```

## 2.配置公私钥

&emsp;&emsp;首先我们进入到我们终端，在终端的默认目录下，进入到隐藏文件夹`.ssh`文件夹中，此时假设分别有`github`和`gitee`的账号，测试我们可以进行如下配置：

### 2.1先配置github

&emsp;&emsp;此时我们执行如下命令：

```shell
ssh-keygen -t rsa -C "github邮箱账号"
```

&emsp;&emsp;此时我们看见出现了如下的提示：

![填写公私钥的位置信息](https://oss.shengouqiang.cn/img/gitOneMoreAccount/saveTheGitHubKey.jpg)

&emsp;&emsp;此时在这里我们写入:`id_rsa_github`，写完之后，我们输入回车，此时会出现是否要对公私钥添加密码信息，此时我们选择不需要，然后直接一路回车到最后就可以了。

### 2.2再配置gitee

&emsp;&emsp;此时我们执行如下命令：
```shell
ssh-keygen -t rsa -C "gitee邮箱账号"
```
&emsp;&emsp;此时我们看见出现了如下的提示：

![填写公私钥的位置信息](https://oss.shengouqiang.cn/img/gitOneMoreAccount/saveTheGiteeKey.jpg)

&emsp;&emsp;此时在这里我们写入:`id_rsa_gitee`，写完之后，我们输入回车，此时会出现是否要对公私钥添加密码信息，此时我们选择不需要，然后直接一路回车到最后就可以了。

## 3.添加config配置文件

&emsp;&emsp;在`.ssh`文件夹中，我们首先创建一个文件

```shell
touch config
```

&emsp;&emsp;此时，我们打开文件，写入如下配置：

```
Host github
Hostname github.com
User git
IdentityFile ~/.ssh/id_rsa_github

Host gitee.com
Hostname gitee.com
User git
IdentityFile ~/.ssh/id_rsa_gitee
```

&emsp;&emsp;在这里，我们说下配置中每一项的内容：

1. `Host`：名字可以取为自己喜欢的名字，不过这个会影响`git`相关命令,例如：如果我们的`Host`改成`myOwn`的话，此时执行`git clone` 的话,会变成 `git clone git@myOwn:XXXXXX`。
2. `Hostname`：这个是真实的域名地址
3. `User`：配置使用用户名,这里默认是`git`,不需要进行改动。
4. `IdentityFile`：默认为公钥文件的绝对路径地址信息。


## 4.添加公钥到对应的平台上

&emsp;&emsp;此时，我们以`gitee`为例：

1. 首先登陆`gitee.com`
2. 输入用户名、密码
3. 进入我的码云，然后点击头像，进行设置

![填写公私钥的位置信息](https://oss.shengouqiang.cn/img/gitOneMoreAccount/findTheSettings.jpg)

4. 在这里，我们首先找到在第二步生成的`id_rsa_gitee.pub`文件，将文件的内容复制到下面中：

![填写公私钥的位置信息](https://oss.shengouqiang.cn/img/gitOneMoreAccount/addTheSshKey.jpg)

## 5.进行测试
&emsp;&emsp;在这里，我们测试可以使用`ssh`的一个命令：

```shell
ssh -T gitee.com
```

&emsp;&emsp;如果此时程序出现的是：

![填写公私钥的位置信息](https://oss.shengouqiang.cn/img/gitOneMoreAccount/showSuccessResult.jpg)

&emsp;&emsp;那么此时恭喜你，你已经配置成功了。如果出现了

![填写公私钥的位置信息](https://oss.shengouqiang.cn/img/gitOneMoreAccount/showErrorResult.jpg)

&emsp;&emsp;那么你可以执行如下命令，查看问题的具体原因：

```
ssh -T -v gitee.com
```

## 6.初始化文件
&emsp;&emsp;因为我们在第一步取消了`email`和`name`的全局配置，因此我们在执行`git clone`和`git init`的时候，可以执行如下的两条命令，来初始化配置一些信息

```shell
git config user.name "yourname"
git config user.email "youremail"
```
