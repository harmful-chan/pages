#!/bin/bash
# v1.0.0
# excrat ``` content from markdown file.
# example :
# 	./mdscript -f test.md -l    # show test.md all script
# 	./mdscript -f test.md -l 0    # show the first scrip from test.md 
# 	
# 	# show all script from web file. sure url already urlencode 
#	./mdscript -u https://github.com/harmful-chan/summary/xxx.md -l    

CACHE=.mdcache

function getRawStartLines()
{
	echo $( grep -n '```ruby' $1 | awk -F ':' '{ printf $1 " " }' )
}
function getRawEndLines()
{
	echo $( grep -n '```' $1| grep -v '```ruby' | awk -F ':' '{ printf $1 " " }' )
}


while [ -n "$1" ]
do
	case $1 in
	--list|-l|ls) # show all or unique index
		shift
		sl=($(getRawStartLines $CACHE))
		el=($(getRawEndLines $CACHE))
		if [ "$1" -gt -1 ] 2>/dev/null ; then
			echo -e "\033[32m[SHELL]\033[0m $1"
			sed -n "$((${sl[0]}+1)),$((${el[0]}-1))p" $CACHE
		else
			count=0
			for (( i=0; i < ${#sl[@]}; i++ ))
			do
				echo -e "\033[32m[SHELL]\033[0m $((count++))"
				sed -n "$((${sl[i]}+1)),$((${el[i]}-1))p" $CACHE | head -n8
				echo '... ... ...'
			done
			continue
		fi
		;;
	--file|-f) # markdown file path.
		shift
		cp -f $1 $CACHE
		;;
	--url|-u) # github file raw url.
		shift
		echo -e "\033[34m[INFO] \033[0mdownload ${1#*_posts/}... to $CACHE"
		wget -c $1 -O $CACHE >/dev/null 2>&1
		echo -e "\033[34m[INFO] \033[0mdownload finish."
		;;
	*)
		;;
	esac
	shift
done

rm -f $CACHE
