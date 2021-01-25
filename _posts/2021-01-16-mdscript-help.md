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
```shell
alias mdspt='bash ${pwd}/mdscript.sh'        # 添加别名 
mdspt create 'file name' 'subtitle' 'tag1'   # create new .md file in current dir
mdspt show -a                                # show all .md fil
mdspt show -f 1 -l                           # show all script content -f [file index] 
mdspt show -f 1 -l 0                         # show specified script content -l [script index]
mdspt show -f ../myblogs.md -l [0]           # use local file -f [file path]
mdspt show -u 'https://github.com/..a.md' -l # use remote file
mdspt clean                                  # remove $HOME/.mdcache
mdspt help                                   # sricpt help
mdspt use                                    # current document

## 注意：-a -u -f等 会在本地生成缓存，若查看同一个文档 可以 
mdspt show -l [0] <=> mdspt show -f ${HOME}/.mdcache/cache -l 0
```


## Help
```
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
    [use] -- 显示上一节内容  
	[clean] -- remove $HOME/.mdcache
	[update] -- remove $HOME/.mdcache/post and update post directory.
```



## ChangeLog
```shell
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
