# Check for an interactive session
[ -z "$PS1" ] && return

# create an archive from a directory
mktar() { tar cvf  "${1%%/}.tar"     "${1%%/}/"; }
mktgz() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }
mktbz() { tar cvjf "${1%%/}.tar.bz2" "${1%%/}/"; }

# ex - extract an archive
# usage: ex <file>
ex()
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjvf $1 ;;
            *.tar.gz)    tar xzvf $1 ;;
            *.tar.xz)    tar xJvf $1 ;;
            *.bz2)       bunzip2 $1 ;;
            *.rar)       unrar x $1 ;;
            *.gz)        gunzip $1 ;;
            *.tar)       tar xvf $1 ;;
            *.tbz2)      tar xjvf $1 ;;
            *.tgz)       tar xzvf $1 ;;
            *.zip)       unzip $1 ;;
            *.par)       unzip $1 ;;
            *.jar)       unzip $1 ;;
            *.Z)         uncompress $1 ;;
            *.7z)        7z x $1 ;;
            *)           echo -e "'$1' can't be uncompressed with ex()" ;;
        esac
    else
        echo -e "\n'$1' is an invalid file"
    fi
}

list()
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar tjf $1 ;;
            *.tar.gz)    tar tzf $1 ;;
            *.tar.xz)    tar tJf $1 ;;
            *.tar)       tar tf $1 ;;
            *.tbz2)      tar tjf $1 ;;
            *.tgz)       tar tzf $1 ;;
            *.zip)       unzip -l $1 ;;
            *.par)       unzip -l $1 ;;
            *.jar)       jar tf $1 ;;
            *)           echo -e "'$1' can't be listed with list()" ;;
        esac
    else
        echo -e "\n'$1' is an invalid file"
    fi
}

bump() {
    if [[ $# -ne 1 ]]
    then
        return 1
    elif ! git rev-parse 2>&-
    then
        return 2
    fi

    git fetch  # fetch to get the most recent tags
    currentVersion=$(git tag | egrep '^v\d+.\d+.\d+$' | sed 's/^v//' | sort -V | tail -n 1)

    case $1 in
        major)
            newVersion=$(echo $currentVersion | awk -F. '{ printf "%d.0.0", $1 + 1 }') ;;

        minor)
            newVersion=$(echo $currentVersion | awk -F. '{ printf "%d.%d.0", $1, $2 + 1 }') ;;

        patch)
            newVersion=$(echo $currentVersion | awk -F. '{ printf "%d.%d.%d", $1, $2, $3 + 1 }') ;;

        *) return 3 ;;
    esac

    git checkout develop &&
    git pull --rebase &&
    git checkout master &&
    git pull --rebase &&
    git merge --no-ff -m "Update to $newVersion" develop &&
    git tag v$newVersion &&
    git push --tags &&
    git push &&
    git checkout develop &&
    git merge --ff master &&
    git push &&
    echo &&
    echo "Successfully bumped version to $newVersion"
}

# open vim help from the shell, e.g. :h holy-grail
:h() { vim -c "help $1" -c only; }

# use vim as man to be able to jump between man pages
# man() { vim -c "Man $*" -c only -c 'set nolist' -c 'nnoremap q :q<cr>'; }
# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[1;31m'        # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

up-pg()
{
    cd ~/.pg
    git submodule foreach --recursive git pull
    find . -type f -regex '.*\.\(groovy\|java\|po\)' -regextype posix-egrep > cscope.files
    cscope -b
    cd $OLDPWD
}

pg()
{
    cd ~/.pg
    if [[ $1 = "-i" ]]; then
        shift
        lower=`echo "$*" | tr '[:upper:]' '[:lower:]'`
        cscope -CL6 "$lower" | sed s_^_~/.pg/_
    else
        cscope -L6 "$*" | sed s_^_~/.pg/_
    fi
    cd $OLDPWD
}

popen()
{
    qlmanage -p $1 &>/dev/null &
}

alias ....='cd ../../..'
alias ...='cd ../..'
alias ..='cd ..'
alias .='PS1= builtin .'
alias ?=pydoc
alias ??=pydoc2
alias doc='cd ~/Documents'
alias down='cd ~/Downloads'
alias eclipse='/Applications/eclipse/Eclipse.app/Contents/MacOS/eclipse'
alias grep='grep -E --color=auto -n -I'
alias fgrep='fgrep --color=auto -n -I'
alias killbg='kill %{1..1000} 2>/dev/null'
# Causes less to automatically exit if the entire file can be displayed on the
# first screen. + display colors
alias less='less -F -X -R'
alias log="gawk '{ print strftime(\"%Y-%m-%d %H:%M:%S\") \" - \" \$0 }'"
alias ls='ls --color=auto'
alias py2=python2
alias py3=python3
alias py=python
alias reload='history -n'
alias sed='sed -E'
alias stitle='echo -ne "\033k$HOSTNAME\033\\"'
alias venv=mkvirtualenv
alias vi=vim

# Palantir's stuff
alias p='cd ~/Documents/Palantir'
alias pdom='~/Documents/Palantir/Mac_QS_3.12.4.1/scripts/StartPDOM.command'

# tz are hard!
alias fr='TZ=Europe/Paris date'
alias ny='TZ=America/New_York date'
alias sf='TZ=US/Pacific date'
alias uk='TZ=Europe/London date'

shopt -s checkwinsize
shopt -s cdspell
shopt -s globstar
shopt -s histappend

export EDITOR=vim
export HISTCONTROL=ignorespace
export HISTTIMEFORMAT='%F %T - '
export HISTFILESIZE=100000
export HISTSIZE=100000
export GRADLE_OPTS=-Xmx2g
export GREP_OPTIONS='--exclude-dir=.git --exclude-dir=build --exclude-dir=ecbuild --exclude-dir=.hg --exclude-dir=bin --exclude-dir=target'
export JAVA_HOME=$(/usr/libexec/java_home -v '1.6')
# use gnu coreutils on Mac (and use the right man pages)
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"
export PATH="~/bin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/bin:$PATH"
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
export PYTHONSTARTUP=~/.pythonrc.py
export WORKON_HOME=~/.virtualenvs
export VIRTUALENVWRAPPER_HOOK_DIR=~/.virtualenvs_hooks

java6() {
    JAVA_HOME=`/usr/libexec/java_home -v '1.6'` "$@"
}

java7() {
    JAVA_HOME=`/usr/libexec/java_home -v '1.7'` "$@"
}

java8() {
    JAVA_HOME=`/usr/libexec/java_home -v '1.8'` "$@"
}

# use bash-completion if available (obviously...)
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# for MacOS
if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
    . $(brew --prefix)/share/bash-completion/bash_completion
fi

Z=`brew --prefix 2>/dev/null`/etc/profile.d/z.sh
if [ -f $Z ]; then
    . $Z
fi

# use virtualenvwrapper, if available...
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    . /usr/local/bin/virtualenvwrapper.sh
fi

# for __git_ps1
if [ -f /usr/local/etc/bash_completion.d/git-prompt.sh ]; then
    . /usr/local/etc/bash_completion.d/git-prompt.sh
fi

bind 'set match-hidden-files off'
bind \C-w:backward-kill-word
stty stop '' # disable ^S

too-long()
{
    pfad=${PWD/#$HOME/\~}
    if [[ ${#pfad} -lt 30 ]]; then
        echo -n "${pfad}"
    else
        echo -n ".../`basename "$pfad"`"
    fi
}

git-branch() {
    plusminus=$'\u00b1'
    dirty=$([[ `git status --porcelain 2>/dev/null` != '' ]] && echo -n " $plusminus")
    __git_ps1 " (%s$dirty)" 2>/dev/null
}

mark=$'\u2713'
cross=$'\u2717'
check="\[\033[01;37m\]\$(if [[ \$? == 0 ]]; then echo \"\[\033[01;32m\]\"$mark; else echo \"\[\033[01;31m\]\"$cross; fi)\[\e[0m\]"
time="\A"
user="\[\e[1;37m\]\u\[\e[0m\]"
host="\[\e[1;34m\]\h\[\e[0m\]"
dir="\[\e[1;32m\]\$(too-long)\[\e[0m\]"
branch="\[\e[1;36m\]\$(git-branch)\[\e[0m\]"
root="\\$"
# e.g. ✓ 16:33 <alexis @ alexis in ~/.dotfiles> (master ±) $
PS1=" $check $time $user @ $host in $dir$branch $root "
