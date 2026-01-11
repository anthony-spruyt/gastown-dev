#!/usr/bin/env bash
set -uo pipefail

# Devcontainer setup verification tests

PASSED=0
FAILED=0

pass() {
  echo "✓ $1"
  PASSED=$((PASSED + 1))
}

fail() {
  echo "✗ $1"
  FAILED=$((FAILED + 1))
}


echo "Running devcontainer verification tests..."
echo ""

# Docker-in-Docker
if docker run --rm hello-world &>/dev/null; then
  pass "Docker-in-Docker is working"
else
  fail "Docker-in-Docker is not working"
fi

# Safe-chain blocks malicious packages
SAFE_NPM="$HOME/.safe-chain/shims/npm"
if [[ -x "$SAFE_NPM" ]]; then
  TEMP_DIR=$(mktemp -d)
  SAFE_OUTPUT=$(cd "$TEMP_DIR" && "$SAFE_NPM" install safe-chain-test 2>&1 || true)
  rm -rf "$TEMP_DIR"
  if echo "$SAFE_OUTPUT" | grep -qi "safe-chain"; then
    pass "Safe-chain is blocking malicious packages"
  else
    fail "Safe-chain is not blocking (check output: $SAFE_OUTPUT)"
  fi
else
  fail "Safe-chain shims not found at $SAFE_NPM"
fi

# SSH agent forwarding
if [[ -n "${SSH_AUTH_SOCK:-}" ]] && ssh-add -l &>/dev/null 2>&1; then
  pass "SSH agent has keys loaded"
else
  fail "SSH agent not available or no keys loaded"
fi

# Check Go version (1.24+)
if command -v go &>/dev/null; then
  GO_VERSION=$(go version | grep -oP 'go\K[0-9]+\.[0-9]+' | head -1)
  GO_MAJOR=$(echo "$GO_VERSION" | cut -d. -f1)
  GO_MINOR=$(echo "$GO_VERSION" | cut -d. -f2)
  if [[ "$GO_MAJOR" -gt 1 ]] || { [[ "$GO_MAJOR" -eq 1 ]] && [[ "$GO_MINOR" -ge 24 ]]; }; then
    pass "Go version $GO_VERSION (>= 1.24)"
  else
    fail "Go version $GO_VERSION (requires >= 1.24)"
  fi
else
  fail "Go is not installed"
fi

# Check Git version (2.20+)
if command -v git &>/dev/null; then
  GIT_VERSION=$(git --version | grep -oP '[0-9]+\.[0-9]+' | head -1)
  GIT_MAJOR=$(echo "$GIT_VERSION" | cut -d. -f1)
  GIT_MINOR=$(echo "$GIT_VERSION" | cut -d. -f2)
  if [[ "$GIT_MAJOR" -gt 2 ]] || { [[ "$GIT_MAJOR" -eq 2 ]] && [[ "$GIT_MINOR" -ge 20 ]]; }; then
    pass "Git version $GIT_VERSION (>= 2.20)"
  else
    fail "Git version $GIT_VERSION (requires >= 2.20)"
  fi
else
  fail "Git is not installed"
fi

# Check tmux version (3.0+)
if command -v tmux &>/dev/null; then
  TMUX_VERSION=$(tmux -V | grep -oP '[0-9]+\.[0-9]+' | head -1)
  TMUX_MAJOR=$(echo "$TMUX_VERSION" | cut -d. -f1)
  if [[ "$TMUX_MAJOR" -ge 3 ]]; then
    pass "tmux version $TMUX_VERSION (>= 3.0)"
  else
    fail "tmux version $TMUX_VERSION (requires >= 3.0)"
  fi
else
  fail "tmux is not installed"
fi

# Check Gas Town (gt)
if command -v gt &>/dev/null; then
  GT_VERSION=$(gt version 2>&1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
  pass "Gas Town (gt) version $GT_VERSION"
else
  fail "Gas Town (gt) is not installed"
fi

# Check Beads (bd)
if command -v bd &>/dev/null; then
  BD_VERSION=$(bd version 2>&1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
  pass "Beads (bd) version $BD_VERSION"
else
  fail "Beads (bd) is not installed"
fi

echo ""
echo "Results: $PASSED passed, $FAILED failed"

if [[ $FAILED -eq 0 ]]; then
  exit 0
else
  exit 1
fi
