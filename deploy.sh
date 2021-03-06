#!/usr/bin/env bash

echo "Update repository..."
git pull

echo "Getting Pathogen..."
mkdir -p .vim/autoload
curl -LSso .vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

echo "Init/update submodules..."
git submodule update --init --recursive

cd
find "$OLDPWD"\
    -maxdepth 1\
    -mindepth 1\
    ! -name deploy.sh\
    ! -name .git\
    ! -name README.md\
    ! -name com.googlecode.iterm2.plist\
    ! -name private.xml\
    -print0 | while IFS= read -d $'\0' -r file
do
    rm -rf "${file##*/}" && ln -s "$file"
done

echo "Restoring keyboard settings..."

echo "Sourcing ~/.bashrc..."
. ~/.bashrc
