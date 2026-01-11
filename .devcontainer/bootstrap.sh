#!/bin/bash
set -euo pipefail

cd /workspaces/gastown

# Init git only if needed
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || git init

# Clean up
TARGET="/workspaces/gastown/gt"

while [ -d "$TARGET" ]; do
    echo "Attempting to delete $TARGET..."
    sudo rm -rf "$TARGET"
    sleep 1
done

echo "gt folder deleted."

mkdir -p /workspaces/gastown/gt

cd /workspaces/gastown/gt

# Create gas town instance
gt install /workspaces/gastown/gt -f

# Add claude config rig
gt rig add rig_claude_config https://github.com/anthony-spruyt/claude-config.git

# Configure agents
gt config agent set claude-opus "claude --model opus --dangerously-skip-permissions"
gt config agent set claude-sonnet "claude --model sonnet --dangerously-skip-permissions"
gt config agent set claude-haiku "claude --model haiku --dangerously-skip-permissions"

# Add crew member to claude config rig
gt crew add rig_amos_burton --rig rig_claude_config