# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Editor
export EDITOR='nvim'

# Tool aliases
alias vim="nvim"
alias cat='bat --paging=never'
alias md='glow -p'
alias mdp='tmux popup -w 80% -h 80% -E "glow -p"'
alias lg='lazygit'

# GitHub-flavored markdown preview server
grip-serve() { grip "$1" 0.0.0.0:6419 & }

# fzf integration (keybindings: Ctrl+R history, Ctrl+T files, Alt+C cd)
if command -v fzf &>/dev/null; then
    eval "$(fzf --zsh 2>/dev/null)" || {
        [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
    }
fi

setopt inc_append_history   # append immediately rather than on shell exit
setopt share_history        # share history across all sessions

# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# Source OS-specific config
_os_config="$HOME/.zshrc.$(uname -s | tr 'A-Z' 'a-z')"
[[ -f "$_os_config" ]] && source "$_os_config"
unset _os_config
