#!/bin/bash
set -euo pipefail

WORKSPACE="/workspaces/gastown-dev"

echo "Starting dashboard..."
cd "$WORKSPACE/gt" && gt dashboard --port 8080