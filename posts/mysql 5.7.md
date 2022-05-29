## 1. 安装部署

**启动/暂停 Mysql 服务**  
`# net start/stop mysql `  
**登陆数据库**  
`# mysql -u root(用户名) -p`   
**远程登陆数据库**  
`# mysql -h 127.0.0.1(主机IP) -u root -p `  
**修改密码**  
`mysql> alter user root@localhost identified by ‘123456’(密码)`  
**查看用户主机地址**  

```
# mysql -uroot -proot
mysql> use mysql;
mysql> select user,host from user;	
```
**新增用户**  
`mysql> create user 'tom1'(用户名)@'localhost'(主机IP) identified by 'tom1'(密码);`  
**退出**  
`mysql> exit/quit`  
**允许远程连接**  
```
mysql> USE mysql;
mysql> GRANT ALL PRIVILEGES ON *.* TO 'root'(用户名)@'%' IDENTIFIED BY 'password'(密码) WITH GRANT OPTION;
mysql> FLUSH PRIVILEGES;    //刷新限权
```

## 数据库操作
**查看/创建/选择/直接删除 数据库**  
`mysql> show/create/use/drop database name(数据库名); `  
**不产生错误删除数据库**  
`mysql> drop database if exists name;`  
**查看警告**  
`mysql> show warnings;`  
**进入数据库**  
`mysql> use name;`  

## 表操作
**创建表**  
`create table tablename(表名) (字段 类型, 字段 类型, ...);`  
 例：创建一个表  

|字段名|类型|数据宽度|是否为空|是否主键|自增|默认值|  
|-|-|-|-|-|-|-|  
|id|int|4|否|primary|key|auto_increment|  
|name|char|20|否||||  
|sex|int|4|否|||0|  
|degree|double|16|是||||

```
mysql> create table class(
    -> id int(4) not null primary key auto_increment comment '主键',
    -> name varchar(20) not null comment '姓名',
    -> sex int(4) not null default '0' comment '性别',
    -> degree double(16,2) default null comment '分数');
```
**删除表**  
`mysql> drop table tablename;`  
**删除可能不存在的表不报错误**  
`mysql> drop table if exists tablename;`  
## 数据操作
**查询表数据**  
`mysql> select * from tablename;`   
**查询固定行数据**  
`mysql> select * from tablename limit 2;`  
### 行操作  
**插入多条数据**    
```
mysql> insert into tablename(表名)(字段1, 字段2, 字段3) 
	-> values('对象1值1','对象1值2','对象1值3'),
	-> ('对象2值1','对象2值1','对象2值3');
```
**删除行数据**  
`mysql> delete from tablename where id='9'（id为9的整行数据）;`  
修改更新数据  
```
mysql> update tablename set 字段 = '值'
    -> where id < 9
    -> order by id desc （指定跟新顺序）
    -> limit 3;(限制更新行数)
```
### 列操作
**增加字段(列)**  
```
mysql> ALTER TABLE tablename
  	-> ADD newtype(添加的字段)
   	-> INT(4)(类型) DEFAULT NULL(默认空)
   	-> COMMENT '考试类别'(提交注释)
   	-> AFTER sex(sex列之后); /FIRST(第一列)
```
**删除字段**  
`mysql> ALTER TABLE tablename DROP 字段1 , DROP 字段2 ...; `  
**修改字段**  
```
mysql> alter table tablename
   	-> change 旧字段 新字段 varchar(50) not null comment '姓名'; // 注意一定要指定类型
```
**修改字段属性**  
`mysql> alter table tablename modify sex(字段) varchar(10)(字段新类型);`  
<!--stackedit_data:
eyJoaXN0b3J5IjpbOTQ1NzM5MjgwLDQxMTI1MTk1Nl19
-->