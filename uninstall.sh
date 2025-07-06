#!/bin/bash

set -e

INSTALL_DIR="$HOME/.local/bin"
SCRIPTS=("snapnow" "snaprestore")
SNAPSHOT_DIR="/snapshots"

echo "Uninstalling Btrfs Snapshot Tools..."

# Confirm uninstall
read -p "Are you sure you want to remove snapnow and snaprestore? [y/N]: " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Cancelled."
    exit 1
fi

# Remove installed scripts
for script in "${SCRIPTS[@]}"; do
    if [[ -f "$INSTALL_DIR/$script" ]]; then
        rm "$INSTALL_DIR/$script"
        echo " Removed $INSTALL_DIR/$script"
    else
        echo "ℹ $script not found in $INSTALL_DIR"
    fi
done

# Offer to remove /snapshots
if [[ -d "$SNAPSHOT_DIR" ]]; then
    read -p "Do you also want to delete the /snapshots folder? [y/N]: " rm_snap
    if [[ "$rm_snap" == "y" || "$rm_snap" == "Y" ]]; then
        sudo rm -rf "$SNAPSHOT_DIR"
        echo " /snapshots folder deleted."
    else
        echo " /snapshots preserved."
    fi
fi

# Try to remove PATH export from shell config
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

if grep -q "# Added by btrfs snapshot tools installer" "$PROFILE"; then
    echo "Cleaning PATH entry from $PROFILE..."
    sed -i '/# Added by btrfs snapshot tools installer/,+1d' "$PROFILE"
    echo "Removed PATH addition."
    echo "To apply, run: source $PROFILE"
else
    echo "No PATH changes found in $PROFILE."
fi

echo "Uninstall complete."
