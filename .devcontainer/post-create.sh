#!/bin/bash
set -euo pipefail

sudo apt update

# Make all shell scripts executable (runs from repo root via postCreateCommand)
sudo find . -type f -name '*.sh' -exec chmod u+x {} +

# Change to script directory for package.json access
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Install and setup safe-chain FIRST before any other npm installs
echo "Installing safe-chain..."
npm install -g "@aikidosec/safe-chain@$(node -p "require('./package.json').dependencies['@aikidosec/safe-chain']")"

echo "Setting up safe-chain..."
safe-chain setup        # Shell aliases for interactive terminals
safe-chain setup-ci     # Executable shims for scripts/CI

# Add safe-chain shims to PATH for all subsequent commands
# This ensures pre-commit and other tools use protected pip/npm
export PATH="$HOME/.safe-chain/shims:$PATH"

echo "Installing remaining npm tools (now protected by safe-chain)..."
npm install -g "@anthropic-ai/claude-code@$(node -p "require('./package.json').dependencies['@anthropic-ai/claude-code']")" --safe-chain-skip-minimum-package-age

echo "Installing tmux..."
sudo apt install -y tmux

echo "Installing Gas Town..."
go install github.com/steveyegge/gastown/cmd/gt@main

echo "Installing Beads..."
go install github.com/steveyegge/beads/cmd/bd@main

echo "Adding Go to PATH..."
GO_PATH_LINE='export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin'
if ! grep -qF "$GO_PATH_LINE" ~/.bashrc; then
    echo "$GO_PATH_LINE" >> ~/.bashrc
fi
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"

echo ""
echo "Running setup verification..."
"$SCRIPT_DIR/verify-setup.sh"
