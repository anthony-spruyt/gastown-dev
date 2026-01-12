#!/bin/bash
set -euo pipefail

WORKSPACE="/workspaces/gastown-dev"
TARGET="$WORKSPACE/gt"
MAX_RETRIES=5

cd "$WORKSPACE"

echo "Cleaning up previous installs..."
retries=0
while [ -d "$TARGET" ]; do
    if [ $retries -ge $MAX_RETRIES ]; then
        echo "ERROR: Failed to delete $TARGET after $MAX_RETRIES attempts"
        exit 1
    fi
    echo "Attempting to delete $TARGET (attempt $((retries + 1))/$MAX_RETRIES)..."
    sudo rm -rf "$TARGET"
    sleep 1
    retries=$((retries + 1))
done

echo "Installing Gas Town..."
mkdir -p "$TARGET"
cd "$TARGET"
gt install "$TARGET" -f

echo "Initializing git..."
# gt git-init --github=anthony-spruyt/gastown-hq
gt git-init

echo "Adding rigs..."
# gt rig add claude_config https://github.com/anthony-spruyt/claude-config.git
gt rig add container_images https://github.com/anthony-spruyt/container-images.git
# gt rig add spruyt_labs https://github.com/anthony-spruyt/spruyt-labs.git

echo "Configuring agents..."
gt config agent set claude "claude --model opus --dangerously-skip-permissions"
gt config agent set claude-opus "claude --model opus --dangerously-skip-permissions"
gt config agent set claude-sonnet "claude --model sonnet --dangerously-skip-permissions"
gt config agent set claude-haiku "claude --model haiku --dangerously-skip-permissions"

gt config default-agent claude

echo "Adding crew..."
# gt crew add anthony --rig claude_config
gt crew add anthony --rig container_images
# gt crew add anthony --rig spruyt_labs

git add . && git commit -m 'Initial Gas Town HQ'

echo "Bootstrap complete!"