#!/bin/bash
# v1.0.0

tmp_dir=~/.mdcache

echo 'step:1 download mscript.sh to ~/.mdcache'
if [ ! -d $tmp_dir ]; then 
    mkdir -p $tmp_dir 
fi
curl -s -L https://github.com/harmful-chan/summary/releases/download/mdscript/mdscript.sh -o $tmp_dir/mdscript.sh

echo "step:2 create alias mdspt='$tmp_dir/mdscript.sh'"
if [ -e ~/.bashrc ]; then
    sed -i -e '/^alias\ mdspt/d' ~/.bashrc
fi

echo "alias mdspt='bash $tmp_dir/mdscript.sh'" >> ~/.bashrc

source ~/.bashrc
