# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

# Static tab title instead of oh-my-zsh's default "user@host" (see below for
# what replaces it) -- oh-my-zsh's auto-title fires on every precmd/preexec,
# so it must be disabled before sourcing, not just overridden after.
DISABLE_AUTO_TITLE=true

source $ZSH/oh-my-zsh.sh

# Set the terminal/tab title once per shell to a stable machine label.
# Plain hostname is ambiguous on the GCP g4 fleet -- g4-96-1 is the literal
# hostname of both the gilead and incyte boxes -- so on those VMs derive a
# "g4-<project>" label from GCP project metadata instead (playground ->
# g4-playground, gilead -> g4-gilead, incyte -> g4-incyte). Everything else
# (laptop, old shared*/ml4g/gilead2/incyte1 VMs) keeps the plain hostname.
_host="$(hostname -s)"
if [[ "$_host" == g4-* ]]; then
    _project="$(curl -s -m 1 -H 'Metadata-Flavor: Google' \
        http://metadata.google.internal/computeMetadata/v1/project/project-id 2>/dev/null)"
    TAB_TITLE="${_project/#genesis-/g4-}"
    [[ -z "$TAB_TITLE" ]] && TAB_TITLE="$_host"
else
    TAB_TITLE="$_host"
fi
unset _host _project
printf '\033]0;%s\007' "$TAB_TITLE"

# Prepend "user@machine-label" to the robbyrussell prompt (the theme itself
# shows no host info, which is exactly the ambiguity problem above -- reuse
# the same TAB_TITLE so the prompt and tab title always agree).
PROMPT="%F{green}%n@${TAB_TITLE}%f ${PROMPT}"

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
