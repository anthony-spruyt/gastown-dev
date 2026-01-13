#!/bin/bash
set -euo pipefail

TARGET="/workspaces/gastown-dev/gt"

export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"

echo "Installing Gas Town..."
go install github.com/steveyegge/gastown/cmd/gt@latest
echo "Installing Beads..."
go install github.com/steveyegge/beads/cmd/bd@latest
echo "Fixing upgrade issues..."

cd "$TARGET"
gt doctor --fix
