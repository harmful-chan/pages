---
layout: post
title: "Thingsboard (三) docker 编译分析"
subtitle: "CentOS 7.6"
author: "harmful-chan"
header-mask: 0.5
catalog: true
tags: 
  - thingsboard
---

## 前言  
按照官方文档执行`./docker-install-tb.sh`默认是从docker hub拉取thingsboard的官方镜像的，若要docker运行自己修改完的代码，需要自己获取一个docker仓库和修改代理里的`pom.xml`。  
本文使用阿里云仓库，且docker tag按照：`registry.cn-qingdao.aliyuncs.com/{空间名}/harthb:{镜像名}_vx.x.x.`(x.x.x为版本号)。  
 
## Quick Start
Github：https://github.com/thingsboard/thingsboard/blob/release-3.2/docker/README.md

**创建日志文件夹**  
./[docker-create-log-folders.sh](https://github.com/thingsboard/thingsboard/blob/release-3.2/docker/docker-create-log-folders.sh)  

**安装**  
./[docker-install-tb.sh](https://github.com/thingsboard/thingsboard/blob/release-3.2/docker/docker-install-tb.sh) --loadDemo`
1. 添加 .env 内的环境变量，这只数据库,dockerhub等信息。  
2. 执行 compose-utlis.sh 内的函数 设置：
> ADDITIONAL_COMPOSE_QUEUE_ARGS="-f docker-compose.kafka.yml"    
> ADDITIONAL_COMPOSE_ARGS="-f docker-compose.postgres.yml"
> ADDITIONAL_STARTUP_SERVICES=postgres
3. 运行 `docker-compose -f docker-compose.yml -f docker-compose.postgres.yml -f docker-compose.kafka.yml up -d redis postgres`  
> 后台启动redis postgres
4. 运行 `docker-compose -f docker-compose.yml -f docker-compose.postgres.yml -f docker-compose.kafka.yml run --no-deps --rm -e INSTALL_TB=true -e LOAD_DEMO=true tb-core1`
> --no-deps 单独启动，不依赖 -e 设置环境变量 --rm 运行完删除容器
> 启动 tb-core1 镜像  


**启动服务**  
./[docker-start-services.sh](https://github.com/thingsboard/thingsboard/blob/release-3.2/docker/docker-start-services.sh)  
> 运行`docker-compose -f docker-compose.yml -f docker-compose.postgres.yml -f docker-compose.kafka.yml up -d`  
> 后台运行所有容器。    

**官方给的docker文件都是从官方docker hub拉取镜像的，运行自己的程序要自己本机编译改docker-compose.yml镜像为自己的项目**  


## 启动文件分析  
### [.env](https://github.com/thingsboard/thingsboard/blob/release-3.2/docker/.env)
总结：设置引用到的项目名称，数据库类型
```shell
DOCKER_REPO=thingsboard
JS_EXECUTOR_DOCKER_NAME=tb-js-executor
TB_NODE_DOCKER_NAME=tb-node
WEB_UI_DOCKER_NAME=tb-web-ui
MQTT_TRANSPORT_DOCKER_NAME=tb-mqtt-transport
HTTP_TRANSPORT_DOCKER_NAME=tb-http-transport
COAP_TRANSPORT_DOCKER_NAME=tb-coap-transport
TB_VERSION=latest
DATABASE=postgres    #cassandra
LOAD_BALANCER_NAME=haproxy-certbot
```
### [compose-utils.sh](https://github.com/thingsboard/thingsboard/blob/release-3.2/docker/compose-utils.sh)
总结：根据`DATABASE=postgres`，设置`ADDITIONAL_COMPOSE_ARGS="-f docker-compose.postgres.yml"`
```shell
#!/bin/bash
# 里面的函数功能都差不多
...
function additionalComposeArgs() {
    source .env    # 当前文件范围加载 环境变量
    ADDITIONAL_COMPOSE_ARGS=""
    case $DATABASE in    #相当于switch语句
        postgres)
        ADDITIONAL_COMPOSE_ARGS="-f docker-compose.postgres.yml"
        ;;
        cassandra)
        ADDITIONAL_COMPOSE_ARGS="-f docker-compose.cassandra.yml"
        ;;
        *)
        echo "Unknown DATABASE value specified: '${DATABASE}'. Should be either postgres or cassandra." >&2
        exit 1
    esac
    echo $ADDITIONAL_COMPOSE_ARGS # 返回值
}
...

```

### 3. [docker-install-tb.sh](https://github.com/thingsboard/thingsboard/blob/release-3.2/docker/docker-install-tb.sh)
总结：后台启动`docker-compose.yml`里的`redis`，`docker-compose.postgres.yml`里的`postgres`。`docker-compose.postgres.yml`里的`tb-core1`。

```shell
#!/bin/bash
while [[ $# -gt 0 ]] # 循环读取传入参数 如果有传入参数--loadDemo，则设置LOAD_DEMO=true
...    


if [ "$LOAD_DEMO" == "true" ]; then  # 按LOAD_DEMO=true，设置loadDemo
...    

set -e    # 命令错误立即退出

#compose-utils.sh提供调用的三个方法，设置获取数据库类型和名称，引用文件，发生错误返回上次命令的返回值
source compose-utils.sh    
ADDITIONAL_COMPOSE_QUEUE_ARGS=$(additionalComposeQueueArgs) || exit $?  
ADDITIONAL_COMPOSE_ARGS=$(additionalComposeArgs) || exit $?  
ADDITIONAL_STARTUP_SERVICES=$(additionalStartupServices) || exit $?  


# 把ADDITIONAL_STARTUP_SERVICES替换为“ ”，-z判断长度为0则为真，！取反
if [ ! -z "${ADDITIONAL_STARTUP_SERVICES// }" ]; then
    docker-compose -f docker-compose.yml $ADDITIONAL_COMPOSE_ARGS up -d redis $ADDITIONAL_STARTUP_SERVICES
fi
# 把ADDITIONAL_STARTUP_SERVICES替换为“ ”，-z判断长度为0则为真，！取反

#运行tb，添加环境变量INSTALL_TB=true，LOAD_DEMO=true
docker-compose -f docker-compose.yml $ADDITIONAL_COMPOSE_ARGS 、
$ADDITIONAL_COMPOSE_QUEUE_ARGS run --no-deps --rm -e INSTALL_TB=true -e LOAD_DEMO=${loadDemo} tb-core1 

```

### 3. docker-start-services.sh
总结：`docker-compose -f docker-compose.yml -f docker-compose.postgres.yml up -d`，后台运行所有容器。
```shell
#!/bin/bash  
set -e  
source compose-utils.sh  
ADDITIONAL_COMPOSE_QUEUE_ARGS=$(additionalComposeQueueArgs) || exit $?  
ADDITIONAL_COMPOSE_ARGS=$(additionalComposeArgs) || exit $?  
docker-compose -f docker-compose.yml $ADDITIONAL_COMPOSE_ARGS $ADDITIONAL_COMPOSE_QUEUE_ARGS up -d  
＃ 全体起立
```
