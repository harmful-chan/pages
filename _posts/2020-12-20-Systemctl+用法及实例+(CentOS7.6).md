---
layout: post
title: Systemctl 用法及实例(CentOS7.6)
date: 2020-12-20 12:20:23 +0900
category: CentOS7.6
---
## 前言
Systemd 是一系列工具的集合，其作用也远远不仅是启动操作系统，它还接管了后台服务、结束、状态查询，以及日志归档、设备管理、电源管理、定时任务等许多职责，并支持通过特定事件（如插入特定 USB 设备）和特定端口数据触发的 On-demand（按需）任务。

## 存放位置
系统服务，开机不需要登录就能运行的程序（可以用于开机自启）
**/usr/lib/systemd/system** 
用户服务，需要登录后才能运行程序
**/usr/lib/systemd/user**
命名
**一般xxx.service**

## Quick Start
#### nginx
> **nginx.service**
```shell
[Unit]
Description=nginx
After=network.target 
[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecStop=/usr/local/nginx/sbin/nginx -s stop -c /usr/local/nginx/conf/nginx.conf
ExecReload= /usr/local/nginx/sbin/nginx -s reload -c /usr/local/nginx/conf/nginx.conf
PrivateTmp=ture
[Install]
WantedBy=multi-user.target
```

#### vs code
> **code-server.service**
```shell
[Unit]
Description=code-server background running.
After=network.target 

[Service]
Type=simple
Environment="PASSWORD=XXX"
EnvironmentFile=-/etc/code-server/code-server
PIDFile=/run/code-server.pid
ExecStart=/usr/bin/code-server --config /etc/code-server/code-server.config.yaml
KillSignal=control-group
ExecStop=/bin/kill -SIGTERM $MAINPID
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
```


## **参数详解**
#### **[Unit]**
```shell
Description：简短描述
Documentation：文档地址
Requires：当前 Unit 依赖的其他 Unit，如果它们没有运行，当前 Unit 会启动失败
Wants：与当前 Unit 配合的其他 Unit，如果它们没有运行，当前 Unit 不会启动失败
BindsTo：与Requires类似，它指定的 Unit 如果退出，会导致当前 Unit 停止运行
Before：如果该字段指定的 Unit 也要启动，那么必须在当前 Unit 之后启动
After：如果该字段指定的 Unit 也要启动，那么必须在当前 Unit 之前启动
Conflicts：这里指定的 Unit 不能与当前 Unit 同时运行
Condition...：当前 Unit 运行必须满足的条件，否则不会运行
Assert...：当前 Unit 运行必须满足的条件，否则会报启动失败

    +-------------------+    +---------------------+
    |After->Condition...| -> |Requires -> Assert...| ->
    +-------------------+    +---------------------+
    +-----+    +-------+    +------+
 -> |Wants| -> |BindsTo| -> |Before| -> ...
    +-----+    +-------+    +------+
```
#### **[Service]**
```shell
Type：定义启动时的进程行为。它有以下几种值。
    Type=simple：(默认值)启动一个子进程运行命令，用于不会退出的程序
    Type=forking：fork一个字进程，等待命令完成后退出，多用于后台进程 
    Type=oneshot：systemctl 等待命令完成再往下执行，像在控制台执行一个命令一样
    Type=dbus：当前服务通过D-Bus启动
    Type=notify：当前服务启动完毕，会通知Systemd，再继续往下执行
    Type=idle：若有其他任务执行完毕，当前服务才会运行
PIDFile：存放PID的绝对路径
ExecStart：启动当前服务的命令
ExecStartPre：启动当前服务之前执行的命令
ExecStartPost：启动当前服务之后执行的命令
ExecReload：重启当前服务时执行的命令
ExecStop：停止当前服务时执行的命令
ExecStopPost：停止当其服务之后执行的命令
RestartSec：自动重启当前服务间隔的秒数
Restart：定义何种情况 Systemd 会自动重启当前服务 
    no(默认值)： # 退出后无操作
    on-success:  # 只有正常退出时（退出状态码为0）,才会重启
    on-failure:  # 非正常退出时，重启，包括被信号终止和超时等
    on-abnormal: # 只有被信号终止或超时，才会重启
    on-abort:    # 只有在收到没有捕捉到的信号终止时，才会重启
    on-watchdog: # 超时退出时，才会重启
    always:      # 不管什么退出原因，都会重启（除了systemctl stop）
    # 对于守护进程，推荐用on-failure
KillMode的类型：
    control-group(默认)：# 当前控制组里的所有子进程，都会被杀掉
    process: # 只杀主进程
    mixed:   # 主进程将收到SIGTERM信号，子进程收到SIGKILL信号
    none:    # 没有进程会被杀掉，只是执行服务的stop命令
PrivateTmp=true # 表示给服务分配独立的临时空间
TimeoutSec：停止命令执行前等待秒数。
TimeoutStartSec：启动命令执行后等待秒数，超时停止。（0 关闭超时检测）
TimeoutStopSec：停止命令执行后等待秒数，超时使用 SIGKILL 停止服务。
Environment：为服务指定环境变量。
EnvironmentFile：环境变量文件，一行一个不要有空格。
Nice：进程优先级（默认为0）其中 -20 为最高优先级，19 为最低优先级。
WorkingDirectory：指定服务的工作目录，目录不纯在命令不能运行
RootDirectory：指定服务进程的根目录（/ 目录）。如果配置了这个参数，服务将无法访问指定目录以外的任何文件
User：指定运行服务的用户
Group：指定运行服务的用户组
MountFlags：服务的 Mount Namespace 配置，会影响进程上下文中挂载点的信息。
    shared：服务与主机共用一个 Mount Namespace，相互影响
    slave：服务使用独立的 Mount Namespace，它会继承主机挂载点，
    但服务对挂载点的操作只有在自己的 Namespace 内生效，不会反映到主机上。
    private：服务使用独立的 Mount Namespace，
    它在启动时没有任何任何挂载点，服务对挂载点的操作也不会反映到主机上。
LimitCPU：LimitSTACK：\
LimitNOFILE：LimitNPROC： 限制特定服务的系统资源量，请看参考

    +-----------+    +----+
    |User->Group| -> |Nice| -> 
    +-----------+    +----+
    +---------------------------------+    +---------------+    +-------+
 -> |RootDirectory -> WorkingDirectory| -> |EnvironmentFile| -> |PIDFile|
    +---------------------------------+    +---------------+    +-------+
    +----+    +-------------------------------------------------------------+    
 -> |Type| -> |ExecStartPre -> ExecStart -> ExecStartPost -> TimeoutStartSec| -> 
    +----+    +-------------------------------------------------------------+ 
    +-------+    +------------------------+
 -> |Restart| -> |ExecReload -> RestartSec| -> 
    +-------+    +------------------------+
	+--------+    +--------------------------------------------------------+
 -> |KillMode| -> |TimeoutSec -> ExecStop -> ExecStopPost -> TimeoutStopSec| -> ...
    +--------+    +--------------------------------------------------------+
```
#### **[Install]**
```shell
WantedBy：Unit 激活时（enable）xxx.service符号链接会放入/etc/systemd/system/xxx.target.wants/目录下面
    multi-user.target: # 表示多用户命令行状态，这个设置很重要
    graphical.target:  # 表示图形用户状体，它依赖于multi-user.target
RequiredBy：Unit 激活时（enable）xxx.service符号链接会放入/etc/systemd/system/xxx.target.required/目录下面
Alias：当前 Unit 可用于启动的别名
Also：当前 Unit 激活（enable）时，会被同时激活的其他 Unit
```
## **Unit 文件占位符和模板**

#### **占位符**
在 Unit 文件中，有时会需要使用到一些与运行环境有关的信息，例如节点 ID、运行服务的用户等。这些信息可以使用占位符来表示，然后在实际运行被动态地替换实际的值。
```shell
-   %n：完整的 Unit 文件名字，包括 .service 后缀名
-   %p：Unit 模板文件名中 @ 符号之前的部分，不包括 @ 符号
-   %i：Unit 模板文件名中 @ 符号之后的部分，不包括 @ 符号和 .service 后缀名
-   %t：存放系统运行文件的目录，通常是 “run”
-   %u：运行服务的用户，如果 Unit 文件中没有指定，则默认为 root
-   %U：运行服务的用户 ID
-   %h：运行服务的用户 Home 目录，即 %{HOME} 环境变量的值
-   %s：运行服务的用户默认 Shell 类型，即 %{SHELL} 环境变量的值
-   %m：实际运行节点的 Machine ID，对于运行位置每个的服务比较有用
-   %b：Boot ID，这是一个随机数，每个节点各不相同，并且每次节点重启时都会改变
-   %H：实际运行节点的主机名
-   %v：内核版本，即 “uname -r” 命令输出的内容
-   %%：在 Unit 模板文件中表示一个普通的百分号
```
#### **模板**
Unit 模板文件的写法与普通的服务 Unit 文件基本相同，不过 Unit 模板的文件名是以 @ 符号结尾的。通过模板启动服务实例时，需要在其文件名的 @ 字符后面附加一个参数字符串。
```shell
# apache@.service 模板
[Unit]
Description=My Advanced Service Template
After=etcd.service docker.service
[Service]
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker kill apache%i
ExecStartPre=-/usr/bin/docker rm apache%i
ExecStartPre=/usr/bin/docker pull coreos/apache
ExecStart=/usr/bin/docker run --name apache%i -p %i:80 coreos/apache /usr/sbin/apache2ctl -D FOREGROUND
ExecStartPost=/usr/bin/etcdctl set /domains/example.com/%H:%i running
ExecStop=/usr/bin/docker stop apache1
ExecStopPost=/usr/bin/docker rm apache1
ExecStopPost=/usr/bin/etcdctl rm /domains/example.com/%H:%i
[Install]
WantedBy=multi-user.target
```

#### **启动服务**
在服务启动时需要在 @ 后面放置一个用于区分服务实例的附加字符参数，通常这个参数用于监控的端口号或控制台 TTY 编译号。
Systemd 在运行服务时，总是会先尝试找到一个完整匹配的 Unit 文件，如果没有找到，才会尝试选择匹配模板。例如上面的命令，System 首先会在约定的目录下寻找名为 apache@8080.service 的文件，如果没有找到，而文件名中包含 @ 字符，它就会尝试去掉后缀参数匹配模板文件。对于 apache@8080.service，systemd 会找到 apache@.service 模板文件，并通过这个模板文件将服务实例化。
```shell
systemctl start apache@8080.service
```

## 参考
[# Systemd 服务管理教程](https://cloud.tencent.com/developer/article/1516125)
[# Linux systemd资源控制初探](https://www.cnblogs.com/jimbo17/p/9107052.html)
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE4ODk4NjI0NTUsLTM4OTUxMjQ3LDcyMj
g5Mzc4MywxNjE3MjIxNTQyLC0zMjY2MDk4ODYsMjA4MDMyODMy
MSwtNTcxNDg2NjcyLC02NDcyNTE4NjAsLTIwNTU0NzE4MDksLT
I0MjI3MjM2NCwxMjM4NTcwNDQzLDE3OTg0NTA5NTQsMzI4MTM0
MjEzLC0xMDgxMTMwNDM5LC0xMjk0NjI5NDk5LC0xMjc3MDEzNj
E4LDEyNjE3NTYxODksMTIxOTI0Mzk2NV19
-->