#!/usr/bin/env bash

# Colors & UI
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    echo -ne "${YELLOW}"
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    echo -e "${NC}"
}

echo -e "${CYAN}[*] Initializing AlphaTunnel Setup...${NC}"
sleep 1

# Detect Termux
if [ -n "$PREFIX" ] && [ -d "/data/data/com.termux" ]; then
    echo -e "${YELLOW}[*] Termux environment detected.${NC}"
    
    echo -ne "${YELLOW}[*] Installing dependencies (proot)...${NC}"
    pkg install proot curl -y > /dev/null 2>&1 &
    spinner $!
    echo -e "${GREEN}[+] Dependencies installed!${NC}"
    
    echo -e "${CYAN}[*] Downloading AlphaTunnel (ARM64)...${NC}"
    curl -L -o $PREFIX/bin/alphatunnel-bin https://github.com/SaadSikder01/alphatunnel-cli/releases/latest/download/alphatunnel-linux-arm64 --progress-bar
    
    chmod +x $PREFIX/bin/alphatunnel-bin
    
    echo -e "${CYAN}[*] Configuring environment (DNS)...${NC}"
    echo -e "#!/data/data/com.termux/files/usr/bin/bash\nproot -b \$PREFIX/etc/resolv.conf:/etc/resolv.conf \$PREFIX/bin/alphatunnel-bin \"\$@\"" > $PREFIX/bin/alphatunnel
    chmod +x $PREFIX/bin/alphatunnel
    
else
    OS="$(uname -s)"
    ARCH="$(uname -m)"
    
    if [ "$OS" = "Darwin" ]; then
        echo -e "${YELLOW}[*] macOS detected.${NC}"
        if [ "$ARCH" = "arm64" ]; then
            BINARY="alphatunnel-darwin-arm64"
        else
            BINARY="alphatunnel-darwin-amd64"
        fi
        INSTALL_DIR="/usr/local/bin"
    else
        echo -e "${YELLOW}[*] Linux detected.${NC}"
        if [ "$ARCH" = "aarch64" ]; then
            BINARY="alphatunnel-linux-arm64"
        else
            BINARY="alphatunnel-linux-amd64"
        fi
        INSTALL_DIR="/usr/local/bin"
    fi
    
    echo -e "${CYAN}[*] Downloading AlphaTunnel ($ARCH)...${NC}"
    curl -L -o alphatunnel https://github.com/SaadSikder01/alphatunnel-cli/releases/latest/download/$BINARY --progress-bar
    chmod +x alphatunnel
    
    echo -e "${CYAN}[*] Moving to $INSTALL_DIR (requires sudo)...${NC}"
    sudo mv alphatunnel $INSTALL_DIR/alphatunnel
    
    if [ "$OS" = "Darwin" ]; then
        xattr -d com.apple.quarantine $INSTALL_DIR/alphatunnel 2>/dev/null
    fi
fi

echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}   AlphaTunnel is ready!${NC}"
echo -e "${GREEN}   Run: alphatunnel release 8000${NC}"
echo -e "${GREEN}=============================================${NC}"
