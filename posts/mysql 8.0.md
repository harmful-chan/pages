## 1. 用户管理

查看绑定端口 `show variables like '%bind_address%';`

创建用户允许本地连接（远程连接相同）

```shell
CREATE USER hans@'localhost';
GRANT ALL PRIVILEGES ON *.* TO hans@'%' WITH GRANT OPTION;
USE mysql;
SHOW TABLES;
ALTER USER hans@'localhost' IDENTIFIED WITH mysql_native_password BY 'Hans123.';
FLUSH PRIVILEGES;
```

查看用户`select user,host from user;`

查看权限 ``
