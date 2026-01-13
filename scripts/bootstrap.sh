#!/bin/bash
set -euo pipefail

WORKSPACE="/workspaces/gastown-dev"
CONFIG="$WORKSPACE/gt.config.yaml"
TARGET="$WORKSPACE/gt"
MAX_RETRIES=5

cd "$WORKSPACE"

# Verify config exists
if [ ! -f "$CONFIG" ]; then
    echo "ERROR: Config file not found: $CONFIG"
    exit 1
fi

# Check if HQ remote exists
HQ_REMOTE=$(yq -r '.hqRemote // ""' "$CONFIG")
HQ_EXISTS=false
if [ -n "$HQ_REMOTE" ]; then
    echo "Checking if HQ repo exists: $HQ_REMOTE"
    if gh repo view "$HQ_REMOTE" &>/dev/null; then
        HQ_EXISTS=true
        echo "  Found existing HQ repo - will restore from it"
    else
        echo "  HQ repo not found - will create fresh and push to GitHub"
    fi
else
    echo "No hqRemote configured - will create local-only Gas Town"
fi

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

if [ "$HQ_EXISTS" = true ]; then
    # Restore mode: clone existing HQ
    echo "Cloning existing HQ from $HQ_REMOTE..."
    gh repo clone "$HQ_REMOTE" "$TARGET"
    cd "$TARGET"
    echo "Installing Gas Town into cloned HQ..."
    gt install "$TARGET" -f
else
    # Fresh mode: create new HQ
    echo "Installing Gas Town (fresh)..."
    mkdir -p "$TARGET"
    cd "$TARGET"
    gt install "$TARGET" -f

    echo "Initializing git..."
    if [ -n "$HQ_REMOTE" ]; then
        gt git-init --github="$HQ_REMOTE"
    else
        gt git-init
    fi
fi

echo "Adding rigs..."
yq -r '.rigs[] | "\(.name) \(.repo)"' "$CONFIG" | while read -r name repo; do
    echo "  Adding rig: $name"
    gt rig add "$name" "$repo"
done

echo "Configuring agents..."
yq -r '.agents[] | "\(.name) \(.command)"' "$CONFIG" | while read -r name command; do
    echo "  Configuring agent: $name"
    gt config agent set "$name" "$command"
done

DEFAULT_AGENT=$(yq -r '.defaultAgent // ""' "$CONFIG")
if [ -n "$DEFAULT_AGENT" ]; then
    echo "  Setting default agent: $DEFAULT_AGENT"
    gt config default-agent "$DEFAULT_AGENT"
fi

echo "Adding crew..."
yq -r '.crew[] | .name as $name | .rigs[] | "\($name) \(.)"' "$CONFIG" | while read -r name rig; do
    echo "  Adding crew $name to rig: $rig"
    gt crew add "$name" --rig "$rig"
done

git add . && git commit -m 'Initial Gas Town HQ'

echo "Bootstrap complete!"