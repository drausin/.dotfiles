### How to deploy these config files

```bash
git clone https://github.com/drausin/.dotfiles.git
cd .dotfiles
./deploy.sh
```

`deploy.sh` will:
1. Install CLI tools (neovim, tree-sitter, bat, delta, fzf, ripgrep, fd, lazygit, etc.) to `~/.local/bin/`
2. Install Oh My Zsh
3. Symlink dotfiles to `$HOME`
4. Set up Neovim with lazy.nvim
5. Set up TPM (Tmux Plugin Manager)

#### Prerequisites

- Linux: `zsh`, `git`, `curl`, `gcc` (for building treesitter parsers)
- macOS: install via Homebrew first:
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew install neovim tmux python@3.12
  ```
