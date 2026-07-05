#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

OS="$(uname -s)"  # Darwin or Linux

# ---------------------------------------------------------------------------
# 1. Install CLI tools
# ---------------------------------------------------------------------------
echo "=== Installing CLI tools ==="
bash "$DOTFILES_DIR/install-tools.sh"

# ---------------------------------------------------------------------------
# 2. Oh My Zsh (must be installed before symlinking .zshrc)
# ---------------------------------------------------------------------------
echo ""
echo "=== Setting up Oh My Zsh ==="
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "  Oh My Zsh already installed."
else
    echo "  Installing Oh My Zsh ..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ---------------------------------------------------------------------------
# 3. Symlink dotfiles to $HOME
# ---------------------------------------------------------------------------
echo ""
echo "=== Deploying dotfiles ==="
for file in .[^.]*; do
    # Skip directories and special entries
    [[ -d "$file" ]] && continue
    if [[ "$file" != ".gitignore" ]]; then
        target="$HOME/$file"
        source="$DOTFILES_DIR/$file"
        # Remove existing file/symlink so ln doesn't fail
        [[ -e "$target" || -L "$target" ]] && rm -f "$target"
        ln -s "$source" "$target"
        echo "  linked $file -> $source"
    fi
done

# ---------------------------------------------------------------------------
# 4. Neovim: migrate to init.lua + lazy.nvim
# ---------------------------------------------------------------------------
echo ""
echo "=== Setting up Neovim ==="
mkdir -p ~/.config/nvim

# Remove old init.vim if present (replaced by init.lua)
if [[ -f ~/.config/nvim/init.vim && ! -L ~/.config/nvim/init.vim ]]; then
    echo "  removing old init.vim"
    rm ~/.config/nvim/init.vim
fi

# Symlink init.lua
target="$HOME/.config/nvim/init.lua"
source="$DOTFILES_DIR/.config/nvim/init.lua"
[[ -e "$target" || -L "$target" ]] && rm -f "$target"
ln -s "$source" "$target"
echo "  linked init.lua -> $source"

# Bootstrap lazy.nvim if not already installed
LAZY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"
if [[ ! -d "$LAZY_DIR" ]]; then
    echo "  bootstrapping lazy.nvim ..."
    git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZY_DIR"
fi

# ---------------------------------------------------------------------------
# 5. htop config
# ---------------------------------------------------------------------------
echo ""
echo "=== Setting up htop ==="
mkdir -p ~/.config/htop
target="$HOME/.config/htop/htoprc"
source="$DOTFILES_DIR/.config/htop/htoprc"
[[ -e "$target" || -L "$target" ]] && rm -f "$target"
ln -s "$source" "$target"
echo "  linked htoprc -> $source"

# ---------------------------------------------------------------------------
# 6. Persistent SSH agent (Linux only — macOS has a built-in agent via launchd)
# ---------------------------------------------------------------------------
if [[ "$OS" == "Linux" ]]; then
    echo ""
    echo "=== Setting up SSH agent service (systemd) ==="
    mkdir -p ~/.config/systemd/user
    target="$HOME/.config/systemd/user/ssh-agent.service"
    source="$DOTFILES_DIR/.config/systemd/user/ssh-agent.service"
    [[ -e "$target" || -L "$target" ]] && rm -f "$target"
    ln -s "$source" "$target"
    echo "  linked ssh-agent.service -> $source"
    systemctl --user daemon-reload
    systemctl --user enable ssh-agent.service
    if systemctl --user is-active --quiet ssh-agent.service; then
        echo "  ssh-agent already running."
    else
        systemctl --user start ssh-agent.service
        echo "  ssh-agent started."
    fi
else
    echo ""
    echo "=== SSH agent ==="
    echo "  macOS: using built-in SSH agent (launchd). Skipping systemd setup."
fi

# ---------------------------------------------------------------------------
# 7. TPM (Tmux Plugin Manager)
# ---------------------------------------------------------------------------
echo ""
echo "=== Setting up TPM ==="
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
    echo "  cloning TPM ..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "  TPM already installed."
fi

# ---------------------------------------------------------------------------
# 8. Git config
# ---------------------------------------------------------------------------
echo ""
echo "=== Configuring git ==="
# Direct egress — no proxy needed on any platform
git config --global --unset http.proxy 2>/dev/null || true
echo "  cleared http.proxy"

# Credential helper — use gh wherever it is
GH_PATH="$(command -v gh 2>/dev/null || true)"
if [[ -n "$GH_PATH" ]]; then
    git config --global 'credential.https://github.com.helper' ""
    git config --global --add 'credential.https://github.com.helper' "!${GH_PATH} auth git-credential"
    echo "  set credential helper to $GH_PATH"
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
echo "=== Deploy complete ==="
echo ""
echo "Next steps:"
echo "  1. tmux source ~/.tmux.conf       (reload tmux config)"
echo "  2. prefix + I                      (install TPM plugins)"
echo "  3. nvim                            (lazy.nvim auto-installs plugins)"
echo "  4. :checkhealth                    (verify neovim setup)"
if [[ "$OS" == "Darwin" ]]; then
    echo "  5. ssh-add --apple-use-keychain ~/.ssh/id_ed25519  (add key to macOS keychain)"
else
    echo "  5. ssh-keygen -t ed25519 && ssh-add ~/.ssh/id_ed25519  (generate key, add to agent)"
fi
echo "  6. Add public key to GitHub: Settings > SSH keys"
