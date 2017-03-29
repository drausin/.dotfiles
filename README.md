### How to deploy these config files

    git clone --recursive https://github.com/drausin/.dotfiles.git
    cd .dotfiles
    . deploy.sh

Vim plugins are managed using Pathogen (see
[tpope/vim-pathogen](https://github.com/tpope/vim-pathogen)).

Remember to `sudo pip install csvkit data_hacks flake8 virtualenv virtualenvwrapper`
the 1st time to get some python-related tools.

### Other stuff that's worth installing, but not handled here

* [Homebrew](http://brew.sh/) (remember to install `coreutils`, `findutils`,
  `gawk`, `gnu-sed`, `screen`, `python3`, `bash`, `htop`, ...)
* [f.lux](http://justgetflux.com/)
* [Sourcetree](https://www.sourcetreeapp.com)
* [Dropbox](https://www.dropbox.com/)
* [1password](https://agilebits.com)
* [`ssh-installkeys`](http://www.catb.org/~esr/ssh-installkeys/) or
  `ssh-copy-id` ([man page](http://linux.die.net/man/1/ssh-copy-id))
* [`sshfs`](http://fuse.sourceforge.net/sshfs.html)
* [Karabiner](https://pqrs.org/osx/karabiner/)
  / [Seil](https://pqrs.org/osx/karabiner/seil.html.en)
* [`bash-completion`](http://bash-completion.alioth.debian.org/)
* [Spectacle](http://spectacleapp.com/)
* [`z`](https://github.com/rupa/z)

### A note about keyboard configuration

1. `deploy.sh` does all the magic.

### A note about Homebrew and useful formulas...

    brew tap homebrew/dupes
    brew tap homebrew/versions

    # --with-default-names
    brew install bash homebrew/versions/bash-completion2 coreutils distribution findutils gawk git gnu-sed gnu-tar homebrew/dupes/grep homebrew/dupes/gzip netcat python python3 q pv homebrew/dupes/screen
