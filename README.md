### How to deploy these config files

    git clone --recursive https://github.com/drausin/.dotfiles.git
    cd .dotfiles
    ./deploy.sh

Vim plugins are managed using Pathogen (see
[tpope/vim-pathogen](https://github.com/tpope/vim-pathogen)).

#### Other stuff for OSX

* [Dropbox](https://www.dropbox.com/)
* [1password](https://agilebits.com)
* [Homebrew](http://brew.sh/) (remember to install `coreutils`, `findutils`,
  `gawk`, `gnu-sed`, `screen`, `python3`, `bash`, `htop`, ...)
* [f.lux](http://justgetflux.com/)
* [MacVim](http://macvim-dev.github.io/macvim/) for +clipboard support

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap homebrew/dupes
brew tap homebrew/versions
brew install bash homebrew/versions/bash-completion2 coreutils findutils gawk git gnu-sed gnu-tar homebrew/dupes/grep homebrew/dupes/gzip netcat python python3 homebrew/dupes/screen

sudo easy_install pip
sudo pip install virtualenv virtualenvwrapper
```
