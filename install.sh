#!/usr/bin/env bash
# ============================================================
# AlphaTunnel CLI Installer — Linux / macOS / Termux
# Usage: curl -sSL https://YOUR-APP.vercel.app/install.sh | bash
# ============================================================
set -e

# ⚠️ CHANGE THIS: আপনার GitHub ইউজারনেম + রিপো নেম বসান
GITHUB_USER="আপনার-ইউজারনেম"
GITHUB_REPO="alphatunnel-cli"

VERSION="${ALPHATUNNEL_VERSION:-latest}"

# ---------- Detect OS ----------
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
case "$OS" in
    linux*)  OS="linux"  ;;
    darwin*) OS="darwin" ;;
    *)
        echo "✗ Unsupported OS: $OS"
        exit 1
        ;;
esac

# ---------- Detect Termux ----------
IS_TERMUX=0
if [ -n "$PREFIX" ] && [ -d "/data/data/com.termux" ]; then
    echo "→ Termux environment detected"
    IS_TERMUX=1
fi

# ---------- Detect architecture ----------
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64|amd64)   ARCH="amd64" ;;
    aarch64|arm64)  ARCH="arm64" ;;
    armv7l|armv6l)  ARCH="arm"   ;;
    *)
        echo "✗ Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

BINARY="alphatunnel-${OS}-${ARCH}"

# ---------- Build download URL ----------
if [ "$VERSION" = "latest" ]; then
    URL="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases/latest/download/${BINARY}"
else
    URL="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/releases/download/${VERSION}/${BINARY}"
fi

# ---------- Choose install dir ----------
if [ "$IS_TERMUX" -eq 1 ]; then
    INSTALL_DIR="$PREFIX/bin"
else
    INSTALL_DIR="$HOME/.local/bin"
fi
mkdir -p "$INSTALL_DIR"

# ---------- Download ----------
echo "→ Downloading AlphaTunnel CLI (${OS}-${ARCH})..."
TMP_FILE="$(mktemp)"
if command -v curl >/dev/null 2>&1; then
    if ! curl -fsSL "$URL" -o "$TMP_FILE"; then
        echo "✗ Download failed. Check your internet or the version tag."
        rm -f "$TMP_FILE"
        exit 1
    fi
elif command -v wget >/dev/null 2>&1; then
    if ! wget -q "$URL" -O "$TMP_FILE"; then
        echo "✗ Download failed."
        rm -f "$TMP_FILE"
        exit 1
    fi
else
    echo "✗ Neither curl nor wget is available"
    exit 1
fi

mv "$TMP_FILE" "$INSTALL_DIR/alphatunnel"
chmod +x "$INSTALL_DIR/alphatunnel"

# ---------- macOS quarantine fix ----------
if [ "$OS" = "darwin" ]; then
    xattr -d com.apple.quarantine "$INSTALL_DIR/alphatunnel" 2>/dev/null || true
fi

# ---------- Ensure PATH ----------
case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
        SHELL_RC=""
        [ -f "$HOME/.bashrc" ] && SHELL_RC="$HOME/.bashrc"
        [ -f "$HOME/.zshrc" ]  && SHELL_RC="$HOME/.zshrc"

        if [ -n "$SHELL_RC" ]; then
            if ! grep -q "AlphaTunnel CLI" "$SHELL_RC" 2>/dev/null; then
                echo "" >> "$SHELL_RC"
                echo "# AlphaTunnel CLI" >> "$SHELL_RC"
                echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
            fi
            echo "→ Added $INSTALL_DIR to PATH in $SHELL_RC"
        else
            echo "→ Add this to your shell profile:"
            echo "    export PATH=\"$INSTALL_DIR:\$PATH\""
        fi

        export PATH="$INSTALL_DIR:$PATH"
        ;;
esac

# ---------- Verify ----------
if "$INSTALL_DIR/alphatunnel" version >/dev/null 2>&1; then
    INSTALLED_VERSION=$("$INSTALL_DIR/alphatunnel" version)
    echo ""
    echo "✅ Installed: $INSTALLED_VERSION"
    echo "   Location:  $INSTALL_DIR/alphatunnel"
    echo ""
    echo "   Restart your shell or run:"
    echo "     source ${SHELL_RC:-~/.bashrc}"
    echo ""
    echo "   Then start a tunnel with:"
    echo "     alphatunnel release <port>"
else
    echo "✗ Installation failed — binary may be corrupt"
    exit 1
fi
