#!/bin/bash
# v1.1.1

tmp_dir=${HOME}/.mdcache
cache=${tmp_dir}/cache.md
post_dir=${tmp_dir}/post
type=

function info() 
{
	echo -e "\033[34m[ INFO ] \033[0m $*"
}
function error()
{
	echo -e "\033[31m[ ERROR ] \033[0m $*"
}
function omit()
{
    echo -e "\033[33m[ OMIT ] $* \033[0m"
}
function script()
{
	echo -e "\033[32m[ SCRIPT] $2 \033[0m\033[33m $1 \033[0m"
}
function progress()
{
	printf "$*"
}
function progress_done()
{
	printf "\033[32mdone\033[0m"
}
function script_content()
{
    array=( $(sed -n '/^```/=' $2) )
    starts=( $(printf '%s\n' ${array[@]} | sed -n '1~2p') )
    ends=( $(printf '%s\n' ${array[@]} | sed -n '2~2p') )
	s=`expr ${starts[${1}]} + 1 `
	e=`expr ${ends[${1}]} - 1`
	sed -n "${s},${e}p" $2
}


function update_post_dir()
{
    if [ ! -d $post_dir ]; then
		info 'download posts ...'
		git clone --depth=1 https://github.com/harmful-chan/summary.git  -b main
		mkdir -p $post_dir
		mv  summary/_posts/* $post_dir
		rm -rf summary/
    fi
}


function show_md()
{
	while [ -n "$1" ]
	do
		case $1 in
		-l) # show all or unique index
			shift
			if [ $1 -ge 0 ] 2>/dev/null ; then
			    script_content $1 $cache
			else
				start_line=($( grep '```' $cache | sed -n '1~2p' ))
				for (( i=0; i < ${#start_line[@]}; i++ ))
				do
					if [ -n "$type" ] && [ "$type" != "${start_line[i]##*'`'}" ]; then
					    continue
					fi
				    script "$i" "${start_line[i]##*'`'}" 
					script_content $i $cache | head -n5 | tee short_content.txt
					sl=$(cat short_content.txt | wc -l)
					if [ $sl -ge 5 ]; then
					    omit '   ...   ...   ...   '
					fi	
					rm -rf short_content.txt
				done
				continue
			fi
			;;
		-f) # markdown file path.
			shift
			if [ -e $1 ]; then
				cp -f $1 $cache
		    elif [ $1 -ge 1 ]; then
				file=$( ls $post_dir | grep -n '.md' | grep -E  "^${1}:" )
				file=${file##*':'}
				cp -f ${post_dir}/$file $cache
		    fi
			;;
		-t)
			shift
			type=$1
			;;
		-u) # github file raw url.
			shift
			info "download ${1#*_posts/}... to $cache"
			curl -s -L $1 -o $cache
			;;
		-a)	
		    update_post_dir
			files=$(ls $post_dir)
			i=1
			for line in $files
		    do
				printf "\033[33m %2d \033[0m %s\n" $i $line
				i=`expr ${i} + 1`
			done
		    ;;
		*)
			error "[show] [$1] command not find."
			;;
		esac
		shift
	done
}

function create_md()
{
	file_name=$(date '+%F')-${1// /-}.md
	cat > $file_name <<-EOF
---
layout: post
title: "$1"
subtitle: "$2"
author: "harmful-chan"
header-mask: 0.5
catalog: true
tags: [ ${3// /, } ]
---
EOF
}

if [ -n "$1" ]; then
    update_post_dir
case $1 in
create)
	shift
	info "create ${@:1:1}.md in ${pwd}"
	create_md "${@:1:1}" "${@:2:1}"  "${@:3}" 
	;;
show)
	shift 
	show_md $@
	;;
use)
    file_path=${post_dir}/$(ls $post_dir | grep 'mdscript-help')
	script_content 0 $file_path
    ;;
help)
    file_path=${post_dir}/$(ls $post_dir | grep 'mdscript-help')
	script_content 1 $file_path
    ;;
clean)
    info "remove $tmp_dir"
    rm -rf $tmp_dir
    ;;
update)
    info "update $post_dir"
	rm -rf $post_dir
	update_post_dir
    ;;
*)
	error "command [$1] not find. " 
	;;
esac
else
    error "please use [help]"
fi
