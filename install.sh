#!/bin/bash

set -e

REPO_URL="https://github.com/the-abra/local-actions.git"
INSTALL_DIR="/usr/local/share/local-actions"
BIN_LINK="/usr/local/bin/laction"

echo "Installing local-actions..."

# Create install directory
sudo mkdir -p "$INSTALL_DIR"

# Clone or update
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "Updating existing installation..."
    cd "$INSTALL_DIR"
    sudo git pull
else
    echo "Cloning repository..."
    sudo git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Ensure executable
sudo chmod +x "$INSTALL_DIR/laction"

# Create symlink
echo "Creating symbolic link at $BIN_LINK..."
sudo ln -sf "$INSTALL_DIR/laction" "$BIN_LINK"

echo "Installation complete. You can now use 'laction'."
