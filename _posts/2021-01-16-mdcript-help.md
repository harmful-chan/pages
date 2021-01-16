---
layout: post
title: "mscript help"
subtitle: "CentOS 7.6"
author: "harmful-chan"
header-mask: 0.5
catalog: true
tags: [ shell ]
---
## QuickStart
```quickstar
# !/bin/bash
# # # # # # # # # # mdscript quickstart # # # # # # # # # # 
# 添加别名 
alias mdspt='bash ${pwd}/mdscript.sh'

# 在当前目录创建一个.md博客文件，
# 并添加标题[file name]，子标题[sub title]，第一个标签[tag1]
mdspt create 'file name' 'sub title' 'tag1' 'tag2' ... 

# 显示所有博客文件
# 从远端拉取文件放在 $HOAM/.mdscript/post 中
mdspt show -a

# 查看缓存目录中文章内的所有的脚本 '```'内的内容
mdspt show -f 1 -l # 1 为文章索引 -a 可以看到

# 查看详细脚本 
mdspt show -f 1 -l 0 # 0 为脚本索引，在每个脚本开头都有显示

# 查看指定.md脚本内容
mdspt show -f ../myblogs.md -l [0]    # -f 能指定文件目录

# 查看远程.md脚本内容
mdspt show -u 'https://github.com/harmful-chan/summary/raw/gh-pages-green/_posts/2020-03-23-%E6%90%AD%E5%BB%BAPPTP%E6%9C%8D%E5%8A%A1%E5%99%A8.md' -l [0]

# 清除缓存
mdspt show --clean

# 查看帮助
mdspt help

## 注意：-a -u -f等 会在本地生成缓存，若查看同一个文档 可以 
mdspt show -l [0] <=> mdspt show -f ${HOME}/.mdcache/cache -l 0
```


## Help
```help
# # # # # # # # # # mdscript help # # # # # # # # # # 
append 
    [create] -- 添加博客文档生成功能
    [show]  -- 原有功能
        -a -- all 显示所有博客文件 
        -u -- url 指定远程.md文件url
        -t -- type 指定脚本类型
        -f -- file 指定本地.md 文件 
        -l -- list 显示.md文件内```之间的内容
        --clean -- 清楚缓存目录 $HOME/.mdscript
    [help] -- 显示本节内同
    [quickstart] -- 显示上一节内容  
```



## ChangeLog
```shell
# !/bin/bash
# # # # # # # # # # # # # # # # # # #ChangeLog # # # # # # # # # # # # # # #
# v1.1.0
# 版本跟新：把帮组文档独立出来，较大改动
# 把整个仓库_posts下的文件放在 $HOME/.mdcache/post 下用于操作
# 修改内容显示函数，支持种类型的脚本，会在开头显示

# v1.0.2
# update '-l' optimized display.
# v1.0.1
# append '--clean' remove $CACHE, by default not remove.
# update '-l' not show index informations.
# v1.0.0
# excrat ``` content from markdown file.
# example :
# 	./mdscript -f test.md -l    # show test.md all script
# 	./mdscript -f test.md -l 0    # show the first scrip from test.md 
# 	
# 	# show all script from web file. sure url already urlencode 
#	./mdscript -u https://github.com/harmful-chan/summary/xxx.md -l    
```
