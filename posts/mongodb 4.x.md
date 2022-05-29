## 1. 权限操作
```shell
#启动服务
mongod -config       # 前台
mongod --fork -config# 后台
#关闭服务
mongod --shutdown --config 
kill -9 pid
# 客户端连接
/bin/mongo
```
### 1.1. 用户权限

- `Read`：允许用户读取指定数据库
- `readWrite`：允许用户读写指定数据库
- `dbAdmin`：允许用户在指定数据库中执行管理函数，如索引创建、删除，查看统计或访问system.profile
- `userAdmin`：允许用户向system.users集合写入，可以找指定数据库里创建、删除和管理用户
- `clusterAdmin`：只在admin数据库中可用，赋予用户所有分片和复制集相关函数的管理权限。
- `readAnyDatabase`：只在admin数据库中可用，赋予用户所有数据库的读权限
- `readWriteAnyDatabase`：只在admin数据库中可用，赋予用户所有数据库的读写权限
- `userAdminAnyDatabase`：只在admin数据库中可用，赋予用户所有数据库的userAdmin权限
- `dbAdminAnyDatabase`：只在admin数据库中可用，赋予用户所有数据库的dbAdmin权限。
- `root`：只在admin数据库中可用。超级账号，超级权限

创建管理员设置，使用/读写/删除所有数据库权限

```shell
# 创建管理员
use admin
db.system.user.find()
db.createUser({user:"uaad",pwd:"uaad",roles:[{role:"userAdminAnyDatabase",db:"admin"}]})
show users

# 重启数据库，登录管理员
quit()
mongod --auth --fork -config 
use admin
db.auth('auud', 'auud')

# 创建普通用户 test 拥有 数据库 test 读写权限
use test
db.createUser({user:"test",pwd:"test",roles:[{role:"readWrite",db:"test"}]})

# 使用test用户在test数据库表user插入名字
use test
db.auth('test','test')
db.user.insert({"name":"zhangsan"})
db.user.find()

# 修改管理员用户 uaad 拥有所有库的读写删除权限
db.updateUser("uaad",{roles:[{role:"userAdminAnyDatabase",db:"admin"},{role:"readWriteAnyDatabase",db:"admin"},{role:"dbAdminAnyDatabase",db:"admin"}]})

# 修改密码
use admin
db.changeUserPassword('uaad','123456')

# 删除 test 用户
use test
db.dropUser('test')

# 查看当前用户
db.runCommand({connectionStatus : 1})
```
## 2. 数据操作

### 2.1. 集合操作

懒加载，有数据时创建

- `db.dropDatabase()` 删除

```shell
show dbs
use test 
db.dropDatabase()
```

### 2.2. 插入文档

懒加载，有记录时创建

- `db.user.insert(user1)` 插入
- `db.user.save(user3) ` 根据ID，存在修改，不存在插入

```shell
# 创建user表
db.createCollection('user')
var user1={
    "name": "二狗",
    "age": 18,
    "address": {
        "country": "china",
        "city": "GZ",
    }
}
var user2={
    "_id": "3",
    "name": "三狗",
    "age": 18,
    "address": {
        "country": "china",
        "city": "GZ",
    }
}
var user3={
    "_id": "3",
    "name": "三狗",
    "age": 10,
    "address": {
        "country": "china",
        "city": "GZ",
    }
}

db.user.insert(user1)  #插入
db.user.insert([user1, user2])   #插多
db.user.save(user3)    # id不存在插入，存在则修改
db.user.save([user3, user2]) 
```
### 2.3. 更新文档

​		`db.user.update(query, update, upsert, multi)` 根据id更新整条记录。

- `query` ：匹配条件`{"name":"zhangsan"}`

- `update`：更新数据

- `upsert`不存在是否插入

- `mulit`：匹配多条是否全部更新

```shell
var user1={
    "name": "二狗",
    "age": 18,
    "address": {
        "country": "china",
        "city": "GZ",
    }
}
var user2={
    "name": "二狗",
    "hob": "bk",
    "hight": 183,
    "weight": 60.5,
}
var user3={
    "name": "二狗",
    "age": 35
}

db.user.insert([user1, user2])

# 更新name,age,除ID外的字段都会删除
db.user.update({"name": "二狗"}, user3)

# 多条匹配更新第一条
db.user.update({"name": "二狗"}, user3, false, false)
db.user.updateOne({"name": "二狗"}, user3)
# >WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 }) 

# 修改全部匹配
# 字段存在则修改，不存在则不改变
db.user.update({"name": "二狗"}, {"$set": user3}, false, true)
db.user.updateMany({"name": "二狗"}, {"$set": user3})
```

### 2.4. 删除文档

​	`db.user.remove(query, justOne)` 删除文档

- `query`：查询条件`{“name”:"二狗"}`
- `justOne`：多条匹配是否只删一条

```shell
# 只删一条
db.user.remove({"name":"二狗"}, true)

# 删除所有匹配
db.user.remove({"name":"二狗"})
db.user.remove({"name":"二狗"}, false)
db.user.deleteMany({"name":"二狗"})

# 删除所有记录
db.user.deleteMany({})
```



## 下载 

- https://www.mongodb.com/try/download/community
- 管理工具
- mongod : 服务端
- mongo : 客户端

## 配置
- 命令行
```shell
mongod --dbpath /var/lib/mongod/
    --logpath /var/log/mongod/mongod.log
    --logappend
    --port 27017
    --bind_ip 127.0.0.1 
```
- 配置文件
```shell
mongod --config /usr/local/mongodb/mongod.conf
```
```shell
# mongod.conf
storage:
  dbPath:  /var/lib/mongod
  journal:
    enabled: true

systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongod/mongod.log

# network interfaces
net:
  port: 27017
  bindIp: 127.0.0.1

processManagement:
  fork: true
  pidFilePath: /var/run/mongod.pid
```


## 部署服务
```shell
# db.createCollection
[Unit]
Description=mongodb
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/var/run/mongod.pid
ExecStart=/usr/local/mongodb/bin/mongod --config /usr/local/mongodb/mongod.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/usr/local/mongodb/bin/mongod --shutdown --config /usr/local/mongodb/mongod.conf
Restart=on-failure
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```



