### How to deploy these config files

    git clone --recursive https://github.com/drausin/.dotfiles.git
    cd .dotfiles
    ./deploy.sh

Vim plugins are managed using Pathogen (see
[tpope/vim-pathogen](https://github.com/tpope/vim-pathogen)).

#### Other stuff for OSX

* [1password](https://agilebits.com)
* [MacVim](http://macvim-dev.github.io/macvim/) for +clipboard support

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install bash bash-completion2 coreutils findutils gawk git gnu-sed gnu-tar grep gzip netcat python3 screen tmux
```
