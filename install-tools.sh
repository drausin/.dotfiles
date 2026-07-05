#!/bin/bash
set -euo pipefail

# Install pre-built CLI tools.
# macOS: uses Homebrew.  Linux: downloads binaries to ~/.local/bin/.
# Idempotent: skips tools already at the expected version.

OS="$(uname -s)"   # Darwin or Linux
ARCH="$(uname -m)" # arm64 / x86_64 / aarch64

# ============================================================================
# macOS — delegate to Homebrew
# ============================================================================
if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Install it first: https://brew.sh"
        exit 1
    fi

    BREW_PACKAGES=(
        glow
        bat
        git-delta
        fzf
        ripgrep
        fd
        lazygit
        entr
        neovim
        tree-sitter
        node
        pyright
    )

    echo "=== Installing tools via Homebrew ==="
    for pkg in "${BREW_PACKAGES[@]}"; do
        if brew list --formula "$pkg" &>/dev/null; then
            echo "  $pkg already installed."
        else
            echo "  Installing $pkg ..."
            brew install "$pkg"
        fi
    done

    # grip (Python package)
    echo "[grip]"
    if command -v grip &>/dev/null; then
        echo "  Already installed, skipping."
    else
        echo "  Installing grip via pip ..."
        pip install --quiet grip
    fi

    echo ""
    echo "All tools installed via Homebrew."
    exit 0
fi

# ============================================================================
# Linux — download pre-built binaries to ~/.local/bin/
# ============================================================================
BIN_DIR="$HOME/.local/bin"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$BIN_DIR"

case "$ARCH" in
    x86_64)  ;;
    aarch64) ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

installed_version() {
    local cmd="$1"
    if command -v "$cmd" &>/dev/null; then
        "$cmd" --version 2>/dev/null | head -1 | grep -oP '[\d]+\.[\d]+\.[\d]+' | head -1
    fi
}

install_from_tarball() {
    local name="$1" url="$2" bin_name="$3" strip="${4:-1}"
    echo "  Downloading $name from $url ..."
    curl -fsSL "$url" -o "$TMP_DIR/$name.tar.gz"
    mkdir -p "$TMP_DIR/$name"
    tar xzf "$TMP_DIR/$name.tar.gz" -C "$TMP_DIR/$name" --strip-components="$strip"
    cp "$TMP_DIR/$name/$bin_name" "$BIN_DIR/$bin_name"
    chmod +x "$BIN_DIR/$bin_name"
}

# ---------------------------------------------------------------------------
# Tool versions
# ---------------------------------------------------------------------------
GLOW_VERSION="2.1.1"
BAT_VERSION="0.26.1"
DELTA_VERSION="0.18.2"
FZF_VERSION="0.70.0"
RIPGREP_VERSION="15.1.0"
FD_VERSION="10.4.2"
LAZYGIT_VERSION="0.60.0"
NODE_VERSION="22.14.0"
NEOVIM_VERSION="0.11.6"
TREESITTER_VERSION="0.24.7"

# ---------------------------------------------------------------------------
# glow — terminal markdown renderer
# ---------------------------------------------------------------------------
echo "[glow]"
if [[ "$(installed_version glow)" == "$GLOW_VERSION" ]]; then
    echo "  Already at v${GLOW_VERSION}, skipping."
else
    GLOW_ARCH="$ARCH"
    [[ "$ARCH" == "aarch64" ]] && GLOW_ARCH="arm64"
    install_from_tarball glow \
        "https://github.com/charmbracelet/glow/releases/download/v${GLOW_VERSION}/glow_${GLOW_VERSION}_Linux_${GLOW_ARCH}.tar.gz" \
        glow 1
fi

# ---------------------------------------------------------------------------
# bat — syntax-highlighted cat
# ---------------------------------------------------------------------------
echo "[bat]"
if [[ "$(installed_version bat)" == "$BAT_VERSION" ]]; then
    echo "  Already at v${BAT_VERSION}, skipping."
else
    install_from_tarball bat \
        "https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-${ARCH}-unknown-linux-gnu.tar.gz" \
        bat 1
fi

# ---------------------------------------------------------------------------
# delta — better git diffs
# ---------------------------------------------------------------------------
echo "[delta]"
if [[ "$(installed_version delta)" == "$DELTA_VERSION" ]]; then
    echo "  Already at v${DELTA_VERSION}, skipping."
else
    install_from_tarball delta \
        "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-${ARCH}-unknown-linux-gnu.tar.gz" \
        delta 1
fi

# ---------------------------------------------------------------------------
# fzf — fuzzy finder
# ---------------------------------------------------------------------------
echo "[fzf]"
if [[ "$(installed_version fzf)" == "$FZF_VERSION" ]]; then
    echo "  Already at v${FZF_VERSION}, skipping."
else
    FZF_ARCH="amd64"
    [[ "$ARCH" == "aarch64" ]] && FZF_ARCH="arm64"
    install_from_tarball fzf \
        "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_${FZF_ARCH}.tar.gz" \
        fzf 0
fi

# ---------------------------------------------------------------------------
# ripgrep (rg) — fast code search
# ---------------------------------------------------------------------------
echo "[ripgrep]"
if [[ "$(installed_version rg)" == "$RIPGREP_VERSION" ]]; then
    echo "  Already at v${RIPGREP_VERSION}, skipping."
else
    RG_LIBC="musl"
    [[ "$ARCH" == "aarch64" ]] && RG_LIBC="gnu"
    install_from_tarball ripgrep \
        "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-${ARCH}-unknown-linux-${RG_LIBC}.tar.gz" \
        rg 1
fi

# ---------------------------------------------------------------------------
# fd — fast file finder
# ---------------------------------------------------------------------------
echo "[fd]"
if [[ "$(installed_version fd)" == "$FD_VERSION" ]]; then
    echo "  Already at v${FD_VERSION}, skipping."
else
    install_from_tarball fd \
        "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-${ARCH}-unknown-linux-gnu.tar.gz" \
        fd 1
fi

# ---------------------------------------------------------------------------
# lazygit — TUI git client
# ---------------------------------------------------------------------------
echo "[lazygit]"
if [[ "$(installed_version lazygit)" == "$LAZYGIT_VERSION" ]]; then
    echo "  Already at v${LAZYGIT_VERSION}, skipping."
else
    LG_ARCH="$ARCH"
    [[ "$ARCH" == "aarch64" ]] && LG_ARCH="arm64"
    install_from_tarball lazygit \
        "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_linux_${LG_ARCH}.tar.gz" \
        lazygit 0
fi

# ---------------------------------------------------------------------------
# entr — run commands on file changes (built from source)
# ---------------------------------------------------------------------------
ENTR_VERSION="5.6"
echo "[entr]"
if command -v entr &>/dev/null; then
    echo "  Already installed, skipping."
else
    echo "  Downloading entr ..."
    curl -fsSL "https://github.com/eradman/entr/archive/refs/tags/${ENTR_VERSION}.tar.gz" -o "$TMP_DIR/entr.tar.gz"
    mkdir -p "$TMP_DIR/entr"
    tar xzf "$TMP_DIR/entr.tar.gz" -C "$TMP_DIR/entr" --strip-components=1
    cd "$TMP_DIR/entr"
    ./configure
    CFLAGS="-static" make
    cp entr "$BIN_DIR/entr"
    chmod +x "$BIN_DIR/entr"
    cd - >/dev/null
fi

# ---------------------------------------------------------------------------
# neovim — text editor
# ---------------------------------------------------------------------------
NVIM_ARCH="x86_64"
[[ "$ARCH" == "aarch64" ]] && NVIM_ARCH="aarch64"

echo "[neovim]"
if [[ "$(installed_version nvim)" == "$NEOVIM_VERSION" ]]; then
    echo "  Already at v${NEOVIM_VERSION}, skipping."
else
    echo "  Downloading Neovim v${NEOVIM_VERSION} ..."
    curl -fsSL "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-${NVIM_ARCH}.tar.gz" \
        -o "$TMP_DIR/nvim.tar.gz"
    mkdir -p "$TMP_DIR/nvim"
    tar xzf "$TMP_DIR/nvim.tar.gz" -C "$TMP_DIR/nvim" --strip-components=1
    cp "$TMP_DIR/nvim/bin/nvim" "$BIN_DIR/nvim"
    cp -r "$TMP_DIR/nvim/lib" "$HOME/.local/"
    cp -r "$TMP_DIR/nvim/share" "$HOME/.local/"
    chmod +x "$BIN_DIR/nvim"
fi

# ---------------------------------------------------------------------------
# tree-sitter CLI — required by nvim-treesitter to build parsers
# ---------------------------------------------------------------------------
TS_ARCH="x64"
[[ "$ARCH" == "aarch64" ]] && TS_ARCH="arm64"

echo "[tree-sitter]"
if [[ "$(installed_version tree-sitter)" == "$TREESITTER_VERSION" ]]; then
    echo "  Already at v${TREESITTER_VERSION}, skipping."
else
    echo "  Downloading tree-sitter v${TREESITTER_VERSION} ..."
    curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/download/v${TREESITTER_VERSION}/tree-sitter-linux-${TS_ARCH}.gz" \
        -o "$TMP_DIR/tree-sitter.gz"
    gunzip -f "$TMP_DIR/tree-sitter.gz"
    cp "$TMP_DIR/tree-sitter" "$BIN_DIR/tree-sitter"
    chmod +x "$BIN_DIR/tree-sitter"
fi

# ---------------------------------------------------------------------------
# Node.js — JavaScript runtime (required by pyright-langserver, etc.)
# ---------------------------------------------------------------------------
NODE_ARCH="x64"
[[ "$ARCH" == "aarch64" ]] && NODE_ARCH="arm64"
NODE_DIR="$HOME/.local/lib/node-v${NODE_VERSION}-linux-${NODE_ARCH}"

echo "[node]"
if [[ "$(installed_version node)" == "$NODE_VERSION" ]]; then
    echo "  Already at v${NODE_VERSION}, skipping."
else
    echo "  Downloading Node.js v${NODE_VERSION} ..."
    curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" \
        -o "$TMP_DIR/node.tar.xz"
    mkdir -p "$HOME/.local/lib"
    tar -xJf "$TMP_DIR/node.tar.xz" -C "$HOME/.local/lib"
    ln -sf "$NODE_DIR/bin/node" "$BIN_DIR/node"
    ln -sf "$NODE_DIR/bin/npm"  "$BIN_DIR/npm"
    ln -sf "$NODE_DIR/bin/npx"  "$BIN_DIR/npx"
fi

# ---------------------------------------------------------------------------
# pyright — Python type checker / LSP (requires node)
# ---------------------------------------------------------------------------
echo "[pyright]"
if command -v pyright-langserver &>/dev/null; then
    echo "  Already installed, skipping."
else
    echo "  Installing pyright via npm ..."
    # npm's `#!/usr/bin/env node` shebang re-resolves node via PATH; force the
    # freshly-installed node first so an old system node (e.g. v12) can't run it.
    PATH="$NODE_DIR/bin:$PATH" "$NODE_DIR/bin/npm" install -g --prefix "$NODE_DIR" pyright
    ln -sf "$NODE_DIR/bin/pyright-langserver" "$BIN_DIR/pyright-langserver"
    ln -sf "$NODE_DIR/bin/pyright"             "$BIN_DIR/pyright"
fi

# ---------------------------------------------------------------------------
# grip — GitHub-flavored markdown preview (Python)
# ---------------------------------------------------------------------------
echo "[grip]"
if command -v grip &>/dev/null; then
    echo "  Already installed, skipping."
else
    echo "  Installing grip via pip ..."
    pip install --quiet grip
fi

echo ""
echo "All tools installed to $BIN_DIR"
echo "Make sure $BIN_DIR is in your PATH."
