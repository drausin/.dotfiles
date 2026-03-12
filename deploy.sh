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
# 2. Copy dotfiles to $HOME
# ---------------------------------------------------------------------------
echo ""
echo "=== Deploying dotfiles ==="
for file in .[^.]*; do
    if [[ "$file" != ".git" && "$file" != ".config" && "$file" != ".gitignore" ]]; then
        cp -a "$file" "$HOME"
        echo "  copying $file"
    fi
done

# ---------------------------------------------------------------------------
# 3. Neovim: migrate to init.lua + lazy.nvim
# ---------------------------------------------------------------------------
echo ""
echo "=== Setting up Neovim ==="
mkdir -p ~/.config/nvim

# Remove old init.vim if present (replaced by init.lua)
if [[ -f ~/.config/nvim/init.vim ]]; then
    echo "  removing old init.vim"
    rm ~/.config/nvim/init.vim
fi

cp .config/nvim/init.lua ~/.config/nvim/init.lua
echo "  copied init.lua"

# Bootstrap lazy.nvim if not already installed
LAZY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"
if [[ ! -d "$LAZY_DIR" ]]; then
    echo "  bootstrapping lazy.nvim ..."
    git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZY_DIR"
fi

# ---------------------------------------------------------------------------
# 4. TPM (Tmux Plugin Manager)
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
