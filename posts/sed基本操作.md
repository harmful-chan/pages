## 参数

-n-：只打印模式匹配的行  

-e-：直接在命令行模式上进行sed动作编辑，此为默认选项  

-f-：将sed的动作写在一个文件内，用–f-filename-执行filename内的sed动作  

-r-：支持扩展表达式  

-i-：直接修改文件内容  

####  行匹配方式

+ `/pattern/`	查询包含pattern的行 
+ `/pattern/,x`	第一个包含pattern到x的行，及x以后包含pattern的行 
+ `x,/pattern/`	开始包含pattern的行
+ `x,y!`	 到y以外的行    

####  列匹配方式
+ `$`行尾
+ `^$` 空行  
+ `.`任意单个字符
+ `*`前面字符多次
+ `.*`后面字符任意


####  转义

+ `{m,n}     ` 前面字符-m到n次                      
+ `{m,}      ` 前面字符->=-m-次                     
+ `{m}-      ` 前面字符-0到m-次                     
+ `<pattern> ` 单词锚点                             
+ `()--      ` 分组，用法格式：(pattern)，引用\1,\2 
+ `[pattern] ` 匹配多个字符                         
+ `[^pattern]` pattern外的多个字符                  
+ `[:digit:] ` [0-9]                                
+ `[:lower:] ` [a-z]                                
+ `[:upper:] ` [A-Z]                                
+ `[:alpha:] ` [a-zA-Z]                             
+ `[:alnum:] ` [0-9a-zA-Z]                          
+ `[:space:] ` 空白字符                             
+ `[:punct:] ` 所有标点符号                         

## 用法
#### 操作方法

+ `=         ` 行号 
+ `a         ` append-指定行后追加新行
+ `i         ` insert-指定行前追加新行
+ `d         ` delete-删除定位行
+ `c         ` change-替换整行
+ `w filename` 类似输出重定向 >
+ `r filename` 类似输入重定向 <
+ `s         ` 替换内容
+ `q         ` 第一个模式匹配完成后退出或立即退出 
+ `l         ` 显示与八进制ACSII代码等价的控制符
+ `{}        ` 在定位行执行的命令组，用分号隔开
+ `n         ` 行数相同的另一个文本的内容拼接在当前行进行操作 
+ `N         ` 在数据流中添加下一行以创建用于处理的多行
+ `g         ` 将模式2粘贴到/pattern-n/
+ `y         ` 传送字符，替换单个字符 

####  find
+ `sed -n '/r*t/p' /etc/passwd` 打印匹配r有0个或者多个，后接一个t字符的行 
+ `sed -n '/.r.*/p' /etc/passwd` 打印匹配有r的行并且r后面跟任意字符
+ `sed -n '/o*/p' /etc/passwd` 打印o字符重复任意次  
+ `sed -n '/o\{1,\}/p' /etc/passwd` 打印o字重复出现一次以上
+ `sed -n '/o\{1,3\}/p' /etc/passwd` 打印o字重复出现一次到三次之间以上
+ `sed -n '/^#/!p' /etc/vsftpd/vsftpd.conf` 打印不是#开头的行
+ `sed -n '/^#/!{/^$/!p}'/etc/vsftpd/vsftpd.conf` 打印不是#开头的行且去除空行 
+ `sed -e '/^#/d'-e '/^$/d'/etc/vsftpd/vsftpd.conf` 删除#开头的行和空行输出 
+ `sed -n '1,/adm/p'/etc/passwd` 打印第一行到含有adm的行

####  insert
+ `sed '/world/s/^/hello /' test.txt` 含有world的行首行插入'hello '
+ `sed '/world/s/$/ you/' test.txt` 含有world的行行尾插入' you'
+ `sed -e '/world'/s/\(.*\)/\1 you/g test.txt` 作用同上，用正则实现
+ `sed 's/world/linux &/' test.txt` 每行world单词前插入'linux '
+ `sed 's/world/& linux/' test.txt` 每行world单词后插入' linux'
+ `sed 's/^/Start /' test.txt` 每行前插入'Start '
+ `sed 's/$/ End/' test.txt` 每行后插入' End'
+ `sed '1,3s/^/#/' test.txt` 1-3行前插入'#' 
+ `sed '/world/ihello /' test.txt` 含有world的行上方插入一行'hello'
+ `sed '/world/ahello /' test.txt` 含有world的行下方方插入一行'hello'

####  substitute
+ `sed 's/123/abc/g' test.txt` 每行的'123'全部替换为abc并显示
+ `sed 's/123/abc/2' test.txt` 每行的第2个'123'替换为abc并显示
+ `sed '/0/,3s/123/abc/3' test.txt` 含有'0'的行到第3行的第3个'123'替换为'abc'并输出

####  delete
+ `sed '5d' test.txt` 删除第5行
+ `sed '1,3d' test.txt` 删除1到3行
+ `sed '/0/,$d' test.txt` 删除第一个含有0行到结尾
+ `sed '/0/,+1d' test.txt` 删除含有'0'的行以及往下一行





