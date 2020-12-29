#!/bin/bash
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

CACHE=.mdcache


while [ -n "$1" ]
do
	case $1 in
	--clean)
		rm -f $CACHE
		;;
	--list|-l) # show all or unique index
		shift
		sh=($( grep '```' $CACHE | sed -n '1~2p' ))
		sl=($( grep -n '```' $CACHE | cut -f1 -d':' | sed -n '1~2p' ))
		el=($( grep -n '```' $CACHE | cut -f1 -d':' | sed -n '2~2p' ))
		if [ "$1" -gt -1 ] 2>/dev/null ; then
			sed -n "$((${sl[0]}+1)),$((${el[0]}-1))p" $CACHE
		else
			count=0
			for (( i=0; i < ${#sl[@]}; i++ ))
			do
				echo -e "\033[32m[script] $((count++)) [${sh[i]##*'`'}] \033[0m"
				sed -n "$((${sl[i]}+1)),$((${el[i]}-1))p" $CACHE | head -n8
				echo '...'
			done
			continue
		fi
		;;
	--file|-f) # markdown file path.
		shift
		rm -f $CACHE
		cp -f $1 $CACHE
		;;
	--url|-u) # github file raw url.
		shift
		rm -f $CACHE
		echo -e "\033[34m[INFO] \033[0mdownload ${1#*_posts/}... to $CACHE"
		wget -c $1 -O $CACHE 
		echo -e "\033[34m[INFO] \033[0mdownload finish."
		;;
	*)
		echo -e "\033[31m[ERROR] \033[0m [$1] cmd not find."
		;;
	esac
	shift
done

