---
layout: post
title: "mysql使用ado.net连接"
platform: "Windows 10"
author: "harmful-chan"
date: "2019-04-06 17:10"
tags: 
  - mysql
---
## 命名空间及常用类
#### System.Data | XML数据操作
DataTable，DataSet，DataRow，DataColumn，DataRelation，     Constraint，DataColumnMapping，DataTableMapping

#### Mysql.Data.MysqlClient | 操作Mysql数据库
MysqlConnection  数据库连接器  
MysqlCommand 数据库命名对象  
MysqlCommandBuilder 生成SQL命令  
MysqlDataReader  数据读取器  
MysqlDataAdapter 数据适配器填充DataSet  
MysqlParameter 为存储过程定义参数  
MysqlTransaction数据库事物

## 常用类功能
**MysqlConnection** 连接数据库  
Use：MySqlConnection conn=new MySqlConnection(connStr);  
Property：.ConnectionString(连接数据库字符串) .State(连接状态Closed、Open两种)      
Method：.Open()(打开连接)  .Close()(关闭连接)    

**MysqlCommand** 数据库sql操作  
Use：MySqlCommand cmd=new MySqlCommand(sqlStr, conn);    
Property：.CommandType(命令类型一般为CommandType.Text)  
Method：.ExecuteNonQuery() (执行insert,delete,update操作，返回受影响行数) .ExecuteReader() (返回MysqlDataReader对象)     

**MysqlDataReader** 包含返回的数据  
Use：MySqlDataReader data=cmd.ExecuteReader()    
Property：[下标/列名]当前行对应的属性值    
Method：.Read() (光标移动到下一行，返回flase表示结束)    

## 连接字符串
**(基本语法)**  
数据源(Data Source)+数据库名称(Initial Catalog)+用户名(User ID)+密码(Password)  

**SQL Server**   
标准安全连接：  
Data Source=.;Initial Catalog=myDataBase;User Id=myUsername;Password=myPassword;  
或者  
Server=myServerAddress;Database=myDataBase;User Id=myUsername;Password=myPassword;Trusted_Connection=False;  
可信连接：  
Data Source=myServerAddress;Initial Catalog=myDataBase;Integrated Security=SSPI;  
或者     Server=myServerAddress;Database=myDatabase;Trusted_Connection=True;  

**Access**  
Provider=Microsoft.Jet.OLEDB.4.0;Data Source=C:\myDatabase.mdb;User Id=admin;Password=;    

**MySQL**  
Server=myServerAddress;Database=myDatabase;Uid=myUsername;Pwd=myPassword;  

**DB2**  
Server=myAddress:myPortNumber;Database=myDatabase;UID=myUsername;PWD=myPassword;  

**Oracle**  
Data Source=TORCL;User Id=myUsername;Password=myPassword;   

## ADO.NET Mysql VS2017插件、驱动 
插件 [提取码：w5ib ](https://pan.baidu.com/s/1bNm8e20hZU6cnU0H7CzHnQ )  
驱动 [提取码：ykc3 ](https://pan.baidu.com/s/1JExlZDO9-4CgkjrjgcyrQg )  
项目Nuget包添加：Mysql.Data（对应驱动版本）  

