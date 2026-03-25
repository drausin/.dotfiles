#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

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
    if [[ "$file" != ".git" && "$file" != ".config" && "$file" != ".gitignore" ]]; then
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
# 5. TPM (Tmux Plugin Manager)
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
