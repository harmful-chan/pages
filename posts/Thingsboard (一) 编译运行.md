---
layout: post
title: "Thingsboard (一) 编译运行"
platform: "Centos 7.6"
author: "harmful-chan"
date: "2020-12-05 17:10"
tags: 
  - thingsboard
---
## Quick Start
**安装 java nodejs maven 代码**
```ruby
# 安装java 1.8 openjdk
yum install -y java-1.8.0-openjdk-devel
# 安装 maven 3.6.3
wget https://apache.website-solution.net/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
tar -xvf apache-maven-3.6.3-bin.tar.gz
cp -rf apache-maven-3.6.3 /usr/local/
ln -s /usr/local/apache-maven-3.6.3/bin/mvn /usr/bin/mvn # 软连接
source /etc/profile ＃ 刷新环境变量 
# 安装 nodejs，以下步骤先翻墙哦
# 安装 nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
# 重新进入终端环境变量才生效
# 安装nodejs
nvm install node
# 拉源码
git clone https://github.com/thingsboard/thingsboard.git
```
**编译**
```ruby
# 安装前段工具
npm install -g cross-env webpack gulp
# 删除 license 信息， 在每个文件开头都有一段的
cd thingsboard
git checkout release-3.2
mvn license:remove
# 注释掉license插件
sed -i '675a\<!--' pom.xml
sed -i '738a\-->' pom.xml

mvn clean install -DskipTests -X //跳过编译测试文件，编译DEBUGE版，linux加上sudo
```

## Require

git 2.16.2 windows命令行版

java jdk 1.8：https://www.cnblogs.com/harmful-chan/p/12193497.html

maven 3.6.3：https://www.cnblogs.com/harmful-chan/p/12193579.html

nvm 1.1.7：https://www.cnblogs.com/harmful-chan/p/12193611.html

　　nodejs10.16.0 

　　npm 6.9.0

数据库准备：

　　postgreSQL 9.5.20：介绍安装及配置

## 1 编译前准备

#### 1.1 下载源码，安装部件

```
npm install -g cross-env
npm install -g webpack
npm install -g gulp
git clone https://github.com/thingsboard/thingsboard.git
cd thingsboard
git branch -a    //查看分支
git checkout release-2.4    //本机发布版最新是2.4建议用这个
```

#### 1.2 屏蔽**license**，修改node版本

记事板打开thingsboard/pom.xml找到“license-maven-plugin”节点注释掉，修改node，npm版本

![img](C:\Users\Administrator\Desktop\summary\posts\Thingsboard (一) 编译运行.assets\1561523-20200114163106000-1551407782.png)

![img](C:\Users\Administrator\Desktop\summary\posts\Thingsboard (一) 编译运行.assets\1561523-20200114163444498-1760021667.png)

跳过js-executor和web-ui的windows编译，本地测试不需要，部署应用才需要打包，同时修改以下两个文件，注释掉这个插件

```
vim thingsboard/msa/js-executor/pom.xml
vim thingsboardmsa/web-ui/pom.xml
```

![img](C:\Users\Administrator\Desktop\summary\posts\Thingsboard (一) 编译运行.assets\1561523-20200314182928867-1242400078.png)

#### 1.3 添加meven仓库

![img](C:\Users\Administrator\Desktop\summary\posts\Thingsboard (一) 编译运行.assets\1561523-20200314182928867-1242400078-164647672061318.png)

**添加Maven仓库**

这一步很重要，其他仓库或多或少少几个包，导致编译失败

```
　　<mirror>
      <!--This sends everything else to /public -->
      <id>nexus</id>
      <mirrorOf>*</mirrorOf>      
      <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
　　</mirror>
　　<mirror>
      <!--This is used to direct the public snapshots repo in the
          profile below over to a different nexus group -->
      <id>nexus-public-snapshots</id>
      <mirrorOf>public-snapshots</mirrorOf>
      <url>http://maven.aliyun.com/nexus/content/repositories/snapshots/</url>
　　</mirror>
```

## 2 打包

```
mvn clean install -DskipTests -X    //跳过编译测试文件，编译DEBUGE版，linux加上sudo
```

**![img](C:\Users\Administrator\Desktop\summary\posts\Thingsboard (一) 编译运行.assets\1561523-20200114163846137-25911816.png)**

 **注意：基本上面步骤不可能顺利完成的，下面开始填坑。**

**1、必须用管理员身份打开cmd，编译过程频繁复制拷贝下载，一步错要重新来过。如果不放心把文件夹的只读权限去掉。**

右击thingsboard文件夹属性，把只读的勾勾去掉。这步用处不大，但好过没有。

![img](C:\Users\Administrator\Desktop\summary\posts\Thingsboard (一) 编译运行.assets\1561523-20200114164812312-776045672.png)

**2、Thingsboard HTTP Transtorp [17/32] 发生错误，说xxx删除不掉，打开控制，把正在运行的JAVA 虚拟机结束任务再编译。**

正常的话如果没用运行过java应用，这个虚拟机都不会用到。

![img](C:\Users\Administrator\Desktop\summary\posts\Thingsboard (一) 编译运行.assets\1561523-20200114165311511-1785899354.png)

 **3.Thingsboard Server UI [22/32] 22还是23忘了，总之就是UI部件报错 。npm ERR! errno: -4048, 之类的。**

```
1、 删除 C:\Users\{当前用户名}\.npmrc文件    //这个是切换国内源用到的临时文件，看别人删我也删了
2、 清空 C:\Users\{当前用户名}\AppData\Roaming\npm-cache    //npm临时缓存
3、 删除 thingsboard\ui\node_modules目录
4、 运行 npm cache clean --force    //清空缓存5、 再次运行打包命令
```

 **4、maven错误，说下载不到xxx包更换源，再打包**

 **5、其他错误，再找吧，一次不行试多两次哈哈。**

参考：

https://blog.csdn.net/liuli283/article/details/88376975

https://www.cnblogs.com/Qianwen-Li/p/11562348.html

https://www.cnblogs.com/danny-djy/p/9051714.html 
