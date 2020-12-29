---
layout: post
title: Thingsboard (一) 编译运行(CentOS7.6) 
date: 2020-12-19 19:20:23 +0900
category: Thingsboard
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
