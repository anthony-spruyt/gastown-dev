#!/bin/bash
set -euo pipefail

echo "Installing Gas Town..."
go install github.com/steveyegge/gastown/cmd/gt@latest
echo "Installing Beads..."
go install github.com/steveyegge/beads/cmd/bd@latest
echo "Fixing upgrade issues..."
gt doctor --fix