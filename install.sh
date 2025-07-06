#!/bin/bash

set -e

INSTALL_DIR="$HOME/.local/bin"
SNAPSHOT_DIR="/snapshots"
SCRIPTS=("snapnow" "snaprestore")

echo "🔧 Installing Btrfs snapshot tools..."

# Create ~/.local/bin if needed
mkdir -p "$INSTALL_DIR"

# Copy and install scripts
for script in "${SCRIPTS[@]}"; do
    if [[ ! -f "$script" ]]; then
        echo "Error: '$script' not found in current directory."
        exit 1
    fi

    chmod +x "$script"
    cp "$script" "$INSTALL_DIR/"
    echo "Installed $script to $INSTALL_DIR"
done

# Create /snapshots directory (requires sudo)
if [[ ! -d "$SNAPSHOT_DIR" ]]; then
    echo "Creating snapshot storage at $SNAPSHOT_DIR (requires sudo)"
    sudo mkdir -p "$SNAPSHOT_DIR"
    sudo chown "$USER":"$USER" "$SNAPSHOT_DIR"
    echo "/snapshots created and owned by $USER"
else
    echo "/snapshots already exists"
fi

# Detect shell profile to update PATH
PROFILE=""
if [[ -n "$ZSH_VERSION" ]]; then
    PROFILE="$HOME/.zshrc"
elif [[ -n "$BASH_VERSION" ]]; then
    PROFILE="$HOME/.bashrc"
elif [[ -f "$HOME/.bash_profile" ]]; then
    PROFILE="$HOME/.bash_profile"
else
    PROFILE="$HOME/.profile"
fi

# Add ~/.local/bin to PATH if missing
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo ""
    echo " Adding '$INSTALL_DIR' to your PATH in $PROFILE"

    echo "" >> "$PROFILE"
    echo "# Added by btrfs snapshot tools installer" >> "$PROFILE"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$PROFILE"

    echo "To apply changes now, run:"
    echo "   source $PROFILE"
else
    echo "'$INSTALL_DIR' is already in your PATH"
fi

echo ""
echo "Installation complete. You can now run:"
echo "   snapnow      → create snapshots"
echo "   snaprestore  → restore snapshots"

