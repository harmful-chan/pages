---
layout: post
title: Thingsboard (一) 编译运行(CentOS7.6)
date: 2020-12-19 19:20:23 +0900
category: Thingsboard
---
## Quick Start
```shell
# 安装java 1.8 openjdk
yum install -y java-1.8.0-openjdk-devel
＃ 安装 maven 3.6.3
wget https://apache.website-solution.net/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
tar -xvf apache-maven-3.6.3-bin.tar.gz
cp -rf apache-maven-3.6.3 /usr/local/
ln -s /usr/local/apache-maven-3.6.3/bin/mvn /usr/bin/mvn # 软连接
source /etc/profile ＃ 刷新环境变量 
```

<!--stackedit_data:
eyJoaXN0b3J5IjpbLTEyNjExNDI4MDgsMTM3MzIyOTA2MF19
-->