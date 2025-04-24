#!/bin/bash

for file in .[^.]*; do
    if [[ "$file" != ".git" ]]; then
	cp -a "$file" "$HOME"
	echo "copying $file"
    fi
done

mkdir -p ~/.config/nvim
cp .config/nvim/init.vim ~/.config/nvim/init.vim
